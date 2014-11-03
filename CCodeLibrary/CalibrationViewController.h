//  CalibrationViewController.h
//  CCodeLibrary

#import "CCodeLibrary.h"
#import <CoreMotion/CoreMotion.h>

@interface CalibrationViewController : UIViewController

@property (nonatomic, strong) UIButton *returnButton;
@property (nonatomic, strong) UIButton *startCancelButton;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIProgressView *progressView;
@property (nonatomic) int calibrationOption;
@property (nonatomic) CGFloat xRange;
@property (nonatomic) CGFloat yRange;
@property (nonatomic) CGFloat maxX;
@property (nonatomic) CGFloat minX;
@property (nonatomic) CGFloat maxY;
@property (nonatomic) CGFloat minY;
@property (nonatomic) CGFloat sumX;
@property (nonatomic) CGFloat sumY;
@property (nonatomic) int counter;
@property (nonatomic) BOOL startCancelState;

@end