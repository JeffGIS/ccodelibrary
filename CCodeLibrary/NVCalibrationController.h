//  NVCalibrationController.h
//  CCodeLibrary

#import <UIKit/UIKit.h>
#import "GSSiSlopeViewController.h"
#import "NVSliderController.h"

@interface NVCalibrationController : UIViewController <GSSiSlopeViewControllerDelegate,UITableViewDataSource,UITableViewDelegate,NVSliderControllerDelegate>

@end