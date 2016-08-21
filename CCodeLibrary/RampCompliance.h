//  RampCompliance.h
//  CCodeLibrary

#ifndef RampCompliance_h
#define RampCompliance_h

#include <stdlib.h>
#include <string.h>
#include <math.h>
#include "RampStruct.h"

//definitions for critical values
#define CV2 100 / 48.0
#define CV5 5.0
#define CV8 100.0 / 12.0
#define CV10 10.0

//code definitions for Basic Code
#define Compliant "A"
#define Signal "B"//button height not within 40-44 inches
#define DetectableWarning "C"//no detectable warning
#define Dimensions "D"//over maximum dimensions
#define SlopeMinor "e"//over critical value but within tolerance
#define SlopeMajor "E"//over tolerance
#define CracksMinor "f"//1/2 inch wide and under
#define CracksMajor "F"//over 1/2 inch wide
#define LevelChangeMinor "g"//1 inch and under
#define LevelChangeMajor "G"//over 1 inch
#define Obstructions "H"//obstruction(s) present

//code definitions for Detail Code
#define RampWidth "D1"
#define RampDepth "D2"
#define RampFrontMinor "e1"
#define RampFrontMajor "E1"
#define RampSideMinor "e2"
#define RampSideMajor "E2"
#define UpperLandingFrontMinor "e3"
#define UpperLandingFrontMajor "E3"
#define UpperLandingSideMinor "e4"
#define UpperLandingSideMajor "E4"
#define StreetLandingFrontMinor "e5"
#define StreetLandingFrontMajor "E5"
#define StreetLandingSideMinor "e6"
#define StreetLandingSideMajor "E6"
#define FlareLeftFrontMinor "e7"
#define FlareLeftFrontMajor "E7"
#define FlareLeftSideMinor "e8"
#define FlareLeftSideMajor "E8"
#define FlareRightFrontMinor "e9"
#define FlareRightFrontMajor "E9"
#define FlareRightSideMinor "e10"
#define FlareRightSideMajor "E10"
#define SwkLeftFrontMinor "e11"
#define SwkLeftFrontMajor "E11"
#define SwkLeftSideMinor "e12"
#define SwkLeftSideMajor "E12"
#define SwkRightFrontMinor "e13"
#define SwkRightFrontMajor "E13"
#define SwkRightSideMinor "e14"
#define SwkRightSideMajor "E14"
#define RampCrackMinor "f1"
#define RampCrackMajor "F1"
#define UpperLandingCrackMinor "f2"
#define UpperLandingCrackMajor "F2"
#define StreetLandingCrackMinor "f3"
#define StreetLandingCrackMajor "F3"
#define SwkLeftCrackMinor "f4"
#define SwkLeftCrackMajor "F4"
#define SwkRightCrackMinor "f5"
#define SwkRightCrackMajor "F5"
#define STOCMinor "g1"
#define STOCMajor "G1"
#define LipMinor "g2"
#define LipMajor "G2"
#define RampObstruction "H1"
#define UpperLandingObstruction "H2"
#define StreetLandingObstruction "H3"

char *rampComplianceCode(RampStruct *ramp, char **detailCode, float tolerance);

#endif /* RampCompliance_h */