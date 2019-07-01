//
//  NVSlopeData.h
//  CCodeLibrary
//
//  Created by Jeff Smith on 7/1/19.
//  Copyright © 2019 GSSi. All rights reserved.
//

#ifndef NVSlopeData_h
#define NVSlopeData_h

typedef NS_ENUM(NSInteger, NVManualStatus)
{
    NVManualStatusDevice,
    NVManualStatusManual,
    NVManualStatusCancelled,
};

typedef struct NVSlopeData {
    double accelX;
    double accelY;
    double accelZ;
    double frontSlopeDegrees;
    double sideSlopeDegrees;
    double frontSlopePct;
    double sideSlopePct;
    double manualFrontSlopeDegrees;
    double manualSideSlopeDegrees;
    double manualFrontSlopePct;
    double manualSideSlopePct;
    double maxSlopePct;
    double maxSlopeDegrees;
    double heading;
    NVManualStatus frontManualStatus;
    NVManualStatus sideManualStatus;
} NVSlopeData;

#endif /* NVSlopeData_h */
