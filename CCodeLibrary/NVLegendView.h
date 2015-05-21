//  NVLegendView.h
//  CCodeLibrary

#import <UIKit/UIKit.h>

@class NVLegendView;

@protocol NVLegendViewDelegate <NSObject>

- (NSUInteger)numberOfRowsInLegendView;
- (NSString *)nameForRowInLegendViewAtIndex:(NSUInteger)index;
- (UIColor *)colorForRowInLegendViewAtIndex:(NSUInteger)index;
- (NSUInteger)countForRowInLegendViewAtIndex:(NSUInteger)index;
- (NSString *)titleForLegendView;

- (void)legendView:(NVLegendView *)legendView
didChangeSelectedIndex:(NSUInteger)index;

@end

@interface NVLegendView : UIView <UIGestureRecognizerDelegate>

@property (nonatomic, weak) id <NVLegendViewDelegate> delegate;

+ (NVLegendView *)showLegendViewAtOrigin:(CGPoint)origin
                                  inView:(UIView *)view
                                delegate:(id)delegate;

- (void)reloadView;
- (void)reloadData;

@end