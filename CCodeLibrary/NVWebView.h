//  NVWebView.h
//  CCodeLibrary

@import UIKit;

@class NVWebView;

@protocol NVWebViewDelegate <NSObject>

@optional
- (void)webViewDidReturn:(NVWebView *)webView;

@end

@interface NVWebView : UIView

@property (nonatomic, weak) id <NVWebViewDelegate> delegate;

+ (instancetype)showWebViewInView:(UIView *)view
                        urlString:(NSString *)urlString;

+ (instancetype)showWebViewInView:(UIView *)view
                   showFileAtPath:(NSString *)path;

- (void)hide:(BOOL)animated;
- (void)showRealtorButton;

@end