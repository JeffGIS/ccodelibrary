//  NVPhotoController.h
//  CCodeLibrary

@import UIKit;
@import CoreLocation;

@interface NVPhoto : NSObject

+ (instancetype)photoWithIdentifier:(NSString *)identifier
                                key:(NSString *)key;

@end

@class NVPhotoController;

@protocol NVPhotoControllerDelegate <NSObject>

- (NSString *)getImagePath:(NVPhotoController *)controller
                    forKey:(NSString *)key;

@end

@interface NVPhotoController : UIViewController

+ (instancetype)photoControllerWithNVPhotosArray:(NSArray *)photosArray
                                        delegate:(id)delegate
                                           title:(NSString *)title;

@end

@interface NVPhotoViewOverlay : UIView

@property (nonatomic) CGPoint startPoint, endPoint;
@property (nonatomic) CGColorRef strokeColor;

@end

@class NVPhotoView;

@protocol NVPhotoViewDelegate <NSObject>

- (NSString *)getInsetImagePath:(NVPhotoView *)photoView
                         forKey:(NSString *)key;

- (CGPoint)getPointForCoordinate:(CLLocationCoordinate2D)coordinate;
- (CGFloat)getVerticalOffset;
- (void)didAddPhotoView;

@end

@interface NVPhotoView : UIImageView

@property (nonatomic) NVPhotoViewOverlay *overlay;

+ (instancetype)showPhotoViewWithNVPhotosArray:(NSArray *)photosArray
                                        inView:(UIView *)view
                                      delegate:(id)delegate
                                    coordinate:(CLLocationCoordinate2D)coordinate;

- (void)updatePosition;
- (void)hidePhotoView:(BOOL)animated;

- (void)updateVerticalOffset:(CGFloat)verticalOffset
                    animated:(BOOL)animated;

@end