//  RampTypeView.m
//  CCodeLibrary

#import "RampTypeView.h"
#import "UserDefaults.h"
#import "TableViewCellLabel.h"

@interface RampTypeView ()

@property (nonatomic) NSArray *rampImages;
@property (nonatomic) UIView *buttonView;
@property (nonatomic) CGRect originalButtonFrame, originalLabelFrame, originalNumberLabelFrame;
@property BOOL inZoomedMode;
@property (nonatomic) UIButton *selectButton;
@property NSInteger zoomedIndex, selectedIndex;
@property RampTypeEditOption editOption;

@end

@implementation RampTypeView

+ (RampTypeView *)showRampTypeViewWithView:(UIView *)view
                                  delegate:(id)delegate
                              selectedType:(RampType)selectedType
                                editOption:(RampTypeEditOption)editOption
{
    RampTypeView *rtView = [[RampTypeView alloc] initWithFrame:view.frame];
    rtView.delegate = delegate;
    rtView.rampImages = [RampTypeView rampTypeImages];
    rtView.rampImageLabelText = [RampTypeView rampTypeText];
    rtView.backgroundColor = UserDefaults.defaults.appleBlue;
    rtView.alpha = 0.0;
    rtView.selectedIndex = selectedType;
    rtView.editOption = editOption;
    [view addSubview:rtView];
    
    UIButton *returnButton = [[UIButton alloc] initWithFrame:CGRectMake(42.0, 26.0, 180.0, 50.0)];
    
    [rtView setupButton:returnButton
                 target:rtView
               selector:@selector(returnButtonTapped:)
                  title:@"< Return"];
    
    [rtView addSubview:returnButton];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(242.0, 20.0, 484.0, 60.0)];
    titleLabel.text = @"Select Ramp Type";
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.textColor = UIColor.whiteColor;
    titleLabel.font = [UIFont boldSystemFontOfSize:48.0];
    [rtView addSubview:titleLabel];
    
    rtView.buttonView = [[UIView alloc] initWithFrame:CGRectMake(42.0, 90.0, 684.0, 912.0)];
    rtView.buttonView.backgroundColor = UIColor.blackColor;
    
    [rtView addSubview:rtView.buttonView];
    
    rtView.selectButton = [[UIButton alloc] initWithFrame:CGRectMake(64.0, (rtView.frame.size.height - 100.0),
                                                                        (rtView.frame.size.width - 128.0), 60.0)];
    
    rtView.selectButton.alpha = 0.0;
    rtView.selectButton.hidden = YES;
    
    [rtView setupButton:rtView.selectButton
                 target:rtView
               selector:@selector(selectButtonTapped:)
                  title:@"Select This Ramp Type"];
    
    [rtView.selectButton setTitleColor:UIColor.whiteColor
                              forState:UIControlStateDisabled];
    
    [rtView addSubview:rtView.selectButton];
    
    CGSize buttonSize = CGSizeMake(((rtView.buttonView.frame.size.width - 8.0) / 3.0),
                                   ((rtView.buttonView.frame.size.height - 8.0) / 3.0));
   
    NSInteger tag = 0;
    
    for (int row = 0; row < 4; row++)
    {
        for (int column = 0; column < 3; column++)
        {
            UIButton *rtButton = [[UIButton alloc] initWithFrame:CGRectMake(((column * buttonSize.width) + 4.0),
                                                                            ((row * buttonSize.height) + 4.0),
                                                                            buttonSize.width, buttonSize.height)];
            
            rtButton.tag = tag;
            rtButton.imageEdgeInsets = UIEdgeInsetsMake(4.0, 4.0, 44.0, 4.0);
            rtButton.layer.borderColor = UIColor.greenColor.CGColor;
            rtButton.layer.borderWidth = 0.0;
            rtButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
            rtButton.imageView.backgroundColor = UIColor.whiteColor;
            
            if (tag < RampTypeCombLeftWalk)
            {
                [rtButton setImage:rtView.rampImages[tag]
                          forState:UIControlStateNormal];
                
                if (tag <= rtView.rampImageLabelText.count)
                {
                    UILabel *rampImageLabel = [[UILabel alloc] initWithFrame:CGRectMake(4.0, (buttonSize.height - 44.0),
                                                                                        (buttonSize.width - 8.0), 40.0)];
                    
                    rampImageLabel.backgroundColor = UIColor.lightGrayColor;
                    rampImageLabel.textColor = UIColor.blackColor;
                    rampImageLabel.textAlignment = NSTextAlignmentCenter;
                    rampImageLabel.font = [UIFont boldSystemFontOfSize:16.0];
                    rampImageLabel.numberOfLines = 0;
                    rampImageLabel.text = rtView.rampImageLabelText[tag];
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
                }
                
                [rtButton addTarget:rtView
                             action:@selector(rtButtonTapped:)
                   forControlEvents:UIControlEventTouchUpInside];
                
                [rtView.buttonView addSubview:rtButton];
            }
            
            tag ++;
        }
    }
    
    [rtView highlightSelectedButton];
    
    [UIView animateWithDuration:0.25
                     animations:^{
                         rtView.alpha = 1.0;
                     }];
    
    return rtView;
}

+ (NSArray *)rampTypeImages
{
    NSArray *imageNames = @[@"Perp",
                            @"PerpNonWalkable",
                            @"ComPerp",
                            @"ComPerpNW",
                            @"OneWayAdj",
                            @"OneWayBlend",
                            @"Parallel",
                            @"DepCorner",
                            @"Fan",
                            @"ComPerp_leftRamp",
                            @"ComPerp_rightRamp",
                            @"ComPerpNW_leftRamp",
                            @"ComPerpNW_rightRamp"];
    
    NSMutableArray *tempArray = [[NSMutableArray alloc] initWithCapacity:rampTypeCount];
    
    for (int i = 0; i < rampTypeCount; i++)
    {
        UIImage *rampImage = [UIImage imageWithContentsOfFile:[NSBundle.mainBundle pathForResource:imageNames[i]
                                                                                            ofType:@"png"]];
        
        [tempArray insertObject:rampImage
                        atIndex:i];
    }
    
    NSArray *imageArray = tempArray.copy;
    
    return imageArray;
}

+ (NSArray *)rampTypeText
{
    return @[@"Perpendicular", @"Perpendicular With\nNon-Walkable Surface", @"Combined Perpendicular\nWith Walkable Surface",
             @"Combined Perpendicular\nWith Non-Walkable Surface", @"One Way Directional\nAdjacent to Curb & Gutter",
             @"One Way Directional\nBlended Transition", @"Parallel", @"Depressed Corner", @"Fan"];
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

- (void)returnButtonTapped:(UIButton *)button
{
    if (_inZoomedMode == NO)
    {
        if (_delegate)
        {
            [_delegate rampTypeView:self
                  didReturnRampType:_selectedIndex
                         editOption:_editOption];
        }
    }
    
    else
    {
        _inZoomedMode = NO;
        
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
}

- (void)rtButtonTapped:(UIButton *)button
{
    _inZoomedMode = YES;
    button.userInteractionEnabled = NO;
    _zoomedIndex = button.tag;
    
    if (_zoomedIndex == _selectedIndex)
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
    [self bringSubviewToFront:_selectButton];
    
    [UIView animateWithDuration:0.25
                     animations:^{
                         _selectButton.alpha = 1.0;
                     }];
}

- (void)selectButtonTapped:(UIButton *)button
{
    _selectedIndex = _zoomedIndex;
    
    if (_delegate)
    {
        [_delegate rampTypeView:self
              didReturnRampType:_selectedIndex
                     editOption:_editOption];
    }
}

- (void)highlightSelectedButton
{
    for (UIButton *buttons in _buttonView.subviews)
    {
        if ([buttons isKindOfClass:UIButton.class])
        {
            if (buttons.tag == _selectedIndex)
                buttons.layer.borderWidth = 4.0;
            
            else
                buttons.layer.borderWidth = 0.0;
        }
    }
}

- (void)hideRampTypeView:(BOOL)animated
{
    if (animated)
    {
        [UIView animateWithDuration:0.25
                         animations:^{
                             self.alpha = 0.0;
                         } completion:^(BOOL finished) {
                             [self removeFromSuperview];
                         }];
    }
    
    else
        [self removeFromSuperview];
}

@end