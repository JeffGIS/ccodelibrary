//  MPIntersection.h
//  CCodeLibrary

#define RAMP 1
#define STREET 2
#define UPPER 3
#define STREETLANDING 2
#define UPPERLANDING 3
#define FLARELEFT 4
#define FLARERIGHT 5
#define SWKLEFT 6
#define SWKRIGHT 7
#define HEADINGERRORDIF 75

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "NVRampTypePageController.h"
#import "IntersectionPoint.h"
#import "GSSiEnums.h"
#import "RampStruct.h"

typedef NS_ENUM(NSInteger, CrackType)
{
    CrackTypeRamp,
    CrackTypeUpperLanding,
    CrackTypeStreetLanding,
    CrackTypeLeftSidewalk,
    CrackTypeRightSidewalk,
};

typedef NS_ENUM(NSInteger, MiddleMeasurement)
{
    MiddleMeasurementNone,
    MiddleMeasurementCurbCutDistance,
    MiddleMeasurementBumpWidth,
    MiddleMeasurementBumpHeight,
};

@interface PSRamp : NSObject
//Preliminary Survey Ramps
@property (nonatomic) int lev21x, lev21y;
@property (nonatomic) int imageX, imageY;
@property (nonatomic) int refno, rampID;
@property (nonatomic) float trueAz;
@property (nonatomic) int adjustedRot;

@end

@interface MPRamp : NSObject

@property int rampNum;
@property (nonatomic, copy) NSString *rampID;
@property int timeComplete;
@property int yearRebuilt;
@property BOOL rampExists;
@property BOOL isComplete;
@property (nonatomic) float approximateHeading;
@property int adjustedRot;
@property BOOL rampInXWalk;
@property BOOL xWalkisComplete, xWalkWidth;
@property BOOL signalisComplete;
@property (nonatomic) enum textures texture;
@property (nonatomic) enum obstructions upperLandingObstruction;
@property (nonatomic) enum obstructions lowerLandingObstruction;
@property (nonatomic) enum obstructions rampObstruction;
@property BOOL hasRampCracks;
@property BOOL hasUpperLandingCracks;
@property BOOL hasStreetLandingCracks;
@property BOOL hasLeftSidewalkCracks, hasRightSidewalkCracks;
@property BOOL gradeBreaksArePerpendicular, detectableWarningIsFullWidth;
@property CrackWidth crackWidth;
@property CrackType currentCrackMeasurement;//this need not be in copy or comparision methods (internal value - not in database)
@property MiddleMeasurement currentMiddleMeasurement;//this need not be in copy or comparision methods (internal value - not in database)
@property int detectableWarningDepth;
@property float domeSpacing, spaceBetweenDomes, domeBaseWidth, domeCapWidth;//these are for detectable warnings
@property DetectableWarningShape dwShape;//these are for detectable warnings
@property int dwMinOffset, dwMaxOffset, dwWidth, dwDepth;//these are for detectable warnings
@property int streetLandingDepth, leftXWalkSideWidth, rightXWalkSideWidth;//these are for diagonal ramp type
@property (nonatomic) int rampWidth, rampDepth;
@property (nonatomic) float rampSlopeFront;
@property (nonatomic) float rampSlopeSide;
@property (nonatomic) float rampSlopeHeading;
@property (nonatomic) float upperLandingSlopeFront;
@property (nonatomic) float upperLandingSlopeSide;
@property (nonatomic) float upperLandingSlopeHeading;
@property (nonatomic) float streetLandingSlopeFront;
@property (nonatomic) float streetLandingSlopeSide;
@property (nonatomic) float streetLandingSlopeHeading;
@property (nonatomic) float flareLeftSlopeFront;
@property (nonatomic) float flareLeftSlopeSide;
@property (nonatomic) float flareLeftSlopeHeading;
@property (nonatomic) float flareRightSlopeFront;
@property (nonatomic) float flareRightSlopeSide;
@property (nonatomic) float flareRightSlopeHeading;
@property (nonatomic) float swkLeftSlopeFront;
@property (nonatomic) float swkLeftSlopeSide;
@property (nonatomic) float swkLeftSlopeHeading;
@property (nonatomic) float swkRightSlopeFront;
@property (nonatomic) float swkRightSlopeSide;
@property (nonatomic) float swkRightSlopeHeading;
@property NVSignalType PEDSignalType;
@property NVButtonType PEDButtonType;
@property AudibleWalkIndication awi;
@property BOOL hasLocatorTone, hasInfoSign, hasBraille, hasTactileArrow;
@property (nonatomic) float locatorToneVolume, audibleWalkIndicationVolume;//dB measured from 3 feet
@property int PEDButtonHeight, PEDButtonDist;
@property (nonatomic) float SteepTopOfCurb;
@property (nonatomic) float PedRampLip;
@property int lev21x, lev21y;
@property NSString *rampComment;
@property RampType rampType;
@property float curbCutDistance;
@property float bumpWidth;
@property float bumpHeight;
@property NSString * fromFile;
@property int CornerID;
@property int Retired;

- (BOOL) isEqualTo:(MPRamp*)oldRamp;

@end

@interface MPIntersection : NSObject

@property (nonatomic) int intID;
@property (nonatomic) int intRotation;
@property int zoomLevel;
@property BOOL doLater;
@property (nonatomic) int timeComplete;
@property IntersectionStatus status;
@property int lastUpdate;
@property int assignedPrelim;
@property int assignedDetail;
@property (nonatomic) int currentCorner;
@property (nonatomic) int currentSignal;
@property (nonatomic) int currentObstruction;
@property (nonatomic) float currentCornerHeading;
@property int currentRamp;
@property (nonatomic, copy) NSString *name1;
@property BOOL signal23Exists;
@property BOOL signal45Exists;
@property BOOL signal67Exists;
@property BOOL signal81Exists;
@property (nonatomic) int signal23lev21x;
@property (nonatomic) int signal23lev21y;
@property (nonatomic) int signal45lev21x;
@property (nonatomic) int signal45lev21y;
@property (nonatomic) int signal67lev21x;
@property (nonatomic) int signal67lev21y;
@property (nonatomic) int signal81lev21x;
@property (nonatomic) int signal81lev21y;
@property BOOL xWalkAExists;
@property BOOL xWalkBExists;
@property BOOL xWalkCExists;
@property BOOL xWalkDExists;
@property (nonatomic) int xWalkAlev21x;
@property (nonatomic) int xWalkAlev21y;
@property (nonatomic) int xWalkBlev21x;
@property (nonatomic) int xWalkBlev21y;
@property (nonatomic) int xWalkClev21x;
@property (nonatomic) int xWalkClev21y;
@property (nonatomic) int xWalkDlev21x;
@property (nonatomic) int xWalkDlev21y;
@property (nonatomic) int corner23heading;
@property (nonatomic) int corner45heading;
@property (nonatomic) int corner67heading;
@property (nonatomic) int corner81heading;
@property BOOL corner23isComplete;
@property BOOL corner45isComplete;
@property BOOL corner67isComplete;
@property BOOL corner81isComplete;
@property (nonatomic) int quadDev0, quadDev90, quadDev180, quadDev270;
@property (nonatomic) int lev21x, lev21y;
@property (nonatomic) double lat,lon;
@property NSString * intersectionComment;
@property (nonatomic) NSMutableArray *ramps;
@property (nonatomic) int pairedMode;

- (void)intersectionInit;
- (void) setRampsXWalkAndSignal;
- (int) numRamps;
- (BOOL) isEqualTo:(MPIntersection*)oldInt;

@end
