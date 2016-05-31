//  NVRampTypePageView.m
//  CCodeLibrary

#import "NVRampTypePageView.h"
#import "UserDefaults.h"
#import "TableViewCellLabel.h"
#import "UIImage+ImageFromColor.h"
#import "Colors.h"

@interface NVRampTypePageView ()

@property (nonatomic, weak) id <NVRampTypePageViewDelegate> delegate;
@property (nonatomic) NSArray *rampTypes;
@property NSUInteger startingIndex;
@property (nonatomic) UIView *buttonView;
@property (nonatomic) UIButton *selectButton, *returnButton;
@property (nonatomic) CGRect originalButtonFrame, originalLabelFrame, originalNumberLabelFrame;
@property (nonatomic) Colors *colors;
@property NSInteger zoomedIndex;
@property RampType selectedType;

@end

@implementation NVRampTypePageView

+ (instancetype)pageViewWithRampTypes:(NSArray *)rampTypes
                        startingIndex:(NSUInteger)startingIndex
                         selectedType:(RampType)selectedType
                             delegate:(id)delegate
{
    if (!delegate)
    {
        NSLog(@"NVRampTypePageView ERROR:Cannot set delegate to nil");
        return nil;
    }
    
    if (![delegate respondsToSelector:@selector(rampTypePageView:didReturnRampType:)] ||
        ![delegate respondsToSelector:@selector(rampTypePageViewDidZoom:)])
    {
        NSLog(@"NVRampTypePageView ERROR:Delegate must respond to all selectors in protocol");
        return nil;
    }
    
    NVRampTypePageView *nvpv = NVRampTypePageView.new;
    nvpv.colors = UserDefaults.defaults.defaultColors;
    nvpv.startingIndex = startingIndex;
    nvpv.rampTypes = rampTypes;
    nvpv.delegate = delegate;
    nvpv.selectedType = selectedType;
    nvpv.isZoomed = NO;
    
    return nvpv;
}

- (void)loadView
{
    UIView *view = [[UIView alloc] initWithFrame:UIScreen.mainScreen.bounds];
    view.backgroundColor = UIColor.clearColor;
    self.view = view;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _buttonView = [[UIView alloc] initWithFrame:CGRectMake(42.0, 72.0, 684.0, 912.0)];
    _buttonView.backgroundColor = UIColor.blackColor;
    
    [self.view addSubview:_buttonView];
    
    [self setupReturnButton];
    
    _selectButton = [[UIButton alloc] initWithFrame:CGRectMake(64.0, (self.view.frame.size.height - 118.0),
                                                                     (self.view.frame.size.width - 128.0), 60.0)];
    
    _selectButton.alpha = 0.0;
    
    [self setupButton:_selectButton
               target:self
             selector:@selector(selectButtonTapped:)
                title:@"Select This Ramp Type"];
    
    [_selectButton setTitleColor:UIColor.whiteColor
                        forState:UIControlStateDisabled];
    
    [self.view addSubview:_selectButton];
    
    CGSize buttonSize = CGSizeMake(((_buttonView.frame.size.width - 8.0) / 3.0),
                                   ((_buttonView.frame.size.height - 8.0) / 3.0));
    
    NSInteger tag = _startingIndex;
    
    for (int row = 0; row < 3; row++)
    {
        if (tag >= (_startingIndex + _rampTypes.count))
            break;
        
        for (int column = 0; column < 3; column++)
        {
            if (tag >= (_startingIndex + _rampTypes.count))
                break;
            
            UIButton *rtButton = [[UIButton alloc] initWithFrame:CGRectMake(((column * buttonSize.width) + 4.0),
                                                                            ((row * buttonSize.height) + 4.0),
                                                                            buttonSize.width, buttonSize.height)];
            
            rtButton.tag = tag;
            rtButton.imageEdgeInsets = UIEdgeInsetsMake(4.0, 4.0, 44.0, 4.0);
            rtButton.layer.borderColor = UIColor.greenColor.CGColor;
            rtButton.layer.borderWidth = 0.0;
            rtButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
            rtButton.imageView.backgroundColor = UIColor.whiteColor;
            
            NVRampType *rt = NVRampTypePageController.defaultRampTypes[rtButton.tag];
            
            UIImage *rampImage = [UIImage imageWithContentsOfFile:[NSBundle.mainBundle pathForResource:rt.imageName
                                                                                                ofType:@"png"]];
            
            if (!rampImage)
            {
                rampImage = [UIImage imageWithContentsOfFile:[NSBundle.mainBundle pathForResource:@"BlankWhiteImage"
                                                                                           ofType:@"png"]];
            }
            
            [rtButton setImage:rampImage
                      forState:UIControlStateNormal];
            
            UILabel *rampImageLabel = [[UILabel alloc] initWithFrame:CGRectMake(4.0, (buttonSize.height - 44.0),
                                                                                (buttonSize.width - 8.0), 40.0)];
            
            rampImageLabel.backgroundColor = UIColor.lightGrayColor;
            rampImageLabel.textColor = UIColor.blackColor;
            rampImageLabel.textAlignment = NSTextAlignmentCenter;
            rampImageLabel.font = [UIFont systemFontOfSize:16.0];
            rampImageLabel.numberOfLines = 0;
            rampImageLabel.text = rt.displayText;
            [rtButton addSubview:rampImageLabel];
            
            TableViewCellLabel *rtNumberLabel = [[TableViewCellLabel alloc] initWithFrame:
                                                 CGRectMake(4.0, 4.0, (buttonSize.width - 8.0), (buttonSize.height - 44.0))];
            
            rtNumberLabel.backgroundColor = UIColor.clearColor;
            rtNumberLabel.textColor = UserDefaults.defaults.appleBlue;
            rtNumberLabel.alpha = 0.3;
            rtNumberLabel.textAlignment = NSTextAlignmentCenter;
            rtNumberLabel.font = [UIFont boldSystemFontOfSize:200.0];
            rtNumberLabel.adjustsFontSizeToFitWidth = YES;
            rtNumberLabel.text = [NSString stringWithFormat:@"%li", (long)(tag + 1)];
            [rtButton addSubview:rtNumberLabel];
            
            [rtButton addTarget:self
                         action:@selector(rtButtonTapped:)
               forControlEvents:UIControlEventTouchUpInside];
            
            [_buttonView addSubview:rtButton];
            
            tag ++;
        }
    }
    
    [self highlightSelectedButton];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)setupReturnButton
{
    _returnButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _returnButton.frame = CGRectMake(20.0, 8.0, 160.0, 56.0);
    _returnButton.backgroundColor = _colors.enabledColor;
    _returnButton.titleLabel.font = [UIFont boldSystemFontOfSize:32.0];
    _returnButton.layer.cornerRadius = 10.0;
    
    [_returnButton setTitle:@"< Return"
                   forState:UIControlStateNormal];
    
    [_returnButton setTitleColor:_colors.titleColor
                        forState:UIControlStateNormal];
    
    [_returnButton setTitleColor:_colors.highlightedColor
                        forState:UIControlStateHighlighted];
    
    [_returnButton addTarget:self
                      action:@selector(returnButtonTapped:)
            forControlEvents:UIControlEventTouchUpInside];
    
    _returnButton.hidden = YES;
    [self.view addSubview:_returnButton];
}

- (void)setupButton:(UIButton *)button
             target:(id)target
           selector:(SEL)selector
              title:(NSString *)title
{
    button.backgroundColor = UIColor.whiteColor;
    button.layer.cornerRadius = 10.0;
    button.titleLabel.font = [UIFont boldSystemFontOfSize:36.0];
    button.titleLabel.textAlignment = NSTextAlignmentCenter;
    
    [button setTitle:title
            forState:UIControlStateNormal];
    
    [button setTitleColor:UIColor.blackColor
                 forState:UIControlStateNormal];
    
    [button setTitleColor:UIColor.lightGrayColor
                 forState:UIControlStateHighlighted];
    
    [button addTarget:target
               action:selector
     forControlEvents:UIControlEventTouchUpInside];
}

- (void)highlightSelectedButton
{
    for (UIButton *buttons in _buttonView.subviews)
    {
        if ([buttons isKindOfClass:UIButton.class])
        {
            if (buttons.tag == _selectedType)
                buttons.layer.borderWidth = 4.0;
            
            else
                buttons.layer.borderWidth = 0.0;
        }
    }
}

- (void)returnButtonTapped:(UIButton *)button
{
    _isZoomed = NO;
    [_delegate rampTypePageViewDidZoom:_isZoomed];
    _returnButton.hidden = YES;
    
    for (UIButton *buttons in _buttonView.subviews)
    {
        if ([buttons isKindOfClass:UIButton.class])
        {
            if (!buttons.hidden)
            {
                [UIView animateWithDuration:0.25
                                 animations:^{
                                     buttons.frame = _originalButtonFrame;
                                     buttons.imageEdgeInsets = UIEdgeInsetsMake(4.0, 4.0, 44.0, 4.0);
                                 } completion:^(BOOL finished) {
                                     buttons.userInteractionEnabled = YES;
                                 }];
                
                for (UILabel *labels in buttons.subviews)
                {
                    if ([labels isKindOfClass:UILabel.class] &&
                        ![labels isKindOfClass:TableViewCellLabel.class])
                    {
                        [UIView animateWithDuration:0.25
                                         animations:^{
                                             labels.frame = _originalLabelFrame;
                                             labels.font = [UIFont boldSystemFontOfSize:16.0];
                                         }];
                    }
                    
                    else if ([labels isKindOfClass:TableViewCellLabel.class])
                    {
                        [UIView animateWithDuration:0.25
                                         animations:^{
                                             labels.frame = _originalNumberLabelFrame;
                                             labels.font = [UIFont boldSystemFontOfSize:200.0];
                                             labels.alpha = 0.4;
                                             labels.backgroundColor = UIColor.clearColor;
                                         }];
                    }
                }
            }
            
            else
            {
                buttons.hidden = NO;
                
                [UIView animateWithDuration:0.25
                                 animations:^{
                                     buttons.alpha = 1.0;
                                 }];
            }
        }
    }
    
    [UIView animateWithDuration:0.25
                     animations:^{
                         _selectButton.alpha = 0.0;
                     } completion:^(BOOL finished) {
                         _selectButton.hidden = YES;
                     }];
}

- (void)rtButtonTapped:(UIButton *)button
{
    _isZoomed = YES;
    [_delegate rampTypePageViewDidZoom:_isZoomed];
    _returnButton.hidden = NO;
    
    button.userInteractionEnabled = NO;
    _zoomedIndex = button.tag;
    
    if (_zoomedIndex == _selectedType)
    {
        [_selectButton setTitle:@"This is the Selected Ramp Type"
                       forState:UIControlStateNormal];
        
        _selectButton.backgroundColor = _buttonView.backgroundColor;
        _selectButton.enabled = NO;
    }
    
    else
    {
        [_selectButton setTitle:@"Select This Ramp Type"
                       forState:UIControlStateNormal];
        
        _selectButton.backgroundColor = UIColor.whiteColor;
        _selectButton.enabled = YES;
    }
    
    for (UIButton *buttons in _buttonView.subviews)
    {
        if ([buttons isKindOfClass:UIButton.class])
        {
            if (buttons != button)
            {
                [UIView animateWithDuration:0.25
                                 animations:^{
                                     buttons.alpha = 0.0;
                                 } completion:^(BOOL finished) {
                                     buttons.hidden = YES;
                                 }];
            }
            
        }
    }
    
    _originalButtonFrame = button.frame;
    
    [UIView animateWithDuration:0.25
                     animations:^{
                         button.frame = CGRectMake(4.0, 4.0,
                                                   (_buttonView.frame.size.width - 8.0),
                                                   (_buttonView.frame.size.height - 8.0));
                         
                         button.imageEdgeInsets = UIEdgeInsetsMake(4.0, 4.0, 4.0, 4.0);
                     }];
    
    for (UILabel *labels in button.subviews)
    {
        if ([labels isKindOfClass:UILabel.class] &&
            ![labels isKindOfClass:TableViewCellLabel.class])
        {
            _originalLabelFrame = labels.frame;
            
            [UIView animateWithDuration:0.25
                             animations:^{
                                 labels.frame = CGRectMake(100.0, 4.0,
                                                           (button.frame.size.width - 104.0), 96.0);
                                 
                                 labels.font = [UIFont boldSystemFontOfSize:40.0];
                             }];
        }
        
        else if ([labels isKindOfClass:TableViewCellLabel.class])
        {
            _originalNumberLabelFrame = labels.frame;
            
            [UIView animateWithDuration:0.25
                             animations:^{
                                 labels.frame = CGRectMake(4.0, 4.0, 96.0, 96.0);
                                 labels.font = [UIFont boldSystemFontOfSize:112.0];
                                 labels.alpha = 1.0;
                                 labels.backgroundColor = UIColor.whiteColor;
                             }];
        }
    }
    
    _selectButton.hidden = NO;
    [self.view bringSubviewToFront:_selectButton];
    
    [UIView animateWithDuration:0.25
                     animations:^{
                         _selectButton.alpha = 1.0;
                     }];
}

- (void)selectButtonTapped:(UIButton *)button
{
    _selectedType = _zoomedIndex;
    
    [_delegate rampTypePageView:self
              didReturnRampType:_selectedType];
}

@end