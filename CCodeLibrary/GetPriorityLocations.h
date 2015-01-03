//  GetPriorityLocations.h
//  CCodeLibrary

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "PriorityLocation.h"
#import "PointInAreaClass.h"
#import "GSSiEnums.h"
#import "GSSiPopoverView.h"
#import "UserDefaults.h"
#import "MathUtil.h"

@class GetPriorityLocations;

@protocol GetPriorityLocationsDelegate <NSObject>

- (void)didFinishPriorityLocationArray:(NSMutableArray *)locationArray;

@end

@interface GetPriorityLocations : NSObject

@property (nonatomic, weak) id <GetPriorityLocationsDelegate> delegate;

+ (GetPriorityLocations *)getLocations;

- (void)drawAccessoryImageForType:(NSInteger)type
                             cell:(UITableViewCell *)cell;

- (void)priorityLocationArrayForBounds:(dbounds)bounds
                           popoverView:(GSSiPopoverView *)popover;

@end