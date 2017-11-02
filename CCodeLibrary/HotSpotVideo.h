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

@property int width, height, numImages, length;
@property HSVideoTypes type;
@property (nonatomic) NSMutableArray *imageFiles;
@property (nonatomic, copy) NSArray<NSNumber *> *timeRanges;
@property (nonatomic, copy) NSString *backgroundImageFile;

@end
