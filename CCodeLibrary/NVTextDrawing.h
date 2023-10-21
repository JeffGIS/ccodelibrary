//  NVTextDrawing.h
//  CCodeLibrary

#import <UIKit/UIKit.h>
#import "CCodeLibrary.h"

@interface NVTextDrawing : NSObject

@property NSInteger processingID;

+ (BOOL)drawText:(NSString *)text
       inContext:(CGContextRef)context
   withinPolygon:(LPDPOINT)pPoints
   withNumPoints:(NSInteger)numPoints
     andNumLoops:(NSInteger)numLoops
         loopLen:(int*)polyPartLen
    withinBounds:(LPMNMXCORD)pBounds
        fontSize:(CGFloat)fontSize
     minFontSize:(CGFloat)minFontSize
       textColor:(CGColorRef)textColor
     shadowColor:(CGColorRef)shadowColor
    processingID:(NSInteger)processingID;

+ (BOOL)drawText:(NSString *)text
   inRotatedRect:(CGContextRef)context
        rectMidX:(CGFloat)mpX
        rectMidY:(CGFloat)mpY
           width:(CGFloat)textWidth
          height:(CGFloat)textHeight
        rotation:(CGFloat)rotateRadians
        fontSize:(CGFloat)fontSize
       textColor:(CGColorRef)textColor
     shadowColor:(CGColorRef)shadowColor;


+ (NSUInteger)getTextContainerPoints:(LPDPOINT)textPoints
                            numLines:(NSInteger *)pnLines
                             totArea:(CGFloat *)totArea
               averageCharacterWidth:(CGFloat *)aveCharWidth
              averageCharacterHeight:(CGFloat *)aveCharHeight
                    attributedString:(NSAttributedString *)attributedString;

+ (BOOL)getRotation:(CGFloat *)rotation
    ofLongestStraightLine:(int)nPoints
             points:(DPOINT *)pPoints
           numLoops:(int)numLoops
            loopLen:(int*)polyPartLen
          maxOffset:(CGFloat)offset
          minLength:(CGFloat)minLength;

+ (void)drawTextShadowForRect:(CGRect)rect
                    attString:(NSAttributedString *)attString
                      context:(CGContextRef)context;

@end
