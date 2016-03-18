//  NVPDFSnapshotter.m
//  CCodeLibrary

#import "NVPDFSnapshotter.h"
#import "NVTextVC.h"
#import "PickedItem.h"
#import "CrimeData.h"

@implementation NVPDFSnapshotter

+ (NSData *)pdfFromViews:(NSArray *)views
             pickedItems:(NSArray *)pickedItems
{
    NSMutableData *pdf = NSMutableData.data;
    UIGraphicsBeginPDFContextToData(pdf, CGRectZero, NULL);
    UIGraphicsBeginPDFPageWithInfo([views[0] bounds], NULL);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    for (UIView *view in views)
        [view.layer renderInContext:context];
    
    if (pickedItems.count)
    {
        UIFont *font = [UIFont fontWithName:@"CourierNewPS-BoldMT"
                                       size:6.0];
        
        NSDictionary *attributes = @{NSFontAttributeName:font};
        CGSize textSize = CGSizeZero;
        CGFloat linkWidth = 10.0, pageMargin = 10.0;
        CGRect linkFrame = CGRectZero;
        PickedItem *pi = NULL;
        NSString *report = nil;
        
        for (int i = 0; i < pickedItems.count; i++)
        {
            pi = (PickedItem *)pickedItems[i];
            report = [CrimeData reportForControlNumber:pi.refno];
            
            if (report && ![report isEqualToString:@""])
            {
                linkFrame = CGRectMake(((pi.screenPoint.x / 2.0) - (linkWidth / 2.0)),
                                       ((pi.screenPoint.y / 2.0) - (linkWidth / 2.0)),
                                       linkWidth, linkWidth);
                
                UIGraphicsSetPDFContextDestinationForRect([NSString stringWithFormat:@"%li",
                                                           (long)pi.refno], linkFrame);
            }
        }
        
        for (int i = 0; i < pickedItems.count; i++)
        {
            pi = (PickedItem *)pickedItems[i];
            report = [CrimeData reportForControlNumber:pi.refno];
            
            if (report && ![report isEqualToString:@""])
            {
                report = [report stringByReplacingOccurrencesOfString:@"\t"
                                                           withString:@"    "];
                
                textSize = sizeOfString(report, font);
                
                UIGraphicsBeginPDFPageWithInfo(CGRectMake(0.0, 0.0, (textSize.width + 20),
                                                          (textSize.height + 20)), attributes);
                
                [report drawAtPoint:CGPointMake(pageMargin, pageMargin)
                        withAttributes:attributes];
                
                UIGraphicsAddPDFContextDestinationAtPoint([NSString stringWithFormat:@"%li", (long)pi.refno],
                                                          CGPointMake(pageMargin, (textSize.height - pageMargin)));
            }
        }
    }
    
    UIGraphicsEndPDFContext();
    return pdf;
}

@end