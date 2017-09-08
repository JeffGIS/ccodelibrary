//  FacilityRecord.h
//  CCodeLibrary

@import Foundation;

typedef struct {
    int facID;
    int lastUpdateTime;
    int status;
    int assignedTo;
    int lev21X;
    int lev21Y;
    int rotation;
    int nStreets;
    char streetNames[512];
    char streetAzms[128];
}FACILITY_STRUCT;

@interface FacilityRecord : NSObject

@property int intID;
@property int lev21X;
@property int lev21Y;
@property int rotation;

@end
