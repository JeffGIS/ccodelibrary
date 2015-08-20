//  NVRoutes.m
//  CCodeLibrary

#import "NVRoutes.h"

@interface NVRoutes ()

@property (nonatomic) NSMutableArray *distanceArray;
@property NSUInteger count;

@end

@implementation NVRoutes

+ (NVRoutes *)getTotalDistanceArrayFromCoords:(CLLocationCoordinate2D *)fromCoords
                                numFromCoords:(NSUInteger)numFromCoords
                                     toCoords:(CLLocationCoordinate2D *)toCoords
                                  numToCoords:(NSUInteger)numToCoords
                                     delegate:(id)delegate
{
    NVRoutes *routes = [[NVRoutes alloc] init];
    routes.delegate = delegate;
    routes.count = 0;
    routes.distanceArray = [[NSMutableArray alloc] initWithCapacity:numFromCoords];
    
    for (int i = 0; i < numFromCoords; i++)
        [routes.distanceArray addObject:NSNull.null];
    
    for (int i = 0; i < numFromCoords; i++)
    {
        MKPlacemark *fpm = [[MKPlacemark alloc] initWithCoordinate:fromCoords[i]
                                                          addressDictionary:nil];
        
        MKMapItem *fmi = [[MKMapItem alloc] initWithPlacemark:fpm];
        
        __block NSUInteger jCount = 0;
        __block CLLocationDistance jDistance = 0.0;
        __block BOOL receivedError = NO;
        
        for (int j = 0; j < numToCoords; j++)
        {
            MKPlacemark *tpm = [[MKPlacemark alloc] initWithCoordinate:toCoords[j]
                                                     addressDictionary:nil];
            
            MKMapItem *tmi = [[MKMapItem alloc] initWithPlacemark:tpm];
            
            MKDirectionsRequest *request = [[MKDirectionsRequest alloc] init];
            request.source = fmi;
            request.destination = tmi;
            request.transportType = MKDirectionsTransportTypeAutomobile;
            request.requestsAlternateRoutes = NO;
            
            MKDirections *directions = [[MKDirections alloc] initWithRequest:request];
            
            [directions calculateDirectionsWithCompletionHandler:
             ^(MKDirectionsResponse *response, NSError *error) {
                 routes.count++;
                 jCount++;
                 
                 if (error)
                 {
                     NSLog(@"MKDR ERROR(%d:%d):%@", i, j, error.localizedDescription);
                     receivedError = YES;
                     
                     [routes.distanceArray replaceObjectAtIndex:i
                                                     withObject:[NSNumber numberWithInteger:-error.code]];
                 }
                 
                 else if (!receivedError)
                 {
                     MKRoute *theRoute = response.routes[0];
                     jDistance += theRoute.distance;
                     
                     if (jCount == numToCoords)
                     {
                         [routes.distanceArray replaceObjectAtIndex:i
                                                         withObject:[NSNumber numberWithDouble:jDistance]];
                     }
                 }
                 
                 if (routes.count == (numToCoords * numFromCoords) && routes.delegate)
                     [routes.delegate NVRoutesDidReturnDistanceArray:routes.distanceArray];
             }];
        }
    }
    
    return routes;
}

@end