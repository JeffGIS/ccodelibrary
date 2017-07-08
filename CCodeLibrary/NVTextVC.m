//  NVTextVC.m
//  CCodeLibrary

#import "NVTextVC.h"
#import "UserDefaults.h"

@interface NVTextVC ()

@property (nonatomic, copy) NSString *text;
@property (nonatomic) UIButton *returnButton, *searchButton;
@property (nonatomic) UITextView *textView;
@property (nonatomic) CGFloat margin, fontSize;
@property (nonatomic) UIFont *font;
@property (nonatomic) UIScrollView *scrollView;
@property (nonatomic) NSMutableArray<NSValue *> *rangeArray;
@property int currentRange;

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
        _rangeArray = NSMutableArray.array;
        _currentRange = 0;
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
    [self setupSearchButton];
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
    [_returnButton setTitle:@"< Return" forState:UIControlStateNormal];
    [_returnButton setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    [_returnButton setTitleColor:UIColor.lightGrayColor forState:UIControlStateHighlighted];
    [_returnButton addTarget:self action:@selector(dismiss:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:_returnButton];
    [_returnButton constrainTopToAnchor:self.view.topAnchor constant:(_margin / 2.0)];
    [_returnButton constrainLeadingToAnchor:self.view.leadingAnchor constant:_margin];
    [_returnButton constrainHeightToConstant:40.0];
}

- (void)setupSearchButton
{
    _searchButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _searchButton.translatesAutoresizingMaskIntoConstraints = NO;
    _searchButton.backgroundColor = UIColor.clearColor;
    _searchButton.titleLabel.font = _font;
    _searchButton.titleLabel.textAlignment = NSTextAlignmentLeft;
    _searchButton.titleLabel.adjustsFontSizeToFitWidth = YES;
    _searchButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [_searchButton setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    [_searchButton setTitleColor:UIColor.lightGrayColor forState:UIControlStateHighlighted];
    [_searchButton addTarget:self action:@selector(search:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:_searchButton];
    [_searchButton constrainTopToAnchor:_returnButton.topAnchor];
    [_searchButton constrainTrailingToAnchor:self.view.trailingAnchor constant:-_margin];
    [_searchButton constrainHeightToAnchor:_returnButton.heightAnchor];
}

- (void)setupTextView
{
    _scrollView = UIScrollView.new;
    _scrollView.translatesAutoresizingMaskIntoConstraints = NO;
    _scrollView.layer.borderColor = UIColor.blackColor.CGColor;
    _scrollView.layer.borderWidth = 2.0;
    _scrollView.directionalLockEnabled = YES;
    _scrollView.backgroundColor = UIColor.darkGrayColor;
    
    [self.view addSubview:_scrollView];
    [_scrollView constrainTopToAnchor:_returnButton.bottomAnchor constant:(_margin / 2.0)];
    [_scrollView constrainLeadingToAnchor:self.view.leadingAnchor constant:_margin];
    [_scrollView constrainTrailingToAnchor:self.view.trailingAnchor constant:-_margin];
    [_scrollView constrainBottomToAnchor:self.view.bottomAnchor constant:-_margin];
    
    [self.view layoutSubviews];
    
    UIFont *font = [UIFont fontWithName:@"CourierNewPS-BoldMT" size:_fontSize];
    _text = [_text stringByReplacingOccurrencesOfString:@"\t" withString:@"    "];
    
    NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:_text];
    
    if (_redSubstring && _redSubstring.length)
        attributedText = [self setColor:UIColor.redColor forSubstring:_redSubstring inText:attributedText];
    
    if (_greenSubstring && _greenSubstring.length)
        attributedText = [self setColor:UserDefaults.defaults.darkGreen forSubstring:_greenSubstring inText:attributedText];
    
    if (_blueSubstring && _blueSubstring.length)
        attributedText = [self setColor:UIColor.blueColor forSubstring:_blueSubstring inText:attributedText];

    CGSize textSize = sizeOfString(_text, font);
    
    if (!_clampTextViewToText)
    {
        textSize.height = MAX(_scrollView.frame.size.height, textSize.height);
        textSize.width = MAX(_scrollView.frame.size.width, textSize.width);
    }
    
    _scrollView.contentSize = textSize;
    
    _textView = [[UITextView alloc] initWithFrame:CGRectMake(0.0, 0.0, textSize.width, textSize.height)];
    _textView.attributedText = attributedText.copy;
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
    
    [_searchButton setTitle:[NSString stringWithFormat:@"Search: %li matches", (unsigned long)_rangeArray.count]
                   forState:UIControlStateNormal];
    
    if (_rangeArray.count)
    {
        NSArray *sortedRangeArray = [_rangeArray sortedArrayUsingComparator:^NSComparisonResult(NSValue *value1, NSValue *value2)
                                     {
                                         NSComparisonResult result = NSOrderedSame;
                                         
                                         if (value1.rangeValue.location > value2.rangeValue.location)
                                             result = NSOrderedDescending;
                                         
                                         else if (value1.rangeValue.location < value2.rangeValue.location)
                                             result = NSOrderedAscending;
                                         
                                         return result;
                                     }];
        
        _rangeArray = sortedRangeArray.mutableCopy;
    }
    
    else
    {
        _searchButton.alpha = 0.5;
        _searchButton.userInteractionEnabled = NO;
    }
}

- (void)textWasPinched:(UIPinchGestureRecognizer *)gesture
{
    _fontSize = floorf(((_fontSize * gesture.scale) * 10.0) + 0.5) / 10.0;
    _fontSize = MIN(_fontSize, _maxFontSize);
    _fontSize = MAX(_fontSize, _minFontSize);
    UIFont *font = [UIFont fontWithName:@"CourierNewPS-BoldMT" size:_fontSize];
    
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
    [self dismissViewControllerAnimated:YES completion:nil];
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

- (NSMutableAttributedString *)setColor:(UIColor *)color
                           forSubstring:(NSString *)substring
                                 inText:(NSMutableAttributedString *)text
{
    NSUInteger length = text.length;
    NSRange range = NSMakeRange(0, length);
    
    while(range.location != NSNotFound)
    {
        range = [text.string rangeOfString:substring options:NSCaseInsensitiveSearch range:range];
        
        if(range.location != NSNotFound)
        {
            [text setAttributes:@{NSForegroundColorAttributeName:color}
                          range:NSMakeRange(range.location, substring.length)];
            
            [_rangeArray addObject:[NSValue valueWithRange:range]];
            range = NSMakeRange((range.location + range.length), (length - (range.location + range.length)));
        }
    }
    
    return text;
}

- (void)search:(UIButton *)button
{
    NSRange range = [_rangeArray[_currentRange++] rangeValue];
    
    range = [_textView.layoutManager glyphRangeForCharacterRange:range
                                            actualCharacterRange:nil];
    
    CGRect rect = [_textView.layoutManager boundingRectForGlyphRange:range
                                                     inTextContainer:_textView.textContainer];
    
    CGFloat yOffset = (_textView.textContainerInset.top + rect.origin.y);
    [_scrollView setContentOffset:CGPointMake(0.0, yOffset) animated:YES];
    
    [_searchButton setTitle:[NSString stringWithFormat:@"Search: %i of %li matches", _currentRange, (unsigned long)_rangeArray.count]
                   forState:UIControlStateNormal];
    
    if (_currentRange >= _rangeArray.count)
        _currentRange = 0;
}

@end
