//  NVCRISSignupView.m
//  CCodeLibrary

#import "NVCRISSignupView.h"
#import "UserDefaults.h"

@interface NVCRISSignupView () <UITextViewDelegate>

@property (nonatomic, weak) id <NVCRISSignupViewDelegate> delegate;
@property (nonatomic) UIView *overlayView;
@property (nonatomic) UILabel *titleLabel, *nameLabel, *orgLabel, *phoneLabel, *emailLabel, *userNumberLabel;
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
    
    signup.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, signup.frame.size.width,
                                                                  (signup.frame.size.height / 7.0))];
    
    signup.titleLabel.text = @"NVCRIS Signup Screen";
    signup.titleLabel.font = [UIFont boldSystemFontOfSize:32.0];
    signup.titleLabel.textColor = UIColor.blackColor;
    signup.titleLabel.textAlignment = NSTextAlignmentCenter;
    
    [signup addSubview:signup.titleLabel];
    
    signup.nameLabel = [[UILabel alloc] initWithFrame:CGRectMake((signup.frame.size.width * 0.025), (signup.frame.size.height / 7.0),
                                                                 (signup.frame.size.width * 0.225), signup.frame.size.height / 7.0)];
    
    [signup setupLabel:signup.nameLabel];
    signup.nameLabel.text = @"Name:";
    
    signup.nameTF = [[UITextField alloc] initWithFrame:CGRectMake((signup.frame.size.width * 0.2625), ((signup.frame.size.height / 7.0) + 8.0),
                                                                  (signup.frame.size.width * 0.725), (signup.frame.size.height / 7.0) - 16.0)];
    
    [signup setupTF:signup.nameTF];
    [signup.nameTF becomeFirstResponder];
    
    signup.orgLabel = [[UILabel alloc] initWithFrame:CGRectMake((signup.frame.size.width * 0.025), ((signup.frame.size.height / 7.0) * 2.0),
                                                                (signup.frame.size.width * 0.225), signup.frame.size.height / 7.0)];
    
    [signup setupLabel:signup.orgLabel];
    signup.orgLabel.text = @"Organization:";
    
    signup.orgTF = [[UITextField alloc] initWithFrame:CGRectMake((signup.frame.size.width * 0.2625), (((signup.frame.size.height / 7.0) * 2.0) + 8.0),
                                                                 (signup.frame.size.width * 0.725), (signup.frame.size.height / 7.0) - 16.0)];
    
    [signup setupTF:signup.orgTF];
    
    signup.phoneLabel = [[UILabel alloc] initWithFrame:CGRectMake((signup.frame.size.width * 0.025), ((signup.frame.size.height / 7.0) * 3.0),
                                                                  (signup.frame.size.width * 0.225), signup.frame.size.height / 7.0)];
    
    [signup setupLabel:signup.phoneLabel];
    signup.phoneLabel.text = @"Phone:";
    
    signup.phoneTF = [[UITextField alloc] initWithFrame:CGRectMake((signup.frame.size.width * 0.2625), (((signup.frame.size.height / 7.0) * 3.0) + 8.0),
                                                                   (signup.frame.size.width * 0.725), (signup.frame.size.height / 7.0) - 16.0)];
    
    [signup setupTF:signup.phoneTF];
    signup.phoneTF.keyboardType = UIKeyboardTypeNumberPad;
    
    [UIView animateWithDuration:0.25
                     animations:^{
                         signup.overlayView.alpha = 0.7;
                         signup.alpha = 1.0;
                     }];
    
    return signup;
}

- (void)setupLabel:(UILabel *)label
{
    label.font = [UIFont boldSystemFontOfSize:24.0];
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
    tf.font = [UIFont boldSystemFontOfSize:32.0];
    tf.textAlignment = NSTextAlignmentCenter;
    
    [self addSubview:tf];
}

@end