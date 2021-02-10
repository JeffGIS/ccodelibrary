//  NVMarkerInfoButton.m
//  CCodeLibrary

#import "NVMarkerInfoButton.h"

@interface NVMarkerInfoButton ()

@property (nonatomic, weak) id <NVMarkerInfoButtonDelegate> delegate;
@property (nonatomic, copy) NSString *title;
@property (nonatomic) UILabel *label;

@end

@implementation NVMarkerInfoButton

+ (instancetype)markerWithPosition:(CLLocationCoordinate2D)position
                             title:(NSString *)title
                              type:(NVMarkerInfoButtonType)type
                              view:(UIView *)view
                          delegate:(id)delegate
{
    if (!delegate || !view)
    {
        NSLog(@"NVMarkerInfoButton ERROR:Cannot set delegate or view to nil");
        return nil;
    }
    
    if (![delegate respondsToSelector:@selector(pointForCoordinate:)] ||
        ![delegate respondsToSelector:@selector(statusBarHeight:)])
    {
        NSLog(@"NVMarkerInfoButton ERROR:Delegate must respond to all selectors in protocol");
        return nil;
    }
    
    NVMarkerInfoButton *nvmib = NVMarkerInfoButton.new;
    nvmib.backgroundColor = UIColor.clearColor;
    nvmib.delegate = delegate;
    nvmib.position = position;
    nvmib.title = title;
    nvmib.type = type;
    
    UIImage *image = nil;
    
    switch (nvmib.type)
    {
        case NVMarkerInfoButtonTypePropList:
            image = [UIImage imageWithContentsOfFile:[NSBundle.mainBundle pathForResource:@"greenInfoMarker"
                                                                                   ofType:@"png"]];
            break;
            
        case NVMarkerInfoButtonTypeDestinationsGroup:
            image = [UIImage imageWithContentsOfFile:[NSBundle.mainBundle pathForResource:@"orangeInfoMarker"
                                                                                   ofType:@"png"]];
            break;
            
        case NVMarkerInfoButtonTypeDestinationsIndividual:
        case NVMarkerInfoButtonTypeDefault:
            image = [UIImage imageWithContentsOfFile:[NSBundle.mainBundle pathForResource:@"blueInfoMarker"
                                                                                   ofType:@"png"]];
            break;
    }
    
    CGSize size = CGSizeMake((image.size.width / 2.0), (image.size.height / 2.0));
    nvmib.frame = CGRectMake(0.0, 0.0, size.width, size.height);
    CGPoint target = [nvmib.delegate pointForCoordinate:nvmib.position];
    CGFloat statusBarHeight = [nvmib.delegate statusBarHeight:UIApplication.sharedApplication.statusBarOrientation];
    nvmib.center = CGPointMake(target.x, ((target.y + statusBarHeight) - (nvmib.frame.size.height / 2.0)));
    
    [view addSubview:nvmib];
    [nvmib setImage:image forState:UIControlStateNormal];
    [nvmib addTarget:nvmib action:@selector(markerInfoButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    nvmib.label = UILabel.new;
    nvmib.label.translatesAutoresizingMaskIntoConstraints = NO;
    nvmib.label.font = [UIFont systemFontOfSize:16.0];
    nvmib.label.adjustsFontSizeToFitWidth = YES;
    nvmib.label.textAlignment = NSTextAlignmentCenter;
    nvmib.label.numberOfLines = 0;
    nvmib.label.text = nvmib.title;
    nvmib.label.textColor = UIColor.blackColor;
    [nvmib addSubview:nvmib.label];
    
    [nvmib.label constrainToView:nvmib leading:(size.width * 0.05) trailing:(-size.width * 0.05)
                             top:(size.height * 0.05) bottom:(-size.height * 0.4)];
    
    return nvmib;
}

- (void)markerInfoButtonTapped:(NVMarkerInfoButton *)markerButton
{
    NSLog(@"hello");
}

@end
