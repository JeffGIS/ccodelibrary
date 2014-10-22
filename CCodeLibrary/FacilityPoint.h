//  FacilityPoint.h
//  CCodeLibrary

#import <Foundation/Foundation.h>

@interface FacilityPoint : NSObject

@property int facID;
@property short assignedTo;
@property short status;
@property int nramps;
@property double latitude;
@property double longitude;
@property double dist;

@end