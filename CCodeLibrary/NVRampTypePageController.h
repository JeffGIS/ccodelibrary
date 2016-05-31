//  NVRampTypePageController.h
//  CCodeLibrary

@import UIKit;

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
    RampTypeBuiltUp,
    RampTypeCombLeftWalk,//left side of RampTypeCombPerpWalk
    RampTypeCombRightWalk,//right side of RampTypeCombPerpWalk
    RampTypeCombLeftNonWalk,//left side of RampTypeCombPerpNonWalk
    RampTypeCombRightNonWalk,//right side of RampTypeCombPerpNonWalk
    RampTypeCombBuiltUpLeft,//left side of RampTypeCombBuiltUp
    RampTypeCombBuiltUpRight,//right side of RampTypeCombBuiltUp
    rampTypeCount //always last item
};

#define lastSelectableRampType RampTypeBuiltUp

typedef NS_ENUM(NSInteger, RampTypeEditOption)
{
    RampTypeEditOptionDefault,
    RampTypeEditOptionGlobal,
    RampTypeEditOptionIndividual,
};

@interface NVRampType : NSObject

@property (nonatomic) NSString *imageName, *displayText;
@property RampType type;

@end

@class NVRampTypePageController;

@protocol NVRampTypePageControllerDelegate <NSObject>

- (void)rampTypeController:(NVRampTypePageController *)rampTypeController
         didReturnRampType:(RampType)rampType
                editOption:(RampTypeEditOption)editOption;

@end

@interface NVRampTypePageController : UIPageViewController

+ (instancetype)rampTypeControllerWithDelegate:(id)delegate
                                  selectedType:(RampType)selectedType
                                    editOption:(RampTypeEditOption)editOption;

+ (NSArray *)defaultRampTypes;

@end