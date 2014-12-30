//  PriorityLocation.h
//  CCodeLibrary

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface PriorityLocation : NSObject

@property (nonatomic) CLLocationCoordinate2D coordinate;
@property (nonatomic, copy) NSString *name;
@property (nonatomic) NSInteger type;

@end