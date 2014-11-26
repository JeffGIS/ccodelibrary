//  MPIntersection.h
//  CCodeLibrary

#define RAMP    1
#define STREET  2
#define UPPER   3
#define RAMP 1
#define STREETLANDING 2
#define UPPERLANDING 3
#define FLARELEFT 4
#define FLARERIGHT 5
#define HEADINGERRORDIF 50

#import <Foundation/Foundation.h>

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

@property int lev21x;
@property int lev21y;
@property int imageX;
@property int imageY;
@property int refno;
@property float trueAz;
@property int adjustedRot;
@property int rampID;

@end

@interface MPRamp : NSObject

@property int rampNum;
@property (nonatomic, strong) NSString *rampID;
@property int timeComplete;
@property bool rampExists;
@property bool isComplete;
@property float approximateHeading;
@property int   adjustedRot;
@property bool rampInXWalk;
@property bool xWalkisComplete;
@property bool signalisComplete;
@property enum textures texture;
@property enum obstructions upperLandingObstruction;
@property enum obstructions lowerLandingObstruction;
@property enum obstructions rampObstruction;
@property bool hasRampCracks;
@property bool hasUpperLandingCracks;
@property bool hasStreetLandingCracks;
@property int rampWidth;
@property int rampDepth;
@property float rampSlopeFront;
@property float rampSlopeSide;
@property float rampSlopeHeading;
@property float upperLandingSlopeFront;
@property float upperLandingSlopeSide;
@property float upperLandingSlopeHeading;
@property float streetLandingSlopeFront;
@property float streetLandingSlopeSide;
@property float streetLandingSlopeHeading;
@property float flareLeftSlopeFront;
@property float flareLeftSlopeSide;
@property float flareLeftSlopeHeading;
@property float flareRightSlopeFront;
@property float flareRightSlopeSide;
@property float flareRightSlopeHeading;
@property bool hasPEDSignal;
@property bool hasPEDButton;
@property int PEDButtonHeight;
@property int PEDButtonDist;
@property float SteepTopOfCurb;
@property float PedRampLip;
@property int lev21x;
@property int lev21y;

@end

@interface MPIntersection : NSObject

@property int intID;
@property bool dataUpdated;
@property int intRotation;
@property bool doLater;
@property int timeComplete;
@property int currentCorner;
@property int currentSignal;
@property int currentObstruction;
@property float currentCornerHeading;
@property (nonatomic, strong) MPRamp *currentRamp;
@property (nonatomic, strong) NSString *name1;
@property (nonatomic, strong) NSString *name2;
@property (nonatomic, strong) NSString *name3;
@property bool signal23Exists;
@property bool signal45Exists;
@property bool signal67Exists;
@property bool signal81Exists;
@property int signal23lev21x;
@property int signal23lev21y;
@property int signal45lev21x;
@property int signal45lev21y;
@property int signal67lev21x;
@property int signal67lev21y;
@property int signal81lev21x;
@property int signal81lev21y;
@property bool xWalkAExists;
@property bool xWalkBExists;
@property bool xWalkCExists;
@property bool xWalkDExists;
@property int xWalkAlev21x;
@property int xWalkAlev21y;
@property int xWalkBlev21x;
@property int xWalkBlev21y;
@property int xWalkClev21x;
@property int xWalkClev21y;
@property int xWalkDlev21x;
@property int xWalkDlev21y;
@property int  corner23heading;
@property int  corner45heading;
@property int  corner67heading;
@property int  corner81heading;
@property bool corner23isComplete;
@property bool corner45isComplete;
@property bool corner67isComplete;
@property bool corner81isComplete;
@property int quadDev0, quadDev90, quadDev180, quadDev270;
@property int lev21x, lev21y;
@property double lat,lon;
@property (nonatomic,strong) NSMutableArray *ramps;

- (void) setRampsXWalkAndSignal;

@end