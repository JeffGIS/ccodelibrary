//  RampTypeView.h
//  CCodeLibrary

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, RampType)
{
    RampTypePerp,
    RampTypeCombPerpWalk,
    RampTypeCombPerpNonWalk,
    RampTypeOneWayDirCurbGutter,
    RampTypeOneWayDirBlendTrans,
    RampTypeParallel,
    RampTypeDepressedCorner,
    RampTypeFan,
};

@class RampTypeView;

@protocol RampTypeViewDelegate <NSObject>

- (void)rampTypeView:(RampTypeView *)rampTypeView
   didReturnRampType:(NSInteger)rampType;

@end

@interface RampTypeView : UIView

@property (nonatomic, weak) id <RampTypeViewDelegate> delegate;
@property (nonatomic) NSArray *rampImageLabelText;

+ (RampTypeView *)showRampTypeViewWithView:(UIView *)view
                                  delegate:(id)delegate;

- (void)hideRampTypeView:(BOOL)animated;

@end