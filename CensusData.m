//
//  CensusData.m
//  CCodeLibrary
//
//  Created by Jeff Smith on 3/13/16.
//  Copyright © 2016 GSSi. All rights reserved.
//

#import "CensusData.h"
#import "CCodeLibrary.h"

@implementation CensusData

- (NSString*) databasePath
{
    _documentsDirectory = UserDefaults.defaults.sharedFilePath;
    NSString * path = [NSBundle.mainBundle pathForResource:@"censusdata"
                                             ofType:@"slt"];
    _fileName = @"censusdata.slt";
    return path;
}

- (BOOL)open
{
    if (!_isOpen)
    {
        self.isOpen = YES;
        NSString * path = [self databasePath];
        self.isOpen = !SQLOK(145,sqlite3_open(path.UTF8String, &_database), _database);
        //NSLog(@"Property Database open");
        
        _fileSize = (NSInteger)[NSFileManager.defaultManager attributesOfItemAtPath:path
                                                                              error:nil].fileSize;
        return TRUE;
    }
    else
        return FALSE;
}

- (void)close:(BOOL)opened
{
    if (opened)
    {
        SQLOK(146,sqlite3_close(_database), _database);
        //NSLog(@"Property Database close");
        _isOpen = NO;
    }
}

- (NSString *)value:(NSString *)valueName
        forAreaType:(NSString *)areaType
            withKey:(NSString *)areaID

{
    sqlite3_stmt *statement = NULL;
    NSString *value = @"";
    NSString *query = [NSString stringWithFormat:@"SELECT [%@] FROM CENSUS%@DATA WHERE GEOG_UNIT ='%@'",valueName,areaType,areaID];
    BOOL opened = [self open];
    SQLOK(0,sqlite3_prepare_v2(_database, query.UTF8String, -1, &statement, 0), _database);
    
    if (sqlite3_step(statement) == SQLITE_ROW)
    {
        LPSTR cvalue = (LPSTR)sqlite3_column_text(statement,0);
        value = [NSString stringWithUTF8String:cvalue];
    }
    
    SQLOK(0,sqlite3_finalize(statement), _database);
    [self close:opened];
    return value;
}

- (NSArray *)getCensusChartFields:(CensusAreaTypes)areaType
{
    NSMutableArray *rtn = NSMutableArray.array;
    
    switch (areaType)
    {
        case CATBlocks:
        [rtn addObject:[NSString stringWithFormat:@"%s\x03%i", "Males by Age", CAVMalesByAge]];
        [rtn addObject:[NSString stringWithFormat:@"%s\x03%i", "Females by Age", CAVFemalesByAge]];
            break;
        case CATTracts:
        [rtn addObject:[NSString stringWithFormat:@"%s\x03%i", "Males by Age", CAVMalesByAge]];
        [rtn addObject:[NSString stringWithFormat:@"%s\x03%i", "Females by Age", CAVFemalesByAge]];
            break;
        default:
            break;
    }
    
    return rtn.copy;
}

- (NSString *)getValue:(char *)xVal
                 field:(char *)fld
              areaType:(NSString *)areaType
                 geoID:(NSString *)geoID
{
    NSString *value = [self value:[NSString stringWithUTF8String:fld]
                      forAreaType:areaType
                          withKey:geoID];
    
    NSString *rtn = [NSString stringWithFormat:@"%s\x03%@",xVal,value];
    return rtn;
}

- (NSArray *)getCensusChartFieldValues:(CensusAreaValue)valueType
                              areaType:(NSString *)areaType
                                 geoID:(NSString *)geoID
{
    NSMutableArray *rtn = NSMutableArray.array;
    
    switch (valueType)
    {
        case CAVMalesByAge:
        [rtn addObject:[self getValue:"0 to 4" field:"M_0_4" areaType:areaType geoID:geoID]];
        [rtn addObject:[self getValue:"5 to 9" field:"M_5_9" areaType:areaType geoID:geoID]];
        [rtn addObject:[self getValue:"10 to 14" field:"M_10_14" areaType:areaType geoID:geoID]];
        [rtn addObject:[self getValue:"15 to 19" field:"M_15_19" areaType:areaType geoID:geoID]];
        [rtn addObject:[self getValue:"20 to 24" field:"M_20_24" areaType:areaType geoID:geoID]];
        [rtn addObject:[self getValue:"25 to 29" field:"M_25_29" areaType:areaType geoID:geoID]];
        [rtn addObject:[self getValue:"30 to 34" field:"M_30_34" areaType:areaType geoID:geoID]];
        [rtn addObject:[self getValue:"35 to 39" field:"M_35_39" areaType:areaType geoID:geoID]];
        [rtn addObject:[self getValue:"40 to 44" field:"M_40_44" areaType:areaType geoID:geoID]];
        [rtn addObject:[self getValue:"45 to 49" field:"M_45_49" areaType:areaType geoID:geoID]];
        [rtn addObject:[self getValue:"50 to 54" field:"M_50_54" areaType:areaType geoID:geoID]];
        [rtn addObject:[self getValue:"55 to 59" field:"M_55_59" areaType:areaType geoID:geoID]];
        [rtn addObject:[self getValue:"60 to 64" field:"M_60_64" areaType:areaType geoID:geoID]];
        [rtn addObject:[self getValue:"65 to 69" field:"M_65_69" areaType:areaType geoID:geoID]];
        [rtn addObject:[self getValue:"70 to 74" field:"M_70_74" areaType:areaType geoID:geoID]];
        [rtn addObject:[self getValue:"75 to 79" field:"M_75_79" areaType:areaType geoID:geoID]];
        [rtn addObject:[self getValue:"80 to 84" field:"M_80_84" areaType:areaType geoID:geoID]];
        [rtn addObject:[self getValue:"over age 85" field:"M_OVER85" areaType:areaType geoID:geoID]];
        break;
        case CAVFemalesByAge:
        [rtn addObject:[self getValue:"0 to 4" field:"F_0_4" areaType:areaType geoID:geoID]];
        [rtn addObject:[self getValue:"5 to 9" field:"F_5_9" areaType:areaType geoID:geoID]];
        [rtn addObject:[self getValue:"10 to 14" field:"F_10_14" areaType:areaType geoID:geoID]];
        [rtn addObject:[self getValue:"15 to 19" field:"F_15_19" areaType:areaType geoID:geoID]];
        [rtn addObject:[self getValue:"20 to 24" field:"F_20_24" areaType:areaType geoID:geoID]];
        [rtn addObject:[self getValue:"25 to 29" field:"F_25_29" areaType:areaType geoID:geoID]];
        [rtn addObject:[self getValue:"30 to 34" field:"F_30_34" areaType:areaType geoID:geoID]];
        [rtn addObject:[self getValue:"35 to 39" field:"F_35_39" areaType:areaType geoID:geoID]];
        [rtn addObject:[self getValue:"40 to 44" field:"F_40_44" areaType:areaType geoID:geoID]];
        [rtn addObject:[self getValue:"45 to 49" field:"F_45_49" areaType:areaType geoID:geoID]];
        [rtn addObject:[self getValue:"50 to 54" field:"F_50_54" areaType:areaType geoID:geoID]];
        [rtn addObject:[self getValue:"55 to 59" field:"F_55_59" areaType:areaType geoID:geoID]];
        [rtn addObject:[self getValue:"60 to 64" field:"F_60_64" areaType:areaType geoID:geoID]];
        [rtn addObject:[self getValue:"65 to 69" field:"F_65_69" areaType:areaType geoID:geoID]];
        [rtn addObject:[self getValue:"70 to 74" field:"F_70_74" areaType:areaType geoID:geoID]];
        [rtn addObject:[self getValue:"75 to 79" field:"F_75_79" areaType:areaType geoID:geoID]];
        [rtn addObject:[self getValue:"80 to 84" field:"F_80_84" areaType:areaType geoID:geoID]];
        [rtn addObject:[self getValue:"over age 85" field:"F_OVER85" areaType:areaType geoID:geoID]];
        break;
        default:
            break;
    }
    
    return rtn.copy;
}

@end
