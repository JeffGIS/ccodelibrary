//  NVRampTypePageController.h
//  CCodeLibrary

@import UIKit;
#import "RampStruct.h"

#define lastSelectableRampType RampTypeOneWayDirCurbGutter

typedef NS_ENUM(NSInteger, RampTypeEditOption)
{
    RampTypeEditOptionDefault,
    RampTypeEditOptionGlobal,
    RampTypeEditOptionIndividual,
};

@interface NVRampType : NSObject

@property (nonatomic, copy) NSString *imageName, *displayText;
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
