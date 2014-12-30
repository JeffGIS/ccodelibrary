//  GSSiEnums.h
//  CCodeLibrary

#import <Foundation/Foundation.h>

@interface GSSiEnums : NSObject

typedef NS_ENUM(NSInteger, MMLMFrom)
{
    MMLMFromDefault,
    MMLMFromStatusMap,
    MMLMFromAssignInt,
    MMLMFromSelectCity,
    MMLMFromPriorityLocations,
};

typedef NS_ENUM(NSInteger, MSCFrom)
{
    MSCFromDefault,
    MSCFromSelectCity,
    MSCFromManageiPads,
    MSCFromPriorityLocations,
};

typedef NS_ENUM(NSInteger, GMSStatus)
{
    GMSStatusDefault,
    GMSStatusSetList,
    GMSStatusGetList,
    GMSStatusDelete,
};

typedef NS_ENUM(NSInteger, GMSMessage)
{
    GMSMessageDefault,
    GMSMessageOpenConnect,
    GMSMessageSetNearby,
    GMSMessageCheckNearby,
    GMSMessageCancelConnect,
};

typedef NS_ENUM(NSInteger, FTPStatus)
{
    FTPStatusDefault,
    FTPStatusOK,
    FTPStatusStop,
    FTPStatusCancel,
    FTPStatusFileWriteError,
    FTPStatusConnectionFailed,
    FTPStatusConnectionFailedTryingSecondary,
    FTPStatusFailedToUnzip,
};

typedef NS_ENUM(NSInteger, INTDBStatus)
{
    INTDBStatusDefault,
    INTDBStatusOK,
    INTDBStatusFailed,
    INTDBStatusNoNetworkConnection,
    INTDBStatusNoUploadedFile,
    INTDBStatusFailedToUnzip,
};

typedef NS_ENUM(NSInteger, IntStatus)
{
    IntStatusDefault,
    IntStatusPrelimComplete,
    IntStatusComplex,
    IntStatusDetailComplete,
};

typedef NS_ENUM(NSInteger, AreaFileStatus)
{
    AreaFileStatusDefault,
    AreaFileStatusOK,
    AreaFileStatusFailed,
};

typedef NS_ENUM(NSInteger, GMServerStatus)
{
    GMServerStatusDefault,
    GMServerStatusOK,
    GMServerStatusOpenFailed,
    GMServerStatusSendFailed,
    GMServerStatusNoResponse,
};

typedef NS_ENUM(NSInteger, IntTextType)
{
    IntTextTypeDefault,
    IntTextTypeIndex,
    IntTextTypeData,
};

typedef NS_ENUM(NSInteger, IntElementType)
{
    IntElementTypeDefault,
    IntElementTypeRamp,
    IntElementTypeXWalk,
    IntElementTypeSignal,
    IntElementTypeIntersection,
};

typedef NS_ENUM(NSInteger, GetAssStatus)
{
    GetAssStatusDefault,
    GetAssStatusOK,
    GetAssStatusFailed,
};

typedef NS_ENUM(NSInteger, PriorityLocationType)
{
    PriorityLocationTypeDefault,
    PriorityLocationTypeSchool,
};

@end