//  NVCalibrationController.h
//  CCodeLibrary

#import <UIKit/UIKit.h>
#import "GSSiSlopeViewController.h"
#import "NVSliderController.h"
#import "NVLargeAlertView.h"

@interface NVCalibrationController : UIViewController <GSSiSlopeViewControllerDelegate,UITableViewDataSource,UITableViewDelegate,NVSliderControllerDelegate,NVLargeAlertViewDelegate>

@end