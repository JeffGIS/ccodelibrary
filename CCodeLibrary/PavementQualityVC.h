//  PavementQualityVC.h
//  CCodeLibrary

@import UIKit;

@class PavementQualityVC;

@protocol PavementQualityDelegate<NSObject>

- (void)pavementQualityController:(PavementQualityVC *)controller
                 didReturnQuality:(int)quality;

@end

@interface PavementQualityVC : UIViewController

+ (void)presentPavementQualityInController:(UIViewController *)controller
                                  delegate:(id<PavementQualityDelegate>)delegate;

@end
