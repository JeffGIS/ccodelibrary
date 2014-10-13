//  ElementOverlayView.m
//  CCodeLibrary

#import "ElementOverlayView.h"

@implementation ElementOverlayView

- (id)initWithParentView:(UIView *)parView
{
    CGRect frame = parView.frame;
    frame.origin.x = frame.origin.y = 0;
    self = [super initWithFrame:frame];
    
    if (self)
    {
        self.backgroundColor = nil;
        self.opaque = NO;
        self.parentView = parView;
    }
    
    return self;
}

- (void)drawRect:(CGRect)rect
{
    CGRect pointRect;
    
    UIColor *green = UserDefaults.defaults.darkGreen;
    
    CGFloat maxSize = 60.0;
    CGFloat size;
    CGContextRef context = UIGraphicsGetCurrentContext();
    size =  maxSize;
    
    IBOUNDS bounds21 = [CRAPI.sharedInstance boundsFromRect:self.bounds
                                        usingTransformation:self.pTranBMPToW];
    
    InflateMNMXCORL(&bounds21, 1000);
    
    NSArray *pointsArray = [self.database getIntersectionElementsFromDatabaseinBounds:(IBOUNDS)bounds21
                                                                            skipIntID:0];
    
    for (int i = 0; i < pointsArray.count; i++)
    {
        IntersectionElement *info = (IntersectionElement *)pointsArray[i];
        IPOINT lev21pt;
        lev21pt.x = info.lev21x;
        lev21pt.y = info.lev21y;
        
        CGPoint pt = [CRAPI.sharedInstance  pointForLev21Coordinate:lev21pt
                                                usingTransformation:self.pTranWToBMP];
        
        pt.x /= self.xFactor;
        pt.y /= self.yFactor;
        
        if ((pt.x > - size) && (pt.x < (self.parentView.frame.size.width + size) &&
                                (pt.y > - size) && (pt.y < self.parentView.frame.size.height + size)))
        {
            CGContextSetStrokeColorWithColor(context, UIColor.blackColor.CGColor);
            CGContextSetFillColorWithColor(context, green.CGColor);
            pointRect = CGRectMake(pt.x - (size / 2.0), pt.y - (size / 2.0), size, size);
            CGContextSetLineWidth(context, (size / 12.0));
            CGContextFillEllipseInRect(context, pointRect);
            CGContextStrokeEllipseInRect(context, pointRect);
            CGContextFillPath(context);
        }
    }
    
    return;
}

- (void)dealloc
{
    int ii=1;
    ii++;
}

@end