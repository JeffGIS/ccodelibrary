//  SymbolDictionary.h
//  GMMobile

@import Foundation;
#import "DisplayCharacteristics.h"
#import "DPoint.h"

@interface SymbolDictionary : NSObject

+ (void)drawPointWithSymbol:(CGContextRef)context
                         at:(LPDPOINT)pt
                usingSymbol:(PointSymbols)sym
                       Size:(CGFloat)size
                  fillColor:(CGColorRef)fcolor
                  lineColor:(CGColorRef)lcolor
                  lineWidth:(CGFloat)lwidth;

UIImage *imageFromSymbol(PointSymbols sym, CGFloat size, UIColor *symColor);
+ (UIColor *)polygonSymbolFillColor:(PolygonSymbols)symbol;

+ (UIColor *)polylineStrokeColor:(PolylineSymbols)symbol
                       lineWidth:(CGFloat *)lineWidth;

+ (UIColor *)polygonSymbolBorderColor:(PolygonSymbols)symbol;
+ (int)polygonSymbolBorderWidth:(PolygonSymbols)symbol;
+ (NSArray <DPoint *> *)symbolDefForType:(PointSymbols)type;

@end
