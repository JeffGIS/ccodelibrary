//  GetPriorityLocations.h
//  CCodeLibrary

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import "PriorityLocation.h"
#import "PointInAreaClass.h"
#import "GSSiEnums.h"
#import "GSSiPopoverView.h"
#import "UserDefaults.h"
#import "MathUtil.h"

@class GetPriorityLocations;

@protocol GetPriorityLocationsDelegate <NSObject>

@optional
- (void)didFinishPriorityLocationArray:(NSMutableArray *)locationArray;
- (void)didFinishCustomNearbySearchArray:(NSMutableArray *)nearbySearchArray;
- (void)didFinishWithZeroResults;

@end

@interface GetPriorityLocations : NSObject

@property (nonatomic, weak) id <GetPriorityLocationsDelegate> delegate;

+ (GetPriorityLocations *)getLocations;
+ (void)savePriorityLocations:(NSMutableArray *)contents;
+ (NSMutableArray *)getPriorityLocations;

- (void)drawAccessoryImageForType:(NSInteger)type
                             cell:(UITableViewCell *)cell;

- (void)priorityLocationArrayForBounds:(dbounds)bounds
                               popover:(GSSiPopoverView *)popover;

- (void)customPriorityLocationSearchForKeyword:(NSString *)keyword
                                        target:(CLLocationCoordinate2D)target
                                        radius:(CGFloat)radius
                                       popover:(GSSiPopoverView *)popover;

- (void)addCustomPriorityLocationToList:(PriorityLocation *)pLoc;

- (void)tryMKLocalSearch:(NSString *)keyword
                  region:(MKCoordinateRegion)region
                 popover:(GSSiPopoverView *)popover;

- (NSArray *)categoryNames;

@end