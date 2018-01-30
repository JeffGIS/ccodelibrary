//  RHClip.m
//  CCodeLibrary

#import "RHClip.h"

@implementation RHClip

- (NSString *)description
{
    NSString *qualityString = @"";
    NSString *notesString = [_notes stringByReplacingOccurrencesOfString:@"\n" withString:@" "];
    
    switch (_quality)
    {
        case RHClipQualityNeutral:
            qualityString = @"Neutral";
            break;
        case RHClipQualityPro:
            qualityString = @"Pro";
            break;
        case RHClipQualityCon:
            qualityString = @"Con";
            break;
        default:break;
    }
    
    return [NSString stringWithFormat:@"PROPNUM:%d, TITLE:%@, START:%f, END:%f, QUALITY:%@, COST:%f, NOTES:%@ ",
            _propNum, _title, _startTime, _endTime, qualityString, _cost, notesString];
}

@end
