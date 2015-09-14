//  NVTextDrawing.h
//  CCodeLibrary

#import <UIKit/UIKit.h>
#import "CCodeTypes.h"

@interface NVTextDrawing : NSObject

+ (NSUInteger)getTextContainerPoints:(LPDPOINT)textPoints
                            numLines:(NSInteger *)pnLines
                             totArea:(CGFloat*)totArea
               averageCharacterWidth:(CGFloat*)aveCharWidth
              averageCharacterHeight:(CGFloat*)aveCharHeight
                    attributedString:(NSAttributedString *)attributedString;

@end