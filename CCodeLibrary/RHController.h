//  RHController.h
//  CCodeLibrary

@import UIKit;

@class RHController;

@protocol RHControllerDelegate <NSObject>

- (void)controllerDidTapPlayRecordButton;
- (void)controllerDidTapConnectButton;
- (void)controllerDidTapReturnButton;

@end

@interface RHController : UIView

@property (nonatomic) UIButton *playRecordButton;

- (void)showInView:(UIView *)view
          delegate:(id<RHControllerDelegate>)delegate;

- (void)incrementTime;
- (void)startTimer;
- (void)stopTimer;
- (void)updateConnectButton;

@end
