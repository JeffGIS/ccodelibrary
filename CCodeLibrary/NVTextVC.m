//  NVTextVC.m
//  CCodeLibrary

#import "NVTextVC.h"
#import "UserDefaults.h"

@interface NVTextVC ()

@property (nonatomic) NSString *text;
@property (nonatomic) UIButton *returnButton;
@property (nonatomic) UITextView *textView;
@property (nonatomic) CGFloat margin;
@property (nonatomic) UIFont *font;

@end

@implementation NVTextVC

- (id)initWithText:(NSString *)text
{
    self = [super init];
    
    if (self)
    {
        _text = text;
    }
    
    return self;
}

- (void)loadView
{
    UIView *view = [[UIView alloc] initWithFrame:UIScreen.mainScreen.bounds];
    self.view = view;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = UserDefaults.defaults.appleBlue;
    
    if (UIDevice.currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPhone)
    {
        _font = [UIFont boldSystemFontOfSize:24.0];
        _margin = 8.0;
    }
    
    else
    {
        _font = [UIFont boldSystemFontOfSize:32.0];
        _margin = 20.0;
    }
    
    [self setupReturnButton];
    [self setupTextView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)setupReturnButton
{
    _returnButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _returnButton.translatesAutoresizingMaskIntoConstraints = NO;
    _returnButton.backgroundColor = UIColor.clearColor;
    _returnButton.titleLabel.font = _font;
    _returnButton.titleLabel.textAlignment = NSTextAlignmentLeft;
    _returnButton.titleLabel.adjustsFontSizeToFitWidth = YES;
    _returnButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    
    [_returnButton setTitle:@"< Return"
                   forState:UIControlStateNormal];
    
    [_returnButton setTitleColor:UIColor.whiteColor
                        forState:UIControlStateNormal];
    
    [_returnButton setTitleColor:UIColor.lightGrayColor
                        forState:UIControlStateHighlighted];
    
    [_returnButton addTarget:self
                      action:@selector(dismiss:)
            forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:_returnButton];
    
    [_returnButton.topAnchor constraintEqualToAnchor:self.view.topAnchor
                                            constant:(_margin / 2.0)].active = YES;
    
    [_returnButton.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor
                                                constant:_margin].active = YES;
    
    [_returnButton.heightAnchor constraintEqualToConstant:40.0].active = YES;
}

- (void)setupTextView
{
    _textView = [[UITextView alloc] init];
    _textView.translatesAutoresizingMaskIntoConstraints = NO;
    _textView.text = _text;
    _textView.layer.borderColor = UIColor.blackColor.CGColor;
    _textView.layer.borderWidth = 2.0;
    _textView.editable = NO;
    
    _textView.font = [UIFont fontWithName:@"CourierNewPS-BoldMT"
                                     size:16.0];
    
    [self.view addSubview:_textView];
    
    [_textView.topAnchor constraintEqualToAnchor:_returnButton.bottomAnchor
                                        constant:(_margin / 2.0)].active = YES;
    
    [_textView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor
                                            constant:_margin].active = YES;
    
    [_textView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor
                                             constant:-_margin].active = YES;
    
    [_textView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor
                                           constant:-_margin].active = YES;
}

- (void)dismiss:(UIButton *)button
{
    [self dismissViewControllerAnimated:YES
                             completion:nil];
}

@end