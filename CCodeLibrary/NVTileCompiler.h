//  NVTileCompiler.h
//  CCodeLibrary

@import UIKit;
#import "NVAlertView.h"

@class NVTileCompiler;

@protocol NVTileCompilerDelegate <NSObject>

- (void)tileCompilerReturnedImagePath:(NSString *)imagePath;

@end

@interface NVTileCompiler : NSObject <NSURLSessionDataDelegate,NSURLSessionTaskDelegate>

@property (nonatomic, weak) id <NVTileCompilerDelegate> delegate;

+ (NVTileCompiler *)compileImageForIntersectionID:(int)intersectionID
                                              lat:(double)lat
                                              lon:(double)lon
                                             zoom:(int)zoom
                                     forceRefresh:(BOOL)forceRefresh
                                         delegate:(id)delegate
                                      currentView:(UIView *)currentView;

@end

@interface NVTile : NSObject

@property (nonatomic) NSMutableData *mutableData;
@property (nonatomic) UIImage *tileImage;
@property (nonatomic) int tilex, tiley, nxpixels, nypixels;
@property (nonatomic) int xintile, yintile, xincomposite, yincomposite;
@property (nonatomic, copy) NSString *filepath;

@end