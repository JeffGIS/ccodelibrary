//  NVRoutes.h
//  CCodeLibrary

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@class NVRoutes;

@protocol NVRoutesDelegate <NSObject>

- (void)NVRoutesDidReturnDistanceArray:(NSArray *)distanceArray;

@end

@interface NVRoutes : NSObject

@property (nonatomic, weak) id <NVRoutesDelegate> delegate;

+ (NVRoutes *)getTotalDistanceArrayFromCoords:(CLLocationCoordinate2D *)fromCoords
                                numFromCoords:(NSUInteger)numFromCoords
                                     toCoords:(CLLocationCoordinate2D *)toCoords
                                  numToCoords:(NSUInteger)numToCoords
                                     delegate:(id)delegate;

@end