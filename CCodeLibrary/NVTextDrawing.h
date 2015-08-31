//  NVTextDrawing.h
//  CCodeLibrary

#import <UIKit/UIKit.h>
#import "CCodeTypes.h"

@interface NVTextDrawing : NSObject

+ (void)getTextContainerPoints:(LPDPOINT)textPoints
              attributedString:(NSAttributedString *)attributedString;

@end