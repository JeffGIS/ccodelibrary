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
@property (nonatomic) UIScrollView *scrollView;

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
    UIFont *font = [UIFont fontWithName:@"CourierNewPS-BoldMT"
                                   size:16.0];
    
    _text = [_text stringByReplacingOccurrencesOfString:@"\t"
                                             withString:@"    "];
    
    CGSize textSize = sizeOfString(_text, font);
    
    _textView = [[UITextView alloc] initWithFrame:CGRectMake(0.0, 0.0, textSize.width, textSize.height)];
    _textView.text = _text;
    _textView.font = font;
    _textView.editable = NO;
    _textView.scrollEnabled = NO;

    _scrollView = [[UIScrollView alloc] init];
    _scrollView.translatesAutoresizingMaskIntoConstraints = NO;
    _scrollView.layer.borderColor = UIColor.blackColor.CGColor;
    _scrollView.layer.borderWidth = 2.0;
    _scrollView.contentSize = textSize;
    _scrollView.directionalLockEnabled = YES;
    
    [self.view addSubview:_scrollView];
    
    [_scrollView.topAnchor constraintEqualToAnchor:_returnButton.bottomAnchor
                                          constant:(_margin / 2.0)].active = YES;
    
    [_scrollView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor
                                              constant:_margin].active = YES;
    
    [_scrollView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor
                                               constant:-_margin].active = YES;
    
    [_scrollView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor
                                             constant:-_margin].active = YES;
    
    [_scrollView addSubview:_textView];
}

- (void)dismiss:(UIButton *)button
{
    [self dismissViewControllerAnimated:YES
                             completion:nil];
}

CGSize sizeOfString(NSString *string, UIFont *font)
{
    NSUInteger numLines, index, longestLine, stringLength = string.length;
    
    for (index = 0, numLines = 0, longestLine = 0; index < stringLength; numLines++)
    {
        NSUInteger oldIndex = index;
        index = NSMaxRange([string lineRangeForRange:NSMakeRange(index, 0)]);
        longestLine = MAX(longestLine, (index - oldIndex));
    }
    
    CGFloat stringHeight = (font.lineHeight * numLines);
    CGFloat stringWidth = (longestLine * 10.0);
    
    return CGSizeMake(stringWidth, stringHeight);
}

@end