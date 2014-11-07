//  SlopeViewController.h
//  CCodeLibrary

#import "CCodeLibrary.h"
#import <CoreMotion/CoreMotion.h>

@interface SlopeViewController : UIViewController

@property (nonatomic, strong) UIButton *unableButton;
@property (nonatomic, strong) UIButton *startCancelButton;
@property (nonatomic, strong) UIImageView *arrowView;
@property (nonatomic, strong) UIProgressView *progressView;
@property (nonatomic, strong) UILabel *frontSlopeLabel;
@property (nonatomic, strong) UILabel *sideSlopeLabel;
@property (nonatomic, strong) UILabel *maxSlopeLabel;
@property (nonatomic, strong) UILabel *promptLabel;
@property (nonatomic) BOOL startCancelState;
@property (nonatomic) BOOL hasRun;
@property (nonatomic) CGFloat xRange;
@property (nonatomic) CGFloat yRange;
@property (nonatomic) CGFloat maxX;
@property (nonatomic) CGFloat minX;
@property (nonatomic) CGFloat maxY;
@property (nonatomic) CGFloat minY;
@property (nonatomic) CGFloat sumX;
@property (nonatomic) CGFloat sumY;
@property (nonatomic) CGFloat sumZ;
@property (nonatomic) CGFloat x1;
@property (nonatomic) CGFloat y1;
@property (nonatomic) CGFloat z;
@property (nonatomic) CGFloat x2;
@property (nonatomic) CGFloat y2;
@property (nonatomic) CGFloat frontSlope;
@property (nonatomic) CGFloat sideSlope;
@property (nonatomic) CGFloat maxSlope;
@property (nonatomic) int counter;
@property (nonatomic) int calibrationOption;

@end