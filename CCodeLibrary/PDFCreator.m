//  PDFCreator.m
//  CCodeLibrary

#import "PDFCreator.h"
@import CoreText;
#import "CRAPI.h"

#define SS_CELL_HEIGHT 60
#define SS_MARGIN 20
#define SS_FONT_FACTOR 22.0

@implementation PDFPageNV

- (id)init
{
    self = [super init];
    
    if (self)
    {
        _PDFPageImages = NSMutableArray.new;
        _PDFPageTextBlocks = NSMutableArray.new;
        _PDFPagePropertySpreadSheets = NSMutableArray.new;
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
        fromPageArray:(NSArray <PDFPageNV *> *)pageArray
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
        PDFPageNV *page = nil;
        PDFPageImage *pageImage = nil;
        PDFPageTextBlock *pageText = nil;
        PDFPagePropertySpreadSheet *spreadSheet = nil;
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
            
            for (int j = 0; j < page.PDFPagePropertySpreadSheets.count; j++)
            {
                spreadSheet = page.PDFPagePropertySpreadSheets[j];
                [PDFCreator setCurrentSpreadsheet:spreadSheet];
                CGPoint origin = CGPointMake(spreadSheet.upperLeftX, spreadSheet.upperLeftY);
                
                [PDFCreator writePDFtoFile:nil
                             fromTextArray:CRAPI.sharedInstance.arrayOutput
                                   context:PDFContext
                                createPage:NO
                                    origin:origin];
            }
            
            CGPDFContextEndPage(PDFContext);
            CFRelease(PDFData);
        }
        
        CFRelease(PDFDict);
        CGContextRelease(PDFContext);
        
        returnCode = PDFCreate_OK;
    }
    
    return returnCode;
}

+ (CGSize)sizeForSpreadSheet:(PDFPagePropertySpreadSheet *)spreadSheet
                      margin:(CGFloat)margin
{
    [PDFCreator setCurrentSpreadsheet:spreadSheet];
    return [PDFCreator sizeForTextArray:CRAPI.sharedInstance.arrayOutput];
}

+ (CGSize)sizeForTextArray:(NSArray <NSArray *> *)textArray
{
    CGFloat pageWidth = 0.0;
    CGFloat cellHeight = SS_CELL_HEIGHT;
    CGFloat margin = SS_MARGIN;
    NSInteger length = 0;
    
    for (NSArray *innerArray in textArray)
    {
        length = 0;
        
        for (NSString *text in innerArray)
            length = MAX(text.length, length);
        
        float textWidth = ((length * SS_FONT_FACTOR) + margin);
        pageWidth += textWidth;
    }
    
    return CGSizeMake(pageWidth, (margin * 2.0) + (cellHeight * textArray[0].count));
}

+ (void)setCurrentSpreadsheet:(PDFPagePropertySpreadSheet *)spreadSheet
{
    if ([CRAPI.sharedInstance.spreadsheetDelegate respondsToSelector:@selector(setCurrentFieldList:)])
        [CRAPI.sharedInstance.spreadsheetDelegate setCurrentFieldList:spreadSheet.fieldList];
    
    if ([CRAPI.sharedInstance.spreadsheetDelegate respondsToSelector:@selector(setCurrentPropList:)])
        [CRAPI.sharedInstance.spreadsheetDelegate setCurrentPropList:spreadSheet.propertyList];
}

+ (int)writePDFtoFile:(NSString *)filePath
        fromTextArray:(NSArray <NSArray *> *)textArray
              context:(CGContextRef)context
           createPage:(BOOL)createPage
               origin:(CGPoint)origin
{
    int returnCode = PDFCreate_FAIL;
    CFMutableDictionaryRef PDFDict = NULL;
    CGContextRef PDFContext = NULL;
    
    if ((filePath && filePath.length) || context)
    {
        if (context)
            PDFContext = context;
        
        else
        {
            CFStringRef PDFPath = CFStringCreateWithCString(NULL, filePath.UTF8String, kCFStringEncodingUTF8);
            CFURLRef PDFUrl = CFURLCreateWithFileSystemPath(NULL, PDFPath, kCFURLPOSIXPathStyle, 0);
            CFRelease(PDFPath);
            
            CFMutableDictionaryRef PDFDict = CFDictionaryCreateMutable(NULL, 0, &kCFTypeDictionaryKeyCallBacks,
                                                                       &kCFTypeDictionaryValueCallBacks);
            
            CFDictionarySetValue(PDFDict, kCGPDFContextTitle, CFSTR("PDF Extract File"));
            CFDictionarySetValue(PDFDict, kCGPDFContextCreator, CFSTR("GSSi"));
            
            PDFContext = CGPDFContextCreateWithURL(PDFUrl, NULL, PDFDict);
            CFRelease(PDFDict);
            CFRelease(PDFUrl);
        }

        CGContextSetStrokeColorWithColor(PDFContext, UIColor.blackColor.CGColor);
        
        PDFDict = CFDictionaryCreateMutable(NULL, 0, &kCFTypeDictionaryKeyCallBacks,
                                            &kCFTypeDictionaryValueCallBacks);
        
        CFDataRef PDFData = NULL;
        
        CTFontRef fontRef = CTFontCreateWithName((CFStringRef)@"CourierNewPS-BoldMT",
                                                 36.0, NULL);
        
        NSMutableParagraphStyle *style = NSParagraphStyle.defaultParagraphStyle.mutableCopy;
        style.alignment = NSTextAlignmentCenter;
        
        NSDictionary *textAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                        (__bridge id)fontRef, kCTFontAttributeName,
                                        style, kCTParagraphStyleAttributeName,
                                        UIColor.blackColor.CGColor, kCTForegroundColorAttributeName, nil];
        
        NSAttributedString *attrbText = nil;
        CGRect cellRect = CGRectZero;
        CGFloat margin = SS_MARGIN;
        CGFloat xPos = margin;
        CGFloat yPos = margin;
        CGFloat cellHeight = SS_CELL_HEIGHT;
        CGFloat cellWidth = 0.0;
        NSArray *innerArray = nil;
        
        CGSize pageSize = [PDFCreator sizeForTextArray:textArray];
        
        if (createPage)
        {
            CGRect pageRect = CGRectMake(0.0, 0.0, pageSize.height, pageSize.width);
            PDFData = CFDataCreate(NULL, (const UInt8 *)&pageRect, sizeof(CGRect));
            CFDictionarySetValue(PDFDict, kCGPDFContextMediaBox, PDFData);
            CGPDFContextBeginPage(PDFContext, PDFDict);
        }
        
        NSInteger length = 0;
        float textWidth = 0.0;
        
        for (int i = 0; i < textArray.count; i++)
        {
            length = 0;
            
            for (NSString *text in innerArray)
                length = MAX(text.length, length);
            
            textWidth = ((length * SS_FONT_FACTOR) + margin);
            innerArray = textArray[i];
            cellWidth = length;
            
            for (NSString *text in innerArray)
            {
                attrbText = [[NSAttributedString alloc] initWithString:text
                                                            attributes:textAttributes];
                
                cellRect = CGRectMake((xPos + origin.x), (pageSize.height - cellHeight - yPos - origin.y),
                                      cellWidth, cellHeight);
                
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
        CFRelease(PDFDict);
        
        if (!context)
            CGContextRelease(PDFContext);
        
        returnCode = PDFCreate_OK;
    }
    
    return returnCode;
}

@end
