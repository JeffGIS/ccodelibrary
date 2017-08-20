//  VerticalSegmentedControl.h
//  CCodeLibrary

#import <UIKit/UIKit.h>

typedef void (^IndexChangeBlock)(NSInteger index);

typedef NS_ENUM(NSInteger, VerticalSegmentedControlSelectionStyle)
{
    VerticalSegmentedControlSelectionStyleTextHeightStrip,
    VerticalSegmentedControlSelectionStyleFullHeightStrip,
    VerticalSegmentedControlSelectionStyleBox
};

typedef NS_ENUM(NSInteger, VerticalSegmentedControlSelectionLocation)
{
    VerticalSegmentedControlSelectionLocationLeft,
    VerticalSegmentedControlSelectionLocationRight,
};

typedef NS_ENUM(NSInteger, VerticalSegmentedControlTextAlignment)
{
    VerticalSegmentedControlTextAlignmentLeft,
    VerticalSegmentedControlTextAlignmentCenter,
    VerticalSegmentedControlTextAlignmentRight,
};

extern int const kVerticalSegmentedControlNoSegment;

@interface VerticalSegmentedControl : UIControl

@property (nonatomic, copy, readonly) NSArray *sectionTitles;
@property (nonatomic, strong) UIColor *backgroundColor UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) UIFont  *textFont UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) UIColor *textColor UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) UIColor *selectedTextColor UI_APPEARANCE_SELECTOR;
@property (nonatomic, assign) VerticalSegmentedControlTextAlignment textAlignment UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) UIColor *selectionIndicatorColor UI_APPEARANCE_SELECTOR;
@property (nonatomic, assign) CGFloat  selectionIndicatorThickness UI_APPEARANCE_SELECTOR;
@property (nonatomic, assign) CGFloat  selectionBoxBackgroundColorAlpha UI_APPEARANCE_SELECTOR;
@property (nonatomic, assign) CGFloat  selectionBoxBorderColorAlpha UI_APPEARANCE_SELECTOR;
@property (nonatomic, assign) CGFloat  selectionBoxBorderWidth UI_APPEARANCE_SELECTOR;
@property (nonatomic, assign) VerticalSegmentedControlSelectionStyle selectionStyle UI_APPEARANCE_SELECTOR;
@property (nonatomic, assign) VerticalSegmentedControlSelectionLocation selectionLocation UI_APPEARANCE_SELECTOR;
@property (nonatomic, assign) UIEdgeInsets segmentEdgeInset UI_APPEARANCE_SELECTOR;
@property (nonatomic, assign) CGFloat width UI_APPEARANCE_SELECTOR;
@property (nonatomic, assign) NSInteger selectedSegmentIndex;
@property (nonatomic, copy) IndexChangeBlock indexChangeBlock;

- (id)initWithSectionTitles:(NSArray *)sectiontitles;

- (void)setSelectedSegmentIndex:(NSUInteger)index
                       animated:(bool)animated;

@end
