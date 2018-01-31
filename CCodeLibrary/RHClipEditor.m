//  RHClipEditor.m
//  CCodeLibrary

#import "RHClipEditor.h"
#import "NVSpreadsheetVC.h"
#import "UserDefaults.h"

@interface RHClipEditor () <UITextFieldDelegate,NVAlertViewDelegate,UITextViewDelegate>

@property (nonatomic, weak) id<NVSpreadsheetVCDelegate> delegate;
@property (nonatomic) RHClip *currentClip;
@property (nonatomic) UIButton *returnButton, *qualityButton;
@property (nonatomic) UILabel *titleLabel, *qualityLabel, *costLabel, *notesLabel;
@property (nonatomic) UITextField *titleTF, *costTF;
@property (nonatomic) UITextView *notesTV;

@end

@implementation RHClipEditor

+ (instancetype)editorWithClip:(RHClip *)clip
                      delegate:(id)delegate
{
    RHClipEditor *editor = RHClipEditor.new;
    editor.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    editor.delegate = delegate;
    editor.currentClip = clip;
    return editor;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = UserDefaults.defaults.appleBlue;
    CGFloat bigFont = 28.0, littleFont = 24.0, margin = 10.0;
    
    _returnButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _returnButton.translatesAutoresizingMaskIntoConstraints = NO;
    _returnButton.backgroundColor = UIColor.clearColor;
    [_returnButton setTitle:@"< Return" forState:UIControlStateNormal];
    [_returnButton setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    [_returnButton setTitleColor:UIColor.lightGrayColor forState:UIControlStateHighlighted];
    _returnButton.titleLabel.font = [UIFont boldSystemFontOfSize:36.0];
    [self.view addSubview:_returnButton];
    [_returnButton constrainLeadingToAnchor:self.view.leadingAnchor constant:margin];
    [_returnButton constrainTopToAnchor:self.view.topAnchor];
    
    [_returnButton addTarget:self
                      action:@selector(returnButtonTapped)
            forControlEvents:UIControlEventTouchUpInside];
    
    _titleLabel = UILabel.new;
    _titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _titleLabel.textColor = UIColor.blackColor;
    _titleLabel.text = @"Title";
    _titleLabel.font = [UIFont boldSystemFontOfSize:littleFont];
    
    [self.view addSubview:_titleLabel];
    [_titleLabel constrainLeadingToAnchor:_returnButton.leadingAnchor];
    [_titleLabel constrainTopToAnchor:_returnButton.bottomAnchor constant:margin];
    
    _titleTF = UITextField.new;
    _titleTF.translatesAutoresizingMaskIntoConstraints = NO;
    _titleTF.delegate = self;
    _titleTF.text = _currentClip.title;
    _titleTF.textAlignment = NSTextAlignmentCenter;
    _titleTF.textColor = UIColor.blackColor;
    _titleTF.placeholder = @"Enter Title Here";
    _titleTF.backgroundColor = UIColor.whiteColor;
    _titleTF.font = [UIFont boldSystemFontOfSize:bigFont];
    
    [self.view addSubview:_titleTF];
    [_titleTF constrainLeadingToAnchor:_returnButton.leadingAnchor];
    [_titleTF constrainTrailingToAnchor:self.view.trailingAnchor constant:-margin];
    [_titleTF constrainTopToAnchor:_titleLabel.bottomAnchor constant:(margin * 0.5)];
    [_titleTF constrainHeightToConstant:(bigFont * 1.5)];
    
    _qualityLabel = UILabel.new;
    _qualityLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _qualityLabel.textColor = UIColor.blackColor;
    _qualityLabel.text = @"Quality";
    _qualityLabel.font = [UIFont boldSystemFontOfSize:littleFont];
    
    [self.view addSubview:_qualityLabel];
    [_qualityLabel constrainLeadingToAnchor:_returnButton.leadingAnchor];
    [_qualityLabel constrainTopToAnchor:_titleTF.bottomAnchor constant:(margin * 2.0)];
    
    _qualityButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _qualityButton.translatesAutoresizingMaskIntoConstraints = NO;
    _qualityButton.backgroundColor = UIColor.whiteColor;
    [_qualityButton setTitleColor:UIColor.lightGrayColor forState:UIControlStateHighlighted];
    _qualityButton.titleLabel.font = [UIFont boldSystemFontOfSize:bigFont];
    _qualityButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    [self updateQualityButtonText];
    
    [self.view addSubview:_qualityButton];
    [_qualityButton constrainLeadingToAnchor:_returnButton.leadingAnchor];
    [_qualityButton constrainTrailingToAnchor:_titleTF.trailingAnchor];
    [_qualityButton constrainTopToAnchor:_qualityLabel.bottomAnchor constant:(margin * 0.5)];
    [_qualityButton constrainHeightToAnchor:_titleTF.heightAnchor];
    
    [_qualityButton addTarget:self
                      action:@selector(qualityButtonTapped)
            forControlEvents:UIControlEventTouchUpInside];
    
    _costLabel = UILabel.new;
    _costLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _costLabel.textColor = UIColor.blackColor;
    _costLabel.text = @"Cost";
    _costLabel.font = [UIFont boldSystemFontOfSize:littleFont];
    
    [self.view addSubview:_costLabel];
    [_costLabel constrainLeadingToAnchor:_returnButton.leadingAnchor];
    [_costLabel constrainTopToAnchor:_qualityButton.bottomAnchor constant:(margin * 2.0)];
    
    _costTF = UITextField.new;
    _costTF.translatesAutoresizingMaskIntoConstraints = NO;
    _costTF.delegate = self;
    _costTF.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
    _costTF.text = [NSString stringWithFormat:@"$%.2f", _currentClip.cost];
    _costTF.textAlignment = NSTextAlignmentCenter;
    _costTF.textColor = UIColor.blackColor;
    _costTF.placeholder = @"Enter Cost Here";
    _costTF.backgroundColor = UIColor.whiteColor;
    _costTF.font = [UIFont boldSystemFontOfSize:bigFont];
    
    [self.view addSubview:_costTF];
    [_costTF constrainLeadingToAnchor:_returnButton.leadingAnchor];
    [_costTF constrainTrailingToAnchor:_titleTF.trailingAnchor];
    [_costTF constrainTopToAnchor:_costLabel.bottomAnchor constant:(margin * 0.5)];
    [_costTF constrainHeightToConstant:(bigFont * 1.5)];
    
    _notesLabel = UILabel.new;
    _notesLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _notesLabel.textColor = UIColor.blackColor;
    _notesLabel.text = @"Notes";
    _notesLabel.font = [UIFont boldSystemFontOfSize:littleFont];
    
    [self.view addSubview:_notesLabel];
    [_notesLabel constrainLeadingToAnchor:_returnButton.leadingAnchor];
    [_notesLabel constrainTopToAnchor:_costTF.bottomAnchor constant:(margin * 2.0)];
    
    _notesTV = UITextView.new;
    _notesTV.translatesAutoresizingMaskIntoConstraints = NO;
    _notesTV.delegate = self;
    _notesTV.text = _currentClip.notes;
    _notesTV.textColor = UIColor.blackColor;
    _notesTV.backgroundColor = UIColor.whiteColor;
    _notesTV.font = [UIFont boldSystemFontOfSize:bigFont];
    
    [self.view addSubview:_notesTV];
    [_notesTV constrainLeadingToAnchor:_returnButton.leadingAnchor];
    [_notesTV constrainTrailingToAnchor:_titleTF.trailingAnchor];
    [_notesTV constrainTopToAnchor:_notesLabel.bottomAnchor constant:(margin * 0.5)];
    [_notesTV constrainBottomToAnchor:self.view.bottomAnchor constant:-margin];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)returnButtonTapped
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)qualityButtonTapped
{
    NVAlertView *alert = [NVAlertView showLargeAlertViewinView:self.view
                                                      delegate:self
                                                         title:@"Select Quality for this Clip"
                                               buttonTextArray:@[@"Pro", @"Con", @"Neutral"]
                                              destructiveIndex:0];
#pragma unused(alert)
}

- (void)alertView:(NVAlertView *)alertView
didTapButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex)
    {
        case 0://pro
            _currentClip.quality = RHClipQualityPro;
            break;
        case 1://con
            _currentClip.quality = RHClipQualityCon;
            break;
        case 2://neutral
            _currentClip.quality = RHClipQualityNeutral;
            break;
        default:break;
    }
    
    [self updateQualityButtonText];
    [alertView hideLargeAlertView:YES];
}

- (void)updateQualityButtonText
{
    [_qualityButton setTitle:[RHClip stringForQuality:_currentClip.quality]
                    forState:UIControlStateNormal];
    
    [_qualityButton setTitleColor:[RHClip colorForQuality:_currentClip.quality]
                         forState:UIControlStateNormal];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == _titleTF)
        _currentClip.title = textField.text;
    
    [textField resignFirstResponder];
    return NO;
}

@end
