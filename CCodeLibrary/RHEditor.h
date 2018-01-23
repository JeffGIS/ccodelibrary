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

@property int clipID; //set to 0 for new clip, non zero to edit existing clip
@property double startTime, endTime;
@property double cost;
@property int timestamp;
@property RHClipQuality quality;
@property (nonatomic, copy) NSString *title, *notes, *pid, *videoFileName;

@end

@class RHEditor;

@protocol RHEditorDelegate <NSObject>

- (NSString *)pidForCoord:(CLLocationCoordinate2D *)coord;

@end

@interface RHEditor : UIViewController

@property (nonatomic, weak) id<RHEditorDelegate> delegate;

@end
