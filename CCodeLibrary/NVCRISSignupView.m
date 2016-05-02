//  NVCRISSignupView.m
//  CCodeLibrary

#import "NVCRISSignupView.h"
#import "UserDefaults.h"

@interface NVCRISSignupView () <UITextViewDelegate>

@property (nonatomic, weak) id <NVCRISSignupViewDelegate> delegate;
@property (nonatomic) UIView *overlayView;
@property (nonatomic) UILabel *titleLabel, *promptLabel, *nameLabel, *orgLabel, *phoneLabel, *emailLabel, *userNumberLabel;
@property (nonatomic) UITextField *nameTF, *orgTF, *phoneTF, *emailTF, *userNumberTF;
@property (nonatomic) UIButton *sendButton;

@end

@implementation NVCRISSignupView

+ (instancetype)showSignupViewinView:(UIView *)view
                            delegate:(id)delegate
{
    if (!delegate || !view)
    {
        NSLog(@"NVAlertView ERROR:Cannot set delegate or view to nil");
        return nil;
    }
    
    if (![delegate respondsToSelector:@selector(signupView:didReturnUserNumber:)])
    {
        NSLog(@"NVAlertView ERROR:Delegate must respond to all selectors in protocol");
        return nil;
    }
    
    NVCRISSignupView *signup = NVCRISSignupView.new;
    signup.overlayView = [[UIView alloc] initWithFrame:view.frame];
    signup.overlayView.backgroundColor = UIColor.blackColor;
    signup.overlayView.alpha = 0.0;
    signup.delegate = delegate;
    
    [view addSubview:signup.overlayView];
    
    signup.frame = CGRectMake(0.0, 0.0, (view.frame.size.width * 0.95), (view.frame.size.height * 0.6));
    signup.center = CGPointMake((view.frame.size.width / 2.0), (view.frame.size.height / 3.0));
    signup.backgroundColor = UserDefaults.defaults.appleGray;
    signup.alpha = 0.0;
    signup.layer.cornerRadius = 10.0;
    signup.clipsToBounds = YES;
    
    [view addSubview:signup];
    
    CGFloat numElements = 8.0;
    
    signup.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, signup.frame.size.width,
                                                                  (signup.frame.size.height / numElements))];
    
    signup.titleLabel.text = @"NVCRIS Signup Screen";
    signup.titleLabel.font = [UIFont boldSystemFontOfSize:40.0];
    signup.titleLabel.textColor = UIColor.blackColor;
    signup.titleLabel.textAlignment = NSTextAlignmentCenter;
    
    [signup addSubview:signup.titleLabel];
    
    signup.promptLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, (signup.frame.size.height / numElements),
                                                                   signup.frame.size.width, (signup.frame.size.height / numElements))];
    
    signup.promptLabel.text = @"Complete this form and tap on 'Send'\nto get a NVCRIS User Number";
    signup.promptLabel.font = [UIFont boldSystemFontOfSize:28.0];
    signup.promptLabel.textColor = UIColor.blackColor;
    signup.promptLabel.textAlignment = NSTextAlignmentCenter;
    signup.promptLabel.numberOfLines = 2;
    
    [signup addSubview:signup.promptLabel];
    
    signup.nameLabel = [[UILabel alloc] initWithFrame:CGRectMake((signup.frame.size.width * 0.025),
                                                                 ((signup.frame.size.height / numElements) * 2.0),
                                                                 (signup.frame.size.width * 0.225),
                                                                 (signup.frame.size.height / numElements))];
    
    [signup setupLabel:signup.nameLabel];
    signup.nameLabel.text = @"Name:";
    
    signup.nameTF = [[UITextField alloc] initWithFrame:CGRectMake((signup.frame.size.width * 0.2625),
                                                                  (((signup.frame.size.height / numElements) * 2.0) + 8.0),
                                                                  (signup.frame.size.width * 0.725),
                                                                  ((signup.frame.size.height / numElements) - 16.0))];
    
    [signup setupTF:signup.nameTF];
    [signup.nameTF becomeFirstResponder];
    
    signup.orgLabel = [[UILabel alloc] initWithFrame:CGRectMake((signup.frame.size.width * 0.025),
                                                                ((signup.frame.size.height / numElements) * 3.0),
                                                                (signup.frame.size.width * 0.225),
                                                                (signup.frame.size.height / numElements))];
    
    [signup setupLabel:signup.orgLabel];
    signup.orgLabel.text = @"Organization:";
    
    signup.orgTF = [[UITextField alloc] initWithFrame:CGRectMake((signup.frame.size.width * 0.2625),
                                                                 (((signup.frame.size.height / numElements) * 3.0) + 8.0),
                                                                 (signup.frame.size.width * 0.725),
                                                                 ((signup.frame.size.height / numElements) - 16.0))];
    
    [signup setupTF:signup.orgTF];
    
    signup.phoneLabel = [[UILabel alloc] initWithFrame:CGRectMake((signup.frame.size.width * 0.025),
                                                                  ((signup.frame.size.height / numElements) * 4.0),
                                                                  (signup.frame.size.width * 0.225),
                                                                  (signup.frame.size.height / numElements))];
    
    [signup setupLabel:signup.phoneLabel];
    signup.phoneLabel.text = @"Phone:";
    
    signup.phoneTF = [[UITextField alloc] initWithFrame:CGRectMake((signup.frame.size.width * 0.2625),
                                                                   (((signup.frame.size.height / numElements) * 4.0) + 8.0),
                                                                   (signup.frame.size.width * 0.725),
                                                                   ((signup.frame.size.height / numElements) - 16.0))];
    
    [signup setupTF:signup.phoneTF];
    signup.phoneTF.keyboardType = UIKeyboardTypeNumberPad;
    
    signup.emailLabel = [[UILabel alloc] initWithFrame:CGRectMake((signup.frame.size.width * 0.025),
                                                                  ((signup.frame.size.height / numElements) * 5.0),
                                                                  (signup.frame.size.width * 0.225),
                                                                  (signup.frame.size.height / numElements))];
    
    [signup setupLabel:signup.emailLabel];
    signup.emailLabel.text = @"Email:";
    
    signup.emailTF = [[UITextField alloc] initWithFrame:CGRectMake((signup.frame.size.width * 0.2625),
                                                                   (((signup.frame.size.height / numElements) * 5.0) + 8.0),
                                                                   (signup.frame.size.width * 0.725),
                                                                   ((signup.frame.size.height / numElements) - 16.0))];
    
    [signup setupTF:signup.emailTF];
    
    signup.sendButton = [UIButton buttonWithType:UIButtonTypeCustom];
    
    signup.sendButton.frame = CGRectMake((signup.frame.size.width / 4.0),
                                         (((signup.frame.size.height / numElements) * 6.0) + 8.0),
                                         (signup.frame.size.width / 2.0),
                                         (signup.frame.size.height / numElements) - 16.0);
    
    signup.sendButton.backgroundColor = UIColor.blackColor;
    signup.sendButton.layer.cornerRadius = 10.0;
    signup.sendButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    signup.sendButton.titleLabel.font = [UIFont boldSystemFontOfSize:36.0];
    
    [signup.sendButton setTitle:@"Send"
                       forState:UIControlStateNormal];
    
    [signup.sendButton setTitleColor:UIColor.whiteColor
                            forState:UIControlStateNormal];
    
    [signup.sendButton setTitleColor:UIColor.lightGrayColor
                            forState:UIControlStateHighlighted];
    
    [signup.sendButton addTarget:signup
                          action:@selector(sendButtonTapped:)
                forControlEvents:UIControlEventTouchUpInside];
    
    [signup addSubview:signup.sendButton];
    
    signup.userNumberLabel = [[UILabel alloc] initWithFrame:CGRectMake((signup.frame.size.width * 0.025),
                                                                       ((signup.frame.size.height / numElements) * 7.0),
                                                                       (signup.frame.size.width * 0.225),
                                                                       (signup.frame.size.height / numElements))];
    
    [signup setupLabel:signup.userNumberLabel];
    signup.userNumberLabel.text = @"NVCRIS\nUser Number:";
    signup.userNumberLabel.numberOfLines = 2;
    signup.userNumberLabel.alpha = 0.3;
    
    signup.userNumberTF = [[UITextField alloc] initWithFrame:CGRectMake((signup.frame.size.width * 0.2625),
                                                                        (((signup.frame.size.height / numElements) * 7.0) + 8.0),
                                                                        (signup.frame.size.width * 0.725),
                                                                        ((signup.frame.size.height / numElements) - 16.0))];
    
    [signup setupTF:signup.userNumberTF];
    signup.userNumberTF.alpha = 0.3;
    signup.userNumberTF.enabled = NO;
    signup.userNumberTF.keyboardType = UIKeyboardTypeNumberPad;
    
    [UIView animateWithDuration:0.25
                     animations:^{
                         signup.overlayView.alpha = 0.7;
                         signup.alpha = 1.0;
                     }];
    
    return signup;
}

- (void)setupLabel:(UILabel *)label
{
    label.font = [UIFont systemFontOfSize:24.0];
    label.textColor = UIColor.blackColor;
    label.textAlignment = NSTextAlignmentRight;
    
    [self addSubview:label];
}

- (void)setupTF:(UITextField *)tf
{
    tf.layer.borderColor = UIColor.blackColor.CGColor;
    tf.layer.borderWidth = 2.0;
    tf.layer.cornerRadius = 10.0;
    tf.backgroundColor = UIColor.whiteColor;
    tf.font = [UIFont boldSystemFontOfSize:28.0];
    tf.textAlignment = NSTextAlignmentCenter;
    tf.clearButtonMode = UITextFieldViewModeWhileEditing;
    
    [self addSubview:tf];
}

- (void)hideSignupView:(BOOL)animated
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

- (void)sendButtonTapped:(UIButton *)button
{
    if ([button.currentTitle isEqualToString:@"Continue"])
    {
        [_delegate signupView:self
          didReturnUserNumber:_userNumberTF.text];
    }
    
    else
    {
        [self makeTFLikeLabel:_nameTF];
        [self makeTFLikeLabel:_orgTF];
        [self makeTFLikeLabel:_phoneTF];
        [self makeTFLikeLabel:_emailTF];
        
        _promptLabel.text = @"We sent you an email to the address you provided with your NVCRIS User Number. Enter it in below and tap on 'Continue'.";
        _promptLabel.font = [UIFont systemFontOfSize:24.0];
        
        [_sendButton setTitle:@"Continue"
                     forState:UIControlStateNormal];
        
        _userNumberLabel.alpha = 1.0;
        _userNumberTF.alpha = 1.0;
        _userNumberTF.enabled = YES;
        [_userNumberTF becomeFirstResponder];
    }
}

- (void)makeTFLikeLabel:(UITextField *)tf
{
    if (tf.isFirstResponder)
        [tf resignFirstResponder];
    
    tf.backgroundColor = UIColor.clearColor;
    tf.layer.borderWidth = 0.0;
    tf.userInteractionEnabled = NO;
    tf.textAlignment = NSTextAlignmentLeft;
}

@end