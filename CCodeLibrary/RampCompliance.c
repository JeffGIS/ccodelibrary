//  RampCompliance.c
//  CCodeLibrary

#include "RampCompliance.h"

char *rampComplianceCode(RampStruct *ramp, char **detailCode, float tolerance)
{
    char *basic = (char *)calloc(16, sizeof(char));
    char *detail = (char *)calloc(64, sizeof(char));
    
    //signals
    if (ramp->PEDButtonHeight > 0)
    {
        if (ramp->PEDButtonHeight < 40 || ramp->PEDButtonHeight > 44)
        {
            basic = strcat(basic, Signal);
            detail = strcat(detail, Signal);
        }
    }
    
    //detectable warnings
    if (ramp->texture < truncatedStoneDomes || ramp->texture > castironTruncatedDomes)
    {
        basic = strcat(basic, DetectableWarning);
        detail = strcat(detail, DetectableWarning);
    }
    
    int flagged = 0;
    
    //dimensions
    if (ramp->rampWidth > 0)
    {
        if (ramp->rampWidth < 36)
        {
            basic = strcat(basic, Dimensions);
            detail = strcat(detail, RampWidth);
            flagged = 1;
        }
    }
    
    if (ramp->rampDepth > 0)
    {
        if (ramp->rampDepth < 36)
        {
            if (flagged < 1)
                basic = strcat(basic, Dimensions);
            
            detail = strcat(detail, RampDepth);
        }
    }
    
    flagged = 0;
    
    //ramp slopes (8,2)
    float value = fabsf(ramp->rampSlopeFront);
    
    if (value > (CV8 + tolerance) && value < 9990.0)
    {
        basic = strcat(basic, SlopeMajor);
        detail = strcat(detail, RampFrontMajor);
        flagged = 2;
    }
    
    else if (value > CV8 && value < 9990.0)
    {
        basic = strcat(basic, SlopeMinor);
        detail = strcat(detail, RampFrontMinor);
        flagged = 1;
    }
    
    value = fabsf(ramp->rampSlopeSide);
    
    if (value > (CV2 + tolerance) && value < 9990.0)
    {
        if (flagged < 2)
        {
            if (flagged == 1)
                basic[strlen(basic) - 1] = '\0';
            
            basic = strcat(basic, SlopeMajor);
            flagged = 2;
        }
        
        detail = strcat(detail, RampSideMajor);
    }
    
    else if (value > CV2 && value < 9990.0)
    {
        if (flagged < 1)
        {
            basic = strcat(basic, SlopeMinor);
            flagged = 1;
        }
        
        detail = strcat(detail, RampSideMinor);
    }
    
    //upper landing slopes (2,2)
    value = fabsf(ramp->upperLandingSlopeFront);
    
    if (value > (CV2 + tolerance) && value < 9990.0)
    {
        if (flagged < 2)
        {
            if (flagged == 1)
                basic[strlen(basic) - 1] = '\0';
            
            basic = strcat(basic, SlopeMajor);
            flagged = 2;
        }
        
        detail = strcat(detail, UpperLandingFrontMajor);
    }
    
    else if (value > CV2 && value < 9990.0)
    {
        if (flagged < 1)
        {
            basic = strcat(basic, SlopeMinor);
            flagged = 1;
        }
        
        detail = strcat(detail, UpperLandingFrontMinor);
    }
    
    value = fabsf(ramp->upperLandingSlopeSide);
    
    if (value > (CV2 + tolerance) && value < 9990.0)
    {
        if (flagged < 2)
        {
            if (flagged == 1)
                basic[strlen(basic) - 1] = '\0';
            
            basic = strcat(basic, SlopeMajor);
            flagged = 2;
        }
        
        detail = strcat(detail, UpperLandingSideMajor);
    }
    
    else if (value > CV2 && value < 9990.0)
    {
        if (flagged < 1)
        {
            basic = strcat(basic, SlopeMinor);
            flagged = 1;
        }
        
        detail = strcat(detail, UpperLandingSideMinor);
    }
    
    //street landing slopes (2,2)
    value = fabsf(ramp->streetLandingSlopeFront);
    
    if (value > (CV2 + tolerance) && value < 9990.0)
    {
        if (flagged < 2)
        {
            if (flagged == 1)
                basic[strlen(basic) - 1] = '\0';
            
            basic = strcat(basic, SlopeMajor);
            flagged = 2;
        }
        
        detail = strcat(detail, StreetLandingFrontMajor);
    }
    
    else if (value > CV2 && value < 9990.0)
    {
        if (flagged < 1)
        {
            basic = strcat(basic, SlopeMinor);
            flagged = 1;
        }
        
        detail = strcat(detail, StreetLandingFrontMinor);
    }
    
    value = fabsf(ramp->streetLandingSlopeSide);
    
    if (value > (CV2 + tolerance) && value < 9990.0)
    {
        if (flagged < 2)
        {
            if (flagged == 1)
                basic[strlen(basic) - 1] = '\0';
            
            basic = strcat(basic, SlopeMajor);
            flagged = 2;
        }
        
        detail = strcat(detail, StreetLandingSideMajor);
    }
    
    else if (value > CV2 && value < 9990.0)
    {
        if (flagged < 1)
        {
            basic = strcat(basic, SlopeMinor);
            flagged = 1;
        }
        
        detail = strcat(detail, StreetLandingSideMinor);
    }

    //flare left slopes (10,2)
    value = fabsf(ramp->flareLeftSlopeFront);
    
    if (value > (CV10 + tolerance) && value < 9990.0)
    {
        if (flagged < 2)
        {
            if (flagged == 1)
                basic[strlen(basic) - 1] = '\0';
            
            basic = strcat(basic, SlopeMajor);
            flagged = 2;
        }
        
        detail = strcat(detail, FlareLeftFrontMajor);
    }
    
    else if (value > CV10 && value < 9990.0)
    {
        if (flagged < 1)
        {
            basic = strcat(basic, SlopeMinor);
            flagged = 1;
        }
        
        detail = strcat(detail, FlareLeftFrontMinor);
    }
    
    value = fabsf(ramp->flareLeftSlopeSide);
    
    if (value > (CV2 + tolerance) && value < 9990.0)
    {
        if (flagged < 2)
        {
            if (flagged == 1)
                basic[strlen(basic) - 1] = '\0';
            
            basic = strcat(basic, SlopeMajor);
            flagged = 2;
        }
        
        detail = strcat(detail, FlareLeftSideMajor);
    }
    
    else if (value > CV2 && value < 9990.0)
    {
        if (flagged < 1)
        {
            basic = strcat(basic, SlopeMinor);
            flagged = 1;
        }
        
        detail = strcat(detail, FlareLeftSideMinor);
    }

    //flare right slopes (10,2)
    value = fabsf(ramp->flareRightSlopeFront);
    
    if (value > (CV10 + tolerance) && value < 9990.0)
    {
        if (flagged < 2)
        {
            if (flagged == 1)
                basic[strlen(basic) - 1] = '\0';
            
            basic = strcat(basic, SlopeMajor);
            flagged = 2;
        }
        
        detail = strcat(detail, FlareRightFrontMajor);
    }
    
    else if (value > CV10 && value < 9990.0)
    {
        if (flagged < 1)
        {
            basic = strcat(basic, SlopeMinor);
            flagged = 1;
        }
        
        detail = strcat(detail, FlareRightFrontMinor);
    }
    
    value = fabsf(ramp->flareRightSlopeSide);
    
    if (value > (CV2 + tolerance) && value < 9990.0)
    {
        if (flagged < 2)
        {
            if (flagged == 1)
                basic[strlen(basic) - 1] = '\0';
            
            basic = strcat(basic, SlopeMajor);
            flagged = 2;
        }
        
        detail = strcat(detail, FlareRightSideMajor);
    }
    
    else if (value > CV2 && value < 9990.0)
    {
        if (flagged < 1)
        {
            basic = strcat(basic, SlopeMinor);
            flagged = 1;
        }
        
        detail = strcat(detail, FlareRightSideMinor);
    }
    
    //sidewalk left slopes (5,2)
    value = fabsf(ramp->swkLeftSlopeFront);
    
    if (value > (CV5 + tolerance) && value < 9990.0)
    {
        if (flagged < 2)
        {
            if (flagged == 1)
                basic[strlen(basic) - 1] = '\0';
            
            basic = strcat(basic, SlopeMajor);
            flagged = 2;
        }
        
        detail = strcat(detail, SwkLeftFrontMajor);
    }
    
    else if (value > CV5 && value < 9990.0)
    {
        if (flagged < 1)
        {
            basic = strcat(basic, SlopeMinor);
            flagged = 1;
        }
        
        detail = strcat(detail, SwkLeftFrontMinor);
    }
    
    value = fabsf(ramp->swkLeftSlopeSide);
    
    if (value > (CV2 + tolerance) && value < 9990.0)
    {
        if (flagged < 2)
        {
            if (flagged == 1)
                basic[strlen(basic) - 1] = '\0';
            
            basic = strcat(basic, SlopeMajor);
            flagged = 2;
        }
        
        detail = strcat(detail, SwkLeftSideMajor);
    }
    
    else if (value > CV2 && value < 9990.0)
    {
        if (flagged < 1)
        {
            basic = strcat(basic, SlopeMinor);
            flagged = 1;
        }
        
        detail = strcat(detail, SwkLeftSideMinor);
    }
    
    //sidewalk right slopes (5,2)
    value = fabsf(ramp->swkRightSlopeFront);
    
    if (value > (CV5 + tolerance) && value < 9990.0)
    {
        if (flagged < 2)
        {
            if (flagged == 1)
                basic[strlen(basic) - 1] = '\0';
            
            basic = strcat(basic, SlopeMajor);
            flagged = 2;
        }
        
        detail = strcat(detail, SwkRightFrontMajor);
    }
    
    else if (value > CV5 && value < 9990.0)
    {
        if (flagged < 1)
        {
            basic = strcat(basic, SlopeMinor);
            flagged = 1;
        }
        
        detail = strcat(detail, SwkRightFrontMinor);
    }
    
    value = fabsf(ramp->swkRightSlopeSide);
    
    if (value > (CV2 + tolerance) && value < 9990.0)
    {
        if (flagged < 2)
        {
            if (flagged == 1)
                basic[strlen(basic) - 1] = '\0';
            
            basic = strcat(basic, SlopeMajor);
            flagged = 2;
        }
        
        detail = strcat(detail, SwkRightSideMajor);
    }
    
    else if (value > CV2 && value < 9990.0)
    {
        if (flagged < 1)
        {
            basic = strcat(basic, SlopeMinor);
            flagged = 1;
        }
        
        detail = strcat(detail, SwkRightSideMinor);
    }
    
    flagged = 0;
    
    //ramp cracks
    if (ramp->hasRampCracks == 1)
    {
        if (ramp->crackWidth.rampCrackWidth > 0.5)
        {
            basic = strcat(basic, CracksMajor);
            detail = strcat(detail, RampCrackMajor);
            flagged = 2;
        }
        
        else
        {
            basic = strcat(basic, CracksMinor);
            detail = strcat(detail, RampCrackMinor);
            flagged = 1;
        }
    }
    
    //upper landing cracks
    if (ramp->hasUpperLandingCracks == 1)
    {
        if (ramp->crackWidth.upperLandingCrackWidth > 0.5)
        {
            if (flagged < 2)
            {
                if (flagged == 1)
                    basic[strlen(basic) - 1] = '\0';
                
                basic = strcat(basic, CracksMajor);
                flagged = 2;
            }
            
            detail = strcat(detail, UpperLandingCrackMajor);
        }
        
        else
        {
            if (flagged < 1)
            {
                basic = strcat(basic, CracksMinor);
                flagged = 1;
            }
            
            detail = strcat(detail, UpperLandingCrackMinor);
        }
    }
    
    //street landing cracks
    if (ramp->hasStreetLandingCracks == 1)
    {
        if (ramp->crackWidth.streetLandingCrackWidth > 0.5)
        {
            if (flagged < 2)
            {
                if (flagged == 1)
                    basic[strlen(basic) - 1] = '\0';
                
                basic = strcat(basic, CracksMajor);
                flagged = 2;
            }
            
            detail = strcat(detail, StreetLandingCrackMajor);
        }
        
        else
        {
            if (flagged < 1)
            {
                basic = strcat(basic, CracksMinor);
                flagged = 1;
            }
            
            detail = strcat(detail, StreetLandingCrackMinor);
        }
    }
    
    //left sidewalk cracks
    if (ramp->hasLeftSidewalkCracks == 1)
    {
        if (ramp->crackWidth.leftSidewalkCrackWidth > 0.5)
        {
            if (flagged < 2)
            {
                if (flagged == 1)
                    basic[strlen(basic) - 1] = '\0';
                
                basic = strcat(basic, CracksMajor);
                flagged = 2;
            }
            
            detail = strcat(detail, SwkLeftCrackMajor);
        }
        
        else
        {
            if (flagged < 1)
            {
                basic = strcat(basic, CracksMinor);
                flagged = 1;
            }
            
            detail = strcat(detail, SwkLeftCrackMinor);
        }
    }
    
    //right sidewalk cracks
    if (ramp->hasRightSidewalkCracks == 1)
    {
        if (ramp->crackWidth.rightSidewalkCrackWidth > 0.5)
        {
            if (flagged < 2)
            {
                if (flagged == 1)
                    basic[strlen(basic) - 1] = '\0';
                
                basic = strcat(basic, CracksMajor);
                flagged = 2;
            }
            
            detail = strcat(detail, SwkRightCrackMajor);
        }
        
        else
        {
            if (flagged < 1)
            {
                basic = strcat(basic, CracksMinor);
                flagged = 1;
            }
            
            detail = strcat(detail, SwkRightCrackMinor);
        }
    }
    
    flagged = 0;
    
    //steep top of curb
    if (ramp->SteepTopOfCurb > 0.0)
    {
        if (ramp->SteepTopOfCurb > 1.0)
        {
            basic = strcat(basic, LevelChangeMajor);
            detail = strcat(detail, STOCMajor);
            flagged = 2;
        }
        
        else
        {
            basic = strcat(basic, LevelChangeMinor);
            detail = strcat(detail, STOCMinor);
            flagged = 1;
        }
    }
    
    //right sidewalk cracks
    if (ramp->PedRampLip > 0.0)
    {
        if (ramp->PedRampLip > 1.0)
        {
            if (flagged < 2)
            {
                if (flagged == 1)
                    basic[strlen(basic) - 1] = '\0';
                
                basic = strcat(basic, LevelChangeMajor);
                flagged = 2;
            }
            
            detail = strcat(detail, LipMajor);
        }
        
        else
        {
            if (flagged < 1)
            {
                basic = strcat(basic, LevelChangeMinor);
                flagged = 1;
            }
            
            detail = strcat(detail, LipMinor);
        }
    }
    
    flagged = 0;
    
    //obstructions
    if (ramp->rampObstruction > 0)
    {
        if (ramp->rampObstruction < none)
        {
            basic = strcat(basic, Obstructions);
            detail = strcat(detail, RampObstruction);
            flagged = 1;
        }
    }
    
    if (ramp->upperLandingObstruction > 0)
    {
        if (ramp->upperLandingObstruction < none)
        {
            if (flagged < 1)
                basic = strcat(basic, Obstructions);
            
            detail = strcat(detail, UpperLandingObstruction);
        }
    }
    
    if (ramp->lowerLandingObstruction > 0)
    {
        if (ramp->lowerLandingObstruction < none)
        {
            if (flagged < 1)
                basic = strcat(basic, Obstructions);
            
            detail = strcat(detail, StreetLandingObstruction);
        }
    }
    
    //mark as compliant if no flags have been added
    if (strlen(basic) == 0)
    {
        basic = strcat(basic, Compliant);
        detail = strcat(detail, Compliant);
    }
    
    //print to console list of issues
    if (strstr(basic, SlopeMajor))
        printf("\nIntersection %i (Ramp %i) : %s, %s", ramp->intID, ramp->rampNum, basic, detail);
    
    *detailCode = detail;
    
    return basic;
}