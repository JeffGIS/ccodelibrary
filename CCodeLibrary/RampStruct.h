//
//  RampStruct.h
//  CCodeLibrary
//
//  Created by Bill Munson on 8/19/16.
//  Copyright © 2016 GSSi. All rights reserved.
//
enum textures {
    smoothConcrete=1,
    brushedConcrete=2,
    tintedConcrete=3,
    truncatedStoneDomes=4,
    truncatedStampedConcrete=5,
    castironTruncatedDomes=6,
    exposedAggregate=7,
    cutStone=8,
    other=10
};

enum obstructions {
    hydrant=1,
    manhole=2,
    polebox=3,
    pole=4,
    streetmanhole=5,
    otherob=6,
    none=10,
    masterNone=11
};

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

typedef struct CrackWidth {
    float rampCrackWidth;
    float upperLandingCrackWidth;
    float streetLandingCrackWidth;
    float leftSidewalkCrackWidth;
    float rightSidewalkCrackWidth;
} CrackWidth;


#ifndef RampStruct_h
#define RampStruct_h

struct {
    int rampNum;
    char rampID[16];
    int timeComplete;
    int yearRebuilt;
    BOOL rampExists;
    BOOL isComplete;
    float approximateHeading;
    int adjustedRot;
    BOOL rampInXWalk;
    BOOL xWalkisComplete, xWalkWidth;
    BOOL signalisComplete;
    enum textures texture;
    enum obstructions upperLandingObstruction;
    enum obstructions lowerLandingObstruction;
    enum obstructions rampObstruction;
    BOOL hasRampCracks;
    BOOL hasUpperLandingCracks;
    BOOL hasStreetLandingCracks;
    BOOL hasLeftSidewalkCracks, hasRightSidewalkCracks;
    BOOL gradeBreaksArePerpendicular, detectableWarningIsFullWidth;
    CrackWidth crackWidth;
    CrackType currentCrackMeasurement;//this need not be in copy or comparision methods (internal value - not in database)
    MiddleMeasurement currentMiddleMeasurement;//this need not be in copy or comparision methods (internal value - not in database)
    int detectableWarningDepth;
    float domeSpacing, spaceBetweenDomes, domeBaseWidth, domeCapWidth;//these are for detectable warnings
    int streetLandingDepth, leftXWalkSideWidth, rightXWalkSideWidth;//these are for diagonal ramp type
    int rampWidth, rampDepth;
    float rampSlopeFront;
    float rampSlopeSide;
    float rampSlopeHeading;
    float upperLandingSlopeFront;
    float upperLandingSlopeSide;
    float upperLandingSlopeHeading;
    float streetLandingSlopeFront;
    float streetLandingSlopeSide;
    float streetLandingSlopeHeading;
    float flareLeftSlopeFront;
    float flareLeftSlopeSide;
    float flareLeftSlopeHeading;
    float flareRightSlopeFront;
    float flareRightSlopeSide;
    float flareRightSlopeHeading;
    float swkLeftSlopeFront;
    float swkLeftSlopeSide;
    float swkLeftSlopeHeading;
    float swkRightSlopeFront;
    float swkRightSlopeSide;
    float swkRightSlopeHeading;
    NVSignalType PEDSignalType;
    NVButtonType PEDButtonType;
    AudibleWalkIndication awi;
    BOOL hasLocatorTone, hasInfoSign, hasBraille, hasTactileArrow;
    float locatorToneVolume, audibleWalkIndicationVolume;//dB measured from 3 feet
    int PEDButtonHeight, PEDButtonDist;
    float SteepTopOfCurb;
    float PedRampLip;
    int lev21x, lev21y;
    char rampComment[4096];
    RampType rampType;
    float curbCutDistance;
    float bumpWidth;
    float bumpHeight;
} RAMPSTRUCT;


#endif /* RampStruct_h */
