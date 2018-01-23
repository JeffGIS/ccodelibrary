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
@property int timestamp, propNum;
@property RHClipQuality quality;
@property (nonatomic, copy) NSString *title, *notes, *videoFileName;

@end

@interface RHEditor : UIViewController

+ (instancetype)editorWithPropNum:(int)propNum
                         delegate:(id)delegate;

@end
