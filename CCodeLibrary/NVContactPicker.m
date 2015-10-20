//  NVContactPicker.m
//  CCodeLibrary

#import "NVContactPicker.h"

@interface NVContactPicker ()

@property (nonatomic) CNContactPickerViewController *cpvc;

@end

@implementation NVContactPicker

+ (NVContactPicker *)presentContactPickerInDelegate:(id)delegate
{
    NVContactPicker *nvcp = [[NVContactPicker alloc] init];
    nvcp.delegate = delegate;
    
    if (UIDevice.currentDevice.systemVersion.floatValue > 8.99)
    {
        nvcp.cpvc = [[CNContactPickerViewController alloc] init];
        nvcp.cpvc.delegate = nvcp;
        
        if ([delegate isKindOfClass:UIViewController.class])
        {
            [delegate presentViewController:nvcp.cpvc
                                   animated:YES
                                 completion:nil];
        }
    }
    
    return nvcp;
}

- (void)contactPicker:(CNContactPickerViewController *)picker
     didSelectContact:(CNContact *)contact
{
    if (_delegate)
    {
        [_delegate contactPicker:self
                  didReturnEmail:contact.emailAddresses[0].value
                  forContactName:[NSString stringWithFormat:@"%@ %@",
                                  contact.givenName, contact.familyName]];
    }
}

@end