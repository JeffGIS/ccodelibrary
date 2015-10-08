//  NVDestinationOptions.h
//  CCodeLibrary

#import <UIKit/UIKit.h>

@class NVDestinationOptions;

@protocol NVDestinationOptionsDelegate <NSObject>

- (void)destinationOptions:(NVDestinationOptions *)destinationOptions
        didReturnFrequency:(CGFloat)frequency
                timeDepart:(NSInteger)timeDepart
                timeReturn:(NSInteger)timeReturn
             destinationID:(NSInteger)destinationID;

@end

@interface NVDestinationOptions : UIView

@property (nonatomic, weak) id <NVDestinationOptionsDelegate> delegate;

+ (NVDestinationOptions *)showDestinationOptionsInView:(UIView *)view
                                              delegate:(id)delegate
                                             frequency:(CGFloat)frequency
                                            timeDepart:(NSInteger)timeDepart
                                            timeReturn:(NSInteger)timeReturn
                                         destinationID:(NSInteger)destinationID;

- (void)hideDestinationOptions:(BOOL)animated;

@end