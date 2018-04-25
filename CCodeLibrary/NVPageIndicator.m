//  NVPageIndicator.m
//  CCodeLibrary

#import "NVPageIndicator.h"

#define MAX_DOTS 9

@interface NVPageIndicator ()

@property (nonatomic, weak) id<NVPageIndicatorDelegate> delegate;
@property CGFloat spacing;
@property int numDots;
@property (nonatomic) UIColor *tintColor, *selectedColor, *highlightedColor;

@end

@implementation NVPageIndicator

+ (instancetype)showPageIndicatorInView:(UIView *)view
                            leadingView:(UIView *)leadingView
                           trailingView:(UIView *)trailingView
                                topView:(UIView *)topView
                             bottomView:(UIView *)bottomView
                                numDots:(int)numDots
                               delegate:(id<NVPageIndicatorDelegate>)delegate
{
    NVPageIndicator *nvpi = NVPageIndicator.new;
    nvpi.translatesAutoresizingMaskIntoConstraints = NO;
    nvpi.delegate = delegate;
    nvpi.spacing = 20.0;
    nvpi.numDots = MIN(numDots, MAX_DOTS);
    nvpi.tintColor = UIColor.grayColor;
    nvpi.selectedColor = UIColor.blackColor;
    
    [view addSubview:nvpi];
    
    if (leadingView)
        [nvpi constrainLeadingToAnchor:leadingView.trailingAnchor];
    else
        [nvpi constrainLeadingToAnchor:view.leadingAnchor];
    
    if (trailingView)
        [nvpi constrainTrailingToAnchor:trailingView.leadingAnchor];
    else
        [nvpi constrainTrailingToAnchor:view.trailingAnchor];
    
    if (topView)
        [nvpi constrainTopToAnchor:topView.bottomAnchor];
    else
        [nvpi constrainTopToAnchor:view.topAnchor];
    
    if (bottomView)
        [nvpi constrainBottomToAnchor:bottomView.topAnchor];
    else
        [nvpi constrainBottomToAnchor:view.bottomAnchor];
    
    [nvpi addDots];
    
    return nvpi;
}

- (void)addDots
{
    for (int i = 1; i <= _numDots; i++)
    {
        NVEllipseView *dot = NVEllipseView.new;
        dot.translatesAutoresizingMaskIntoConstraints = NO;
        dot.alpha = 1.0;
        
        if (i == 1)
            dot.fillColor = _selectedColor;
        
        else
            dot.fillColor = _tintColor;
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                              action:@selector(dotTapped:)];
        
        [dot addGestureRecognizer:tap];
        
        [self addSubview:dot];
        [dot constrainCenterYToAnchor:self.centerYAnchor];
        [dot constrainTopToAnchor:self.topAnchor constant:(_spacing * 0.2)];
        [dot constrainBottomToAnchor:self.bottomAnchor constant:-_spacing * 0.2];
        [dot constrainWidthToAnchor:dot.heightAnchor];
        
        switch (i)
        {
            case 1:
                [dot constrainCenterXToAnchor:self.centerXAnchor];
                dot.tag = 5;
                break;
            case 2:
                [dot constrainLeadingToAnchor:[self viewWithTag:5].trailingAnchor constant:_spacing];
                dot.tag = 6;
                break;
            case 3:
                [dot constrainTrailingToAnchor:[self viewWithTag:5].leadingAnchor constant:-_spacing];
                dot.tag = 4;
                break;
            case 4:
                [dot constrainLeadingToAnchor:[self viewWithTag:6].trailingAnchor constant:_spacing];
                dot.tag = 7;
                break;
            case 5:
                [dot constrainTrailingToAnchor:[self viewWithTag:4].leadingAnchor constant:-_spacing];
                dot.tag = 3;
                break;
            case 6:
                [dot constrainLeadingToAnchor:[self viewWithTag:7].trailingAnchor constant:_spacing];
                dot.tag = 8;
                break;
            case 7:
                [dot constrainTrailingToAnchor:[self viewWithTag:3].leadingAnchor constant:-_spacing];
                dot.tag = 2;
                break;
            case 8:
                [dot constrainLeadingToAnchor:[self viewWithTag:8].trailingAnchor constant:_spacing];
                dot.tag = 9;
                break;
            case 9:
                [dot constrainTrailingToAnchor:[self viewWithTag:2].leadingAnchor constant:-_spacing];
                dot.tag = 1;
                break;
            default:break;
        }
    }
}

- (void)dotTapped:(UITapGestureRecognizer *)gesture
{
    for (NVEllipseView *dot in self.subviews)
    {
        if ([dot isKindOfClass:NVEllipseView.class])
        {
            dot.fillColor = _tintColor;
            [dot setNeedsDisplay];
        }
    }
    
    NVEllipseView *thisDot = (NVEllipseView *)gesture.view;
    thisDot.fillColor = _selectedColor;
    [thisDot setNeedsDisplay];
    
    if (_delegate && [_delegate respondsToSelector:@selector(pageIndicator:wasTappedAtIndex:)])
    {
        int tag = (int)(gesture.view.tag - 1);
        
        switch (_numDots)
        {
            case 1:
            case 2:
                tag -= 4;
                break;
            case 3:
            case 4:
                tag -= 3;
                break;
            case 5:
            case 6:
                tag -= 2;
                break;
            case 7:
            case 8:
                tag -= 1;
                break;
            default:break;
        }
        
        [_delegate pageIndicator:self wasTappedAtIndex:tag];
    }
}

@end
