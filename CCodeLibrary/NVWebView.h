//  NVWebView.h
//  CCodeLibrary

@import UIKit;

@interface NVWebView : UIView

+ (instancetype)showWebViewInView:(UIView *)view
                        urlString:(NSString *)urlString;

- (void)hide:(BOOL)animated;

@end