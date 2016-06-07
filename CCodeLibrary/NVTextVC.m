//  NVTextVC.m
//  CCodeLibrary

#import "NVTextVC.h"
#import "UserDefaults.h"

@interface NVTextVC ()

@property (nonatomic, copy) NSString *text;
@property (nonatomic) UIButton *returnButton;
@property (nonatomic) UITextView *textView;
@property (nonatomic) CGFloat margin, fontSize;
@property (nonatomic) UIFont *font;
@property (nonatomic) UIScrollView *scrollView;

@end

@implementation NVTextVC

- (id)initWithText:(NSString *)text
          fontSize:(CGFloat)fontSize
{
    self = [super init];
    
    if (self)
    {
        _text = text;
        _fontSize = fontSize;
        _zoomingEnabled = YES;
        _minFontSize = (_fontSize / 2.0);
        _maxFontSize = (_fontSize * 2.0);
        _clampTextViewToText = YES;
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
    _scrollView = [[UIScrollView alloc] init];
    _scrollView.translatesAutoresizingMaskIntoConstraints = NO;
    _scrollView.layer.borderColor = UIColor.blackColor.CGColor;
    _scrollView.layer.borderWidth = 2.0;
    _scrollView.directionalLockEnabled = YES;
    _scrollView.backgroundColor = UIColor.darkGrayColor;
    
    [self.view addSubview:_scrollView];
    
    [_scrollView.topAnchor constraintEqualToAnchor:_returnButton.bottomAnchor
                                          constant:(_margin / 2.0)].active = YES;
    
    [_scrollView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor
                                              constant:_margin].active = YES;
    
    [_scrollView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor
                                               constant:-_margin].active = YES;
    
    [_scrollView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor
                                             constant:-_margin].active = YES;
    
    [self.view layoutSubviews];
    
    UIFont *font = [UIFont fontWithName:@"CourierNewPS-BoldMT"
                                   size:_fontSize];
    
    _text = [_text stringByReplacingOccurrencesOfString:@"\t"
                                             withString:@"    "];
    
    CGSize textSize = sizeOfString(_text, font);
    
    if (!_clampTextViewToText)
    {
        textSize.height = MAX(_scrollView.frame.size.height, textSize.height);
        textSize.width = MAX(_scrollView.frame.size.width, textSize.width);
    }
    
    _scrollView.contentSize = textSize;
    
    _textView = [[UITextView alloc] initWithFrame:CGRectMake(0.0, 0.0, textSize.width, textSize.height)];
    _textView.text = _text;
    _textView.font = font;
    _textView.editable = NO;
    _textView.scrollEnabled = NO;
    
    [_scrollView addSubview:_textView];
    
    if (_zoomingEnabled)
    {
        UIPinchGestureRecognizer *pinch = [[UIPinchGestureRecognizer alloc] initWithTarget:self
                                                                                    action:@selector(textWasPinched:)];
        
        [_textView addGestureRecognizer:pinch];
    }
}

- (void)textWasPinched:(UIPinchGestureRecognizer *)gesture
{
    _fontSize = floorf(((_fontSize * gesture.scale) * 10.0) + 0.5) / 10.0;
    _fontSize = MIN(_fontSize, _maxFontSize);
    _fontSize = MAX(_fontSize, _minFontSize);
    
    UIFont *font = [UIFont fontWithName:@"CourierNewPS-BoldMT"
                                   size:_fontSize];
    
    if (font != _textView.font)
    {
        CGSize textSize = sizeOfString(_text, font);
        
        if (!_clampTextViewToText)
        {
            textSize.height = MAX(_scrollView.frame.size.height, textSize.height);
            textSize.width = MAX(_scrollView.frame.size.width, textSize.width);
        }
        
        _scrollView.contentSize = textSize;
        
        _textView.frame = CGRectMake(0.0, 0.0, textSize.width, textSize.height);
        _textView.font = font;
        
        gesture.scale = 1.0;
    }
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
    CGFloat stringWidth = (longestLine * (font.pointSize * 0.6));
    
    return CGSizeMake(stringWidth, stringHeight);
}

@end