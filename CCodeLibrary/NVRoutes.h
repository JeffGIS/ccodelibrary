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

+ (NVRoutes *)getTotalDistanceArrayFromCoords:(NSArray *)fromCoords
                                     toCoords:(NSArray *)toCoords
                                     delegate:(id)delegate;

@end