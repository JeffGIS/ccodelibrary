//  Facility.h
//  CCodeLibrary

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface Facility : NSObject

@property DPOINT location;
@property int zoomLevel;
@property int facID;

@property (nonatomic, copy) NSString *name;

@end
