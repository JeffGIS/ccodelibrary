//  CalibrationViewController.h
//  CCodeLibrary

#import "CCodeLibrary.h"
#import <CoreMotion/CoreMotion.h>

@interface CalibrationViewController : UIViewController

@property (nonatomic, strong) UIButton *returnButton;
@property (nonatomic, strong) UIButton *startCancelButton;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *progressLabel;
@property (nonatomic, strong) UILabel *resultsLabel;
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
@property (nonatomic) CGFloat sumZ;
@property (nonatomic) CGFloat x1;
@property (nonatomic) CGFloat y1;
@property (nonatomic) CGFloat x2;
@property (nonatomic) CGFloat y2;
@property (nonatomic) CGFloat xAdj;
@property (nonatomic) CGFloat yAdj;
@property (nonatomic) int counter;
@property (nonatomic) BOOL startCancelState;
@property (nonatomic) BOOL hasRun;

@end