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
        
        CFDictionarySetValue(PDFDict, kCGPDFContextTitle, CFSTR("PDF Extract File"));
        CFDictionarySetValue(PDFDict, kCGPDFContextCreator, CFSTR("GSSi"));
        
        CGContextRef PDFContext = CGPDFContextCreateWithURL(PDFUrl, NULL, PDFDict);
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

+ (int)writePDFtoFile:(NSString *)filePath
        fromTextArray:(NSArray <NSArray *> *)textArray
{
    int returnCode = PDFCreate_FAIL;
    
    if (filePath && filePath.length)
    {
        CFStringRef PDFPath = CFStringCreateWithCString(NULL, filePath.UTF8String, kCFStringEncodingUTF8);
        CFURLRef PDFUrl = CFURLCreateWithFileSystemPath(NULL, PDFPath, kCFURLPOSIXPathStyle, 0);
        CFRelease(PDFPath);
        
        CFMutableDictionaryRef PDFDict = CFDictionaryCreateMutable(NULL, 0, &kCFTypeDictionaryKeyCallBacks,
                                                                   &kCFTypeDictionaryValueCallBacks);
        
        CFDictionarySetValue(PDFDict, kCGPDFContextTitle, CFSTR("PDF Extract File"));
        CFDictionarySetValue(PDFDict, kCGPDFContextCreator, CFSTR("GSSi"));
        
        CGContextRef PDFContext = CGPDFContextCreateWithURL(PDFUrl, NULL, PDFDict);
        CGContextSetStrokeColorWithColor(PDFContext, UIColor.blackColor.CGColor);
        CFRelease(PDFDict);
        CFRelease(PDFUrl);
        
        PDFDict = CFDictionaryCreateMutable(NULL, 0, &kCFTypeDictionaryKeyCallBacks,
                                            &kCFTypeDictionaryValueCallBacks);
        
        CFDataRef PDFData = NULL;
        
        CTFontRef fontRef = CTFontCreateWithName((CFStringRef)@"AppleSDGothicNeo-Bold",
                                                 32.0, NULL);
        
        NSMutableParagraphStyle *style = NSParagraphStyle.defaultParagraphStyle.mutableCopy;
        style.alignment = NSTextAlignmentCenter;
        
        NSDictionary *textAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                        (__bridge id)fontRef, kCTFontAttributeName,
                                        style, kCTParagraphStyleAttributeName,
                                        UIColor.blackColor.CGColor, kCTForegroundColorAttributeName, nil];
        
        NSAttributedString *attrbText = nil;
        CGRect cellRect = CGRectZero;
        CGFloat margin = 20.0;
        CGFloat xPos = margin;
        CGFloat yPos = margin;
        CGFloat cellWidth = 360.0;
        CGFloat cellHeight = 60.0;
        
        CGRect pageRect = CGRectMake(0.0, 0.0, ((margin * 2.0) + (cellWidth * textArray.count)),
                                     ((margin * 2.0) + (cellHeight * textArray[0].count)));
        
        PDFData = CFDataCreate(NULL, (const UInt8 *)&pageRect, sizeof(CGRect));
        CFDictionarySetValue(PDFDict, kCGPDFContextMediaBox, PDFData);
        CGPDFContextBeginPage(PDFContext, PDFDict);
        
        for (NSArray *innerArray in textArray)
        {
            for (NSString *text in innerArray)
            {
                attrbText = [[NSAttributedString alloc] initWithString:text
                                                            attributes:textAttributes];
                
                cellRect = CGRectMake(xPos, (pageRect.size.height - cellHeight - yPos), cellWidth, cellHeight);
                CGContextAddRect(PDFContext, cellRect);
                CGContextStrokePath(PDFContext);
                
                cellRect = CGRectMake(cellRect.origin.x, (cellRect.origin.y - 6.0),
                                      cellRect.size.width, cellRect.size.height - 6.0);
                
                CGPathRef path = CGPathCreateWithRect(cellRect, NULL);
                CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)attrbText);
                CTFrameRef frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, text.length), path, NULL);
                
                CTFrameDraw(frame, PDFContext);
                
                CFRelease(path);
                CFRelease(framesetter);
                CFRelease(frame);
                
                yPos += cellHeight;
            }
            
            yPos = margin;
            xPos += cellWidth;
        }
        
        CGPDFContextEndPage(PDFContext);
        CFRelease(PDFData);
        CGContextRelease(PDFContext);
        CFRelease(PDFDict);
        
        returnCode = PDFCreate_OK;
    }
    
    return returnCode;
}

@end
