//  RHClipEditor.m
//  CCodeLibrary

#import "RHClipEditor.h"
#import "NVSpreadsheetVC.h"
#import "UserDefaults.h"

@interface RHClipEditor () <UITextFieldDelegate,NVAlertViewDelegate,UITextViewDelegate>

@property (nonatomic, weak) id<NVSpreadsheetVCDelegate> delegate;
@property (nonatomic, weak) id<RHClipEditorDelegate> presenterDelegate;
@property (nonatomic) RHClip *currentClip;
@property (nonatomic) UIButton *returnButton, *qualityButton, *dismissKeyboardButton;
@property (nonatomic) UILabel *titleLabel, *qualityLabel, *costLabel, *notesLabel;
@property (nonatomic) UITextField *titleTF, *costTF;
@property (nonatomic) UITextView *notesTV;
@property CGFloat margin;

@end

@implementation RHClipEditor

+ (instancetype)editorWithClip:(RHClip *)clip
                      delegate:(id)delegate
             presenterDelegate:(id)presenterDelegate
{
    RHClipEditor *editor = RHClipEditor.new;
    editor.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    editor.delegate = delegate;
    editor.presenterDelegate = presenterDelegate;
    editor.currentClip = clip;
    return editor;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [NSNotificationCenter.defaultCenter addObserver:self
                                           selector:@selector(keyboardWillShow:)
                                               name:UIKeyboardWillShowNotification
                                             object:nil];
    
    [NSNotificationCenter.defaultCenter addObserver:self
                                           selector:@selector(keyboardWillHide:)
                                               name:UIKeyboardWillHideNotification
                                             object:nil];
    
    self.view.backgroundColor = UserDefaults.defaults.appleBlue;
    CGFloat bigFont = 28.0, littleFont = 24.0;
    _margin = 10.0;
    
    _returnButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _returnButton.translatesAutoresizingMaskIntoConstraints = NO;
    _returnButton.backgroundColor = UIColor.clearColor;
    [_returnButton setTitle:@"< Return" forState:UIControlStateNormal];
    [_returnButton setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    [_returnButton setTitleColor:UIColor.lightGrayColor forState:UIControlStateHighlighted];
    _returnButton.titleLabel.font = [UIFont boldSystemFontOfSize:36.0];
    [self.view addSubview:_returnButton];
    [_returnButton constrainLeadingToAnchor:self.view.leadingAnchor constant:_margin];
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
    [_titleLabel constrainTopToAnchor:_returnButton.bottomAnchor constant:_margin];
    
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
    [_titleTF constrainTrailingToAnchor:self.view.trailingAnchor constant:-_margin];
    [_titleTF constrainTopToAnchor:_titleLabel.bottomAnchor constant:(_margin * 0.5)];
    [_titleTF constrainHeightToConstant:(bigFont * 1.5)];
    
    _qualityLabel = UILabel.new;
    _qualityLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _qualityLabel.textColor = UIColor.blackColor;
    _qualityLabel.text = @"Quality";
    _qualityLabel.font = [UIFont boldSystemFontOfSize:littleFont];
    
    [self.view addSubview:_qualityLabel];
    [_qualityLabel constrainLeadingToAnchor:_returnButton.leadingAnchor];
    [_qualityLabel constrainTopToAnchor:_titleTF.bottomAnchor constant:(_margin * 2.0)];
    
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
    [_qualityButton constrainTopToAnchor:_qualityLabel.bottomAnchor constant:(_margin * 0.5)];
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
    [_costLabel constrainTopToAnchor:_qualityButton.bottomAnchor constant:(_margin * 2.0)];
    
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
    [_costTF constrainTopToAnchor:_costLabel.bottomAnchor constant:(_margin * 0.5)];
    [_costTF constrainHeightToConstant:(bigFont * 1.5)];
    
    _notesLabel = UILabel.new;
    _notesLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _notesLabel.textColor = UIColor.blackColor;
    _notesLabel.text = @"Notes";
    _notesLabel.font = [UIFont boldSystemFontOfSize:littleFont];
    
    [self.view addSubview:_notesLabel];
    [_notesLabel constrainLeadingToAnchor:_returnButton.leadingAnchor];
    [_notesLabel constrainTopToAnchor:_costTF.bottomAnchor constant:(_margin * 2.0)];
    
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
    [_notesTV constrainTopToAnchor:_notesLabel.bottomAnchor constant:(_margin * 0.5)];
    [_notesTV constrainBottomToAnchor:self.view.bottomAnchor constant:-_margin];
    
    _dismissKeyboardButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _dismissKeyboardButton.translatesAutoresizingMaskIntoConstraints = NO;
    _dismissKeyboardButton.backgroundColor = UIColor.clearColor;
    [_dismissKeyboardButton setTitle:@"Dismiss Keyboard" forState:UIControlStateNormal];
    [_dismissKeyboardButton setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    [_dismissKeyboardButton setTitleColor:UIColor.lightGrayColor forState:UIControlStateHighlighted];
    _dismissKeyboardButton.titleLabel.font = [UIFont boldSystemFontOfSize:36.0];
    
    [_dismissKeyboardButton addTarget:self
                               action:@selector(dismissKeyboardButtonTapped)
                     forControlEvents:UIControlEventTouchUpInside];
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
    if (_delegate && [_delegate respondsToSelector:@selector(addVideoClip:)])
        [_delegate addVideoClip:_currentClip];
    
    if (_presenterDelegate && [_presenterDelegate respondsToSelector:@selector(clipEditorDidReturn:)])
        [_presenterDelegate clipEditorDidReturn:self];
}

- (void)qualityButtonTapped
{
    [NVAlertView showLargeAlertViewinView:self.view
                                 delegate:self
                                    title:@"Select Quality for this Clip"
                          buttonTextArray:@[@"Pro", @"Con", @"Neutral"]
                         destructiveIndex:0];
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

- (BOOL)textField:(UITextField *)textField
shouldChangeCharactersInRange:(NSRange)range
replacementString:(NSString *)string
{
    if (textField == _costTF)
    {
        NSMutableCharacterSet *decimalChars = NSMutableCharacterSet.decimalDigitCharacterSet;
        [decimalChars addCharactersInString:@"."];
        NSCharacterSet *stringSet = [NSCharacterSet characterSetWithCharactersInString:string];
        
        return ([decimalChars isSupersetOfSet:stringSet]);
    }
    
    else
        return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == _titleTF)
        _currentClip.title = textField.text;
    
    else if (textField == _costTF)
    {
        NSString *cost = [_costTF.text stringByReplacingOccurrencesOfString:@"$" withString:@""];
        
        if (cost.length)
        {
            NSMutableCharacterSet *decimalChars = NSMutableCharacterSet.decimalDigitCharacterSet;
            [decimalChars addCharactersInString:@"."];
            NSCharacterSet *notDecimalChars = decimalChars.invertedSet;
            
            if ([cost rangeOfCharacterFromSet:notDecimalChars].location == NSNotFound)
            {
                _currentClip.cost = cost.doubleValue;
                _costTF.text = [NSString stringWithFormat:@"$%.2f", _currentClip.cost];
            }
        }
    }
    
    [textField resignFirstResponder];
    return NO;
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    _currentClip.notes = textView.text;
}

- (void)keyboardWillShow:(NSNotification *)notification
{
    [UIView animateWithDuration:0.25
                     animations:^{
                         _returnButton.alpha = 0.0;
                         _returnButton.alpha = 0.0;
                     }];
    
    if (_titleTF.isFirstResponder)
    {
        [UIView animateWithDuration:0.25
                         animations:^{
                             _qualityLabel.alpha = 0.0;
                             _qualityButton.alpha = 0.0;
                             _costLabel.alpha = 0.0;
                             _costTF.alpha = 0.0;
                             _notesLabel.alpha = 0.0;
                             _notesTV.alpha = 0.0;
                         }];
    }
    
    else if (_costTF.isFirstResponder)
    {
        [UIView animateWithDuration:0.25
                         animations:^{
                             _titleLabel.alpha = 0.0;
                             _titleTF.alpha = 0.0;
                             _qualityLabel.alpha = 0.0;
                             _qualityButton.alpha = 0.0;
                             _notesLabel.alpha = 0.0;
                             _notesTV.alpha = 0.0;
                         }];
    }
    
    else if (_notesTV.isFirstResponder)
    {
        if (UIDevice.currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPhone)
        {
            _titleLabel.alpha = 0.0;
            _titleTF.alpha = 0.0;
            _qualityLabel.alpha = 0.0;
            _qualityButton.alpha = 0.0;
            _costLabel.alpha = 0.0;
            _costTF.alpha = 0.0;
            
            [_notesLabel removeAllConstraints];
            [_notesTV removeAllConstraints];
            
            [_notesLabel constrainLeadingToAnchor:_returnButton.leadingAnchor];
            [_notesLabel constrainBottomToAnchor:_returnButton.bottomAnchor];
            CGSize size = _notesLabel.frame.size;
            [_notesLabel constrainWidthToConstant:size.width];
            [_notesLabel constrainHeightToConstant:size.height];
            [_notesTV constrainLeadingToAnchor:_returnButton.leadingAnchor];
            [_notesTV constrainTrailingToAnchor:_titleTF.trailingAnchor];
            [_notesTV constrainTopToAnchor:_notesLabel.bottomAnchor constant:(_margin * 0.5)];
            CGFloat height = _notesTV.frame.size.height;
            [_notesTV constrainHeightToConstant:height];
            
            [self.view addSubview:_dismissKeyboardButton];
            [_dismissKeyboardButton constrainTopToAnchor:_notesTV.bottomAnchor constant:_margin];
            [_dismissKeyboardButton constrainCenterXToAnchor:self.view.centerXAnchor];
        }
        
        else
        {
            [UIView animateWithDuration:0.25
                             animations:^{
                                 _titleLabel.alpha = 0.0;
                                 _titleTF.alpha = 0.0;
                                 _qualityLabel.alpha = 0.0;
                                 _qualityButton.alpha = 0.0;
                                 _costLabel.alpha = 0.0;
                                 _costTF.alpha = 0.0;
                             }];
        }
    }
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    [UIView animateWithDuration:0.25
                     animations:^{
                         for (UIView *subviews in self.view.subviews)
                             subviews.alpha = 1.0;
                     }];
}

- (void)dismissKeyboardButtonTapped
{
    if (_notesTV.isFirstResponder)
    {
        [_notesTV resignFirstResponder];
        [_dismissKeyboardButton removeFromSuperview];
        
        CGSize size = _notesLabel.frame.size;
        [_notesLabel removeAllConstraints];
        [_notesTV removeAllConstraints];
        
        [_notesLabel constrainLeadingToAnchor:_returnButton.leadingAnchor];
        [_notesLabel constrainTopToAnchor:_costTF.bottomAnchor constant:(_margin * 2.0)];
        [_notesLabel constrainWidthToConstant:size.width];
        [_notesLabel constrainHeightToConstant:size.height];
        [_notesTV constrainLeadingToAnchor:_returnButton.leadingAnchor];
        [_notesTV constrainTrailingToAnchor:_titleTF.trailingAnchor];
        [_notesTV constrainTopToAnchor:_notesLabel.bottomAnchor constant:(_margin * 0.5)];
        [_notesTV constrainBottomToAnchor:self.view.bottomAnchor constant:-_margin];
    }
}

@end
