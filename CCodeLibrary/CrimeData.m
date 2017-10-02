//
//  CrimeData.m
//  CCodeLibrary
//
//  Created by JEFFREY E SMITH on 10/10/15.
//  Copyright © 2015 GSSi. All rights reserved.
//
/*
CREATE TABLE OFFENSEXY (id INT PRIMARY KEY,'ControlNbr' INT,'OffenseOrder' INT,'Offense' CHAR(6),'CityCode' CHAR(2),'CaseYear' INT,'CaseNbr' CHAR(6),'ControlType' CHAR(1),'Attempt' CHAR(1),'BeginDate2' CHAR(19),'Precinct' CHAR(2),'UCRCode' CHAR(2),'NIBRSCode' CHAR(3),'CrimeCategory' CHAR(1),'CrimeClass' CHAR(1),'LastChangedID2' CHAR(11),'LastChanged2' CHAR(19),'OriginalCaseYear' INT,'OriginalCaseNbr' CHAR(6),'HouseNbr' CHAR(6),'HouseModifier' CHAR(1),'StreetName' CHAR(22),'StreetType' CHAR(2),'StreetDirection' CHAR(2),'IntersectionStreetName' CHAR(22),'IntersectionStreetType' CHAR(2),'IntersectionStreetDirection' CHAR(2),'Apartment' CHAR(5),'City2' CHAR(30),'State' CHAR(2),'VictimBusiness' CHAR(1),'Zipcode2' CHAR(9),'EndDate' CHAR(19),'ReportedDate' CHAR(19),'BeginDate' CHAR(19),'DispatchedTime' CHAR(4),'ArrivedTime' CHAR(4),'Location' CHAR(30),'ClearedTime' CHAR(4),'PrimaryOffense' CHAR(6),'SupervisorID' CHAR(11),'AssistingOfficerID' CHAR(11),'NotPublicInformation' CHAR(1),'UnitNbr' CHAR(4),'ReportingID' CHAR(11),'CallNbr' CHAR(11),'EnteredID' CHAR(11),'EnteredDate' CHAR(19),'LastChanged' CHAR(19),'AdultStatus' INT,'JuvenileStatus' INT,'Solvable' INT,'NotPublicAddressInformation' CHAR(1),'LastChangedID' CHAR(11),'ForceSupervisorReviewRequired' INT,'ForceSupervisorReviewCompeted' INT,'ForceIAUReviewCompleted' INT,'MatchCode' INT,'LocationCode' INT,'StreetNum' INT,'HouseNum' INT,'IntID' INT,'StreetNum1' INT,'StreetNum2' INT,'Street1MP' REAL,'Street2MP' REAL,'MunicNum' INT,'ZIP' INT,'X' REAL,'Y' REAL,'NumPartsRemoved' INT,'AddressTAGPrefix' CHAR(8),'AddressTAGUDI' CHAR(64),'Street' CHAR(80),'House' CHAR(12),'City' CHAR(32),'ZIPCODE' CHAR(12),'Symbol' CHAR(64),'FromDate' INT,'ToDate' INT,'Note' CHAR(100),'UCR' INT)
*/

#define LOAD_PEOPLE_UPDATE 4757

#define INPUTBUFSIZE USHRT_MAX * 32

#import "CrimeData.h"
#import "UserDefaults.h"
#import "CRAPI.h"
#import "GeoMasterServer.h"
#import "GSSiPopoverView.h"
#import "FTPDataPull.h"
#import "compress.h"
#import "NVAlertView.h"
#include "shr.h"

@interface CrimeData () <GeoMasterServerDelegate,GSSiPopoverViewDelegate,FTPDataPullDelegate,NVAlertViewDelegate>

@property (nonatomic) UIColor *red;
@property (nonatomic) GeoMasterServer *GMServer;
@property (nonatomic) GSSiPopoverView *popoverView;
@property (nonatomic) NSTimer *updateTimer;
@property FTPDataPull *pull;
@property Bool keepGoing;
@property Bool firstFail;
@property (nonatomic) UIView *fromView;

@end

@implementation CrimeData

- (NSString *)databasePath
{
    return self.path;
}

- (id)init
{
    self = [super init];
    
    if (self)
    {
        _documentsDirectory = UserDefaults.defaults.sharedFilePath;
        _documentsDirectory = [_documentsDirectory stringByAppendingString:@"/MplsPolice"];
        _fileName = @"CrimeData.slt";
        _path = [NSString stringWithFormat:@"%@/%@", _documentsDirectory, _fileName];
        _reportsDirectory = [NSString stringWithFormat:@"%@/Reports", _documentsDirectory];
        [NSFileManager.defaultManager createDirectoryAtPath:_reportsDirectory
                                withIntermediateDirectories:YES
                                                 attributes:nil
                                                      error:nil];
        
    }
    
    return self;
}

- (void)dealloc
{
    [self close:YES];
    NSLog(@"Crime Database dealloc");
}
- (void) fixName
{
/*    NSString *newFilePath = [NSString stringWithFormat:@"%@.uploaded", _path];
    NSError *error = nil;
    NSLog(@"%@", newFilePath);
    
    int fileSize = [NSFileManager.defaultManager attributesOfItemAtPath:newFilePath
                                                               error:nil].fileSize;
    if (fileSize > 0)
    {
        [self clear];
        [NSFileManager.defaultManager moveItemAtPath:newFilePath
                                          toPath:_path
                                           error:&error];
        _fileSize = [NSFileManager.defaultManager attributesOfItemAtPath:_path
                                                                   error:nil].fileSize;
    
        if (error)
            NSLog(@"ERROR renaming file:%@", _fileName);
    }*/
}

- (Bool)open
{
    [self fixName];
    if (!_isOpen)
    {
        _isOpen = !SQLOK(__FILE__,__LINE__,sqlite3_open(self.path.UTF8String, &_database), _database);
        NSLog(@"Crime Database open");
        
        _fileSize = [NSFileManager.defaultManager attributesOfItemAtPath:_path
                                                                   error:nil].fileSize;
        if (_fileSize > 0)
        {
/*            [self startTransaction];
            [self executeCmd:"CREATE INDEX IF NOT EXISTS OFFENSEXY_KEY ON OFFENSEXY (ControlNbr, OffenseOrder)"];
            [self commitTransaction];*/
        }

        return TRUE;
    }
    return FALSE;
}

- (void)close:(Bool)opened
{
    if (opened && _isOpen)
    {
        SQLOK(__FILE__,__LINE__,sqlite3_close(_database),_database);
        NSLog(@"Crime Database close");
        _isOpen = NO;
    }
}

- (Bool)clear
{
    [self close:YES];
    
    Bool st = [NSFileManager.defaultManager removeItemAtPath:_path
                                                       error:nil];
         st = [NSFileManager.defaultManager removeItemAtPath:_reportsDirectory
                                                       error:nil];
    return st;
}

- (int) datasetVersion
{
    int rtn = -1;
    Bool opened = [self open];
    if (_isOpen && _fileSize > 0)
    {
        NSString *query = [NSString stringWithFormat:@"SELECT VersionNum FROM VERSION"];
        
        sqlite3_stmt *statement = NULL;
        
        SQLOK(__FILE__,__LINE__,SQLitePrepare(_database, query.UTF8String, -1, &statement, 0), _database);
        if (sqlite3_step(statement) == SQLITE_ROW)
        {
            LPSTR version = (LPSTR)sqlite3_column_text(statement, 0);
            rtn = atoi (version);
        }
        SQLOK(__FILE__,__LINE__,SQLiteFinalize(statement), _database);
    }

    [self close:opened];
    return rtn;
}
- (int) maxID
{
    int rtn = -1;
    NSString *query = [NSString stringWithFormat:@"SELECT max(id) FROM OFFENSEXY"];
    
    sqlite3_stmt *statement = NULL;
    
    SQLOK(__FILE__,__LINE__,SQLitePrepare(_database, query.UTF8String, -1, &statement, 0), _database);
    if (sqlite3_step(statement) == SQLITE_ROW)
    {
        rtn = sqlite3_column_int(statement, 0);
    }
    SQLOK(__FILE__,__LINE__,SQLiteFinalize(statement), _database);
    return rtn;
}

- (NSInteger) lastUpdate
{
    NSInteger rtn = 0;
    Bool opened = [self open];
    if (_isOpen && _fileSize > 0)
    {
        NSString *query = [NSString stringWithFormat:@"SELECT LastUpdate FROM UPDATES"];
        
        sqlite3_stmt *statement = NULL;
        
        SQLOK(__FILE__,__LINE__,SQLitePrepare(_database, query.UTF8String, -1, &statement, 0), _database);
        if (sqlite3_step(statement) == SQLITE_ROW)
        {
            rtn = sqlite3_column_int(statement, 0);
        }
        SQLOK(__FILE__,__LINE__,SQLiteFinalize(statement), _database);
        if (!rtn)
            [self executeCmd:"CREATE TABLE IF NOT EXISTS UPDATES (id INTEGER PRIMARY KEY,LastUpdate INT)"];
    }
    [self close:opened];
    return rtn;
}

- (Bool)executeCmd:(char *)cmd
{
    Bool rtn = !SQLOK(__FILE__,__LINE__,SQLiteExec(_database, cmd, 0, 0, 0), _database);
    return rtn;
}

- (Bool)startTransaction
{
    Bool rtn = [self open];
    SQLOK(__FILE__,__LINE__,SQLiteExec(_database, "BEGIN", 0, 0, 0), _database);
    return rtn;
}

- (void)commitTransaction
{
    SQLOK(__FILE__,__LINE__,SQLiteExec(_database, "COMMIT", 0, 0, 0),_database);
}

- (Bool) fileAndOffsetForControlNumber:(NSInteger)cnumber
                                  file:(int *)pFile
                                offset:(int *)pOffset
{
    Bool rtn = FALSE;
    
    Bool opened = [self open];
    NSString *query = [NSString stringWithFormat:@"SELECT File, Offset FROM REPORTLOC WHERE ControlNbr = %li",(long)cnumber];
    
    sqlite3_stmt *statement = NULL;
    
    SQLOK(__FILE__,__LINE__,SQLitePrepare(_database, query.UTF8String, -1, &statement, 0), _database);
    if (sqlite3_step(statement) == SQLITE_ROW)
    {
        *pFile = sqlite3_column_int(statement, 0);
        *pOffset = sqlite3_column_int(statement, 1);
        rtn = TRUE;
    }
    SQLOK(__FILE__,__LINE__,SQLiteFinalize(statement),_database);
    [self close:opened];
    return rtn;
}

+ (NSString *)reportForControlNumber:(NSInteger)cnumber
{
    CrimeData *cd = [[CrimeData alloc]init];
    return [cd reportForControlNum:cnumber];
}

- (NSString *)reportForControlNum:(NSInteger)cnumber
{
    NSString * report = @"";
    int ifile, offset;
    Bool opened = [self open];
    
    if ([self fileAndOffsetForControlNumber:cnumber
                                     file:&ifile
                                   offset:&offset])
    {
        //    NSString *file = [NSBundle.mainBundle pathForResource:@"3496486"
        //                                                   ofType:@"TXT"];
        NSString *toDirectory = self.reportsDirectory;
        NSString *file = [NSString stringWithFormat:@"%@/%i.gcf",toDirectory,ifile];
        NSString *reportFile = [NSString stringWithFormat:@"%@/%i.TXT",toDirectory,(int)cnumber];
//        int fileSize = [NSFileManager.defaultManager attributesOfItemAtPath:file
//                                                                      error:nil].fileSize;
        
        if (DecompressGMZipFile((LPSTR)file.UTF8String, (LPSTR)toDirectory.UTF8String,offset,1,0))
        {
            NSError *error = nil;
            report = [NSString stringWithContentsOfFile:reportFile encoding:NSUTF8StringEncoding error:&error];
            [NSFileManager.defaultManager removeItemAtPath:reportFile error:nil];
        }
    }
    [self close:opened];
    return report;
}

- (Bool)update:(UIView *)fromView
          auto:(Bool)autoUpdate
      delegate:(id)delegate
{
    Bool rtn = FALSE;
    _firstFail = TRUE;
    static int nextTime = -1;
    static int lastTime = 0;
    NSCalendar *cal = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDate * now = [NSDate date];
    int timeInSeconds = [now timeIntervalSinceReferenceDate];
    if (!autoUpdate || timeInSeconds - lastTime > nextTime * 60)
    {
        rtn = TRUE;
        
        _myLastUpdate = (int)[self lastUpdate];
       
        _delegate = delegate;
        _GMServer = GeoMasterServer.open;
        //_GMServer.useTestServer = NO;
        _GMServer.delegate = self;
        _GMServer.messageID = GMSMessageGetPoliceUpdate;
        [_GMServer initCommunication:5.0];
        
        _fromView = fromView;
        _popoverView = [[GSSiPopoverView alloc] initWithView:fromView];
        _popoverView.delegate = self;
        _popoverView.progressView.hidden = YES;
        _popoverView.progressLabel.hidden = YES;
        _autoUpdate = autoUpdate;
        float waitTime = 2.0;
        if (!autoUpdate)
            waitTime = 0;
        [_popoverView showAfter:waitTime
                      withTitle:@"Waiting\nto Connect\nto Manager"];
    }
    int minutes = (int)[cal component:NSCalendarUnitMinute fromDate:now];
    if (minutes < 15)
        nextTime = 15 - minutes;
    else if (minutes < 45)
        nextTime = 45 - minutes;
    else
        nextTime = 60 - minutes + 15;
    nextTime += 7;
    lastTime = timeInSeconds;
    return rtn;
}

- (void)GSSiPopoverViewdidCancel:(GSSiPopoverView *)popoverView
{
    _keepGoing = FALSE;
    [_updateTimer invalidate];
    [popoverView hide];
    if (_delegate)
        [_delegate CrimeDataUpdateDidComplete:0];
}

- (void)closeGMServer
{
    if (_GMServer)
    {
        [_popoverView hide];
        [_GMServer closeServer];
        _GMServer.delegate = nil;
    }
    
    _GMServer = nil;
}

- (void)GMServerDidOpen:(GeoMasterServer *)server
{
    NSString *msg = @"";
    
    switch (server.messageID)
    {
        case GMSMessageGetPoliceUpdate:
            msg = [NSString stringWithFormat:@"$M(LastPoliceUpdate,(%@),%i)\r\n",UIDevice.currentDevice.name,_myLastUpdate];
            break;
            
    }
    
    if (msg)
        [_GMServer sendMessage:msg];
    
    NSLog(@"GMServer Query: %@", msg);
}

- (void)GMServer:(GeoMasterServer *)server
didReceiveMessage:(NSString *)message
      withStatus:(long)status
{
    NSLog(@"GMServer Message(Police Update): %@", message);
    
    if (status == GMServerStatusOK)
    {
        switch (server.messageID)
        {
            case GMSMessageGetPoliceUpdate:
            {
                if (_myLastUpdate != 131)
                    _nextUpdate = _myLastUpdate + 1;
                else
                    _nextUpdate = 1101;
                _serversLastUpdate = (int)(message.integerValue);
                //_serversLastUpdate =570;
                if (_updateTimer)
                    [_updateTimer invalidate];
                
                _updateTimer = [NSTimer scheduledTimerWithTimeInterval:0.05
                                                                target:self
                                                              selector:@selector(updateFromServer:)
                                                              userInfo:nil
                                                               repeats:NO];
                
            }
                break;
        }
    }
    else
    {
        _keepGoing = FALSE;
        [_updateTimer invalidate];
        [_popoverView hide];
        if (_delegate)
            [_delegate CrimeDataUpdateDidComplete:0];

    }
    [self closeGMServer];
}


- (void)GMServer:(GeoMasterServer *)server
 didReceiveError:(NSString *)error
      withStatus:(long)status
{
    [self closeGMServer];
    
    NSString *titleMessage = @"";
    
    if ([error isEqualToString:@"Internet Connection Not Available"])
        titleMessage = @"Network Error";
    
    else
        titleMessage = @"NVServer Error";
    
    NVAlertView *alert = [NVAlertView showLargeAlertViewinView:_fromView
                                                      delegate:self
                                                         title:titleMessage
                                               buttonTextArray:@[@"OK"]
                                              destructiveIndex:0];
#pragma unused(alert)
}

- (void)alertView:(NVAlertView *)alertView
didTapButtonAtIndex:(NSInteger)buttonIndex
{
    [alertView hideLargeAlertView:YES];
    if (_delegate)
        [_delegate CrimeDataUpdateDidComplete:0];
}

- (void)updateFromServer:(NSTimer *)timer
{
    NSString *devID = UIDevice.currentDevice.name;
    
    if (_nextUpdate > _serversLastUpdate)
    {
        if ([_popoverView.superview.subviews containsObject:_popoverView])
        {
            _popoverView.title = @"Data up-to-date";
            
            [_popoverView.popoverCancel setTitle:@"OK"
                                        forState:UIControlStateNormal];
            
            _popoverView.progressView.hidden = YES;
            _popoverView.progressLabel.hidden = YES;
            if (_autoUpdate)
                [_popoverView hide];
            else
                [_popoverView show];
            if (_delegate)
                [_delegate CrimeDataUpdateDidComplete:0];
        }
        
        return;
    }
    
    [_popoverView showAfter:0.0
                  withTitle:[NSString stringWithFormat:@"Update %i of %i",(int)_nextUpdate,_serversLastUpdate]];
    
    _popoverView.progressView.hidden = NO;
    _popoverView.progressLabel.hidden = NO;
    
    Bool fileExists = NO;
    NSString *fileName = [NSString stringWithFormat:@"%i.gcf",(int)_nextUpdate];
    NSString *fromDir = @"GMMobile/MplsPolice";
    NSString *toDir = NSTemporaryDirectory ( );
    if ([devID containsString:@"Jeff"] && _nextUpdate == LOAD_PEOPLE_UPDATE)
    {
        fileName = @"people.gcf";
        fileName = @"persdesc.gcf";
    }

    _pull = FTPDataPull.pull;
    _pull.delegate = self;
    _pull.popover = _popoverView;
    _pull.useTestServer = NO;
    _pull.dataType = FTPDataCrimes;
    
    if ([_pull getFile:fileName
        fromDirectory:fromDir
               toFile:fileName
          toDirectory:toDir
        refreshOption:FTPDataPullRefreshOptionCheckFileSize] == FTPStatusFileExists)
    {
        fileExists = YES;
    }
  
}

- (void)FTPdidComplete:(FTPDataType)dataType
            withStatus:(FTPStatus)status
       andStatusString:(NSString *)statusString
              filePath:(NSString *)path
{
    
    if (status == FTPStatusOK || status == FTPStatusFileExists)
    {
        dispatch_queue_t overallQueue = dispatch_queue_create("overallQueue",NULL);
        
        dispatch_async(overallQueue,
                       ^{

        [self loadUpdate:path];
        if (_nextUpdate == 131)
            _nextUpdate = 1101;
        else
            _nextUpdate++;
                           dispatch_async(dispatch_get_main_queue(),
                                          ^{

        _updateTimer = [NSTimer scheduledTimerWithTimeInterval:0.05
                                                        target:self
                                                      selector:@selector(updateFromServer:)
                                                      userInfo:nil
                                                       repeats:NO];
                                          });
                       });
    }
    else if (_firstFail && status != FTPStatusUserCancel)
    {
        _firstFail = FALSE;
        _updateTimer = [NSTimer scheduledTimerWithTimeInterval:0.05
                                                        target:self
                                                      selector:@selector(updateFromServer:)
                                                      userInfo:nil
                                                       repeats:NO];
    }
    else
    {
        _popoverView.title = statusString;
    }
}

-(int) idForCnum:(int)cnum
          andSeq:(int)seq
{
    int rtn = -1;
    NSString *query = [NSString stringWithFormat:@"SELECT id FROM OFFENSEXY WHERE ControlNbr = %li AND OffenseOrder = %i",(long)cnum, seq ];
    sqlite3_stmt *statement = NULL;
    
    SQLOK(__FILE__,__LINE__,SQLitePrepare(_database, query.UTF8String, -1, &statement, 0), _database);
    if (sqlite3_step(statement) == SQLITE_ROW)
    {
        rtn = sqlite3_column_int(statement, 0);
    }
    SQLOK(__FILE__,__LINE__,SQLiteFinalize(statement),_database);
    if (rtn < 0)
    {
        rtn = [self maxID] + 1;
    }
    
    return rtn;
}

-(void) getIdForUpdate:(LPSTR)str
                remove:(Bool)remove
{
    static char fromString[32], toString[32];
    
    int cnum;
    int  seq;
    
    LPSTR pLoc = strstr (str,"OFFENSEXY VALUES(|");
    if (pLoc)
    {
        pLoc += 18;
        LPSTR pEnd = strchr (pLoc,'|');
        if (pEnd)
        {
            *pEnd = 0;
            strncpy (fromString,pLoc-1,sizeof(fromString));
            strcat (fromString,"|");
            *pEnd++ = '|';
            pLoc = pEnd + 1;
            pEnd = strchr (pLoc,'\'');
            *(pEnd-1) = 0;
            sscanf (pLoc,"%i,%i",&cnum,&seq);
            *(pEnd-1) = ',';
            int idnum = cnum;
            if (!remove)
                idnum = [self idForCnum:cnum
                                 andSeq:seq];
            sprintf (toString,"%i",idnum);
            REPLAC(str, fromString, toString, INPUTBUFSIZE);
        }

    }
    else
    {
        REPLAC(str, fromString, toString, INPUTBUFSIZE);
    }
}
-(Bool) loadUpdate:(NSString *)path
{
    Bool rtn = FALSE;
    char outFilePath[512];
    double totLen;
    int nerr = 0;
    NSString *toDirectory = _reportsDirectory;
    int fileSize = (int)[NSFileManager.defaultManager attributesOfItemAtPath:path
                                                                       error:nil].fileSize;

    _popoverView.title = [NSString stringWithFormat:@"Loading update %li",(long)_nextUpdate];
    if (DecompressGMZipFile((LPSTR)path.UTF8String, (LPSTR)toDirectory.UTF8String,0,0,outFilePath))
    {
        Bool opened = [self startTransaction];
        NSString * file = [NSString stringWithFormat:@"%@/cmdfile%i.txt",toDirectory,_nextUpdate];
        if (_nextUpdate == LOAD_PEOPLE_UPDATE)
            file = [NSString stringWithUTF8String:outFilePath];
        FILE *fid = fopen(file.UTF8String, "rb");
        if (!fid)
        {
            file = [NSString stringWithFormat:@"%@/cmdfile.txt",toDirectory];
            fid = fopen(file.UTF8String, "rb");
        }
        if (fid)
        {
            int line = 0;
            totLen = FileLengthF(fid);
            LPSTR str = malloc(INPUTBUFSIZE);
            LPSTR laststr = malloc(INPUTBUFSIZE);
            _keepGoing = TRUE;
            while (_keepGoing && fgetstringF(str, (INPUTBUFSIZE - 2), fid))
            {
                strcpy (laststr,str);
                if (_nextUpdate != LOAD_PEOPLE_UPDATE)
                    [self getIdForUpdate:str
                              remove:NO];
                if (![self executeCmd:str])
                    nerr++;
                if ((line % 10) == 0)
                    dispatch_async(dispatch_get_main_queue(),
                               ^{

                [_popoverView updateProgress:ftell(fid) / totLen];
                               });
                line++;
            }
            fclose(fid);
            free(str);
            free (laststr);
        }
        [NSFileManager.defaultManager removeItemAtPath:file error:nil];
        [NSFileManager.defaultManager removeItemAtPath:path error:nil];
        NSString *cmd = [NSString stringWithFormat:@"INSERT OR REPLACE INTO UPDATES VALUES (1,%li)",(long)(long)_nextUpdate];
        [self executeCmd:(LPSTR)cmd.UTF8String];
        if (_keepGoing)
            [self commitTransaction];
        [self close:opened];
        rtn = TRUE;
    }

    return rtn;
}

@end
