//  NVRampTypePageView.h
//  CCodeLibrary

@import UIKit;

@interface NVRampTypePageView : UIViewController

+ (instancetype)pageViewWithRampTypes:(NSArray *)rampTypes
                        startingIndex:(NSUInteger)startingIndex;

@end