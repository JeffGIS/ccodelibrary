//  PDFCreator.m
//  CCodeLibrary

#import "PDFCreator.h"

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
        
        CGRect pageRect = CGRectZero;
        CFDataRef PDFData = NULL;
        
        for (int i = 0; i < pageArray.count; i++)
        {
            pageRect = CGRectMake(0.0, 0.0, pageArray[i].pageWidth, pageArray[i].pageHeight);
            PDFData = CFDataCreate(NULL, (const UInt8 *)&pageRect, sizeof(CGRect));
            CFDictionarySetValue(PDFDict, kCGPDFContextMediaBox, PDFData);
            CGPDFContextBeginPage (PDFContext, PDFDict);
            
            //draw page here
            
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
