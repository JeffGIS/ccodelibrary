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

#import "CrimeData.h"
#import "UserDefaults.h"
#import "CRAPI.h"
#import "GeomasterServer.h"
#import "GSSiPopoverView.h"

@interface CrimeData () <GeoMasterServerDelegate,GSSiPopoverViewDelegate>
@property (nonatomic) UIColor *red;
@property (nonatomic) GeoMasterServer *GMServer;
@property (nonatomic) GSSiPopoverView *popoverView;
@property (nonatomic) NSTimer *updateTimer;

@end

@implementation CrimeData


static int SQLOK(int sqlReturn,sqlite3 *database)
{
    if (sqlReturn != SQLITE_OK)
    {
        NSLog(@"%@", [NSString stringWithFormat:@"SQLite Error %i = %i:%s",
                      sqlReturn, sqlite3_errcode(database), sqlite3_errmsg(database)]);
    }
    
    return sqlReturn;
}


- (id)init
{
    self = [super init];
    
    if (self)
    {
        _documentsDirectory = UserDefaults.defaults.sharedFilePath;
        _fileName = @"Crimes.sqlite";
        _path = [NSString stringWithFormat:@"%@/%@", _documentsDirectory, _fileName];
    }
    
    return self;
}

- (void)dealloc
{
    [self close];
    NSLog(@"Crime Database dealloc");
}

- (BOOL)open
{
    if (!_isOpen)
    {
        _isOpen = !SQLOK(sqlite3_open(self.path.UTF8String, &_database), _database);
        NSLog(@"Crime Database open");
        
        _fileSize = [NSFileManager.defaultManager attributesOfItemAtPath:_path
                                                                   error:nil].fileSize;
        return TRUE;
    }
    return FALSE;
}

- (void)close
{
    if (_isOpen)
    {
        SQLOK(sqlite3_close(_database),_database);
        NSLog(@"Crime Database close");
    }
    _isOpen = NO;
}

- (BOOL)clear
{
    [self close];
    
    BOOL st = [NSFileManager.defaultManager removeItemAtPath:_path
    error:nil];
    return st;
}

- (int) datasetVersion
{
    int rtn = -1;
    BOOL opened = [self open];
    if (_isOpen && _fileSize > 0)
    {
        NSString *query = [NSString stringWithFormat:@"SELECT max(id) FROM OFFENSEXY"];
        
        sqlite3_stmt *statement = NULL;
        
        SQLOK(sqlite3_prepare_v2(_database, query.UTF8String, -1, &statement, 0), _database);
        if (sqlite3_step(statement) == SQLITE_ROW)
        {
            int maxID = sqlite3_column_int(statement, 0);
            if (maxID > 0)
                rtn = 0;
        }
        SQLOK(sqlite3_finalize(statement), _database);
    }
    if (opened)
        [self close];
    return rtn;
}

- (NSInteger) lastUpdate
{
    NSInteger rtn = -1;
    BOOL opened = [self open];
    if (_isOpen && _fileSize > 0)
    {
        NSString *query = [NSString stringWithFormat:@"SELECT LastUpdate FROM UPDATES"];
        
        sqlite3_stmt *statement = NULL;
        
        SQLOK(sqlite3_prepare_v2(_database, query.UTF8String, -1, &statement, 0), _database);
        if (sqlite3_step(statement) == SQLITE_ROW)
        {
            rtn = sqlite3_column_int(statement, 0);
        }
        SQLOK(sqlite3_finalize(statement), _database);
    }
    if (opened)
        [self close];
    return rtn;
}

- (BOOL)executeCmd:(char *)cmd
{
    BOOL rtn = !SQLOK(sqlite3_exec(_database, cmd, 0, 0, 0), _database);
    return rtn;
}

- (void)startTransaction
{
    [self open];
    SQLOK(sqlite3_exec(_database, "BEGIN", 0, 0, 0), _database);
}

- (void)commitTransaction
{
    SQLOK(sqlite3_exec(_database, "COMMIT", 0, 0, 0),_database);
}

+ (NSString *)reportForControlNumber:(NSInteger)cnumber
{
    NSString *file = [NSBundle.mainBundle pathForResource:@"3496486"
                                                   ofType:@"TXT"];
    NSError *error = nil;
    NSString *report = [NSString stringWithContentsOfFile:file encoding:NSUTF8StringEncoding error:&error];
    
    return report;
}

- (BOOL)update:(UIView *)fromView
{
    BOOL rtn = FALSE;
    _GMServer = GeoMasterServer.open;
    _GMServer.delegate = self;
    _GMServer.messageID = GMSMessageGetPoliceUpdate;
    [_GMServer initCommunication:5.0];
    _popoverView = [[GSSiPopoverView alloc] initWithView:fromView];
    _popoverView.delegate = self;

    _popoverView.progressView.hidden = YES;
    
    [_popoverView showAfter:0.0
                  withTitle:@"Waiting\nto Connect\nto Manager"];
    
    return rtn;
}

- (void)GSSiPopoverViewdidCancel:(GSSiPopoverView *)popoverView
{
    [popoverView hide];
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
            msg = [NSString stringWithFormat:@"$M(LastPoliceUpdate)\r\n"];
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
                _myLastUpdate = [self lastUpdate];
                _serversLastUpdate = message.integerValue;
                
                if (_serversLastUpdate > _myLastUpdate)
                {
                    if (_updateTimer)
                        [_updateTimer invalidate];
                    
                    _updateTimer = [NSTimer scheduledTimerWithTimeInterval:0.25
                                                                  target:self
                                                                  selector:@selector(updateFromServer:)
                                                                userInfo:nil
                                                                 repeats:NO];
                    
                }
            }
                break;
        }
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
        titleMessage = @"GMServer Error";
    
    UIAlertView *serverError = [[UIAlertView alloc] initWithTitle:titleMessage
                                                          message:error
                                                         delegate:nil
                                                cancelButtonTitle:@"OK"
                                                otherButtonTitles:nil];
    
    [serverError show];
}

- (void)updateFromServer:(NSTimer *)timer
{
    if (_myLastUpdate >= _serversLastUpdate)
    {
        [_popoverView hide];
        return;
    }
    
    
}


@end
