//  NVRoutes.m
//  CCodeLibrary

#import "NVRoutes.h"

@interface NVRoutes ()

@property (nonatomic) NSMutableArray *distanceArray;
@property NSUInteger count;

@end

@implementation NVRoutes

+ (NVRoutes *)getTotalDistanceArrayFromCoords:(NSArray *)fromCoords
                                     toCoords:(NSArray *)toCoords
                                     delegate:(id)delegate
{
    if (!fromCoords.count || !toCoords.count)
        return nil;
    
    NVRoutes *routes = [[NVRoutes alloc] init];
    routes.delegate = delegate;
    routes.count = 0;
    routes.distanceArray = [[NSMutableArray alloc] initWithCapacity:fromCoords.count];
    
    for (int i = 0; i < fromCoords.count; i++)
        [routes.distanceArray addObject:NSNull.null];
    
    for (int i = 0; i < fromCoords.count; i++)
    {
        MKPlacemark *fpm = [[MKPlacemark alloc] initWithCoordinate:[fromCoords[i] coordinate]
                                                 addressDictionary:nil];
        
        MKMapItem *fmi = [[MKMapItem alloc] initWithPlacemark:fpm];
        
        __block NSUInteger jCount = 0;
        __block CLLocationDistance jDistance = 0.0;
        __block BOOL receivedError = NO;
        
        for (int j = 0; j < toCoords.count; j++)
        {
            MKPlacemark *tpm = [[MKPlacemark alloc] initWithCoordinate:[toCoords[j] coordinate]
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
                     
                     if (jCount == toCoords.count)
                     {
                         [routes.distanceArray replaceObjectAtIndex:i
                                                         withObject:[NSNumber numberWithDouble:jDistance]];
                     }
                 }
                 
                 if (routes.count == (toCoords.count * fromCoords.count) && routes.delegate)
                     [routes.delegate NVRoutesDidReturnDistanceArray:routes.distanceArray];
             }];
        }
    }
    
    return routes;
}

@end