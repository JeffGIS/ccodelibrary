//
//  CensusData.h
//  CCodeLibrary
//
//  Created by Jeff Smith on 3/13/16.
//  Copyright © 2016 GSSi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SQLiteLib.h"

typedef NS_ENUM(NSInteger, CensusAreaTypes)
{
    CATBlocks,
    CATBlockGroups,
    CATBlockGroups_ACS,
    CATTracts,
};
typedef NS_ENUM(NSInteger, CensusAreaValue)
{
    CAVMalesByAge,
    CAVFemalesByAge,
};

@interface CensusData : NSObject

@property sqlite3 *database;
@property (atomic) BOOL isOpen;
@property (nonatomic, copy) NSString *documentsDirectory;
@property (nonatomic, copy) NSString *fileName;
@property NSInteger fileSize;

- (NSString*) databasePath;
- (BOOL)open;
- (void)close:(BOOL)opened;

-(NSString*) value:(NSString*)valueName
       forAreaType:(NSString*) areaType
           withKey:(NSString*)areaID;
-(NSArray *) getCensusChartFields:(CensusAreaTypes)areaType;
-(NSArray *) getCensusChartFieldValues:(CensusAreaValue)valueType
                              areaType:(NSString*)areaType
                                 geoID:(NSString*)geoID;
@end
