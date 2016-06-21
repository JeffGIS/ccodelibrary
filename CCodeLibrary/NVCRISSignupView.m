//  NVCRISSignupView.m
//  CCodeLibrary

#import "NVCRISSignupView.h"
#import "UserDefaults.h"

@interface NVCRISSignupView () <UITextFieldDelegate,NVWebViewDelegate>

@property (nonatomic, weak) id <NVCRISSignupViewDelegate> delegate;
@property (nonatomic) UIView *overlayView;
@property (nonatomic) UILabel *titleLabel, *promptLabel, *nameLabel, *orgLabel, *phoneLabel, *emailLabel, *userNumberLabel, *termsLabel;
@property (nonatomic) UITextField *nameTF, *orgTF, *phoneTF, *emailTF, *userNumberTF;
@property (nonatomic) UIButton *sendButton, *privacyButton, *termsButton, *checkmarkButton, *backButton;

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
    
    if (![delegate respondsToSelector:@selector(signupView:didReturnUserNumber:)] ||
        ![delegate respondsToSelector:@selector(signupView:didReturnName:organization:phone:email:)])
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
    
    signup.frame = CGRectMake(0.0, 0.0, (view.frame.size.width * 0.95), (view.frame.size.height * 0.65));
    signup.center = CGPointMake((view.frame.size.width / 2.0), ((view.frame.size.height / 3.0) + 10.0));
    signup.backgroundColor = UserDefaults.defaults.appleGray;
    signup.alpha = 0.0;
    signup.layer.cornerRadius = 10.0;
    signup.clipsToBounds = YES;
    
    [view addSubview:signup];
    
    CGFloat numElements = 9.0;
    
    signup.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(4.0, 0.0, (signup.frame.size.width - 8.0),
                                                                  (signup.frame.size.height / numElements))];
    
    signup.titleLabel.text = @"NVCRIS Signup Screen";
    signup.titleLabel.font = [UIFont boldSystemFontOfSize:40.0];
    signup.titleLabel.textColor = UIColor.blackColor;
    signup.titleLabel.textAlignment = NSTextAlignmentCenter;
    
    [signup addSubview:signup.titleLabel];
    
    signup.promptLabel = [[UILabel alloc] initWithFrame:CGRectMake(4.0, (signup.frame.size.height / numElements),
                                                                   (signup.frame.size.width - 8.0),
                                                                   (signup.frame.size.height / numElements))];
    
    signup.promptLabel.text = @"To begin the signup process,\ntap on 'Terms of Service'.";
    signup.promptLabel.font = [UIFont boldSystemFontOfSize:28.0];
    signup.promptLabel.textColor = UIColor.blackColor;
    signup.promptLabel.textAlignment = NSTextAlignmentCenter;
    signup.promptLabel.numberOfLines = 2;
    
    [signup addSubview:signup.promptLabel];
    
    signup.privacyButton = [UIButton buttonWithType:UIButtonTypeCustom];
    
    signup.privacyButton.frame = CGRectMake((signup.frame.size.width * 0.0125),
                                            (((signup.frame.size.height / numElements) * 7.0) + 8.0),
                                            (signup.frame.size.width * 0.225),
                                            ((signup.frame.size.height / numElements) - 16.0));
    
    signup.privacyButton.titleLabel.font = [UIFont systemFontOfSize:22.0];
    signup.privacyButton.backgroundColor = UIColor.clearColor;
    signup.privacyButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    signup.privacyButton.enabled = NO;
    signup.privacyButton.alpha = 0.3;
    
    [signup.privacyButton setTitleColor:UIColor.blackColor
                 forState:UIControlStateNormal];
    
    [signup.privacyButton setTitleColor:UIColor.lightGrayColor
                 forState:UIControlStateHighlighted];
    
    [signup addSubview:signup.privacyButton];
    
    [signup.privacyButton setTitle:@"Privacy Policy"
                          forState:UIControlStateNormal];
    
    [signup.privacyButton addTarget:signup
                             action:@selector(privacyPolicyTapped:)
                   forControlEvents:UIControlEventTouchUpInside];
    
    signup.termsButton = [UIButton buttonWithType:UIButtonTypeCustom];
    
    signup.termsButton.frame = CGRectMake((signup.frame.size.width * 0.6875),
                                          (((signup.frame.size.height / numElements) * 2.0) + 8.0),
                                          (signup.frame.size.width * 0.3),
                                          (signup.frame.size.height / numElements) - 16.0);
    
    [signup setupButton:signup.termsButton];
    signup.termsButton.titleLabel.font = [UIFont boldSystemFontOfSize:20.0];
    signup.termsButton.titleLabel.numberOfLines = 2;
    
    [signup.termsButton setTitle:@"Terms of\nService"
                          forState:UIControlStateNormal];
    
    [signup.termsButton addTarget:signup
                           action:@selector(termsTapped:)
                 forControlEvents:UIControlEventTouchUpInside];
    
    signup.nameLabel = [[UILabel alloc] initWithFrame:CGRectMake((signup.frame.size.width * 0.0125),
                                                                 ((signup.frame.size.height / numElements) * 3.0),
                                                                 (signup.frame.size.width * 0.225),
                                                                 (signup.frame.size.height / numElements))];
    
    [signup setupLabel:signup.nameLabel];
    signup.nameLabel.text = @"Name:";
    
    signup.nameTF = [[UITextField alloc] initWithFrame:CGRectMake((signup.frame.size.width * 0.25),
                                                                  (((signup.frame.size.height / numElements) * 3.0) + 8.0),
                                                                  (signup.frame.size.width * 0.7375),
                                                                  ((signup.frame.size.height / numElements) - 16.0))];
    
    [signup setupTF:signup.nameTF];
    signup.nameTF.text = [UserDefaults.defaults stringForKey:@"UserNameInfo"];
    signup.nameTF.autocapitalizationType = UITextAutocapitalizationTypeWords;
    
    signup.orgLabel = [[UILabel alloc] initWithFrame:CGRectMake((signup.frame.size.width * 0.0125),
                                                                ((signup.frame.size.height / numElements) * 4.0),
                                                                (signup.frame.size.width * 0.225),
                                                                (signup.frame.size.height / numElements))];
    
    [signup setupLabel:signup.orgLabel];
    signup.orgLabel.text = @"Organization:";
    
    signup.orgTF = [[UITextField alloc] initWithFrame:CGRectMake((signup.frame.size.width * 0.25),
                                                                 (((signup.frame.size.height / numElements) * 4.0) + 8.0),
                                                                 (signup.frame.size.width * 0.7375),
                                                                 ((signup.frame.size.height / numElements) - 16.0))];
    
    [signup setupTF:signup.orgTF];
    signup.orgTF.text = [UserDefaults.defaults stringForKey:@"UserOrgInfo"];
    signup.orgTF.autocapitalizationType = UITextAutocapitalizationTypeWords;
    
    signup.phoneLabel = [[UILabel alloc] initWithFrame:CGRectMake((signup.frame.size.width * 0.0125),
                                                                  ((signup.frame.size.height / numElements) * 5.0),
                                                                  (signup.frame.size.width * 0.225),
                                                                  (signup.frame.size.height / numElements))];
    
    [signup setupLabel:signup.phoneLabel];
    signup.phoneLabel.text = @"Phone:";
    
    signup.phoneTF = [[UITextField alloc] initWithFrame:CGRectMake((signup.frame.size.width * 0.25),
                                                                   (((signup.frame.size.height / numElements) * 5.0) + 8.0),
                                                                   (signup.frame.size.width * 0.7375),
                                                                   ((signup.frame.size.height / numElements) - 16.0))];
    
    [signup setupTF:signup.phoneTF];
    signup.phoneTF.keyboardType = UIKeyboardTypeNumberPad;
    signup.phoneTF.text = [UserDefaults.defaults stringForKey:@"UserPhoneInfo"];
    
    signup.emailLabel = [[UILabel alloc] initWithFrame:CGRectMake((signup.frame.size.width * 0.0125),
                                                                  ((signup.frame.size.height / numElements) * 6.0),
                                                                  (signup.frame.size.width * 0.225),
                                                                  (signup.frame.size.height / numElements))];
    
    [signup setupLabel:signup.emailLabel];
    signup.emailLabel.text = @"Email:";
    
    signup.emailTF = [[UITextField alloc] initWithFrame:CGRectMake((signup.frame.size.width * 0.25),
                                                                   (((signup.frame.size.height / numElements) * 6.0) + 8.0),
                                                                   (signup.frame.size.width * 0.7375),
                                                                   ((signup.frame.size.height / numElements) - 16.0))];
    
    [signup setupTF:signup.emailTF];
    signup.emailTF.keyboardType = UIKeyboardTypeEmailAddress;
    signup.emailTF.autocapitalizationType = UITextAutocapitalizationTypeNone;
    signup.emailTF.text = [UserDefaults.defaults stringForKey:@"UserEmailInfo"];
    
    signup.sendButton = [UIButton buttonWithType:UIButtonTypeCustom];
    
    signup.sendButton.frame = CGRectMake(0.0, (((signup.frame.size.height / numElements) * 7.0) + 8.0),
                                         (signup.frame.size.width * 0.4),
                                         (signup.frame.size.height / numElements) - 16.0);
    
    signup.sendButton.center = CGPointMake(signup.emailTF.center.x, signup.sendButton.center.y);
    [signup setupButton:signup.sendButton];
    signup.sendButton.titleLabel.font = [UIFont boldSystemFontOfSize:36.0];
    signup.sendButton.enabled = NO;
    signup.sendButton.alpha = 0.3;
    
    [signup.sendButton setTitle:@"Send"
                       forState:UIControlStateNormal];
    
    [signup.sendButton addTarget:signup
                          action:@selector(sendButtonTapped:)
                forControlEvents:UIControlEventTouchUpInside];
    
    signup.backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    
    signup.backButton.frame = CGRectMake((signup.frame.size.width * 0.25),
                                         (((signup.frame.size.height / numElements) * 7.0) + 8.0),
                                         CGRectGetMinX(signup.sendButton.frame) - (signup.frame.size.width * 0.2625),
                                         ((signup.frame.size.height / numElements) - 16.0));
    
    signup.backButton.titleLabel.font = [UIFont systemFontOfSize:22.0];
    signup.backButton.backgroundColor = UIColor.clearColor;
    signup.backButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    signup.backButton.hidden = YES;
    
    [signup.backButton setTitleColor:UIColor.blackColor
                            forState:UIControlStateNormal];
    
    [signup.backButton setTitleColor:UIColor.lightGrayColor
                            forState:UIControlStateHighlighted];
    
    [signup addSubview:signup.backButton];
    
    [signup.backButton setTitle:@"Go Back"
                       forState:UIControlStateNormal];
    
    [signup.backButton addTarget:signup
                          action:@selector(backButtonTapped:)
                forControlEvents:UIControlEventTouchUpInside];
    
    signup.checkmarkButton = [UIButton buttonWithType:UIButtonTypeCustom];
    signup.checkmarkButton.alpha = 0.3;
    
    signup.checkmarkButton.frame = CGRectMake((signup.frame.size.width * 0.0125),
                                              (((signup.frame.size.height / numElements) * 2.0) + 8.0),
                                              ((signup.frame.size.height / numElements) - 16.0),
                                              ((signup.frame.size.height / numElements) - 16.0));
    
    if ([UserDefaults.defaults boolForKey:@"AcceptedTermsOfService"])
    {
        signup.checkmarkButton.userInteractionEnabled = NO;
        
        [signup.checkmarkButton setImage:[UIImage imageWithContentsOfFile:[NSBundle.mainBundle pathForResource:@"checkedBox"
                                                                                                        ofType:@"png"]]
                                forState:UIControlStateNormal];
        
        [signup enableLabels:YES];
        
        [signup enableControl:signup.nameTF
                      enabled:YES];
        
        [signup enableControl:signup.orgTF
                      enabled:YES];
        
        [signup enableControl:signup.phoneTF
                      enabled:YES];
        
        [signup enableControl:signup.emailTF
                      enabled:YES];
        
        [signup enableControl:signup.sendButton
                      enabled:signup.nameTF.text.length && signup.orgTF.text.length && signup.phoneTF.text.length && signup.emailTF.text.length];
        
        [signup enableControl:signup.privacyButton
                      enabled:YES];
        
        signup.promptLabel.text = @"Complete this form and tap on 'Send'\nto get a NVCRIS User Number";
        [signup.nameTF becomeFirstResponder];
    }
    
    else
    {
        signup.checkmarkButton.enabled = NO;
        
        [signup.checkmarkButton setImage:[UIImage imageWithContentsOfFile:[NSBundle.mainBundle pathForResource:@"uncheckedBox"
                                                                                                        ofType:@"png"]]
                                forState:UIControlStateNormal];
        
        [signup.checkmarkButton setImage:[UIImage imageWithContentsOfFile:[NSBundle.mainBundle pathForResource:@"checkedBox"
                                                                                                        ofType:@"png"]]
                                forState:UIControlStateSelected];
        
        [signup.checkmarkButton addTarget:signup
                                   action:@selector(checkmarkTapped:)
                         forControlEvents:UIControlEventTouchUpInside];
    }
    
    [signup addSubview:signup.checkmarkButton];
    
    CGFloat termsLabelOriginX = (CGRectGetMaxX(signup.checkmarkButton.frame) + 4.0);
    
    signup.termsLabel = [[UILabel alloc] initWithFrame:CGRectMake(termsLabelOriginX, ((signup.frame.size.height / numElements) * 2.0),
                                                                  ((signup.termsButton.frame.origin.x - termsLabelOriginX) - 4.0),
                                                                  (signup.frame.size.height / numElements))];
    
    signup.termsLabel.textColor = UIColor.blackColor;
    signup.termsLabel.font = [UIFont systemFontOfSize:24.0];
    signup.termsLabel.text = @"I have read and agree to be bound by the NVCRIS Terms of Service.";
    signup.termsLabel.numberOfLines = 2;
    signup.termsLabel.alpha = 0.3;
    
    [signup addSubview:signup.termsLabel];
    
    signup.userNumberLabel = [[UILabel alloc] initWithFrame:CGRectMake((signup.frame.size.width * 0.025),
                                                                       ((signup.frame.size.height / numElements) * 8.0),
                                                                       (signup.frame.size.width * 0.225),
                                                                       (signup.frame.size.height / numElements))];
    
    [signup setupLabel:signup.userNumberLabel];
    signup.userNumberLabel.text = @"NVCRIS\nUser Number:";
    signup.userNumberLabel.numberOfLines = 2;
    
    signup.userNumberTF = [[UITextField alloc] initWithFrame:CGRectMake((signup.frame.size.width * 0.2625),
                                                                        (((signup.frame.size.height / numElements) * 8.0) + 8.0),
                                                                        (signup.frame.size.width * 0.725),
                                                                        ((signup.frame.size.height / numElements) - 16.0))];
    
    [signup setupTF:signup.userNumberTF];
    signup.userNumberTF.keyboardType = UIKeyboardTypeNumberPad;
    
    [UIView animateWithDuration:0.25
                     animations:^{
                         signup.overlayView.alpha = 0.7;
                         signup.alpha = 1.0;
                     }];
    
    return signup;
}

- (void)setupButton:(UIButton *)button
{
    button.backgroundColor = UIColor.blackColor;
    button.layer.cornerRadius = 10.0;
    button.titleLabel.textAlignment = NSTextAlignmentCenter;
    
    [button setTitleColor:UIColor.whiteColor
                 forState:UIControlStateNormal];
    
    [button setTitleColor:UIColor.lightGrayColor
                 forState:UIControlStateHighlighted];
    
    [self addSubview:button];
}

- (void)setupLabel:(UILabel *)label
{
    label.font = [UIFont systemFontOfSize:24.0];
    label.textColor = UIColor.blackColor;
    label.textAlignment = NSTextAlignmentRight;
    label.alpha = 0.3;
    
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
    tf.autocorrectionType = UITextAutocorrectionTypeNo;
    tf.delegate = self;
    tf.enabled = NO;
    tf.alpha = 0.3;
    
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
        [_userNumberTF resignFirstResponder];
        
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
        
        _checkmarkButton.userInteractionEnabled = NO;
        _checkmarkButton.alpha = 0.3;
        _termsLabel.alpha = 0.3;
        _backButton.hidden = NO;
        
        [UserDefaults.defaults saveBool:YES
                                 forKey:@"AcceptedTermsOfService"];
        
        _userNumberLabel.alpha = 1.0;
        _userNumberTF.alpha = 1.0;
        _userNumberTF.enabled = YES;
        [_userNumberTF becomeFirstResponder];
        
        [_delegate signupView:self
                didReturnName:_nameTF.text
                 organization:_orgTF.text
                        phone:_phoneTF.text
                        email:_emailTF.text];
    }
}

- (void)goBack
{
    [self backButtonTapped:nil];
}

- (void)backButtonTapped:(UIButton *)button
{
    [self makeTFLikeTF:_nameTF];
    [self makeTFLikeTF:_orgTF];
    [self makeTFLikeTF:_phoneTF];
    [self makeTFLikeTF:_emailTF];
    
    [self enableControl:_userNumberTF
                enabled:NO];
    
    _userNumberTF.text = @"";
    
    [_nameTF becomeFirstResponder];
    button.hidden = YES;
    
    _promptLabel.text = @"Complete this form and tap on 'Send'\nto get a NVCRIS User Number";
    _promptLabel.font = [UIFont systemFontOfSize:28.0];
    
    [_sendButton setTitle:@"Send"
                 forState:UIControlStateNormal];
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

- (void)makeTFLikeTF:(UITextField *)tf
{
    tf.backgroundColor = UIColor.whiteColor;
    tf.layer.borderWidth = 2.0;
    tf.userInteractionEnabled = YES;
    tf.textAlignment = NSTextAlignmentCenter;
}

- (void)privacyPolicyTapped:(UIButton *)button
{
    [self dismissKeyboard];
    
    NVWebView *nvwv = [NVWebView showWebViewInView:self.superview
                                         urlString:@"www.newvisiongis.com/gssi-privacy-policy.html"];
    
    nvwv.delegate = self;
}

- (void)termsTapped:(UIButton *)button
{
    [self dismissKeyboard];
    
    NVWebView *nvwv = [NVWebView showWebViewInView:self.superview
                                         urlString:@"www.newvisiongis.com/nvcris-terms-of-service.html"];
    
    nvwv.delegate = self;
    
    if (_checkmarkButton.userInteractionEnabled)
    {
        [self performSelector:@selector(enableCheckmark)
                   withObject:nil
                   afterDelay:1.0];
    }
}

- (void)enableCheckmark
{
    _checkmarkButton.enabled = YES;
    _checkmarkButton.alpha = 1.0;
    _termsLabel.alpha = 1.0;
    _promptLabel.text = @"To continue, tap on box to acknowledge and\nagree to the NVCRIS Terms of Service.";
}

- (void)checkmarkTapped:(UIButton *)button
{
    button.selected = !button.selected;
    
    [self enableLabels:button.selected];
    
    [self enableControl:_nameTF
                enabled:button.selected];
    
    [self enableControl:_orgTF
                enabled:button.selected];
    
    [self enableControl:_phoneTF
                enabled:button.selected];
    
    [self enableControl:_emailTF
                enabled:button.selected];
    
    [self enableControl:_sendButton
                enabled:button.selected && _nameTF.text.length && _orgTF.text.length && _phoneTF.text.length && _emailTF.text.length];
    
    [self enableControl:_privacyButton
                enabled:button.selected];
    
    if (button.selected)
    {
        _promptLabel.text = @"Complete this form and tap on 'Send'\nto get a NVCRIS User Number";
        [_nameTF becomeFirstResponder];
    }
    
    else
    {
        [self dismissKeyboard];
        _promptLabel.text = @"To continue, tap on box to acknowledge and\nagree to the NVCRIS Terms of Service.";
    }
}

- (void)enableControl:(UIControl *)control
              enabled:(BOOL)enabled
{
    control.enabled = enabled;
    
    if (enabled)
        control.alpha = 1.0;
    
    else
    {
        control.alpha = 0.3;
        
        if (control.isFirstResponder)
            [control resignFirstResponder];
    }
}

- (void)enableLabels:(BOOL)enabled
{
    if (enabled)
    {
        _nameLabel.alpha = 1.0;
        _orgLabel.alpha = 1.0;
        _phoneLabel.alpha = 1.0;
        _emailLabel.alpha = 1.0;
    }
    
    else
    {
        _nameLabel.alpha = 0.3;
        _orgLabel.alpha = 0.3;
        _phoneLabel.alpha = 0.3;
        _emailLabel.alpha = 0.3;
    }
}

- (void)dismissKeyboard
{
    for (UITextField *tfs in self.subviews)
    {
        if ([tfs isFirstResponder])
            [tfs resignFirstResponder];
    }
}

- (void)webViewDidReturn:(NVWebView *)webView
{
    if (_userNumberTF.enabled)
    {
        [webView hide:NO];
        [_userNumberTF becomeFirstResponder];
    }
    
    else if (_nameTF.enabled)
    {
        [webView hide:NO];
        [_nameTF becomeFirstResponder];
    }
    
    else
        [webView hide:YES];
}

- (BOOL)textField:(UITextField *)textField
shouldChangeCharactersInRange:(NSRange)range
replacementString:(NSString *)string
{
    NSString *testName = @"App Store Tester";
    NSString *testOrg = @"App Store";
    NSString *testPhone = @"(555) 555-5555";
    NSString *testEmail = @"test@test.com";
    NSString *testUserNumber = @"TESTER";
    
    if (textField == _phoneTF)
    {
        NSString *totalString = [NSString stringWithFormat:@"%@%@", textField.text, string];
        
        if (range.length == 1)
        {
            textField.text = [self formatPhoneNumber:totalString
                                      deleteLastChar:YES];
        }
        
        else
        {
            textField.text = [self formatPhoneNumber:totalString
                                      deleteLastChar:NO];
        }
        
        if (![textField.text isEqualToString:testPhone])
        {
            [UserDefaults.defaults saveString:textField.text
                                       forKey:@"UserPhoneInfo"];
        }
    }
    
    else
    {
        NSMutableString *tempString = [[NSMutableString alloc] initWithString:textField.text];
        NSRange tempRange = {0};
        
        if (range.length == 1)
        {
            [tempString deleteCharactersInRange:range];
            tempRange = NSMakeRange(range.location, 0);
        }
        
        else
        {
            [tempString insertString:string
                             atIndex:range.location];
            
            tempRange = NSMakeRange((range.location + 1), range.length);
        }
        
        textField.text = tempString.copy;
        
        if (textField == _nameTF)
        {
            [UserDefaults.defaults saveString:textField.text
                                       forKey:@"UserNameInfo"];
        }
        
        else if (textField == _orgTF)
        {
            [UserDefaults.defaults saveString:textField.text
                                       forKey:@"UserOrgInfo"];
        }
        
        else if (textField == _emailTF)
        {
            [UserDefaults.defaults saveString:textField.text
                                       forKey:@"UserEmailInfo"];
        }
        
        UITextPosition *start = [textField positionFromPosition:textField.beginningOfDocument
                                                         offset:tempRange.location];
        
        UITextPosition *end = [textField positionFromPosition:start
                                                       offset:tempRange.length];
        
        [textField setSelectedTextRange:[textField textRangeFromPosition:start
                                                              toPosition:end]];
    }
    
    BOOL testEmailEntered = [_emailTF.text isEqualToString:testEmail];
    
    [self enableControl:_sendButton
                enabled:((_nameTF.text.length && _orgTF.text.length && _phoneTF.text.length
                          && _emailTF.text.length) || testEmailEntered)];
    
    if (testEmailEntered)
    {
        [_sendButton setTitle:@"Continue"
                     forState:UIControlStateNormal];
        
        
        
        _nameTF.text = testName;
        _orgTF.text = testOrg;
        _phoneTF.text = testPhone;
        _userNumberTF.text = testUserNumber;
        
        [UserDefaults.defaults saveString:@""
                                   forKey:@"UserPhoneInfo"];
        
        [UserDefaults.defaults saveString:@""
                                   forKey:@"UserNameInfo"];
        
        [UserDefaults.defaults saveString:@""
                                   forKey:@"UserOrgInfo"];
        
        [UserDefaults.defaults saveString:@""
                                   forKey:@"UserEmailInfo"];
    }
    
    else
    {
        _nameTF.text = [UserDefaults.defaults stringForKey:@"UserNameInfo"];
        _orgTF.text = [UserDefaults.defaults stringForKey:@"UserOrgInfo"];
        _phoneTF.text = [UserDefaults.defaults stringForKey:@"UserPhoneInfo"];
        _emailTF.text = [UserDefaults.defaults stringForKey:@"UserEmailInfo"];
        _userNumberTF.text = @"";
        
        [_sendButton setTitle:@"Send"
                     forState:UIControlStateNormal];
    }
    
    [self enableControl:_sendButton
                enabled:((_nameTF.text.length && _orgTF.text.length && _phoneTF.text.length
                          && _emailTF.text.length) || testEmailEntered)];
    
    return NO;
}



- (BOOL)textFieldShouldClear:(UITextField *)textField
{
    textField.text = @"";
    
    if (textField == _nameTF)
    {
        [UserDefaults.defaults saveString:textField.text
                                   forKey:@"UserNameInfo"];
    }
    
    else if (textField == _orgTF)
    {
        [UserDefaults.defaults saveString:textField.text
                                   forKey:@"UserOrgInfo"];
    }
    
    else if (textField == _phoneTF)
    {
        [UserDefaults.defaults saveString:textField.text
                                   forKey:@"UserPhoneInfo"];
    }
    
    else if (textField == _emailTF)
    {
        [UserDefaults.defaults saveString:textField.text
                                   forKey:@"UserEmailInfo"];
    }
    
    [self enableControl:_sendButton
                enabled:_nameTF.text.length && _orgTF.text.length && _phoneTF.text.length && _emailTF.text.length];
    
    return NO;
}

- (NSString *)formatPhoneNumber:(NSString *)simpleNumber
                 deleteLastChar:(BOOL)deleteLastChar
{
    if (simpleNumber.length == 0)
        return @"";
    
    NSError *error = nil;
    
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"[\\s-\\(\\)]"
                                                                           options:NSRegularExpressionCaseInsensitive
                                                                             error:&error];
    
    simpleNumber = [regex stringByReplacingMatchesInString:simpleNumber
                                                   options:0
                                                     range:NSMakeRange(0, simpleNumber.length)
                                              withTemplate:@""];
    
    if (simpleNumber.length > 10)
        simpleNumber = [simpleNumber substringToIndex:10];
    
    if (deleteLastChar)
        simpleNumber = [simpleNumber substringToIndex:(simpleNumber.length - 1)];
    
    if (simpleNumber.length < 7)
    {
        simpleNumber = [simpleNumber stringByReplacingOccurrencesOfString:@"(\\d{3})(\\d+)"
                                                               withString:@"($1) $2"
                                                                  options:NSRegularExpressionSearch
                                                                    range:NSMakeRange(0, simpleNumber.length)];
    }
    
    else
    {
        simpleNumber = [simpleNumber stringByReplacingOccurrencesOfString:@"(\\d{3})(\\d{3})(\\d+)"
                                                               withString:@"($1) $2-$3"
                                                                  options:NSRegularExpressionSearch
                                                                    range:NSMakeRange(0, simpleNumber.length)];
    }
    
    return simpleNumber;
}

- (void)presentKeyboard
{
    [_userNumberTF becomeFirstResponder];
}

@end