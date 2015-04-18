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
    MMLMFromPriorityMap,
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
    FTPStatusFileExists,
    FTPStatusUserCancel,
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

typedef NS_ENUM(NSInteger, PropertyTableViewSetting)
{
    PropertyTableViewSettingDefault,
    PropertyTableViewSettingOptions,
    PropertyTableViewSettingPropertyReport,
    PropertyTableViewSettingHCWebsite,
    PropertyTableViewSettingStreetView,
    PropertyTableViewSettingCensusArea,
    PropertyTableViewSettingPropList,
    PropertyTableViewSettingDestinations,
};

typedef NS_ENUM(NSInteger, MapViewScreenSetting)
{
    MapViewScreenSettingFullscreen,
    MapViewScreenSettingSplitScreen,
    MapViewScreenSettingTriScreen,
    MapViewScreenSettingPlatView,
    MapViewScreenSettingSplitBottomScreen,
};

typedef NS_ENUM(NSInteger, CensusZoomSetting)
{
    CensusZoomSettingCancel,
    CensusZoomSettingBlock,
    CensusZoomSettingBlockGroup,
    CensusZoomSettingTract,
};

typedef NS_ENUM(NSInteger, SewerPipeSetting)
{
    SewerPipeSettingDefault,
    SewerPipeSettingAttributes,
    SewerPipeSettingTraceUp,
    SewerPipeSettingTraceDown,
    SewerPipeSettingRemoveTrace,
    SewerPipeSettingUpdateCleanDate,
    SewerPipeSettingUpdateNotes,
};

typedef NS_ENUM(NSInteger, CustomSetting)
{
    CustomSettingDefault,
    CustomSettingSnapToNode,
    CustomSettingSnapToLine,
};

typedef NS_ENUM(NSInteger, AlleyWallSetting)
{
    AlleyWallSettingDefault,
    AlleyWallSettingMoveWallPoint,
    AlleyWallSettingDeleteWallPoint,
    AlleyWallSettingEditWallAttributes,
};

typedef NS_ENUM(NSInteger, MapTypeSetting)
{
    MapTypeSettingStandard,
    MapTypeSettingHybrid,
};

typedef NS_ENUM(NSInteger, MarkerInfoWindowType)
{
    MarkerInfoWindowTypeDefault,
    MarkerInfoWindowTypePID,
    MarkerInfoWindowTypeStormSewer,
    MarkerInfoWindowTypeAlleyWall,
    MarkerInfoWindowTypeCustom,
};

typedef NS_ENUM(NSInteger, DigitizationMode)
{
    DigitizationModeCustom,
    DigitizationModeAlleyWall,
    DigitizationModeSewer,
    DigitizationModeProperty,
};

@end