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
@synthesize swkLeftSlopeSide;
@synthesize swkLeftSlopeFront;
@synthesize swkLeftSlopeHeading;
@synthesize swkRightSlopeSide;
@synthesize swkRightSlopeFront;
@synthesize swkRightSlopeHeading;
@synthesize PEDButtonDist;
@synthesize PEDButtonHeight;
@synthesize SteepTopOfCurb;
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

- (void)intersectionInit
{
    self.intID = -1;
    self.dataUpdated = NO;
    self.intRotation = 0;
    self.doLater = NO;
    self.timeComplete = 0;
    self.name1 = @"NOTYETSET";
    self.signal23Exists = NO;
    self.signal45Exists = NO;
    self.signal67Exists = NO;
    self.signal81Exists = NO;
    self.xWalkAExists = NO;
    self.xWalkBExists = NO;
    self.xWalkCExists = NO;
    self.xWalkDExists = NO;
    self.corner23isComplete = NO;
    self.corner45isComplete = NO;
    self.corner67isComplete = NO;
    self.corner81isComplete = NO;
    self.quadDev0 = 0;
    self.quadDev90 = 90;
    self.quadDev180 = 180;
    self.quadDev270 = 270;
    self.intersectionComment = @"";
    
    for (int i = 1; i < 13; i++)
    {
        MPRamp *ramp = [self.ramps objectAtIndex:i];
        ramp.rampNum = i;
        ramp.rampExists = NO;
        ramp.timeComplete = 0;
        ramp.isComplete = YES;
        ramp.xWalkisComplete = YES;
        ramp.signalisComplete = YES;
        ramp.PEDSignalType = NVSignalTypeNone;
        ramp.PEDButtonType = NVButtonTypeNone;
        ramp.awi = AudibleWalkIndicationNone;
        ramp.hasLocatorTone = NO;
        ramp.hasInfoSign = NO;
        ramp.hasBraille = NO;
        ramp.hasTactileArrow = NO;
        ramp.PEDButtonHeight = 0;
        ramp.PEDButtonDist = 0;
        ramp.SteepTopOfCurb = 0;
        ramp.PedRampLip = 0;
        ramp.rampComment = @"";
        switch (i)
        {
            default:
                if (i % 2)
                    ramp.rampID = [NSString stringWithFormat:@"%i(Left)",i];
                
                else
                    ramp.rampID = [NSString stringWithFormat:@"%i(Right)",i];
                break;
                
            case 9:
                ramp.rampID = @"23 (Middle)";
                break;
                
            case 10:
                ramp.rampID = @"45 (Middle)";
                break;
                
            case 11:
                ramp.rampID = @"67 (Middle)";
                break;
                
            case 12:
                ramp.rampID = @"81 (Middle)";
                break;
        }
    }
}
- (int) numRamps
{
    int n = 0;
    for (int i = 1; i < 13 ;i++)
    {
        MPRamp *ramp = [self.ramps objectAtIndex:i];
        if (ramp.rampExists)
            n++;
    }
    
    return n;
}
- (void) setRampsXWalkAndSignal
{
    MPIntersection *currentIntersection = self;
    MPRamp *ramp;
    
    for (int i = 1; i < 13 ;i++)
    {
        ramp = [currentIntersection.ramps objectAtIndex:i];
        
        switch (i)
        {
            case 1:
                ramp.xWalkisComplete = ramp.rampExists ? !currentIntersection.xWalkAExists : YES;
                ramp.signalisComplete = !currentIntersection.signal23Exists;
                break;
                
            case 2:
                ramp.xWalkisComplete = ramp.rampExists ? !currentIntersection.xWalkAExists : YES;
                ramp.signalisComplete = !currentIntersection.signal81Exists;
                break;
                
            case 3:
                ramp.xWalkisComplete = ramp.rampExists ? !currentIntersection.xWalkBExists : YES;
                ramp.signalisComplete = !currentIntersection.signal45Exists;
                break;
                
            case 4:
                ramp.xWalkisComplete = ramp.rampExists ? !currentIntersection.xWalkBExists : YES;
                ramp.signalisComplete = !currentIntersection.signal23Exists;
                break;
                
            case 5:
                ramp.xWalkisComplete = ramp.rampExists ? !currentIntersection.xWalkCExists : YES;
                ramp.signalisComplete = !currentIntersection.signal67Exists;
                break;
                
            case 6:
                ramp.xWalkisComplete = ramp.rampExists ? !currentIntersection.xWalkCExists : YES;
                ramp.signalisComplete = !currentIntersection.signal45Exists;
                break;
                
            case 7:
                ramp.xWalkisComplete = ramp.rampExists ? !currentIntersection.xWalkDExists : YES;
                ramp.signalisComplete = !currentIntersection.signal81Exists;
                break;
                
            case 8:
                ramp.xWalkisComplete = ramp.rampExists ? !currentIntersection.xWalkDExists : YES;
                ramp.signalisComplete = !currentIntersection.signal67Exists;
                break;
                
            default:
                ramp.xWalkisComplete = YES;
                ramp.signalisComplete = YES;
                break;
        }
    }
}

@end