//  NVWebView.h
//  CCodeLibrary

@import UIKit;

@interface NVWebView : UIView

+ (instancetype)showWebViewInView:(UIView *)view
                        urlString:(NSString *)urlString;

+ (instancetype)showWebViewInView:(UIView *)view
                   showFileAtPath:(NSString *)path;

- (void)hide:(BOOL)animated;

@end