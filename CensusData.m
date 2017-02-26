//
//  CensusData.m
//  CCodeLibrary
//
//  Created by Jeff Smith on 3/13/16.
//  Copyright © 2016 GSSi. All rights reserved.
//

#import "CensusData.h"
#import "CCodeLibrary.h"

@interface CensusData ()
@property sqlite3 *tempdatabase;
@end

@implementation CensusData

+ (NSString*) databasePath
{
    NSString * documentsDirectory = UserDefaults.defaults.localFilePath;
    NSString * path = [NSBundle.mainBundle pathForResource:@"censusdata"
                                                    ofType:@"slt"];
    return path;
}

+ (NSString*) computedFieldsPath
{
    NSString * documentsDirectory = UserDefaults.defaults.localFilePath;
    NSString * path = [NSString stringWithFormat:@"%@/ComputedCensusData.slt",documentsDirectory];
    return path;
}

- (BOOL)open
{
    if (_isOpen)
        return FALSE;
    
    int fileSize = (NSInteger)[NSFileManager.defaultManager attributesOfItemAtPath:[CensusData computedFieldsPath]
                                                                             error:nil].fileSize;
    if (fileSize <= 0)
    {
        SQLOK(145,sqlite3_open([CensusData computedFieldsPath].UTF8String, &_tempdatabase), _tempdatabase);
        SQLOK(146,sqlite3_close(_tempdatabase), _tempdatabase);
    }
    
    fileSize = (NSInteger)[NSFileManager.defaultManager attributesOfItemAtPath:[CensusData databasePath]
                                                                         error:nil].fileSize;
    if (fileSize > 0)
    {
        _isOpen = !SQLOK(145,sqlite3_open([CensusData databasePath].UTF8String, &_database), _database);
        if (_isOpen)
        {
            NSString *attachCmd = [NSString stringWithFormat:@"ATTACH DATABASE '%@' AS COMPUTEDCENSUSFIELDS",[CensusData computedFieldsPath]];
            [self executeCmd:(LPSTR)attachCmd.UTF8String];
            [self addSTDVFields];
            return TRUE;
        }
    }
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

- (void) addSTDVAge:(char*)tableName
{
    sqlite3_stmt *statement = NULL;
    NSString * query = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS COMPUTEDCENSUSFIELDS.ADDEDFIELDS (GEOG_UNIT CHAR(17),STDV_AGE REAL,MEAN_AGE REAL)"];
    [self executeCmd:query.UTF8String];
    int nVals = 0;
    
    query = @"SELECT GEOG_UNIT";
    for (int iage = 0;iage < 81;iage+=5)
    {
        query = [query stringByAppendingString:[NSString stringWithFormat:@",M_%i_%i",iage,iage+4]];
        nVals++;
    }
    query = [query stringByAppendingString:@",M_OVER85"];
    nVals++;
    for (int iage = 0;iage < 81;iage+=5)
    {
        query = [query stringByAppendingString:[NSString stringWithFormat:@",F_%i_%i",iage,iage+4]];
        nVals++;
    }
    query = [query stringByAppendingString:[NSString stringWithFormat:@",F_OVER85 FROM %s",tableName]];
    nVals++;
    SQLOK(0,sqlite3_prepare_v2(_database, query.UTF8String, -1, &statement, 0), _database);
    
    while (sqlite3_step(statement) == SQLITE_ROW)
    {
        double value;
        NSNumber * age;
        NSNumber * count;
        int i = 0;
        LPSTR key = (LPSTR)sqlite3_column_text(statement,i++);
        NSMutableArray *ageArray = NSMutableArray.new;
        NSMutableArray *countArray = NSMutableArray.new;
        for (int iage = 0;iage < 81;iage+=5)
        {
            age = [NSNumber numberWithDouble:iage+2.5];
            [ageArray addObject:age];
            value = sqlite3_column_double(statement,i++);
            count = [NSNumber numberWithDouble:value];
            [countArray addObject:count];
        }
        age = [NSNumber numberWithDouble:87.5];
        [ageArray addObject:age];
        value = sqlite3_column_double(statement,i++);
        count = [NSNumber numberWithDouble:value];
        [countArray addObject:count];
        
        for (int iage = 0;iage < 81;iage+=5)
        {
            age = [NSNumber numberWithDouble:iage+2.5];
            [ageArray addObject:age];
            value = sqlite3_column_double(statement,i++);
            count = [NSNumber numberWithDouble:value];
            [countArray addObject:count];
        }
        age = [NSNumber numberWithDouble:87.5];
        [ageArray addObject:age];
        value = sqlite3_column_double(statement,i++);
        count = [NSNumber numberWithDouble:value];
        [countArray addObject:count];
        ArrayOfNumbers * aon = [ArrayOfNumbers initWithArray:ageArray andMultipliers:countArray];
        double stdv = [aon standardDeviationOf].doubleValue;
        double mean = [aon meanOf].doubleValue;
        NSString * updateQuery =[NSString stringWithFormat:@"INSERT INTO COMPUTEDCENSUSFIELDS.ADDEDFIELDS VALUES('%s',%f,%f)",key,stdv,mean];
        [self executeCmd:updateQuery.UTF8String];
    }
    
    SQLOK(0,sqlite3_finalize(statement), _database);
    /*    M_0_4= males in this age range (P12);
    M_5_9= males in this age range (P12);
    M_10_14= males in this age range (P12);
    M_15_19= males in this age range (P12);
    M_20_24= males in this age range (P12);
    M_25_29= males in this age range (P12);
    M_30_34= males in this age range (P12);
    M_35_39= males in this age range (P12);
    M_40_44= males in this age range (P12);
    M_45_49= males in this age range (P12);
    M_50_54= males in this age range (P12);
    M_55_59= males in this age range (P12);
    M_60_64= males in this age range (P12);
    M_65_69= males in this age range (P12);
    M_70_74= males in this age range (P12);
    M_75_79= males in this age range (P12);
    M_80_84= males in this age range (P12);
    M_OVER85= males in this age range (P12);
    F_0_4= females in this age range (P12);
    F_5_9= females in this age range (P12);
    F_10_14= females in this age range (P12);
    F_15_19= females in this age range (P12);
    F_20_24= females in this age range (P12);
    F_25_29= females in this age range (P12);
    F_30_34= females in this age range (P12);
    F_35_39= females in this age range (P12);
    F_40_44= females in this age range (P12);
    F_45_49= females in this age range (P12);
    F_50_54= females in this age range (P12);
    F_55_59= females in this age range (P12);
    F_60_64= females in this age range (P12);
    F_65_69= females in this age range (P12);
    F_70_74= females in this age range (P12);
    F_75_79= females in this age range (P12);
    F_80_84= females in this age range (P12);
    F_OVER85= females in this age range (P12);*/
    return;

}
- (void) addSTDVFields
{
    if (!doesSQLiteTableExist("COMPUTEDCENSUSFIELDS.ADDEDFIELDS", _database))
    {
        [self startTransaction];
        [self addSTDVAge:"CENSUSTRACTDATA"];
        [self addSTDVAge:"CENSUSBLOCKGROUPDATA"];
        [self addSTDVAge:"CENSUSBLOCKDATA"];
        [self commitTransaction];
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
    BOOL opened = [self open];
    
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
    [self close:opened];
    
    return rtn.copy;
}

- (BOOL)executeCmd:(char *)cmd
{
    BOOL rtn = !SQLOK(155,sqlite3_exec(_database, cmd, 0, 0, 0), _database);
    return rtn;
}

- (void)startTransaction
{
    [self open];
    SQLOK(156,sqlite3_exec(_database, "BEGIN", 0, 0, 0), _database);
}

- (void)commitTransaction
{
    SQLOK(157,sqlite3_exec(_database, "COMMIT", 0, 0, 0),_database);
}

@end
