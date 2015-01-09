//  PriorityLocation.h
//  CCodeLibrary

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <UIKit/UIKit.h>

@interface PriorityLocation : NSObject <NSCoding>

@property (nonatomic) CLLocationCoordinate2D coordinate;
@property (nonatomic) CGFloat radius;
@property (nonatomic) NSInteger offset;
@property (nonatomic, copy) NSString *name;
@property (nonatomic) NSNumber *type;

@end