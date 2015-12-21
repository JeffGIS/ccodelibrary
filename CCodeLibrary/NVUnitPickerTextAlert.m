//  NVUnitPickerTextAlert.m
//  CCodeLibrary

#import "NVUnitPickerTextAlert.h"
#import "UserDefaults.h"

@interface NVUnitPickerTextAlert ()

@property (nonatomic) UIView *overlayView, *containerView;
@property (nonatomic) UILabel *titleLabel;
@property (nonatomic) UIFont *font;
@property (nonatomic) UITextField *textField;
@property (nonatomic) UIWindow *window;
@property (nonatomic) UIPickerView *picker;
@property (nonatomic) NSArray *pickerArray;

@end

@implementation NVUnitPickerTextAlert

+ (NVUnitPickerTextAlert *)showUnitPickerTextAlertWithTitle:(NSString *)title
                                                pickerArray:(NSArray *)pickerArray
                                                   delegate:(id)delegate
{
    NVUnitPickerTextAlert *nvupta = [[NVUnitPickerTextAlert alloc] init];
    nvupta.window = UIApplication.sharedApplication.keyWindow;
    nvupta.delegate = delegate;
    nvupta.pickerArray = pickerArray;
    
    CGRect bounds = nvupta.window.bounds;
    CGFloat longestSide = MAX(bounds.size.height, bounds.size.width);
    CGFloat shortestSide = MIN(bounds.size.height, bounds.size.width);
    CGFloat sizeFactor = 20.0;
    
    if (UIDevice.currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPhone)
        sizeFactor = 12.0;
    
    nvupta.overlayView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, longestSide, longestSide)];
    nvupta.overlayView.backgroundColor = UIColor.blackColor;
    nvupta.overlayView.alpha = 0.0;
    
    UITapGestureRecognizer *overlayTap = [[UITapGestureRecognizer alloc] initWithTarget:nvupta
                                                                                 action:@selector(overlayTapped:)];
    
    [nvupta.overlayView addGestureRecognizer:overlayTap];
    [nvupta.window addSubview:nvupta.overlayView];
    
    CGFloat titleWidth = (shortestSide * 0.75);
    nvupta.font = [UIFont boldSystemFontOfSize:(sizeFactor * 1.6)];
    
    CGFloat titleHeight = [nvupta getHeightForText:title
                                              font:nvupta.font
                                             width:titleWidth];
    
    nvupta.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(sizeFactor, sizeFactor, titleWidth, titleHeight)];
    nvupta.titleLabel.text = title;
    nvupta.titleLabel.font = nvupta.font;
    nvupta.titleLabel.numberOfLines = 0;
    nvupta.titleLabel.adjustsFontSizeToFitWidth = YES;
    nvupta.titleLabel.backgroundColor = UIColor.clearColor;
    nvupta.titleLabel.textColor = UIColor.blackColor;
    nvupta.titleLabel.textAlignment = NSTextAlignmentCenter;
    
    CGFloat alertHeight = (titleHeight + (sizeFactor * 9.0));
    CGFloat alertWidth = (titleWidth + (sizeFactor * 2.0));
    
    nvupta.frame = CGRectMake(0.0, 0.0, alertWidth, alertHeight);
    nvupta.center = CGPointMake((bounds.size.width / 2.0), (bounds.size.height / 4.0));
    nvupta.backgroundColor = UIColor.whiteColor;
    nvupta.alpha = 0.0;
    nvupta.layer.cornerRadius = (sizeFactor / 2.0);
    nvupta.clipsToBounds = YES;
    
    [nvupta.window addSubview:nvupta];
    [nvupta addSubview:nvupta.titleLabel];
    
    nvupta.containerView = [[UIView alloc] initWithFrame:
                            CGRectMake(sizeFactor, (alertHeight - (sizeFactor * 7.0)),
                                       (alertWidth - (sizeFactor * 2.0)), (sizeFactor * 6.0))];
    
    nvupta.containerView.layer.borderColor = UIColor.darkGrayColor.CGColor;
    nvupta.containerView.layer.borderWidth = (sizeFactor / 5.0);
    nvupta.containerView.backgroundColor = UserDefaults.defaults.appleGray;
    nvupta.containerView.layer.cornerRadius = (sizeFactor / 2.0);
    
    [nvupta addSubview:nvupta.containerView];
    
    nvupta.textField = [[UITextField alloc] initWithFrame:
                        CGRectMake(0.0, 0.0, (nvupta.containerView.frame.size.width / 2.0),
                                   (nvupta.containerView.frame.size.height))];
    
    nvupta.textField.delegate = nvupta;
    nvupta.textField.textAlignment = NSTextAlignmentCenter;
    nvupta.textField.textColor = UIColor.blackColor;
    nvupta.textField.font = nvupta.font;
    nvupta.textField.backgroundColor = UIColor.clearColor;
    nvupta.textField.layer.cornerRadius = nvupta.containerView.layer.cornerRadius;
    nvupta.textField.keyboardType = UIKeyboardTypeNumberPad;
    nvupta.textField.adjustsFontSizeToFitWidth = YES;
    
    [nvupta.containerView addSubview:nvupta.textField];
    
    nvupta.picker = [[UIPickerView alloc] initWithFrame:
                     CGRectMake((nvupta.containerView.frame.size.width / 2.0), 0.0,
                                (nvupta.containerView.frame.size.width / 2.0),
                                (nvupta.containerView.frame.size.height))];
    
    nvupta.picker.delegate = nvupta;
    nvupta.picker.dataSource = nvupta;
    nvupta.picker.backgroundColor = UIColor.clearColor;
    nvupta.picker.layer.cornerRadius = nvupta.containerView.layer.cornerRadius;
    
    [nvupta.containerView addSubview:nvupta.picker];
    
    [UIView animateWithDuration:0.25
                     animations:^{
                         nvupta.overlayView.alpha = 0.7;
                         nvupta.alpha = 1.0;
                     } completion:^(BOOL finished) {
                         [nvupta.textField becomeFirstResponder];
                     }];
    
    return nvupta;
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView
numberOfRowsInComponent:(NSInteger)component
{
    return _pickerArray.count;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView
rowHeightForComponent:(NSInteger)component
{
    return (pickerView.frame.size.height / 3.0);
}

- (UIView *)pickerView:(UIPickerView *)pickerView
            viewForRow:(NSInteger)row
          forComponent:(NSInteger)component
           reusingView:(UIView *)view
{
    UILabel *pView = (UILabel *)view;
    
    if (!pView)
    {
        pView = [[UILabel alloc] init];
        pView.font = _font;
        pView.textAlignment = NSTextAlignmentCenter;
    }
    
    pView.text = _pickerArray[row];
    
    return pView;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if (_delegate)
    {
        NSInteger row = [_picker selectedRowInComponent:0];
        
        [_delegate textAlert:self
               didReturnText:[NSString stringWithFormat:@"%@ %@",
                              textField.text, _pickerArray[row]]];
    }
}

- (BOOL)textField:(UITextField *)textField
shouldChangeCharactersInRange:(NSRange)range
replacementString:(NSString *)string
{
    
    NSCharacterSet *cs = [[NSCharacterSet characterSetWithCharactersInString:@"0123456789"] invertedSet];
    NSString *filtered = [[string componentsSeparatedByCharactersInSet:cs] componentsJoinedByString:@""];
    return [string isEqualToString:filtered];
}

- (void)hideTextAlert:(BOOL)animated
{
    [UIView animateWithDuration:0.25
                     animations:^{
                         self.alpha = 0.0;
                         _overlayView.alpha = 0.0;
                     } completion:^(BOOL finished) {
                         [_overlayView removeFromSuperview];
                         [self removeFromSuperview];
                     }];
}

- (CGFloat)getHeightForText:(NSString *)text
                       font:(UIFont *)font
                      width:(CGFloat)width
{
    CGSize constraint = CGSizeMake(width , 20000.0);
    
    CGSize titleSize = [text boundingRectWithSize:constraint
                                   options:NSStringDrawingUsesLineFragmentOrigin
                                attributes:@{NSFontAttributeName:font}
                                   context:nil].size;
    
    CGFloat totalHeight = ceil(titleSize.height);
    CGFloat height = MAX(totalHeight, 40.0);
    return height;
}

- (void)touchesEnded:(NSSet *)touches
           withEvent:(UIEvent *)event
{
    [_textField resignFirstResponder];
}

- (void)overlayTapped:(UITapGestureRecognizer *)gesture
{
    [_textField resignFirstResponder];
}

- (void)setText:(NSString *)text
{
    NSArray *textArray = [text componentsSeparatedByString:@" "];
    _textField.text = textArray[0];
    
    NSInteger row = [_pickerArray indexOfObject:textArray[1]];
    
    [_picker selectRow:row
           inComponent:0
              animated:NO];
}

- (void)willRotateWithDuration:(NSTimeInterval)duration
{
    [UIView animateWithDuration:duration animations:^{
        self.center = CGPointMake((_window.frame.size.height / 2.0),
                                  (_window.frame.size.width / 4.0));
    }];
}

@end