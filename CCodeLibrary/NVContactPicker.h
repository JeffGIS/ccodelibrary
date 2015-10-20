//  NVContactPicker.h
//  CCodeLibrary

@import UIKit;
@import Contacts;
@import ContactsUI;
@import AddressBook;
@import AddressBookUI;

@class NVContactPicker;

@protocol NVContactPickerDelegate <NSObject>

- (void)contactPicker:(NVContactPicker *)contactPicker
       didReturnEmail:(NSString *)email
       forContactName:(NSString *)contactName;

@end

@interface NVContactPicker : NSObject <CNContactPickerDelegate,ABPeoplePickerNavigationControllerDelegate>

@property (nonatomic, weak) id <NVContactPickerDelegate> delegate;

+ (NVContactPicker *)presentContactPickerInDelegate:(UIViewController *)delegate;

@end