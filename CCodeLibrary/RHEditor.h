//  RHEditor.h
//  CCodeLibrary

@import UIKit;

typedef NS_ENUM(NSInteger, RHClipQuality)
{
    RHClipQualityNeutral,
    RHClipQualityPro,
    RHClipQualityCon,
};

@interface RHClip: NSObject

@property double startTime, endTime;
@property RHClipQuality quality;
@property (nonatomic, copy) NSString *title, *notes;

@end

@interface RHEditor : UIViewController

@end
