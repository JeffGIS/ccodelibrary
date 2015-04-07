//  RampTypeView.h
//  CCodeLibrary

#import <UIKit/UIKit.h>

@class RampTypeView;

@protocol RampTypeViewDelegate <NSObject>

- (void)rampTypeView:(RampTypeView *)rampTypeView
   didReturnRampType:(NSInteger)rampType;

@end

@interface RampTypeView : UIView

@property (nonatomic, weak) id <RampTypeViewDelegate> delegate;

+ (RampTypeView *)showRampTypeViewWithView:(UIView *)view
                                  delegate:(id)delegate;

- (void)hideRampTypeView:(BOOL)animated;

@end