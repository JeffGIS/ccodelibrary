//  DPoint.h
//  CCodeLibrary

@import Foundation;
#import "CCodeTypes.h"

@interface DPoint : NSObject

+ (DPoint *)fromDPOINT:(LPDPOINT)dpt;

@property double x;
@property double y;

@end
