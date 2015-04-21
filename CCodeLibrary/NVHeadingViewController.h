//  NVHeadingViewController.h
//  CCodeLibrary

#import <UIKit/UIKit.h>

@class NVHeadingViewController;

@protocol NVHeadingViewControllerDelegate <NSObject>

@end

@interface NVHeadingViewController : UIViewController

@property (nonatomic, weak) id <NVHeadingViewControllerDelegate> delegate;

+ (NVHeadingViewController *)showHeadingViewController:(id)delegate;

@end