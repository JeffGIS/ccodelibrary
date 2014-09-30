//  VerticalSegmentedControl.m
//  CCodeLibrary

#import "VerticalSegmentedControl.h"
#import <QuartzCore/QuartzCore.h>

#define IS_IOS_LESS_THAN(v) ([UIDevice.currentDevice.systemVersion compare:v options:NSNumericSearch] == NSOrderedAscending)
#define DEFAULT_BACKGROUND_COLOR UIColor.clearColor
#define DEFAULT_TEXT_FONT [UIFont systemFontOfSize:14.0]
#define DEFAULT_TEXT_COLOR  UIColor.blackColor
#define DEFAULT_SELECTION_INDICATOR_COLOR [UIColor colorWithRed:52.0/255.0 green:181.0/255.0 blue:229.0/255.0 alpha:1.0]
#define DEFAULT_SEGMENT_EDGE_INSET UIEdgeInsetsMake(5.0, 5.0, 5.0, 5.0)
#define DEFAULT_BOX_BACKGROUND_COLOR_ALPHA 0.2
#define DEFAULT_BOX_BORDER_COLOR_ALPHA  0.3
#define DEFAULT_BOX_BORDER_WIDTH 1.0

static NSString *const kPositionCALayerAction = @"position";
static NSString *const kBoundsCALayerAction = @"bounds";

static CFTimeInterval const kDefaultAnimationDuration = 0.15;
static CGFloat const kDefaultSelectionIndicatorThickness = 2.0;
static CGFloat const kDefaultSegmentWidth = 100.0;

int const kSMVerticalSegmentedControlNoSegment = -1;

@interface VerticalSegmentedControl()

@property (nonatomic, strong) CALayer *selectionIndicatorStripLayer;
@property (nonatomic, strong) CALayer *selectionIndicatorBoxLayer;
@property (nonatomic, readwrite) CGFloat segmentHeight;
@property (nonatomic, assign) NSInteger visibleSelectedSegmentIndex;

@end

@implementation VerticalSegmentedControl

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        self.opaque = NO;
        _selectedSegmentIndex = 0;
        _visibleSelectedSegmentIndex = 0;
        _backgroundColor = DEFAULT_BACKGROUND_COLOR;
        _textFont = DEFAULT_TEXT_FONT;
        _textColor = DEFAULT_TEXT_COLOR;
        _selectedTextColor = _textColor;
        _textAlignment = VerticalSegmentedControlTextAlignmentLeft;
        _selectionIndicatorColor = DEFAULT_SELECTION_INDICATOR_COLOR;
        _selectionIndicatorThickness = kDefaultSelectionIndicatorThickness;
        _selectionStyle = VerticalSegmentedControlSelectionStyleTextHeightStrip;
        _selectionLocation = VerticalSegmentedControlSelectionLocationLeft;
        _segmentEdgeInset = DEFAULT_SEGMENT_EDGE_INSET;
        _width = kDefaultSegmentWidth;
        _selectionIndicatorStripLayer = CALayer.layer;
        _selectionIndicatorBoxLayer = CALayer.layer;
        _selectionBoxBackgroundColorAlpha = DEFAULT_BOX_BACKGROUND_COLOR_ALPHA;
        _selectionBoxBorderColorAlpha = DEFAULT_BOX_BORDER_COLOR_ALPHA;
        _selectionBoxBorderWidth = DEFAULT_BOX_BORDER_WIDTH;
    }
    
    return self;
}

- (id)initWithSectionTitles:(NSArray *)sectionTitles
{
    if (self = [self initWithFrame:CGRectZero])
    {
        _sectionTitles = sectionTitles;
        [self updateSegmentsRects:CGSizeZero];
    }
    
    return self;
}

- (void)drawRect:(CGRect)rect
{
    [self.backgroundColor setFill];
    UIRectFill(self.bounds);
    
    self.selectionIndicatorStripLayer.backgroundColor = self.selectionIndicatorColor.CGColor;
    
    self.selectionIndicatorBoxLayer.backgroundColor = [self createColorFromOtherColor:self.selectionIndicatorColor
                                                                            withAlpha:self.selectionBoxBackgroundColorAlpha].CGColor;
    
    self.selectionIndicatorBoxLayer.borderColor = [self createColorFromOtherColor:self.selectionIndicatorColor
                                                                        withAlpha:self.selectionBoxBorderColorAlpha].CGColor;
    
    self.selectionIndicatorBoxLayer.borderWidth = self.selectionBoxBorderWidth;
    
    self.layer.sublayers = nil;
    
    [self.sectionTitles enumerateObjectsUsingBlock:^(id titleString, NSUInteger idx, BOOL *stop)
    {
        CGFloat stringHeight = roundf([self getTextHeight:titleString]);
        CGFloat y = (self.segmentHeight * idx + self.segmentHeight / 2.0 - stringHeight / 2.0);
        
        if (IS_IOS_LESS_THAN(@"6.0"))
            y +=(self.textFont.capHeight - self.textFont.xHeight);
        
        CGRect rect = CGRectMake(self.selectionIndicatorThickness + self.segmentEdgeInset.left, y,
                                 self.width - self.selectionIndicatorThickness - self.segmentEdgeInset.left - self.segmentEdgeInset.right,
                                 stringHeight);
        
        CATextLayer *titleLayer = CATextLayer.layer;
        titleLayer.frame = rect;
        titleLayer.font = (__bridge CFTypeRef)(self.textFont.fontName);
        titleLayer.fontSize = self.textFont.pointSize;
        
        switch(self.textAlignment)
        {
            case VerticalSegmentedControlTextAlignmentLeft:
                titleLayer.alignmentMode = kCAAlignmentLeft;
                break;
                
            case VerticalSegmentedControlTextAlignmentCenter:
                titleLayer.alignmentMode = kCAAlignmentCenter;
                break;
                
            case VerticalSegmentedControlTextAlignmentRight:
                titleLayer.alignmentMode = kCAAlignmentRight;
                break;
        }
        
        [titleLayer setString:titleString];
        
        if (self.visibleSelectedSegmentIndex == idx)
            titleLayer.foregroundColor = self.selectedTextColor.CGColor;
        
        else
            titleLayer.foregroundColor = self.textColor.CGColor;
        
        [titleLayer setContentsScale:UIScreen.mainScreen.scale];
        [self.layer addSublayer:titleLayer];
    }];
    
    if (self.selectedSegmentIndex != kSMVerticalSegmentedControlNoSegment && !self.selectionIndicatorStripLayer.superlayer)
    {
        self.selectionIndicatorStripLayer.frame = self.frameForSelectionIndicator;
        [self.layer addSublayer:self.selectionIndicatorStripLayer];
        
        if (self.selectionStyle == VerticalSegmentedControlSelectionStyleBox && !self.selectionIndicatorBoxLayer.superlayer)
        {
            self.selectionIndicatorBoxLayer.frame = self.frameForFillerSelectionIndicator;
            
            [self.layer insertSublayer:self.selectionIndicatorBoxLayer
                               atIndex:0];
        }
    }
}

- (CGFloat)getTextHeight:(NSString *)text
{
    if ([text respondsToSelector:@selector(sizeWithAttributes:)])
        return [text sizeWithAttributes: @{NSFontAttributeName:self.textFont}].height;
    
    else
    {
#pragma clang diagnostic push
#pragma GCC diagnostic ignored "-Wdeprecated"
        return [text sizeWithFont:self.textFont].height;
#pragma clang diagnostic pop
    }
}

- (CGRect)frameForSelectionIndicator
{
    CGFloat indicatorXOffset = 0.0;
    
    if (self.selectionLocation == VerticalSegmentedControlSelectionLocationRight)
        indicatorXOffset = self.bounds.size.width - self.selectionIndicatorThickness;
    
    CGFloat sectionHeight = 0.0;
    
    NSString *title = self.sectionTitles[self.selectedSegmentIndex];
    CGFloat stringHeight = [self getTextHeight:title];
    sectionHeight = stringHeight;
    
    if (self.selectionStyle == VerticalSegmentedControlSelectionStyleTextHeightStrip && sectionHeight <= self.segmentHeight)
    {
        CGFloat heightToStartOfSelectedIndex = (self.segmentHeight * self.selectedSegmentIndex);
        CGFloat y = heightToStartOfSelectedIndex + (self.segmentHeight / 2.0) - (sectionHeight / 2.0);
        return CGRectMake(indicatorXOffset, y, self.selectionIndicatorThickness, sectionHeight);
    }
    
    else
    {
        return CGRectMake(indicatorXOffset, self.segmentHeight * self.selectedSegmentIndex,
                          self.selectionIndicatorThickness, self.segmentHeight);
    }
}

- (CGRect)frameForFillerSelectionIndicator
{
    return CGRectMake(0.0, self.segmentHeight * self.selectedSegmentIndex, self.width, self.segmentHeight);
}

- (void)updateSegmentsRects:(CGSize)size
{
    if (CGRectIsEmpty(self.frame))
    {
        self.segmentHeight = 0.0;
        
        for (NSString *titleString in self.sectionTitles)
        {
            CGFloat stringHeight = [self getTextHeight:titleString] + self.segmentEdgeInset.top + self.segmentEdgeInset.bottom;
            self.segmentHeight = MAX(stringHeight, self.segmentHeight);
        }
        
        self.frame = CGRectMake(0.0, 0.0, self.width, self.segmentHeight * self.sectionTitles.count);
    }
    
    else
    {
        self.segmentHeight = (size.height / self.sectionTitles.count);
        
        self.segmentHeight = roundf(self.segmentHeight);
        self.width = size.width;
    }
}

- (UIColor *)createColorFromOtherColor:(UIColor *)color
                             withAlpha:(CGFloat)alpha
{
    const CGFloat *components = CGColorGetComponents(color.CGColor);
    return [UIColor colorWithRed:components[0]
                           green:components[1]
                            blue:components[2]
                           alpha:alpha];
}

- (void)notifyForSegmentChangeToIndex:(NSInteger)index
{
    if (self.superview)
        [self sendActionsForControlEvents:UIControlEventValueChanged];
    
    if (self.indexChangeBlock)
        self.indexChangeBlock(index);
}

- (void)touchesBegan:(NSSet *)touches
           withEvent:(UIEvent *)event
{
    UITouch *touch = event.allTouches.anyObject;
    CGPoint touchLocation = [touch locationInView:self];
    
    if (CGRectContainsPoint(self.bounds, touchLocation))
    {
        NSInteger segment = (touchLocation.y / self.segmentHeight);
        
        if (segment != self.selectedSegmentIndex)
        {
            [self setSelectedSegmentIndex:segment
                                 animated:YES
                                   notify:YES];
        }
    }
}

- (void)setSelectedSegmentIndex:(NSInteger)index
{
    [self setSelectedSegmentIndex:index
                         animated:NO
                           notify:NO];
}

- (void)setSelectedSegmentIndex:(NSUInteger)index
                       animated:(BOOL)animated
{
    [self setSelectedSegmentIndex:index
                         animated:animated
                           notify:NO];
}

- (void)setSelectedSegmentIndex:(NSUInteger)index
                       animated:(BOOL)animated
                         notify:(BOOL)notify
{
    _selectedSegmentIndex = index;
    self.visibleSelectedSegmentIndex = kSMVerticalSegmentedControlNoSegment;
    
    if (index == kSMVerticalSegmentedControlNoSegment)
    {
        [self.selectionIndicatorStripLayer removeFromSuperlayer];
        [self.selectionIndicatorBoxLayer removeFromSuperlayer];
    }
    
    else
    {
        if (animated)
        {
            if (![self.selectionIndicatorStripLayer superlayer])
            {
                [self.layer addSublayer:self.selectionIndicatorStripLayer];
                
                if (self.selectionStyle == VerticalSegmentedControlSelectionStyleBox && ![self.selectionIndicatorBoxLayer superlayer])
                {
                    [self.layer insertSublayer:self.selectionIndicatorBoxLayer
                                       atIndex:0];
                }
                
                [self setSelectedSegmentIndex:index animated:NO
                                       notify:YES];
                return;
            }
            
            if (notify)
                [self notifyForSegmentChangeToIndex:index];
            
            self.selectionIndicatorStripLayer.actions = nil;
            self.selectionIndicatorBoxLayer.actions = nil;
            
            [CATransaction begin];
            
            [CATransaction setCompletionBlock:^{
                self.visibleSelectedSegmentIndex = index;
                [self setNeedsDisplay];
            }];
            
            [CATransaction setAnimationDuration:kDefaultAnimationDuration];
            [CATransaction setAnimationTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear]];
            self.selectionIndicatorStripLayer.frame = self.frameForSelectionIndicator;
            
            self.selectionIndicatorBoxLayer.frame = self.frameForFillerSelectionIndicator;
            [CATransaction commit];
        }
        
        else
        {
            self.visibleSelectedSegmentIndex = index;
            
            NSDictionary *newActions = @{kPositionCALayerAction:NSNull.null, kBoundsCALayerAction:NSNull.null};
            self.selectionIndicatorStripLayer.actions = newActions;
            self.selectionIndicatorStripLayer.frame = self.frameForSelectionIndicator;
            
            self.selectionIndicatorBoxLayer.actions = newActions;
            self.selectionIndicatorBoxLayer.frame = self.frameForFillerSelectionIndicator;
            
            if (notify)
                [self notifyForSegmentChangeToIndex:index];
        }
    }
    
    [self setNeedsDisplay];
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    
    if (self.sectionTitles)
        [self updateSegmentsRects:frame.size];
    
    [self setNeedsDisplay];
}

- (void)setBounds:(CGRect)bounds
{
    [super setBounds:bounds];
    
    if (self.sectionTitles)
        [self updateSegmentsRects:bounds.size];
    
    [self setNeedsDisplay];
}

- (void)willMoveToSuperview:(UIView *)newSuperview
{
    if (!newSuperview)
        return;
    
    [self updateSegmentsRects:self.frame.size];
}

@end