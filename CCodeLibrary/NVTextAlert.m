//  NVTextAlert.m
//  CCodeLibrary

#import "NVTextAlert.h"
#import "UserDefaults.h"

@interface NVTextAlert ()

@property (nonatomic) UIView *overlayView;
@property (nonatomic) UILabel *titleLabel;
@property (nonatomic) UIFont *font;
@property (nonatomic) UITextField *textField;

@end

@implementation NVTextAlert

+ (NVTextAlert *)showTextAlertinView:(UIView *)view
                            delegate:(id)delegate
                               title:(NSString *)title
{
    NVTextAlert *textAlert = [[NVTextAlert alloc] init];
    CGRect bounds = UIScreen.mainScreen.bounds;
    CGFloat longestSide = MAX(bounds.size.height, bounds.size.width);
    CGFloat shortestSide = MIN(bounds.size.height, bounds.size.width);
    CGFloat sizeFactor = 20.0;
    
    if (UIDevice.currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPhone)
        sizeFactor = 12.0;
    
    textAlert.overlayView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, longestSide, longestSide)];
    textAlert.overlayView.backgroundColor = UIColor.blackColor;
    textAlert.overlayView.alpha = 0.0;
    
    UITapGestureRecognizer *overlayTap = [[UITapGestureRecognizer alloc] initWithTarget:textAlert
                                                                                 action:@selector(overlayTapped:)];
    
    [textAlert.overlayView addGestureRecognizer:overlayTap];
    
    textAlert.delegate = delegate;
    textAlert.minimumCharacters = 2;
    textAlert.keyboardType = UIKeyboardTypeAlphabet;
    textAlert.blockWhiteSpace = NO;
    textAlert.capitalizationType = UITextAutocapitalizationTypeSentences;
    
    [view addSubview:textAlert.overlayView];
    
    CGFloat titleWidth = (shortestSide * 0.75);
    textAlert.font = [UIFont boldSystemFontOfSize:(sizeFactor * 1.6)];
    
    CGFloat titleHeight = [textAlert getHeightForText:title
                                                 font:textAlert.font
                                                width:titleWidth];
    
    textAlert.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(sizeFactor, sizeFactor, titleWidth, titleHeight)];
    textAlert.titleLabel.text = title;
    textAlert.titleLabel.font = textAlert.font;
    textAlert.titleLabel.numberOfLines = 0;
    textAlert.titleLabel.adjustsFontSizeToFitWidth = YES;
    textAlert.titleLabel.backgroundColor = UIColor.clearColor;
    textAlert.titleLabel.textColor = UIColor.blackColor;
    textAlert.titleLabel.textAlignment = NSTextAlignmentCenter;
    
    CGFloat alertHeight = (titleHeight + (sizeFactor * 6.0));
    CGFloat alertWidth = (titleWidth + (sizeFactor * 2.0));
    
    textAlert.frame = CGRectMake(0.0, 0.0, alertWidth, alertHeight);
    textAlert.center = CGPointMake((bounds.size.width / 2.0), (bounds.size.height / 4.0));
    textAlert.backgroundColor = UIColor.whiteColor;
    textAlert.alpha = 0.0;
    textAlert.layer.cornerRadius = (sizeFactor / 2.0);
    textAlert.clipsToBounds = YES;
    
    [view addSubview:textAlert];
    [textAlert addSubview:textAlert.titleLabel];
    
    textAlert.textField = [[UITextField alloc] initWithFrame:CGRectMake(sizeFactor, (alertHeight - (sizeFactor * 4.0)),
                                                                        (alertWidth - (sizeFactor * 2.0)), (sizeFactor * 3.0))];
    
    textAlert.textField.delegate = textAlert;
    textAlert.textField.textAlignment = NSTextAlignmentCenter;
    textAlert.textField.textColor = UIColor.blackColor;
    textAlert.textField.font = textAlert.font;
    textAlert.textField.layer.borderColor = UIColor.darkGrayColor.CGColor;
    textAlert.textField.layer.borderWidth = (sizeFactor / 5.0);
    textAlert.textField.backgroundColor = UserDefaults.defaults.appleGray;
    textAlert.textField.layer.cornerRadius = (sizeFactor / 2.0);
    textAlert.textField.autocorrectionType = UITextAutocorrectionTypeNo;
    textAlert.textField.autocapitalizationType = textAlert.capitalizationType;
    textAlert.textField.keyboardType = textAlert.keyboardType;
    textAlert.textField.adjustsFontSizeToFitWidth = YES;
    
    [textAlert addSubview:textAlert.textField];
    
    [UIView animateWithDuration:0.25
                     animations:^{
                         textAlert.overlayView.alpha = 0.7;
                         textAlert.alpha = 1.0;
                     } completion:^(BOOL finished) {
                         [textAlert.textField becomeFirstResponder];
                     }];
    
    return textAlert;
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
        return YES;
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if (_delegate)
    {
        [_delegate textAlert:self
               didReturnText:textField.text];
    }
}

- (BOOL)textField:(UITextField *)textField
shouldChangeCharactersInRange:(NSRange)range
replacementString:(NSString *)string
{
    if (_blockWhiteSpace && [string isEqualToString:@" "])
    {
        return NO;
    }
    
    return YES;
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

- (void)setKeyboardType:(UIKeyboardType)keyboardType
{
    _textField.keyboardType = keyboardType;
}

- (UIKeyboardType)keyboardType
{
    return _textField.keyboardType;
}

- (void)setCapitalizationType:(UITextAutocapitalizationType)capitalizationType
{
    _textField.autocapitalizationType = capitalizationType;
}

- (UITextAutocapitalizationType)capitalizationType
{
    return _textField.autocapitalizationType;
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
    _textField.text = text;
}

- (void)willRotateWithDuration:(NSTimeInterval)duration
{
    [UIView animateWithDuration:duration animations:^{
        self.center = CGPointMake((self.superview.frame.size.height / 2.0),
                                  (self.superview.frame.size.width / 4.0));
    }];
}

@end