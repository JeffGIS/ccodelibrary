//  NVPhotoController.h
//  CCodeLibrary

@import UIKit;

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