//  NVPDFSnapshotter.m
//  CCodeLibrary

#import "NVPDFSnapshotter.h"

@implementation NVPDFSnapshotter

+ (NSData *)pdfFromViews:(NSArray *)views
{
    NSMutableData *pdf = NSMutableData.data;
    UIGraphicsBeginPDFContextToData(pdf, CGRectZero, nil);
    UIGraphicsBeginPDFPageWithInfo([views[0] bounds], nil);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    for(UIView *view in views)
        [view.layer renderInContext:context];
    
    UIGraphicsEndPDFContext();
    return pdf;
}

@end