//  RampTypeView.h
//  CCodeLibrary

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, RampType)
{
    RampTypePerp,
    RampTypePerpNonWalk,
    RampTypeCombPerpWalk,
    RampTypeCombPerpNonWalk,
    RampTypeOneWayDirCurbGutter,
    RampTypeOneWayDirBlendTrans,
    RampTypeParallel,
    RampTypeDepressedCorner,
    RampTypeFan,
    RampTypeCombLeftWalk,//left side of RampTypeCombPerpWalk
    RampTypeCombRightWalk,//right side of RampTypeCombPerpWalk
    RampTypeCombLeftNonWalk,//left side of RampTypeCombPerpNonWalk
    RampTypeCombRightNonWalk,//right side of RampTypeCombPerpNonWalk
    rampTypeCount //always last item
};

#define lastSelectableRampType RampTypeFan

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

+ (NSArray *)rampTypeImages;
+ (NSArray *)rampTypeText;

- (void)hideRampTypeView:(BOOL)animated;

@end