//  NVPageIndicator.h
//  CCodeLibrary

@import UIKit;

@class NVPageIndicator;

@protocol NVPageIndicatorDelegate<NSObject>

- (void)pageIndicator:(NVPageIndicator *)pageIndicator
     wasTappedAtIndex:(int)index;

@end

@interface NVPageIndicator : UIView

@property (nonatomic) int selectedIndex;
@property (nonatomic) UIColor *tintColor, *selectedColor;

+ (instancetype)showPageIndicatorInView:(UIView *)view
                            leadingView:(UIView *)leadingView
                           trailingView:(UIView *)trailingView
                                topView:(UIView *)topView
                             bottomView:(UIView *)bottomView
                                numDots:(int)numDots
                               delegate:(id<NVPageIndicatorDelegate>)delegate;

@end
