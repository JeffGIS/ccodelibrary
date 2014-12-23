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
        self.opaque = NO;
        self.parentView = parView;
    }
    
    return self;
}

- (void)drawRect:(CGRect)rect
{
    CGRect pointRect;
    CGFloat size = 68.0;
    CGFloat borderWidth = 4.0;
    CGContextRef context = UIGraphicsGetCurrentContext();
    int type;
    
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
        type = info.type;
        
        CGPoint pt = [CRAPI.sharedInstance  pointForLev21Coordinate:lev21pt
                                                usingTransformation:self.pTranWToBMP];
        
        pt.x /= self.xFactor;
        pt.y /= self.yFactor;
        
        if ((pt.x > -size) && (pt.x < (self.parentView.frame.size.width + size) &&
                                (pt.y > -size) && (pt.y < self.parentView.frame.size.height + size)))
        {
            CGContextSetStrokeColorWithColor(context, UIColor.blackColor.CGColor);
            
            if (type == IntElementTypeRamp)
            {
                CGContextSetFillColorWithColor(context, UIColor.redColor.CGColor);
                pointRect = CGRectMake(pt.x - (size / 2.0), pt.y - (size / 2.0), size, size);
                CGContextSetLineWidth(context, borderWidth);
                CGContextFillEllipseInRect(context, pointRect);
                CGContextStrokeEllipseInRect(context, pointRect);
                CGContextFillPath(context);
            }
            
            else if (type == IntElementTypeXWalk)
            {
                CGContextSetFillColorWithColor(context, UIColor.whiteColor.CGColor);
                
                pointRect = CGRectMake((pt.x - ((size * 1.35) / 2.0)),
                                       (pt.y - ((size * 0.5) / 2.0)),
                                       (size * 1.35), (size * 0.5));
                
                CGContextSetLineWidth(context, borderWidth);
                CGContextFillRect(context, pointRect);
                CGContextStrokeRect(context, pointRect);
                CGContextFillPath(context);
            }
            
            else if (type == IntElementTypeSignal)
            {
                UIImage *image = UserDefaults.defaults.triangleImage;
                
                [image drawInRect:CGRectMake((pt.x - ((size * 1.25) / 2.0)),
                                             (pt.y - ((size * 1.75) / 2.0)),
                                             (size * 1.25), (size * 1.75))];
            }
            
            else if (type == IntElementTypeIntersection)
            {
                size = 40.0, borderWidth = 2.0;
                CGContextSetFillColorWithColor(context, UserDefaults.defaults.green.CGColor);
                pointRect = CGRectMake(pt.x - (size / 2.0), pt.y - (size / 2.0), size, size);
                CGContextSetLineWidth(context, borderWidth);
                CGContextFillEllipseInRect(context, pointRect);
                CGContextStrokeEllipseInRect(context, pointRect);
                CGContextFillPath(context);
            }
        }
    }
}

- (void)dealloc
{
    int ii = 1;
    ii++;
}

@end