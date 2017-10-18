//  PDFCreator.m
//  CCodeLibrary

#import "PDFCreator.h"

@implementation PDFPage
- (id)init
{
    self = [super init];
    self.PDFPageImages = NSMutableArray.new;
    self.PDFPageTextBlocks = NSMutableArray.new;
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
    int returnCode = PDFCreate_OK;
    
    return  returnCode;
}

@end
