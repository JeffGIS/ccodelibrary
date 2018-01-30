//  RHWalkScore.h
//  CCodeLibrary

@import Foundation;

#define RH_SCORE_NONE -1;
#define RH_DESCRIPTION_NONE @"Not Available"

@class RHWalkScore;

@protocol RHWalkScoreDelegate <NSObject>

- (void)walkScoreDidReturnItem:(RHWalkScore *)item;
- (void)walkScoreDidReceiveError:(NSString *)error;

@end

@interface RHWalkScore : NSObject

@property (nonatomic, weak) id<RHWalkScoreDelegate> delegate;

@property int walkScore, transitScore, bikeScore, lastUpdate;
@property (nonatomic) NSString *walkDescription, *transitDescription, *bikeDescription;

+ (instancetype)walkScoreWithDelegate:(id<RHWalkScoreDelegate>)delegate;

- (bool)getWalkScoreForAddress:(NSString *)address
                          city:(NSString *)city
                         state:(NSString *)state
                           zip:(int)zip
                           lat:(float)lat
                           lon:(float)lon;

@end
