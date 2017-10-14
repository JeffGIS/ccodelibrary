//  PDFCreator.h
//  CCodeLibrary

@import Foundation;

#define PDFCreate_OK    0
#define PDFCreate_FAIL  1

@interface PDFPageImage : NSObject

@property (nonatomic, copy) NSString *imageFile;
@property CGRect imageLocation;

@end

@interface PDFPageTextBlock : NSObject

@property (nonatomic, copy) NSString *text;
@property (nonatomic) NSFont *font;
@property CGRect textLocation;

@end

@interface PDFPage : NSObject

@property int pageWidth, pageHeight;
@property (nonatomic, copy) NSArray <PDFPageImage *> *PDFPageImages;
@property (nonatomic, copy) NSArray <PDFPageTextBlock *> *PDFPageTextBlocks;

@end

@interface PDFCreator : NSObject

+ (int)writePDFtoFile:(NSString *)filePath
        fromPageArray:(NSArray <PDFPage *> *)pageArray;

@end
