//  NVContactPicker.m
//  CCodeLibrary

#import "NVContactPicker.h"

@interface NVContactPicker ()

@property (nonatomic) CNContactPickerViewController *cpvc;
@property (nonatomic) ABPeoplePickerNavigationController *abpnc;

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
    
    else
    {
        nvcp.abpnc = [[ABPeoplePickerNavigationController alloc] init];
        nvcp.abpnc.peoplePickerDelegate = nvcp;
        
        if ([delegate isKindOfClass:UIViewController.class])
        {
            [delegate presentViewController:nvcp.abpnc
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

- (void)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker
                         didSelectPerson:(ABRecordRef)person
{
    if (_delegate)
    {
        CFStringRef nameRef = ABRecordCopyCompositeName(person);
        ABMultiValueRef emailMultiValue = ABRecordCopyValue(person, kABPersonEmailProperty);
        CFStringRef emailRef = ABMultiValueCopyValueAtIndex(emailMultiValue, 0);
        
        [_delegate contactPicker:self
                  didReturnEmail:(__bridge NSString *)emailRef
                  forContactName:(__bridge NSString *)nameRef];
        
        CFRelease(nameRef);
        CFRelease(emailMultiValue);
        CFRelease(emailRef);
    }
}

@end