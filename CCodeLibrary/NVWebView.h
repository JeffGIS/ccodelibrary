//  NVWebView.h
//  CCodeLibrary

@import UIKit;
@import WebKit;
#import "CCodeTypes.h"
#import "NVPDFDrawing.h"

typedef NS_ENUM(NSInteger, NVPDFDocument)
{
    NVPDFDocumentMNAccessbility,
    NVPDFDocumentFederalADA,
    NVPDFDocumentADAChecklist,
};

@class NVWebView;

@protocol NVWebViewDelegate <NSObject>

@optional
- (void)webViewDidReturn:(NVWebView *)webView;
- (void)webViewDidZoom;

- (void)webView:(NVWebView *)webView
wasTappedAtPoint:(DPOINT)point
     withinPage:(int)page;

- (void)windowWasSelectedWithIdentifierTag:(int)identifierTag;
- (void)webViewDidRemoveLastMarker;
- (void)webViewWasLeftSwiped;
- (void)webViewWasRightSwiped;
- (void)webViewDidRemovePolygon;

@end

@interface NVWebView : UIView

@property (nonatomic, weak) id <NVWebViewDelegate> delegate;
@property BOOL drawsMarkers, rotationEnabled, drawsMultipleMarkers;

+ (instancetype)showWebViewInView:(UIView *)view
                        urlString:(NSString *)urlString;

+ (instancetype)showWebViewInView:(UIView *)view
                   showFileAtPath:(NSString *)path;

+ (instancetype)showPDFDrawing:(NVPDFDrawing *)drawing
                  fromDocument:(NVPDFDocument)document
                        inView:(UIView *)view
                   enableSwipe:(BOOL)enableSwipe;

- (void)hide:(BOOL)animated;
- (void)showRealtorButton;
- (void)hideReturnButton;
- (void)gotoOriginalPosition;
- (void)disableUserInteraction;
- (void)enableUserInteraction;
- (void)clearPosition;
- (void)updatePosition;
- (void)removeLastMarker;
- (void)maskPolygon;

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

- (void)addTapWindowToFrameWithUpperLeft:(DPOINT)upperLeft
                              lowerRight:(DPOINT)lowerRight
                           identifierTag:(int)identifierTag;

@end
