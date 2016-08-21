//  GSSiEnums.h
//  CCodeLibrary

#import <Foundation/Foundation.h>

@interface GSSiEnums : NSObject

typedef NS_ENUM(NSInteger, NVNoteType)
{
    NoteTypeNoType,
    NoteTypeCurbRampIntersectionNote,
    NoteTypeCurbRampCornerNote,
};

typedef NS_ENUM(NSInteger, MMMapType)
{
    MMMapTypePrelim,
    MMMapTypeDetail,
    MMMapTypeRampIssues,
};

typedef NS_ENUM(NSInteger, MMLMFrom)
{
    MMLMFromDefault,
    MMLMFromStatusMap,
    MMLMFromAssignInt,
    MMLMFromSelectCity,
    MMLMFromPriorityLocations,
    MMLMFromPriorityMap,
    MMLMFromRetrieveData,
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
    GMSStatusGetiPadNumber,
    GMSStatusSetiPadList,
    GMSStatusGetiPadList,
    GMSStatusDelete,
    GMSStatusCreateNVOrgNumber,
    GMSStatusActivateAccount,
    GMSStatusRefreshiPadList,
    GMSStatusGetCityList,
    GMSStatusSetCityList,
    GMSStatusPickPlace,
};

typedef NS_ENUM(NSInteger, GMSMessage)
{
    GMSMessageDefault,
    GMSMessageOpenConnect,
    GMSMessageSetNearby,
    GMSMessageCheckNearby,
    GMSMessageCancelConnect,
    GMSMessageGetPoliceUpdate,
    GMSMessageGetUploadStatus,
    GMSMessageFileUploaded,
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
    FTPStatusFileExists,
    FTPStatusUserCancel,
    FTPStatusBusy,
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
    PriorityLocationTypeMedical,
    PriorityLocationTypeLibrary,
    PriorityLocationTypeEmployment,
    PriorityLocationTypePostOffice,
    PriorityLocationTypeGovernment,
    PriorityLocationTypeHotel,
    PriorityLocationTypeSeniorResidential,
    PriorityLocationTypeCustom,
};

typedef NS_ENUM(NSInteger, PriorityOffsetSetting)
{
    PriorityOffsetSettingDefault,
    PriorityOffsetSettingGlobal,
    PriorityOffsetSettingCategory,
    PriorityOffsetSettingIndividual,
};

typedef NS_ENUM(NSInteger, GMMSetting)
{
    GMMSettingDefault,
    GMMSettingPID,
    GMMSettingAddress,
    GMMSettingPropOwner,
    GMMSettingIntersection,
    GMMSettingBoundaries,
};

typedef NS_ENUM(NSInteger, GMLayerSetting)
{
    GMLayerSettingOn,
    GMLayerSettingOff,
    GMLayerSettingAuto,
};

typedef NS_ENUM(NSInteger, MapViewScreenSetting)
{
    MapViewScreenSettingFullscreen,
    MapViewScreenSettingSplitScreen,
    MapViewScreenSettingTriScreen,
    MapViewScreenSettingPlatView,
    MapViewScreenSettingSplitBottomScreen,
};

typedef NS_ENUM(NSInteger, MarkerInfoWindowType)
{
    MarkerInfoWindowTypeDefault,
    MarkerInfoWindowTypePID,
    MarkerInfoWindowTypeStormSewer,
    MarkerInfoWindowTypeAlleyWall,
    MarkerInfoWindowTypeAlleyLine,
    MarkerInfoWindowTypeCustom,
    MarkerInfoWindowTypeCRInt,
    MarkerInfoWindowTypeCrime,
};

typedef NS_ENUM(NSInteger, HardCodedConfigs)
{
    HCConfigAlleyWalls,
    HCConfigAlleyWallStatus,
    HCConfigCurbRamps,
    HCConfigSewers,
    HCConfigMetroProp,
    HCConfigCrimes,
    HCConfigMapleGrove,
    HCConfigFromSpreadsheet,
};

@end