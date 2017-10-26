//  HotSpotVideo.m
//  CCodeLibrary

#import "HotSpotVideo.h"
#import "UserDefaults.h"

@implementation HotSpotVideo

- (id)init
{
    self = [super init];
    
    if (self)
    {
        _imageFiles = NSMutableArray.array;
        _timeRanges = NSMutableArray.array;
    }

    return self;
}

- (void)dealloc
{
    [UserDefaults.defaults saveArray:_imageFiles.copy forKey:@"HotSpotVideoImageFiles"];
    [UserDefaults.defaults saveArray:_timeRanges.copy forKey:@"HotSpotVideoTimeRanges"];
    [UserDefaults.defaults saveInteger:_type forKey:@"HotSpotVideoType"];
}

@end
