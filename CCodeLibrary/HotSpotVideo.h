//  HotSpotVideo.h
//  CCodeLibrary

@import Foundation;

typedef NS_ENUM(NSInteger, HSVideoTypes)
{
    HSTypeTime,
    HSTypeDow,
    HSTypeHour,
};

@interface HotSpotVideo : NSObject

@property int width, height, numImages;
@property HSVideoTypes type;
@property (nonatomic) NSMutableArray *imageFiles, *timeRanges;
@property (nonatomic, copy) NSString *backgroundImageFile;

@end
