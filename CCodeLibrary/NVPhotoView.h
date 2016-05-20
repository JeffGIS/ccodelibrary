//
//  NVPhotoView.h
//  CCodeLibrary
//
//  Created by Jeff Smith on 5/20/16.
//  Copyright © 2016 GSSi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NVPhotos : NSObject
@property NSString * description;
@property NSString * key;
@end

@class NVPhotoView;

@protocol NVPhotoViewDelegate <NSObject>

- (NSString*)getImagePath:(NVPhotoView *)NVPhotoView
                   forKey:(NSString*)key;

@end

@interface NVPhotoView : UIView

@property (nonatomic, weak) id <NVPhotoViewDelegate> delegate;

+ (NVPhotoView *)showPhotoViewinView:(UIView *)view
                         NVPhotosArray:(NSArray*)photosArray
                            delegate:(id)delegate
                               title:(NSString *)title;

- (void)hidePhotoView:(BOOL)animated;

@end