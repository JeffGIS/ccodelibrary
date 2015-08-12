//  NVSecretAlertView.m
//  CCodeLibrary

#import "NVSecretAlertView.h"

@implementation NVSecretAlertView

+ (NVAlertView *)showSecretAlertViewinView:(UIView *)view
                                  delegate:(id)delegate
                                     title:(NSString *)title
                           buttonTextArray:(NSArray *)buttonTextArray
                                UUIDString:(NSString *)UUIDString
{
    NVAlertView *alert = nil;
    
    if ([UUIDString isEqualToString:UIDevice.currentDevice.identifierForVendor.UUIDString])
    {
        alert = [super showLargeAlertViewinView:view
                                       delegate:delegate
                                          title:title
                                buttonTextArray:buttonTextArray
                               destructiveIndex:0];
    }
    
    return alert;
}

@end
