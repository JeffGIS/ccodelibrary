//  NVTextViewAlert.m
//  CCodeLibrary

#import "NVTextViewAlert.h"
#import "UserDefaults.h"

@interface NVTextViewAlert () <UITextViewDelegate>

@property (nonatomic, weak) id <NVTextViewAlertDelegate> delegate;
@property (nonatomic) UILabel *titleLabel;
@property (nonatomic) UITextView *textView;
@property (nonatomic) UIView *overlayView;
@property (nonatomic) UIButton *cancelButton, *saveButton;

@end

@implementation NVTextViewAlert

+ (NVTextViewAlert *)showTextViewAlertinView:(UIView *)view
                                    delegate:(id)delegate
                                       title:(NSString *)title
                                        text:(NSString *)text
{
    if (!delegate || !view || !title || !text)
    {
        NSLog(@"NVAlertView ERROR:Cannot set delegate, view, title or text to nil");
        return nil;
    }
    
    if (![delegate respondsToSelector:@selector(textViewAlert:didReturnText:)] ||
        ![delegate respondsToSelector:@selector(textViewAlertDidCancel:)])
    {
        NSLog(@"NVAlertView ERROR:Delegate must respond to all selectors in protocol");
        return nil;
    }
    
    NVTextViewAlert *alert = NVTextViewAlert.new;
    alert.overlayView = [[UIView alloc] initWithFrame:view.frame];
    alert.overlayView.backgroundColor = UIColor.blackColor;
    alert.overlayView.alpha = 0.0;
    alert.delegate = delegate;
    
    [view addSubview:alert.overlayView];
    
    CGFloat width = 340.0, heightSpacer = 10.0;
    UIFont *font = [UIFont boldSystemFontOfSize:28.0];
    
    if (UIDevice.currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPhone)
        width = 240.0, heightSpacer = 6.0, font = [UIFont boldSystemFontOfSize:20.0];
    
    CGFloat yPosition = heightSpacer;
    
    CGFloat height = [alert getHeightForText:title
                                        font:font
                                       width:width];
    
    alert.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(heightSpacer, yPosition,
                                                                 (width - (heightSpacer * 2.0)), height)];
    
    alert.titleLabel.text = title;
    alert.titleLabel.font = font;
    alert.titleLabel.numberOfLines = 0;
    alert.titleLabel.adjustsFontSizeToFitWidth = YES;
    alert.titleLabel.backgroundColor = UIColor.clearColor;
    alert.titleLabel.textColor = UIColor.blackColor;
    alert.titleLabel.textAlignment = NSTextAlignmentCenter;
    
    [alert addSubview:alert.titleLabel];
    
    yPosition += (height + heightSpacer);
    
    height = [alert getHeightForText:text
                                font:font
                               width:width];
    
    height += heightSpacer;
    
    alert.textView = [[UITextView alloc] initWithFrame:CGRectMake(-1.0 , yPosition,
                                                                 (width + 2.0), height)];
    
    alert.textView.backgroundColor = UIColor.clearColor;
    alert.textView.text = text;
    alert.textView.font = font;
    alert.textView.delegate = alert;
    alert.textView.layer.borderColor = UIColor.lightGrayColor.CGColor;
    alert.textView.layer.borderWidth = 1.0;
    alert.textView.textColor = UIColor.blackColor;
    alert.textView.textAlignment = NSTextAlignmentCenter;
    [alert.textView becomeFirstResponder];
    
    [alert addSubview:alert.textView];
    
    yPosition += (height - 1.0);
    NSString *buttonTitle = @"Save";
    
    height = [alert getHeightForText:buttonTitle
                                font:font
                               width:width];
    
    alert.saveButton = [UIButton buttonWithType:UIButtonTypeCustom];
    alert.saveButton.frame = CGRectMake(-1.0 , yPosition, (width + 2.0), height);
    [alert setupButton:alert.saveButton];
    alert.saveButton.titleLabel.font = font;
    
    [alert.saveButton setTitle:buttonTitle
                      forState:UIControlStateNormal];
    
    [alert.saveButton addTarget:alert
                         action:@selector(saveButtonTapped:)
               forControlEvents:UIControlEventTouchUpInside];
    
    [alert addSubview:alert.saveButton];
    
    yPosition += (height - 1.0);
    buttonTitle = @"Cancel";
    
    height = [alert getHeightForText:buttonTitle
                                font:font
                               width:width];
    
    alert.cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    alert.cancelButton.frame = CGRectMake(-1.0 , yPosition, (width + 2.0), height);
    [alert setupButton:alert.cancelButton];
    alert.cancelButton.titleLabel.font = font;
    
    [alert.cancelButton setTitle:buttonTitle
                      forState:UIControlStateNormal];
    
    [alert.cancelButton addTarget:alert
                           action:@selector(cancelButtonTapped:)
                 forControlEvents:UIControlEventTouchUpInside];
    
    [alert addSubview:alert.cancelButton];
    
    yPosition += (height - 1.0);
    
    alert.frame = CGRectMake(0.0, 0.0, width, yPosition);
    alert.center = view.center;
    alert.backgroundColor = UIColor.whiteColor;
    alert.alpha = 0.0;
    alert.layer.cornerRadius = heightSpacer;
    alert.clipsToBounds = YES;
    
    [view addSubview:alert];
    
    [UIView animateWithDuration:0.25
                     animations:^{
                         alert.overlayView.alpha = 0.7;
                         alert.alpha = 1.0;
                     }];
    
    return alert;
}

- (void)setupButton:(UIButton *)button
{
    button.backgroundColor = UIColor.clearColor;
    button.layer.borderColor = UIColor.lightGrayColor.CGColor;
    button.layer.borderWidth = 1.0;
    button.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    button.titleLabel.numberOfLines = 0;
    button.titleLabel.adjustsFontSizeToFitWidth = YES;
    button.titleLabel.textAlignment = NSTextAlignmentCenter;
    
    [button setTitleColor:UserDefaults.defaults.appleBlue
                 forState:UIControlStateNormal];
    
    [button setTitleColor:UIColor.lightGrayColor
                 forState:UIControlStateHighlighted];
}

- (void)hideTextViewAlert:(BOOL)animated
{
    if (animated)
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
    
    else
    {
        [_overlayView removeFromSuperview];
        [self removeFromSuperview];
    }
}

- (CGFloat)getHeightForText:(NSString *)text
                       font:(UIFont *)font
                      width:(CGFloat)width
{
    CGSize constraint = CGSizeMake(width , 20000.0);
    CGSize titleSize = CGSizeZero;
    CGFloat totalHeight = 0.0;
    
    titleSize = [text boundingRectWithSize:constraint
                                   options:NSStringDrawingUsesLineFragmentOrigin
                                attributes:@{NSFontAttributeName:font}
                                   context:nil].size;
    
    totalHeight = ceil(titleSize.height);
    CGFloat height = MAX(totalHeight, 40.0);
    return height;
}

- (void)saveButtonTapped:(UIButton *)button
{
    [self dismissKeyboard];
    
    [_delegate textViewAlert:self
               didReturnText:_textView.text];
}

- (void)cancelButtonTapped:(UIButton *)button
{
    [self dismissKeyboard];
    
    [_delegate textViewAlertDidCancel:self];
}

- (void)dismissKeyboard
{
    if ([_textView isFirstResponder])
        [_textView resignFirstResponder];
}

@end