//  NVTextDrawing.h
//  CCodeLibrary

#import <UIKit/UIKit.h>
#import "CCodeTypes.h"

@interface NVTextDrawing : NSObject

+ (void) drawText:(NSString*)text
    inRotatedRect:(CGContextRef)context
         rectMidX:(CGFloat)mpX
         rectMidY:(CGFloat)mpY
            width:(CGFloat)textWidth
           height:(CGFloat)textHeight
         rotation:(CGFloat)rotateRadians
         fontSize:(CGFloat)fontSize
        textColor:(UIColor*)textColor;

+ (NSUInteger)getTextContainerPoints:(LPDPOINT)textPoints
                            numLines:(NSInteger *)pnLines
                             totArea:(CGFloat*)totArea
               averageCharacterWidth:(CGFloat*)aveCharWidth
              averageCharacterHeight:(CGFloat*)aveCharHeight
                    attributedString:(NSAttributedString *)attributedString;

@end