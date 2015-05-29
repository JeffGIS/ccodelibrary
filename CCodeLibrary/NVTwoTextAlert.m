//  NVTwoTextAlert.m
//  CCodeLibrary

#import "NVTwoTextAlert.h"
#import "UserDefaults.h"

@interface NVTwoTextAlert ()

@property (nonatomic) UIView *overlayView;
@property (nonatomic) UILabel *titleLabel;
@property (nonatomic) UIFont *font;
@property (nonatomic) UITextField *topTextField, *bottomTextField;

@end

@implementation NVTwoTextAlert

+ (NVTwoTextAlert *)showTwoTextAlertInView:(UIView *)view
                                  delegate:(id)delegate
                                     title:(NSString *)title
                            topPlaceholder:(NSString *)topPlaceholder
                                   topText:(NSString *)topText
                         bottomPlaceholder:(NSString *)bottomPlaceholder
                                bottomText:(NSString *)bottomText
{
    NVTwoTextAlert *textAlert = [[NVTwoTextAlert alloc] init];
    
    CGRect bounds = UIScreen.mainScreen.bounds;
    
    textAlert.overlayView = [[UIView alloc] initWithFrame:bounds];
    textAlert.overlayView.backgroundColor = UIColor.blackColor;
    textAlert.overlayView.alpha = 0.0;
    textAlert.delegate = delegate;
    textAlert.minimumCharacters = 1;
    textAlert.topTextKeyboardType = UIKeyboardTypeAlphabet;
    textAlert.bottomTextKeyboardType = UIKeyboardTypeNumberPad;
    
    [view addSubview:textAlert.overlayView];
    
    CGFloat titleWidth = 340.0;
    textAlert.font = [UIFont boldSystemFontOfSize:32.0];
    
    CGFloat titleHeight = [textAlert getHeightForText:title
                                                 font:textAlert.font
                                                width:titleWidth];
    
    textAlert.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(20.0, 20.0, titleWidth, titleHeight)];
    textAlert.titleLabel.text = title;
    textAlert.titleLabel.font = textAlert.font;
    textAlert.titleLabel.numberOfLines = 0;
    textAlert.titleLabel.adjustsFontSizeToFitWidth = YES;
    textAlert.titleLabel.backgroundColor = UIColor.clearColor;
    textAlert.titleLabel.textColor = UIColor.blackColor;
    textAlert.titleLabel.textAlignment = NSTextAlignmentCenter;
    
    CGFloat alertHeight = (titleHeight + 200.0);
    CGFloat alertWidth = (titleWidth + 40.0);
    
    textAlert.frame = CGRectMake(0.0, 0.0, alertWidth, alertHeight);
    textAlert.center = CGPointMake((bounds.size.width / 2.0), (bounds.size.height / 2.0));
    textAlert.backgroundColor = UIColor.whiteColor;
    textAlert.alpha = 0.0;
    textAlert.layer.cornerRadius = 10.0;
    textAlert.clipsToBounds = YES;
    
    [view addSubview:textAlert];
    [textAlert addSubview:textAlert.titleLabel];
    
    textAlert.topTextField = [[UITextField alloc] initWithFrame:CGRectMake(20.0, (alertHeight - 160.0), (alertWidth - 40.0), 60.0)];
    
    [textAlert setupTextField:textAlert.topTextField];
    textAlert.topTextField.keyboardType = UIKeyboardTypeAlphabet;
    textAlert.topTextField.placeholder = topPlaceholder;
    
    if (topText && ![topText isEqualToString:@""])
        textAlert.topTextField.text = topText;
    
    [textAlert addSubview:textAlert.topTextField];
    
    textAlert.bottomTextField = [[UITextField alloc] initWithFrame:CGRectMake(20.0, (alertHeight - 80.0), (alertWidth - 40.0), 60.0)];
    
    [textAlert setupTextField:textAlert.bottomTextField];
    textAlert.bottomTextField.keyboardType = UIKeyboardTypeNumberPad;
    textAlert.bottomTextField.placeholder = bottomPlaceholder;
    
    if (bottomText && ![bottomText isEqualToString:@""])
        textAlert.topTextField.text = bottomText;
    
    [textAlert addSubview:textAlert.bottomTextField];
    
    [UIView animateWithDuration:0.25
                     animations:^{
                         textAlert.overlayView.alpha = 0.7;
                         textAlert.alpha = 1.0;
                     }];
    
    return textAlert;
}

- (void)setupTextField:(UITextField *)textField
{
    textField.delegate = self;
    textField.textAlignment = NSTextAlignmentCenter;
    textField.textColor = UIColor.blackColor;
    textField.font = _font;
    textField.layer.borderColor = UIColor.darkGrayColor.CGColor;
    textField.layer.borderWidth = 4.0;
    textField.backgroundColor = UserDefaults.defaults.appleGray;
    textField.layer.cornerRadius = 10.0;
    textField.autocorrectionType = UITextAutocorrectionTypeNo;
    textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    textField.adjustsFontSizeToFitWidth = YES;
}

- (void)hideTwoTextAlert:(BOOL)animated
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
    CGSize titleSize;
    CGFloat totalHeight;
    
    titleSize = [text boundingRectWithSize:constraint
                                   options:NSStringDrawingUsesLineFragmentOrigin
                                attributes:@{NSFontAttributeName:font}
                                   context:nil].size;
    
    totalHeight = ceil(titleSize.height);
    CGFloat height = MAX(totalHeight, 40.0);
    return height;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField.text.length < _minimumCharacters)
    {
        [self shakeTextField:textField];
        return NO;
    }
    
    else
    {
        [textField resignFirstResponder];
        
        if (_delegate && _topTextField.text.length && _bottomTextField.text.length)
        {
            [_delegate twoTextAlert:self
                   didReturnTopText:_topTextField.text
                         bottomText:_bottomTextField.text];
        }
        
        return YES;
    }
}

- (void)shakeTextField:(UITextField *)textField
{
    CATransform3D transform = CATransform3DMakeRotation(0.06, 0.0, 0.00, 1.0);
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform"];
    animation.toValue = [NSValue valueWithCATransform3D:transform];
    animation.autoreverses = YES;
    animation.duration = 0.08;
    animation.repeatCount = 2;
    
    [textField.layer addAnimation:animation
                           forKey:@"shakeAnimation"];
}

- (void)setTopTextKeyboardType:(UIKeyboardType)topTextKeyboardType
{
    _topTextField.keyboardType = topTextKeyboardType;
}

- (void)setBottomTextKeyboardType:(UIKeyboardType)bottomTextKeyboardType
{
    _bottomTextField.keyboardType = bottomTextKeyboardType;
}

- (UIKeyboardType)topTextKeyboardType
{
    return _topTextField.keyboardType;
}

- (UIKeyboardType)bottomTextKeyboardType
{
    return _bottomTextField.keyboardType;
}

@end