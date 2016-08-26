//  NVWebView.h
//  CCodeLibrary

@import UIKit;

@class NVWebView;

@protocol NVWebViewDelegate <NSObject>

@optional
- (void)webViewDidReturn:(NVWebView *)webView;

- (void)webView:(NVWebView *)webView
wasTappedAtPoint:(CGPoint)point
     withinPage:(int)page;

@end

@interface NVWebView : UIView

@property (nonatomic, weak) id <NVWebViewDelegate> delegate;

+ (instancetype)showWebViewInView:(UIView *)view
                        urlString:(NSString *)urlString;

+ (instancetype)showWebViewInView:(UIView *)view
                   showFileAtPath:(NSString *)path;

- (void)hide:(BOOL)animated;
- (void)showRealtorButton;
- (void)hideReturnButton;

- (void)zoomToPoint:(CGPoint)point
         withinPage:(int)page
          withScale:(CGFloat)scale
           rotation:(CGFloat)rotation;

@end