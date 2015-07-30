//  MPIntersection.h
//  CCodeLibrary

#define RAMP 1
#define STREET 2
#define UPPER 3
#define STREETLANDING 2
#define UPPERLANDING 3
#define FLARELEFT 4
#define FLARERIGHT 5
#define HEADINGERRORDIF 50

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "RampTypeView.h"

enum textures {
    smoothConcrete=1,
    brushedConcrete=2,
    tintedConcrete=3,
    truncatedStoneDomes=4,
    truncatedStampedConcrete=5,
    castironTruncatedDomes=6,
    exposedAggregate=7,
    cutStone=8,
    other=10};

enum obstructions {
    hydrant=1,
    manhole=2,
    polebox=3,
    pole=4,
    streetmanhole=5,
    otherob=6,
    none=10
};

@interface PSRamp : NSObject

@property (nonatomic) int lev21x, lev21y;
@property (nonatomic) int imageX, imageY;
@property (nonatomic) int refno, rampID;
@property (nonatomic) CGFloat trueAz;
@property (nonatomic) int adjustedRot;

@end

@interface MPRamp : NSObject

@property (nonatomic) int rampNum;
@property (nonatomic, copy) NSString *rampID;
@property (nonatomic) int timeComplete;
@property BOOL rampExists;
@property BOOL isComplete;
@property (nonatomic) CGFloat approximateHeading;
@property (nonatomic) int adjustedRot;
@property BOOL rampInXWalk;
@property BOOL xWalkisComplete;
@property BOOL signalisComplete;
@property (nonatomic) enum textures texture;
@property (nonatomic) enum obstructions upperLandingObstruction;
@property (nonatomic) enum obstructions lowerLandingObstruction;
@property (nonatomic) enum obstructions rampObstruction;
@property BOOL hasRampCracks;
@property BOOL hasUpperLandingCracks;
@property BOOL hasStreetLandingCracks;
@property (nonatomic) int rampWidth, rampDepth;
@property (nonatomic) CGFloat rampSlopeFront;
@property (nonatomic) CGFloat rampSlopeSide;
@property (nonatomic) CGFloat rampSlopeHeading;
@property (nonatomic) CGFloat upperLandingSlopeFront;
@property (nonatomic) CGFloat upperLandingSlopeSide;
@property (nonatomic) CGFloat upperLandingSlopeHeading;
@property (nonatomic) CGFloat streetLandingSlopeFront;
@property (nonatomic) CGFloat streetLandingSlopeSide;
@property (nonatomic) CGFloat streetLandingSlopeHeading;
@property (nonatomic) CGFloat flareLeftSlopeFront;
@property (nonatomic) CGFloat flareLeftSlopeSide;
@property (nonatomic) CGFloat flareLeftSlopeHeading;
@property (nonatomic) CGFloat flareRightSlopeFront;
@property (nonatomic) CGFloat flareRightSlopeSide;
@property (nonatomic) CGFloat flareRightSlopeHeading;
@property BOOL hasPEDSignal, hasPEDButton;
@property (nonatomic) int PEDButtonHeight, PEDButtonDist;
@property (nonatomic) CGFloat SteepTopOfCurb;
@property (nonatomic) CGFloat PedRampLip;
@property (nonatomic) int lev21x, lev21y;
@property RampType rampType;

@end

@interface MPIntersection : NSObject

@property (nonatomic) int intID;
@property BOOL dataUpdated;
@property (nonatomic) int intRotation;
@property BOOL doLater;
@property (nonatomic) int timeComplete;
@property (nonatomic) int currentCorner;
@property (nonatomic) int currentSignal;
@property (nonatomic) int currentObstruction;
@property (nonatomic) float currentCornerHeading;
@property (nonatomic) MPRamp *currentRamp;
@property (nonatomic, copy) NSString *name1;
@property (nonatomic, copy) NSString *name2;
@property (nonatomic, copy) NSString *name3;
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
@property (nonatomic) NSMutableArray *ramps;
@property (nonatomic) int pairedMode;

- (void) setRampsXWalkAndSignal;

@end