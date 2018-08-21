//  NVWebView.h
//  CCodeLibrary

@import UIKit;
@import WebKit;
#import "CCodeTypes.h"
#import "NVPDFDrawing.h"
#import "DPoint.h"
#import "GSSiEnums.h"

typedef NS_ENUM(NSInteger, NVPDFDocument)
{
    NVPDFDocumentMNAccessbility,
    NVPDFDocumentFederalADA,
    NVPDFDocumentADAChecklist,
};

@interface NVWebViewMarker : UIView

@property CGPoint position;

@end

@interface NVEllipseView : UIView

@property (nonatomic) UIColor *fillColor;

@end

@class NVWebView;

@protocol NVWebViewDelegate <NSObject>

@optional
- (void)webViewDidReturn:(NVWebView *)webView;
- (void)webViewDidZoom;
- (void)webViewDidFinishNavigation:(NVWebView *)webView;
- (void)webViewDidRequestNextImage:(NVWebView *)webView;
- (void)webViewDidRequestPreviousImage:(NVWebView *)webView;
- (void)webViewDidReturnHtmlString:(NSString *)htmlString;

- (void)webView:(NVWebView *)webView
wasTappedAtPoint:(DPOINT)point
     withinPage:(int)page;

- (void)webView:(NVWebView *)webView
wasLongPressedAtPoint:(DPOINT)point
     withinPage:(int)page;

- (void)windowWasSelectedWithIdentifierTag:(int)identifierTag;
- (void)webViewDidRemoveLastMarker;
- (void)webViewWasLeftSwiped;
- (void)webViewWasRightSwiped;
- (void)webViewDidRemovePolygon;
- (void)tapViewFinished;

@end

@interface NVWebView : UIView

@property (nonatomic, weak) id <NVWebViewDelegate> delegate;
@property BOOL drawsMarkers, drawsMultipleMarkers;
@property (nonatomic) BOOL rotationEnabled;
@property int numPages;

+ (instancetype)showWebViewInView:(UIView *)view
                        urlString:(NSString *)urlString;

+ (instancetype)showWebViewInView:(UIView *)view
                   showFileAtPath:(NSString *)path
                         delegate:(id)delegate;

+ (instancetype)showPDFDrawing:(NVPDFDrawing *)drawing
                  fromDocument:(NVPDFDocument)document
                        inView:(UIView *)view
                withHighlights:(NSString *)highlights
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
- (void)showNextAndPrevious;
- (void)updateImageViewToImageAtPath:(NSString *)path;
- (CORNERPOINTS)cornerPoints;
- (void)getHtmlString;
- (void)disableZoomScroll;
- (void)addLongPressGestureResponder;

- (void)drawShapeWithPoint:(DPoint *)point
                      type:(PointSymbols)type;

- (void)drawPolylineWithPoints:(NSArray<DPoint *> *)points
                          type:(PolylineSymbols)type;

- (void)drawPolygonWithPoints:(NSArray<DPoint *> *)points
                         type:(PolygonSymbols)type;

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

- (BOOL)addViewToFrameWithUpperLeft:(DPOINT)upperLeft
                         lowerRight:(DPOINT)lowerRight;

- (void)addEllipseToFrameWithUpperLeft:(DPOINT)upperLeft
                            lowerRight:(DPOINT)lowerRight;

@end
