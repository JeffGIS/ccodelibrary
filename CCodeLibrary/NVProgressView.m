//  NVProgressView.m
//  CCodeLibrary

#import "NVProgressView.h"

@interface NVProgressView ()

@property (nonatomic) UIView *progressTrackView;

@end

@implementation NVProgressView

- (id)initWithCenter:(CGPoint)center
               width:(CGFloat)width
          trackColor:(UIColor *)trackColor
       progressColor:(UIColor *)progressColor
{
    self = [super initWithFrame:CGRectMake((center.x - (width / 2.0)),
                                           (center.y - 10.0), width, 20.0)];
    
    if (self)
    {
        self.progressTrackView = [[UIView alloc] initWithFrame:CGRectZero];
        self.progressTrackView.backgroundColor = progressColor;
        [self addSubview:self.progressTrackView];
        
        self.backgroundColor = trackColor;
        self.layer.masksToBounds = YES;
        self.layer.cornerRadius = 10.0;
        self.layer.borderColor = UIColor.darkGrayColor.CGColor;
        self.layer.borderWidth = 2.0;
        self.progress = 0.0;
    }
    
    return self;
}

- (void)setProgress:(CGFloat)progress
{
    _progressTrackView.frame = CGRectMake(0.0, 0.0,
                                          (self.frame.size.width * progress),
                                          self.frame.size.height);
    
    _progress = progress;
}

@end