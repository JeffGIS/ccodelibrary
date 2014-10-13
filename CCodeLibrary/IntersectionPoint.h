//  IntersectionPoint.h
//  CCodeLibrary

#import <Foundation/Foundation.h>

#define INT_ELEMENT_TYPE_RAMP   1
#define INT_ELEMENT_TYPE_XWALK  2
#define INT_ELEMENT_TYPE_SIGNAL 3
#define INT_ELEMENT_TYPE_INTERSECTION   4

@interface IntersectionPoint : NSObject

@property int intID;
@property int status;
@property int nramps;
@property double latitude;
@property double longitude;
@property double dist;

@end

@interface IntersectionElement : NSObject

@property int intID;
@property int elementID;
@property int type;
@property int lev21x;
@property int lev21y;
@property double dist;

@end