//  RHClip.m
//  CCodeLibrary

#import "RHClip.h"
#import "UserDefaults.h"

@implementation RHClip

+ (NSString *)stringForQuality:(RHClipQuality)quality
{
    NSString *qualityString = nil;
    
    switch (quality)
    {
        default:
        case RHClipQualityNeutral:
            qualityString = @"Neutral";
            break;
        case RHClipQualityPro:
            qualityString = @"Pro";
            break;
        case RHClipQualityCon:
            qualityString = @"Con";
            break;
    }
    
    return qualityString;
}

+ (UIColor *)colorForQuality:(RHClipQuality)quality
{
    UIColor *color = nil;
    
    switch (quality)
    {
        default:
        case RHClipQualityNeutral:
            color = UIColor.blackColor;
            break;
        case RHClipQualityPro:
            color = UserDefaults.defaults.darkGreen;
            break;
        case RHClipQualityCon:
            color = UIColor.redColor;
            break;
    }
    
    return color;
}

- (NSString *)description
{
    NSString *qualityString = [RHClip stringForQuality:_quality];
    NSString *notesString = [_notes stringByReplacingOccurrencesOfString:@"\n" withString:@" "];
    
    return [NSString stringWithFormat:@"PROPNUM:%d, CLIPID:%d, TITLE:%@, START:%f, END:%f, "
            "QUALITY:%@, COST:%f, NOTES:%@ ", _propNum, _clipID, _title, _startTime,
            _endTime, qualityString, _cost, notesString];
}

@end
