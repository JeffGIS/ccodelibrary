//  RampTypeView.h
//  CCodeLibrary

#import <UIKit/UIKit.h>
#import "NVRampTypePageController.h"

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