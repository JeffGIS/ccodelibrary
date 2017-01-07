//  NVWebView.h
//  CCodeLibrary

@import UIKit;
@import WebKit;
#import "CCodeTypes.h"

@class NVWebView;

@protocol NVWebViewDelegate <NSObject>

@optional
- (void)webViewDidReturn:(NVWebView *)webView;

- (void)webView:(NVWebView *)webView
wasTappedAtPoint:(DPOINT)point
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
- (void)gotoOriginalPosition;
- (void)disableUserInteraction;
- (void)enableUserInteraction;
- (void)clearPosition;
- (void)updatePosition;

- (void)zoomToPage:(int)page
         upperLeft:(DPOINT)upperLeft
        lowerRight:(DPOINT)lowerRight;

- (void)setConstraintsToLeading:(CGFloat)leading
                       trailing:(CGFloat)trailing
                            top:(CGFloat)top
                         bottom:(CGFloat)bottom;

- (void)zoomToPoint:(DPOINT)point
         withinPage:(int)page
          withScale:(CGFloat)scale
           rotation:(CGFloat)rotation;

@end
