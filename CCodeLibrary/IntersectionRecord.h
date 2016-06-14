//  IntersectionRecord.h
//  CCodeLibrary

#import <Foundation/Foundation.h>

typedef struct {
    int intID;
    int lastUpdateTime;
    int status;
    int assignedToPrelim;
    int assignedToDetail;
    int lev21X;
    int lev21Y;
    int rotation;
    int ramp1;
    int ramp2;
    int ramp3;
    int ramp4;
    int ramp5;
    int ramp6;
    int ramp7;
    int ramp8;
    int ramp81;
    int ramp23;
    int ramp45;
    int ramp67;
    int xWalkA;
    int xWalkB;
    int xWalkC;
    int xWalkD;
    int signal81;
    int signal23;
    int signal45;
    int signal67;
    int nStreets;
    char streetNames[512];
    char streetAzms[128];
    double lat;
    double lon;
    char comment[256];
    int  doLater;
    int  zoomLevel;
}INTERSECTION_STRUCT;

@interface IntersectionRecord : NSObject

@property int intID;
@property int lev21X;
@property int lev21Y;
@property int rotation;
@property int ramp1;
@property int ramp2;
@property int ramp3;
@property int ramp4;
@property int ramp5;
@property int ramp6;
@property int ramp7;
@property int ramp8;
@property int ramp81;
@property int ramp23;
@property int ramp45;
@property int ramp67;
@property int xWalkA;
@property int xWalkB;
@property int xWalkC;
@property int xWalkD;
@property int signal81;
@property int signal23;
@property int signal45;
@property int signal67;

@end