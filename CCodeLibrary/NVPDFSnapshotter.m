//  NVPDFSnapshotter.m
//  CCodeLibrary

#import "NVPDFSnapshotter.h"

@implementation NVPDFSnapshotter

+ (NSData *)pdfFromViews:(NSArray *)views
                 reports:(NSArray *)reports
{
    NSMutableData *pdf = NSMutableData.data;
    UIGraphicsBeginPDFContextToData(pdf, CGRectZero, NULL);
    UIGraphicsBeginPDFPageWithInfo([views[0] bounds], NULL);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    for (UIView *view in views)
        [view.layer renderInContext:context];
    
    if (reports.count)
    {
        UIFont *font = [UIFont fontWithName:@"CourierNewPS-BoldMT"
                                       size:6.0];
        
        NSDictionary *attributes = @{NSFontAttributeName:font};
        
        for (NSString *strings in reports)
        {
            UIGraphicsBeginPDFPage();
            
            [strings drawAtPoint:CGPointMake(10.0, 10.0)
                  withAttributes:attributes];
        }
    }
    
    UIGraphicsEndPDFContext();
    return pdf;
}

@end