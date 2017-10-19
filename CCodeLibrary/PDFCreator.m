//  PDFCreator.m
//  CCodeLibrary

#import "PDFCreator.h"
@import CoreText;

@implementation PDFPage

- (id)init
{
    self = [super init];
    
    if (self)
    {
        _PDFPageImages = NSMutableArray.new;
        _PDFPageTextBlocks = NSMutableArray.new;
    }
    
    return self;
}

@end

@implementation PDFPageImage
@end

@implementation PDFPageTextBlock
@end

@implementation PDFCreator

+ (int)writePDFtoFile:(NSString *)filePath
        fromPageArray:(NSArray <PDFPage *> *)pageArray
{
    int returnCode = PDFCreate_FAIL;
    
    if (filePath && filePath.length)
    {
        CFStringRef PDFPath = CFStringCreateWithCString(NULL, filePath.UTF8String, kCFStringEncodingUTF8);
        CFURLRef PDFUrl = CFURLCreateWithFileSystemPath(NULL, PDFPath, kCFURLPOSIXPathStyle, 0);
        CFRelease(PDFPath);
        
        CFMutableDictionaryRef PDFDict = CFDictionaryCreateMutable(NULL, 0, &kCFTypeDictionaryKeyCallBacks,
                                                                   &kCFTypeDictionaryValueCallBacks);
        
        CFDictionarySetValue(PDFDict, kCGPDFContextTitle, CFSTR("Sample PDF File"));
        CFDictionarySetValue(PDFDict, kCGPDFContextCreator, CFSTR("GSSi"));
        
        CGContextRef PDFContext = CGPDFContextCreateWithURL (PDFUrl, NULL, PDFDict);
        CFRelease(PDFDict);
        CFRelease(PDFUrl);
        
        PDFDict = CFDictionaryCreateMutable(NULL, 0, &kCFTypeDictionaryKeyCallBacks,
                                            &kCFTypeDictionaryValueCallBacks);
        
        CGRect pageRect = CGRectZero, itemRect = CGRectZero;
        CFDataRef PDFData = NULL;
        PDFPage *page = nil;
        PDFPageImage *pageImage = nil;
        PDFPageTextBlock *pageText = nil;
        UIImage *image = nil;
        
        for (int i = 0; i < pageArray.count; i++)
        {
            page = pageArray[i];
            pageRect = CGRectMake(0.0, 0.0, page.pageWidth, page.pageHeight);
            PDFData = CFDataCreate(NULL, (const UInt8 *)&pageRect, sizeof(CGRect));
            CFDictionarySetValue(PDFDict, kCGPDFContextMediaBox, PDFData);
            CGPDFContextBeginPage(PDFContext, PDFDict);
            
            for (int j = 0; j < page.PDFPageImages.count; j++)
            {
                pageImage = page.PDFPageImages[j];
                itemRect = pageImage.imageLocation;
                itemRect.origin.y = (page.pageHeight - itemRect.size.height - itemRect.origin.y);
                image = [UIImage imageWithContentsOfFile:pageImage.imageFile];
                CGContextDrawImage(PDFContext, itemRect, image.CGImage);
            }
            
            for (int j = 0; j < page.PDFPageTextBlocks.count; j++)
            {
                pageText = page.PDFPageTextBlocks[j];
                itemRect = pageText.textLocation;
                itemRect.origin.y = (page.pageHeight - itemRect.size.height - itemRect.origin.y);
                
                CTFontRef fontRef = (__bridge CTFontRef)pageText.font;
                CGColorRef textColor = pageText.textColor.CGColor;
                
                NSMutableParagraphStyle *style = NSParagraphStyle.defaultParagraphStyle.mutableCopy;
                style.alignment = NSTextAlignmentCenter;
                
                NSDictionary *textAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                                (__bridge id)fontRef, kCTFontAttributeName,
                                                style, kCTParagraphStyleAttributeName,
                                                textColor, kCTForegroundColorAttributeName, nil];
                
                NSAttributedString *text = [[NSAttributedString alloc] initWithString:pageText.text
                                                                           attributes:textAttributes];
                
                CGPathRef path = CGPathCreateWithRect(itemRect, NULL);
                CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)text);
                CTFrameRef frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, text.length), path, NULL);
                
                CTFrameDraw(frame, PDFContext);
                
                CFRelease(path);
                CFRelease(framesetter);
                CFRelease(frame);
                CFRelease(fontRef);
            }
            
            CGPDFContextEndPage(PDFContext);
            CFRelease(PDFData);
        }
        
        CGContextRelease(PDFContext);
        CFRelease(PDFDict);
        
        returnCode = PDFCreate_OK;
    }
    
    return returnCode;
}

@end
