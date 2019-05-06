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

@interface PDFPageNV : NSObject

@property int pageWidth, pageHeight;
@property (nonatomic) NSMutableArray <PDFPageImage *> *PDFPageImages;
@property (nonatomic) NSMutableArray <PDFPageTextBlock *> *PDFPageTextBlocks;
@property (nonatomic) NSMutableArray <PDFPagePropertySpreadSheet *> *PDFPagePropertySpreadSheets;

@end

@interface PDFCreator : NSObject

+ (int)writePDFtoFile:(NSString *)filePath
        fromPageArray:(NSArray <PDFPageNV *> *)pageArray;

+ (int)writePDFtoFile:(NSString *)filePath
        fromTextArray:(NSArray <NSArray *> *)textArray
              context:(CGContextRef)context
           createPage:(BOOL)createPage
               origin:(CGPoint)origin;

@end
