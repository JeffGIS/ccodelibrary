//  NVUnitPickerTextAlert.h
//  CCodeLibrary

@import UIKit;

@class NVUnitPickerTextAlert;

@protocol NVUnitPickerTextAlertDelegate <NSObject>

- (void)textAlert:(NVUnitPickerTextAlert *)textAlert
    didReturnText:(NSString *)text;

@end

@interface NVUnitPickerTextAlert : UIView <UITextFieldDelegate,UIPickerViewDataSource,UIPickerViewDelegate>

@property (nonatomic, weak) id <NVUnitPickerTextAlertDelegate> delegate;
@property (nonatomic, copy) NSString *text;

+ (NVUnitPickerTextAlert *)showUnitPickerTextAlertWithTitle:(NSString *)title
                                                pickerArray:(NSArray *)pickerArray
                                                   delegate:(id)delegate;

- (void)hideTextAlert:(BOOL)animated;
- (void)willRotateWithDuration:(NSTimeInterval)duration;

@end