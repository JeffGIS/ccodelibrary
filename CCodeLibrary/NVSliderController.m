//  NVSliderController.m
//  CCodeLibrary

#import "NVSliderController.h"

@implementation NVSliderController

- (id)initWithCenter:(CGPoint)center
               width:(CGFloat)width
          startValue:(CGFloat)startValue
            minValue:(CGFloat)minValue
            maxValue:(CGFloat)maxValue
            delegate:(id)delegate
{
    self = [super initWithFrame:CGRectMake((center.x - (width / 2.0)),
                                           (center.y - 10.0), width, 20.0)];
    
    if (self)
    {
        self.delegate = delegate;
    }
    
    return self;
}

@end