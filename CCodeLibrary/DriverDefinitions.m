//
//  DriverDefinitions.m
//  CCodeLibrary

#import "DriverDefinitions.h"

@implementation DriverDefinitions

- (id)init
{
    self = [super init];
    self.allowUpdates = FALSE;
    return self;
}

- (void)dealloc
{
    SQLite_Close(&_database);
    //NSLog(@"Driver Definitions Closed");
}

- (NSString *)databasePath
{
    NSString * bundleDbPath = [NSBundle.mainBundle pathForResource:@"facdef"
                       ofType:@"slt"];
    long long fileSizeBundle = [NSFileManager.defaultManager attributesOfItemAtPath:bundleDbPath
                                                                              error:nil].fileSize;
    if (!_allowUpdates)
        return bundleDbPath;
    
    NSString *dbPath = [NSString stringWithFormat:@"%@/%@", UserDefaults.defaults.localFilePath, @"facdef.slt"];
    long long fileSize = [NSFileManager.defaultManager attributesOfItemAtPath:dbPath
                                                                        error:nil].fileSize;

    if (fileSize != fileSizeBundle)
    {
        NSError *error = nil;
        
        [NSFileManager.defaultManager copyItemAtPath:bundleDbPath toPath:dbPath error:&error];
        
        if (error)
            NSLog(@"Copy facdef.slt ERROR: %@", error.localizedDescription);
    }

    return dbPath;
}


- (BOOL)open
{
    BOOL rtn = FALSE;
    if (!_isOpen)
    {
        self.isOpen = YES;
        NSString * path = [self databasePath];
        self.isOpen = !SQLOK(__FILE__,__LINE__,SQLite_Open(path.UTF8String, &_database), _database);
        //NSLog(@"Driver Definitions Database open");
        
        rtn = TRUE;
    }
    
    return rtn;
}

- (void)close:(BOOL)opened
{
    if (opened && _isOpen)
    {
        SQLOK(__FILE__,__LINE__,SQLite_Close(&_database),_database);
        //NSLog(@"Driver Definitions Database close");
        self.isOpen = NO;
    }
}

- (int)getPDFParamters:(NSString *)ID
                  parm:(LPPDFPARM)parm
           defaultType:(NSString *)defType
              maxParms:(int)nMax;
{
    int rtn = 0;
    if ([ID isEqualToString:@""])
        return rtn;
    Bool opened = [self open];
    NSString * sectID = @"";
    NSString * type = @"";
    if ([ID containsString:@":"])
    {
        sectID = textAfter(ID, @":");
        type = textBefore(ID, @":");
    }
    else
    {
        sectID = ID;
        type = defType;
    }
    NSString * match = @"=";
    if ([lastCharInString (sectID) isEqual:@"*"])
    {
        sectID = textBeforeLastChar(sectID, @"*");
        match = @">=";
    }
    int lenSectID = (int)sectID.length;
    NSString *query = [NSString stringWithFormat:@"SELECT SECTIONID,NAME,PAGE,ULX,ULY,LRX,LRY FROM MNACCESSCODE WHERE SECTIONID%@'%@' AND TYPE='%@'",match,sectID,type];
    
    sqlite3_stmt *statement = NULL;
    
    SQLOK(__FILE__,__LINE__,SQLitePrepare(self.database, query.UTF8String, -1, &statement, 0), _database);
    while (rtn < nMax && sqlite3_step(statement) == SQLITE_ROW)
    {
        int i = 0;
        LPSTR pSectID = (LPSTR)sqlite3_column_text(statement, i++);
        if (strnicmp (pSectID,sectID.UTF8String,lenSectID))
            break;
        strncpy (parm->SECTIONID,pSectID,sizeof(parm->SECTIONID)-1);
        parm->NAME[sizeof(parm->SECTIONID)-1] = 0;
       LPSTR pName = (LPSTR)sqlite3_column_text(statement, i++);
        strncpy (parm->NAME,pName,sizeof(parm->NAME)-1);
        parm->NAME[sizeof(parm->NAME)-1] = 0;
        parm->PAGE = sqlite3_column_int(statement, i++);
        parm->ULX = sqlite3_column_double(statement, i++);
        parm->ULY = sqlite3_column_double(statement, i++);
        parm->LRX = sqlite3_column_double(statement, i++);
        parm->LRY = sqlite3_column_double(statement, i++);
        rtn++;
        parm++;
    }
    SQLOK(__FILE__,__LINE__,SQLiteFinalize(statement), _database);
    [self close:opened];
    return rtn;
}

- (BOOL)executeCmd:(char *)cmd
{
    BOOL rtn = !SQLOK(__FILE__,__LINE__,SQLiteExec(_database, cmd, 0, 0, 0), _database);
    return rtn;
}

- (BOOL)addDefinition:(NSString *)ID
                 name:(NSString *)name
                 page:(int)page
                  ulx:(float)ulx
                  uly:(float)uly
                  lrx:(float)lrx
                  lry:(float)lry
{
    BOOL opened = [self open];

    NSString * sectID = textAfter(ID, @":");
    NSString * type = textBefore(ID, @":");
    NSString * cmd = [NSString stringWithFormat:@"INSERT OR REPLACE INTO MNACCESSCODE VALUES('%@','%@','%@',%i,%f,%f,%f,%f)",
                      sectID,type,name,page,ulx,uly,lrx,lry];
    BOOL rtn = [self executeCmd:(LPSTR)cmd.UTF8String];
    [self close:opened];
    return rtn;
}

- (NSArray<NSString *> *)getReferencesForFigure:(NSString *)figure
{
    NSMutableArray<NSString *> *refs = NSMutableArray.array;
    PDFPARM parms = {0};
    
    while ([[figure substringFromIndex:figure.length - 1]
            rangeOfCharacterFromSet:NSCharacterSet.decimalDigitCharacterSet].location == NSNotFound)
    {
        figure = [figure substringToIndex:figure.length - 1];
        
        if (figure.length < 5)
            break;
    }
    
    if ([self getPDFParamters:figure parm:&parms defaultType:@"ITEM" maxParms:1])
        [refs addObject:figure];
    
    int outer = 1;
    NSString *outerID = [figure stringByAppendingString:[NSString stringWithFormat:@".%d", outer]];
    
    while ([self getPDFParamters:outerID parm:&parms defaultType:@"ITEM" maxParms:1])
    {
        [refs addObject:outerID];
        
        int inner = 1;
        NSString *innerID = [outerID stringByAppendingString:[NSString stringWithFormat:@".%d", inner]];
        
        while ([self getPDFParamters:innerID parm:&parms defaultType:@"ITEM" maxParms:1])
        {
            [refs addObject:innerID];
            innerID = [outerID stringByAppendingString:[NSString stringWithFormat:@".%d", ++inner]];
        }
        
        outerID = [figure stringByAppendingString:[NSString stringWithFormat:@".%d", ++outer]];
    }
    
    return refs.copy;
}

@end
