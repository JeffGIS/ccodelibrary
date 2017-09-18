//  GSSiEnums.h
//  CCodeLibrary
#ifndef GSSiEnums_h
#define GSSiEnums_h


#import <Foundation/Foundation.h>

//@interface GSSiEnums : NSObject

typedef NS_ENUM(NSInteger, DataSetTypes)
{
    CURBRAMPS,
    ALLEYWALLS,
    NumDataSetTypes
};

typedef NS_ENUM(NSInteger, ValueTypes)
{
    VTInteger,
    VTDouble,
    VTLLPoint,
    VTString,
};

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
    MMMapTypeDataQuality,
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
    MMLMFromPriorityBounds,
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
    GMSStatusGetMessage,
    GMSStatusGetNearbyiPads,
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
    GMSMessageGetiPadNumber,
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
    PriorityLocationTypeParksRec,
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
    GMMSettingMultipleProps,
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
    MapViewScreenSettingSplitPlatView,
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
    MarkerInfoWindowTypeMGVSanPoint,
    MarkerInfoWindowTypeMGVSanMain,
    MarkerInfoWindowTypeCensusBoundary,
    MarkerInfoWindowTypeBA,
    MarkerInfoWindowTypeSdwk,
};

typedef NS_ENUM(NSInteger, HardCodedConfigs)
{
    HCConfigAlleyWalls,
    HCConfigAlleyWallStatus,
    HCConfigCurbRamps,
    HCConfigSidewalk,
    HCConfigSewers,
    HCConfigMetroProp,
    HCConfigCrimes,
    HCConfigMapleGrove,
    HCConfigFromSpreadsheet,
    HCConfigMapleGrovePDF,
    HCConfigFromSlowValues,
NUMHardCodedConfigs};

typedef NS_ENUM(NSInteger, MapitBaseLayer)
{
    MBL_LandUse,
    MBL_Parcels,
    MBL_CensusBlocks,
    MBL_CensusBlockGroups,
    MBL_CensusTracts,
};

typedef NS_ENUM(NSInteger, AdjustCrimeOptions)
{
    ACO_None,
    ACO_Population,
    ACO_HousingUnits,
    ACO_OverDueAverage,
    ACO_OverDueSTDV,
};

typedef NS_ENUM(NSInteger, SpreadsheetTypes)
{
    SST_PropertyList,
    SST_CrimeList,
};

typedef NS_ENUM(NSInteger, SpreadsheetAction)
{
    SSA_None,
    SSA_SortRows,
    SSA_ShowDescription,
    SSA_EditText,
    SSA_SelectRow,
    SSA_MultiSelect,
};

typedef NS_ENUM(NSInteger, DataCompareOptions)
{
    DCOptionRaw,
    DCOptionCount,
    DCOptionTime,
};

typedef NS_ENUM(NSInteger, PointSymbols)
{
    NoSym,
    CrossSym,
    PlusSym,
    DiamondSym,
    TriangleSym,
    SquareSym,
    Star1Sym,
    Star2Sym,
    CircleSym,
    ArsonSym,
    PointSymbolCount
};

typedef NS_ENUM(NSInteger, PolylineSymbols)
{
    NoPolylineSym,
    BlueWidth3Polyline,
    RedWidth3Polyline,
    GreenWidth3Polyline,
    PolylineSymbolCount
};

typedef NS_ENUM(NSInteger, PolygonSymbols)
{
    NoPolygonSym,
    Blue50PCTPolygon,
    Red50PCTPolygon,
    Green50PCTPolygon,
    Yellow50PCTPolygon,
    Grey50PCTPolygon,
    PolygonSymbolCount
};
typedef NS_ENUM(NSInteger, FacGraphicsTypes)
{
    FGTPoint,
    FGTPolyline,
    FGTPolygon,
};

typedef NS_ENUM(NSInteger, FacilityMeasurementType)
{
    FMTInvalidType,
    FMTYesNo,
    FMTImageList,
    FMTChoiceList,
    FMTSlope,
    FMTPounds,
    FMTInches,
    FMTFeet,
    FMTLocatePoint,
    FMTLocatePolyline,
    FMTLocatePolygon,
    FMTDoorCloseSeconds,
    FMTFieldCount,
    FMTText,
    FMTHeader,
    FMTHeaderOnly,
    FMTCount,
    FMTPriorHeader,
};

typedef NS_ENUM(NSInteger, FacPointSymbols)
{
    FPSDrinkingFountain=CrossSym,
    FPSToiletRoom=DiamondSym,
    FPSElevator=TriangleSym,
    FPSEntrance=SquareSym,
    FPSDoor=Star1Sym,
};

typedef NS_ENUM(NSInteger, FacPolylineSymbols)
{
    FPSCirculationPath=RedWidth3Polyline,
    FPSAccessibleRoute=GreenWidth3Polyline,
    FPSRamp=BlueWidth3Polyline,
};

typedef NS_ENUM(NSInteger, FacPolygonSymbols)
{
    FPSPublicArea=Red50PCTPolygon,
    FPSWorkArea=Green50PCTPolygon,
};



//@end

#endif
