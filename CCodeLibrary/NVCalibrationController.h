//  NVCalibrationController.h
//  CCodeLibrary

@import UIKit;

@class NVCalibrationController;

@protocol NVCalibrationControllerDelegate <NSObject>

- (void)calibrationControllerNeedsRefresh:(NVCalibrationController *)controller;

@end

@interface NVCalibrationController : UIViewController

@property (nonatomic, weak) id <NVCalibrationControllerDelegate> delegate;

@end