//  NVReferenceView.h
//  CCodeLibrary

@import UIKit;

@interface NVReferenceView : UIView

@property NSArray * references;
@property int currentReferenceIndex;
@property UIView *containerView;
@property NVWebView *nvwv;

+ (void)showReference:(NSString *)reference
               inView:(UIView *)view;

@end
