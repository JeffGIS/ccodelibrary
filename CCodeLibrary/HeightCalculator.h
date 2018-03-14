//  HeightCalculator.h
//  CCodeLibrary

@import UIKit;

@class HeightCalculator;

@protocol HeightCalculatorDelegate <NSObject>

- (void)heightCalculator:(HeightCalculator *)heightCalculator
          returnedHeight:(double)height;

@end

@interface HeightCalculator : UIViewController

+ (instancetype)presentHeightCalculatorInController:(UIViewController *)controller
                                           delegate:(id<HeightCalculatorDelegate>)delegate;

@end
