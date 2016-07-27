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

-(id) copyWithZone: (NSZone *) zone
{
    MPRamp *another = [[MPRamp allocWithZone: zone] init];
    
    another.rampNum = self.rampNum;
    another.rampID = self.rampID.copy;
    another.timeComplete = self.timeComplete;
    another.rampExists = self.rampExists;
    another.isComplete = self.isComplete;
    another.approximateHeading = self.approximateHeading;
    another.adjustedRot = self.adjustedRot;
    another.rampInXWalk = self.rampInXWalk;
    another.xWalkisComplete = self.xWalkisComplete;
    another.signalisComplete = self.signalisComplete;
    another.hasRampCracks = self.hasRampCracks;
    another.hasUpperLandingCracks = self.hasUpperLandingCracks;
    another.hasStreetLandingCracks = self.hasStreetLandingCracks;
    another.rampWidth = self.rampWidth;
    another.rampDepth = self.rampDepth;
    another.texture = self.texture;
    another.upperLandingObstruction = self.upperLandingObstruction;
    another.lowerLandingObstruction = self.lowerLandingObstruction;
    another.rampObstruction = self.rampObstruction;
    another.rampSlopeSide = self.rampSlopeSide;
    another.rampSlopeFront = self.rampSlopeFront;
    another.rampSlopeHeading = self.rampSlopeHeading;
    another.upperLandingSlopeSide = self.upperLandingSlopeSide;
    another.upperLandingSlopeFront = self.upperLandingSlopeFront;
    another.upperLandingSlopeHeading = self.upperLandingSlopeHeading;
    another.streetLandingSlopeSide = self.streetLandingSlopeSide;
    another.streetLandingSlopeFront = self.streetLandingSlopeFront;
    another.streetLandingSlopeHeading = self.streetLandingSlopeHeading;
    another.flareLeftSlopeSide = self.flareLeftSlopeSide;
    another.flareLeftSlopeFront = self.flareLeftSlopeFront;
    another.flareLeftSlopeHeading = self.flareLeftSlopeHeading;
    another.flareRightSlopeSide = self.flareRightSlopeSide;
    another.flareRightSlopeFront = self.flareRightSlopeFront;
    another.flareRightSlopeHeading = self.flareRightSlopeHeading;
    another.swkLeftSlopeSide = self.swkLeftSlopeSide;
    another.swkLeftSlopeFront = self.swkLeftSlopeFront;
    another.swkLeftSlopeHeading = self.swkLeftSlopeHeading;
    another.swkRightSlopeSide = self.swkRightSlopeSide;
    another.swkRightSlopeFront = self.swkRightSlopeFront;
    another.swkRightSlopeHeading = self.swkRightSlopeHeading;
    another.PEDButtonDist = self.PEDButtonDist;
    another.PEDButtonHeight = self.PEDButtonHeight;
    another.SteepTopOfCurb = self.SteepTopOfCurb;
    another.PedRampLip = self.PedRampLip;
    another.lev21x = self.lev21x;
    another.lev21y = self.lev21y;
    another.crackWidth = self.crackWidth;
    another.curbCutDistance = self.curbCutDistance;
    another.bumpWidth = self.bumpWidth;
    another.bumpHeight = self.bumpHeight;
    return another;
}

- (BOOL) isEqualTo:(MPRamp*)oldRamp
{
    if (oldRamp.rampNum != self.rampNum) goto RtnFalse;
    if (![oldRamp.rampID isEqualToString:self.rampID]) goto RtnFalse;
    if (oldRamp.timeComplete != self.timeComplete) goto RtnFalse;
    if (oldRamp.rampExists != self.rampExists) goto RtnFalse;
    if (oldRamp.isComplete != self.isComplete) goto RtnFalse;
    if (oldRamp.approximateHeading != self.approximateHeading) goto RtnFalse;
    if (oldRamp.adjustedRot != self.adjustedRot) goto RtnFalse;
    if (oldRamp.rampInXWalk != self.rampInXWalk) goto RtnFalse;
    if (oldRamp.xWalkisComplete != self.xWalkisComplete) goto RtnFalse;
    if (oldRamp.signalisComplete != self.signalisComplete) goto RtnFalse;
    if (oldRamp.hasRampCracks != self.hasRampCracks) goto RtnFalse;
    if (oldRamp.hasUpperLandingCracks != self.hasUpperLandingCracks) goto RtnFalse;
    if (oldRamp.hasStreetLandingCracks != self.hasStreetLandingCracks) goto RtnFalse;
    if (oldRamp.rampWidth != self.rampWidth) goto RtnFalse;
    if (oldRamp.rampDepth != self.rampDepth) goto RtnFalse;
    if (oldRamp.texture != self.texture) goto RtnFalse;
    if (oldRamp.upperLandingObstruction != self.upperLandingObstruction) goto RtnFalse;
    if (oldRamp.lowerLandingObstruction != self.lowerLandingObstruction) goto RtnFalse;
    if (oldRamp.rampObstruction != self.rampObstruction) goto RtnFalse;
    if (oldRamp.rampSlopeSide != self.rampSlopeSide) goto RtnFalse;
    if (oldRamp.rampSlopeFront != self.rampSlopeFront) goto RtnFalse;
    if (oldRamp.rampSlopeHeading != self.rampSlopeHeading) goto RtnFalse;
    if (oldRamp.upperLandingSlopeSide != self.upperLandingSlopeSide) goto RtnFalse;
    if (oldRamp.upperLandingSlopeFront != self.upperLandingSlopeFront) goto RtnFalse;
    if (oldRamp.upperLandingSlopeHeading != self.upperLandingSlopeHeading) goto RtnFalse;
    if (oldRamp.streetLandingSlopeSide != self.streetLandingSlopeSide) goto RtnFalse;
    if (oldRamp.streetLandingSlopeFront != self.streetLandingSlopeFront) goto RtnFalse;
    if (oldRamp.streetLandingSlopeHeading != self.streetLandingSlopeHeading) goto RtnFalse;
    if (oldRamp.flareLeftSlopeSide != self.flareLeftSlopeSide) goto RtnFalse;
    if (oldRamp.flareLeftSlopeFront != self.flareLeftSlopeFront) goto RtnFalse;
    if (oldRamp.flareLeftSlopeHeading != self.flareLeftSlopeHeading) goto RtnFalse;
    if (oldRamp.flareRightSlopeSide != self.flareRightSlopeSide) goto RtnFalse;
    if (oldRamp.flareRightSlopeFront != self.flareRightSlopeFront) goto RtnFalse;
    if (oldRamp.flareRightSlopeHeading != self.flareRightSlopeHeading) goto RtnFalse;
    if (oldRamp.swkLeftSlopeSide != self.swkLeftSlopeSide) goto RtnFalse;
    if (oldRamp.swkLeftSlopeFront != self.swkLeftSlopeFront) goto RtnFalse;
    if (oldRamp.swkLeftSlopeHeading != self.swkLeftSlopeHeading) goto RtnFalse;
    if (oldRamp.swkRightSlopeSide != self.swkRightSlopeSide) goto RtnFalse;
    if (oldRamp.swkRightSlopeFront != self.swkRightSlopeFront) goto RtnFalse;
    if (oldRamp.swkRightSlopeHeading != self.swkRightSlopeHeading) goto RtnFalse;
    if (oldRamp.PEDButtonDist != self.PEDButtonDist) goto RtnFalse;
    if (oldRamp.PEDButtonHeight != self.PEDButtonHeight) goto RtnFalse;
    if (oldRamp.SteepTopOfCurb != self.SteepTopOfCurb) goto RtnFalse;
    if (oldRamp.PedRampLip != self.PedRampLip) goto RtnFalse;
    if (oldRamp.curbCutDistance != self.curbCutDistance) goto RtnFalse;
    if (oldRamp.bumpHeight != self.bumpHeight) goto RtnFalse;
    if (oldRamp.bumpWidth != self.bumpWidth) goto RtnFalse;
    if (oldRamp.lev21x != self.lev21x) goto RtnFalse;
    if (oldRamp.lev21y != self.lev21y) goto RtnFalse;
    
    CrackWidth oldCW = oldRamp.crackWidth;
    CrackWidth newCW = self.crackWidth;
    
    if (memcmp(&oldCW, &newCW, sizeof(CrackWidth)) != 0) goto RtnFalse;
    
    return TRUE;
    
RtnFalse:
    return FALSE;
}

@end

@implementation MPIntersection

@synthesize intID;
@synthesize intRotation;
@synthesize doLater;
@synthesize timeComplete;
@synthesize currentCorner;
@synthesize currentSignal;
@synthesize currentObstruction;
@synthesize currentCornerHeading;
@synthesize currentRamp;
@synthesize name1;
@synthesize ramps;
@synthesize signal23Exists;
@synthesize signal45Exists;
@synthesize signal67Exists;
@synthesize signal81Exists;
@synthesize signal23lev21x;
@synthesize signal23lev21y;
@synthesize signal45lev21x;
@synthesize signal45lev21y;
@synthesize signal67lev21x;
@synthesize signal67lev21y;
@synthesize signal81lev21x;
@synthesize signal81lev21y;
@synthesize xWalkAExists;
@synthesize xWalkBExists;
@synthesize xWalkCExists;
@synthesize xWalkDExists;
@synthesize xWalkAlev21x;
@synthesize xWalkAlev21y;
@synthesize xWalkBlev21x;
@synthesize xWalkBlev21y;
@synthesize xWalkClev21x;
@synthesize xWalkClev21y;
@synthesize xWalkDlev21x;
@synthesize xWalkDlev21y;
@synthesize corner23heading;
@synthesize corner45heading;
@synthesize corner67heading;
@synthesize corner81heading;
@synthesize corner23isComplete;
@synthesize corner45isComplete;
@synthesize corner67isComplete;
@synthesize corner81isComplete;
@synthesize quadDev0;
@synthesize quadDev180;
@synthesize quadDev270;
@synthesize quadDev90;
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
        
        //init all 5 crack values to zero
        CrackWidth cw;
        memset(&cw, 0, sizeof(CrackWidth));
        ramp.crackWidth = cw;
        
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

-(id) copyWithZone: (NSZone *) zone
{
    MPIntersection *another = [[MPIntersection allocWithZone: zone] init];
    another.intID = self.intID;
    another.intRotation = self.intRotation;
    another.doLater = self.doLater;
    another.timeComplete = self.timeComplete;
    another.currentCorner = self.currentCorner;
    another.currentSignal = self.currentSignal;
    another.currentObstruction = self.currentObstruction;
    another.currentCornerHeading = self.currentCornerHeading;
    another.currentRamp = self.currentRamp;
    another.name1 = self.name1;
    another.signal23Exists = self.signal23Exists;
    another.signal45Exists = self.signal45Exists;
    another.signal67Exists = self.signal67Exists;
    another.signal81Exists = self.signal81Exists;
    another.signal23lev21x = self.signal23lev21x;
    another.signal23lev21y = self.signal23lev21y;
    another.signal45lev21x = self.signal45lev21x;
    another.signal45lev21y = self.signal45lev21y;
    another.signal67lev21x = self.signal67lev21x;
    another.signal67lev21y = self.signal67lev21y;
    another.signal81lev21x = self.signal81lev21x;
    another.signal81lev21y = self.signal81lev21y;
    another.xWalkAExists = self.xWalkAExists;
    another.xWalkBExists = self.xWalkBExists;
    another.xWalkCExists = self.xWalkCExists;
    another.xWalkDExists = self.xWalkDExists;
    another.xWalkAlev21x = self.xWalkAlev21x;
    another.xWalkAlev21y = self.xWalkAlev21y;
    another.xWalkBlev21x = self.xWalkBlev21x;
    another.xWalkBlev21y = self.xWalkBlev21y;
    another.xWalkClev21x = self.xWalkClev21x;
    another.xWalkClev21y = self.xWalkClev21y;
    another.xWalkDlev21x = self.xWalkDlev21x;
    another.xWalkDlev21y = self.xWalkDlev21y;
    another.corner23heading = self.corner23heading;
    another.corner45heading = self.corner45heading;
    another.corner67heading = self.corner67heading;
    another.corner81heading = self.corner81heading;
    another.corner23isComplete = self.corner23isComplete;
    another.corner45isComplete = self.corner45isComplete;
    another.corner67isComplete = self.corner67isComplete;
    another.corner81isComplete = self.corner81isComplete;
    another.quadDev0 = self.quadDev0;
    another.quadDev180 = self.quadDev180;
    another.quadDev270 = self.quadDev270;
    another.quadDev90 = self.quadDev90;
    another.lev21x = self.lev21x;
    another.lev21y = self.lev21y;
    another.lat = self.lat;
    another.lon = self.lon;
    another.intersectionComment = self.intersectionComment.copy;
    
    another.ramps = [[NSMutableArray alloc]init];
    for (MPRamp *ramp in self.ramps)
    {
        MPRamp *newRamp = [ramp copy];
        [another.ramps addObject:newRamp];
    }
    
    return another;
}

- (BOOL) isEqualTo:(MPIntersection*)oldInt
{
    if (oldInt.intID != self.intID) goto RtnFalse;
    if (oldInt.intRotation != self.intRotation) goto RtnFalse;
    if (oldInt.doLater != self.doLater) goto RtnFalse;
    if (oldInt.timeComplete != self.timeComplete) goto RtnFalse;
    if (oldInt.currentCorner != self.currentCorner) goto RtnFalse;
    if (oldInt.currentSignal != self.currentSignal) goto RtnFalse;
    if (oldInt.currentObstruction != self.currentObstruction) goto RtnFalse;
    if (oldInt.currentCornerHeading != self.currentCornerHeading) goto RtnFalse;
    if (![oldInt.name1 isEqualToString:self.name1]) goto RtnFalse;
    if (oldInt.signal23Exists != self.signal23Exists) goto RtnFalse;
    if (oldInt.signal45Exists != self.signal45Exists) goto RtnFalse;
    if (oldInt.signal67Exists != self.signal67Exists) goto RtnFalse;
    if (oldInt.signal81Exists != self.signal81Exists) goto RtnFalse;
    if (oldInt.signal23lev21x != self.signal23lev21x) goto RtnFalse;
    if (oldInt.signal23lev21y != self.signal23lev21y) goto RtnFalse;
    if (oldInt.signal45lev21x != self.signal45lev21x) goto RtnFalse;
    if (oldInt.signal45lev21y != self.signal45lev21y) goto RtnFalse;
    if (oldInt.signal67lev21x != self.signal67lev21x) goto RtnFalse;
    if (oldInt.signal67lev21y != self.signal67lev21y) goto RtnFalse;
    if (oldInt.signal81lev21x != self.signal81lev21x) goto RtnFalse;
    if (oldInt.signal81lev21y != self.signal81lev21y) goto RtnFalse;
    if (oldInt.xWalkAExists != self.xWalkAExists) goto RtnFalse;
    if (oldInt.xWalkBExists != self.xWalkBExists) goto RtnFalse;
    if (oldInt.xWalkCExists != self.xWalkCExists) goto RtnFalse;
    if (oldInt.xWalkDExists != self.xWalkDExists) goto RtnFalse;
    if (oldInt.xWalkAlev21x != self.xWalkAlev21x) goto RtnFalse;
    if (oldInt.xWalkAlev21y != self.xWalkAlev21y) goto RtnFalse;
    if (oldInt.xWalkBlev21x != self.xWalkBlev21x) goto RtnFalse;
    if (oldInt.xWalkBlev21y != self.xWalkBlev21y) goto RtnFalse;
    if (oldInt.xWalkClev21x != self.xWalkClev21x) goto RtnFalse;
    if (oldInt.xWalkClev21y != self.xWalkClev21y) goto RtnFalse;
    if (oldInt.xWalkDlev21x != self.xWalkDlev21x) goto RtnFalse;
    if (oldInt.xWalkDlev21y != self.xWalkDlev21y) goto RtnFalse;
    if (oldInt.corner23heading != self.corner23heading) goto RtnFalse;
    if (oldInt.corner45heading != self.corner45heading) goto RtnFalse;
    if (oldInt.corner67heading != self.corner67heading) goto RtnFalse;
    if (oldInt.corner81heading != self.corner81heading) goto RtnFalse;
    if (oldInt.corner23isComplete != self.corner23isComplete) goto RtnFalse;
    if (oldInt.corner45isComplete != self.corner45isComplete) goto RtnFalse;
    if (oldInt.corner67isComplete != self.corner67isComplete) goto RtnFalse;
    if (oldInt.corner81isComplete != self.corner81isComplete) goto RtnFalse;
    if (oldInt.quadDev0 != self.quadDev0) goto RtnFalse;
    if (oldInt.quadDev180 != self.quadDev180) goto RtnFalse;
    if (oldInt.quadDev270 != self.quadDev270) goto RtnFalse;
    if (oldInt.quadDev90 != self.quadDev90) goto RtnFalse;
    if (oldInt.lev21x != self.lev21x) goto RtnFalse;
    if (oldInt.lev21y != self.lev21y) goto RtnFalse;
    if (oldInt.lat != self.lat) goto RtnFalse;
    if (oldInt.lon != self.lon) goto RtnFalse;
    if (![oldInt.intersectionComment isEqualToString:self.intersectionComment]) goto RtnFalse;
    
    for (int i = 1; i < 13 ;i++)
    {
        MPRamp *ramp = [self.ramps objectAtIndex:i];
        MPRamp *oldRamp = [oldInt.ramps objectAtIndex:i];
        if (![ramp isEqualTo:oldRamp])
        {
            goto RtnFalse;
            break;
        }
    }
    
    return TRUE;
RtnFalse:
    
    return FALSE;
}

@end