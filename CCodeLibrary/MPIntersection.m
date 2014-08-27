//  MPIntersection.m
//  CCodeLibrary

#import "MPIntersection.h"

@implementation PSRamp
@synthesize lev21x,lev21y;
@synthesize imageX, imageY;
@synthesize refno;
@synthesize trueAz;
@synthesize adjustedRot;
@synthesize rampID;

@end

@implementation MPRamp

@synthesize rampNum;
@synthesize rampID;
@synthesize timeComplete;
@synthesize rampExists;
@synthesize isComplete;
@synthesize approximateHeading;
@synthesize adjustedRot;
@synthesize rampInXWalk;
@synthesize xWalkisComplete;
@synthesize signalisComplete;
@synthesize hasRampCracks;
@synthesize hasUpperLandingCracks;
@synthesize hasStreetLandingCracks;
@synthesize rampWidth;
@synthesize rampDepth;
@synthesize texture;
@synthesize upperLandingObstruction;
@synthesize lowerLandingObstruction;
@synthesize rampObstruction;
@synthesize rampSlopeSide;
@synthesize rampSlopeFront;
@synthesize rampSlopeHeading;
@synthesize upperLandingSlopeSide;
@synthesize upperLandingSlopeFront;
@synthesize upperLandingSlopeHeading;
@synthesize streetLandingSlopeSide;
@synthesize streetLandingSlopeFront;
@synthesize streetLandingSlopeHeading;
@synthesize flareLeftSlopeSide;
@synthesize flareLeftSlopeFront;
@synthesize flareLeftSlopeHeading;
@synthesize flareRightSlopeSide;
@synthesize flareRightSlopeFront;
@synthesize flareRightSlopeHeading;
@synthesize hasPEDButton;
@synthesize hasPEDSignal;
@synthesize PEDButtonDist;
@synthesize PEDButtonHeight;
@synthesize SteepTopOfCurve;
@synthesize PedRampLip;
@synthesize lev21x;
@synthesize lev21y;
@end

@implementation MPIntersection

@synthesize intID;
@synthesize dataUpdated;
@synthesize intRotation;
@synthesize doLater;
@synthesize timeComplete;
@synthesize pairedMode;
@synthesize currentCorner;
@synthesize currentRamp;
@synthesize currentSignal;
@synthesize currentObstruction;
@synthesize currentCornerHeading;
@synthesize name1;
@synthesize name2;
@synthesize name3;
@synthesize ramps;
@synthesize signal23Exists;
@synthesize signal45Exists;
@synthesize signal67Exists;
@synthesize signal81Exists;
@synthesize signal23lev21x,signal23lev21y,signal45lev21x,signal45lev21y,signal67lev21x,signal67lev21y,signal81lev21x,signal81lev21y;
@synthesize xWalkAExists;
@synthesize xWalkBExists;
@synthesize xWalkCExists;
@synthesize xWalkDExists;
@synthesize xWalkAlev21x,xWalkAlev21y,xWalkBlev21x,xWalkBlev21y,xWalkClev21x,xWalkClev21y,xWalkDlev21x,xWalkDlev21y;
@synthesize corner23heading;
@synthesize corner45heading;
@synthesize corner67heading;
@synthesize corner81heading;
@synthesize corner23isComplete;
@synthesize corner45isComplete;
@synthesize corner67isComplete;
@synthesize corner81isComplete;
@synthesize quadDev0,quadDev180,quadDev270,quadDev90;
@synthesize lev21x,lev21y;

- (id)init
{
    self = [super init];
    if (self)
    {

        self.ramps = [NSMutableArray arrayWithCapacity:12];

        for (int i = 0; i < 13; i++)
        {
            MPRamp *ramp = [[MPRamp alloc] init];
            [self.ramps addObject:ramp];
        }
    }
    return self;
}

@end