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
@property int timestamp;
@property RHClipQuality quality;
@property (nonatomic, copy) NSString *title, *notes;

@end

@class RHEditor;

@protocol RHEditorDelegate <NSObject>

- (NSString *)pidForCoord:(CLLocationCoordinate2D *)coord;

@end

@interface RHEditor : UIViewController

@property (nonatomic, weak) id<RHEditorDelegate> delegate;

@end
