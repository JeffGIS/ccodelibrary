//  RHClip.h
//  CCodeLibrary

@import Foundation;

typedef NS_ENUM(NSInteger, RHClipQuality)
{
    RHClipQualityNeutral,
    RHClipQualityPro,
    RHClipQualityCon,
};

@interface RHClip : NSObject

@property int clipID; //set to 0 for new clip, non zero to edit existing clip
@property double startTime, endTime, cost;
@property int propNum;
@property RHClipQuality quality;
@property (nonatomic, copy) NSString *title, *notes, *videoFileName;

@end
