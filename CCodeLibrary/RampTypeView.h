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

typedef NS_ENUM(NSInteger, RampTypeEditOption)
{
    RampTypeEditOptionDefault,
    RampTypeEditOptionGlobal,
    RampTypeEditOptionIndividual,
};

@class RampTypeView;

@protocol RampTypeViewDelegate <NSObject>

- (void)rampTypeView:(RampTypeView *)rampTypeView
   didReturnRampType:(RampType)rampType
          editOption:(RampTypeEditOption)editOption;

@end

@interface RampTypeView : UIView

@property (nonatomic, weak) id <RampTypeViewDelegate> delegate;
@property (nonatomic) NSArray *rampImageLabelText;

+ (RampTypeView *)showRampTypeViewWithView:(UIView *)view
                                  delegate:(id)delegate
                              selectedType:(RampType)selectedType
                                editOption:(RampTypeEditOption)editOption;

- (void)hideRampTypeView:(BOOL)animated;

@end