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
@property (nonatomic) UIFont *font;
@property (nonatomic) UIColor *textColor;
@property CGRect textLocation;

@end

@interface PDFPagePropertySpreadSheet : NSObject

@property (nonatomic, copy) NSString *propertyList;
@property (nonatomic, copy) NSString *fieldList;
@property int upperLeftX, upperLeftY;
@end

@interface PDFPage : NSObject

@property int pageWidth, pageHeight;
@property NSMutableArray <PDFPageImage *> *PDFPageImages;
@property NSMutableArray <PDFPageTextBlock *> *PDFPageTextBlocks;
@property NSMutableArray <PDFPageTextBlock *> *PDFPagePropertySpreadSheets;

@end

@interface PDFCreator : NSObject

+ (int)writePDFtoFile:(NSString *)filePath
        fromPageArray:(NSArray <PDFPage *> *)pageArray;

+ (int)writePDFtoFile:(NSString *)filePath
        fromTextArray:(NSArray <NSArray *> *)textArray
              context:(CGContextRef)context;

@end
