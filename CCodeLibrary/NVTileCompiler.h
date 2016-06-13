//  NVTileCompiler.h
//  CCodeLibrary

@import UIKit;

@class NVTileCompiler;

@protocol NVTileCompilerDelegate <NSObject>

- (void)tileCompilerReturnedImagePath:(NSString *)imagePath
                           hideTarget:(BOOL)hideTarget;

@end

@interface NVTileCompiler : NSObject

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