//  GSSiEnums.h
//  CCodeLibrary

#import <Foundation/Foundation.h>

@interface GSSiEnums : NSObject

typedef NS_ENUM(NSInteger, MMLMFrom)
{
    MMLMFromDefault,
    MMLMFromStatusMap,
    MMLMFromAssignInt,
    MMLMFromSelectCity
};

typedef NS_ENUM(NSInteger, MSCFrom)
{
    MSCFromDefault,
    MSCFromSelectCity,
    MSCFromManageiPads,
};

typedef NS_ENUM(NSInteger, GMSStatus)
{
    GMSStatusDefault,
    GMSStatusSetList,
    GMSStatusGetList,
    GMSStatusDelete,
};

typedef NS_ENUM(NSInteger, GMSMessageID)
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

@end