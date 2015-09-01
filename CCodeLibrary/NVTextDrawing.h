//  NVTextDrawing.h
//  CCodeLibrary

#import <UIKit/UIKit.h>
#import "CCodeTypes.h"

@interface NVTextDrawing : NSObject

+ (NSUInteger)getTextContainerPoints:(LPDPOINT)textPoints
                    attributedString:(NSAttributedString *)attributedString;

@end