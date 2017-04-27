//  NVContactGroupData.m
//  CCodeLibrary

#import "NVContactGroupData.h"
#import "UserDefaults.h"
#import "SQLiteLib.h"

@implementation NVContact

@end

@interface NVContactGroupData ()

@property (nonatomic, copy) NSString *path;
@property sqlite3 *database;
@property BOOL isOpen;

@end

@implementation NVContactGroupData

- (id)init
{
    self = [super init];
    
    if (self)
    {
        _path = [NSString stringWithFormat:@"%@/ContactGroupDatabase.sqlite3", UserDefaults.defaults.sharedFilePath];
        BOOL opened = self.open;
        NSString *cmd = @"CREATE TABLE IF NOT EXISTS Contacts (id INTEGER PRIMARY KEY AUTOINCREMENT,"
        "email CHAR(64), first_name CHAR(64), last_name CHAR(64), UNIQUE(email));";
        SQLOK(1, sqlite3_exec(_database, cmd.UTF8String, 0, 0, 0), _database);
        [self close:opened];
    }
    
    return self;
}


- (BOOL)open
{
    BOOL rtn = NO;
    
    if (!_isOpen)
    {
        _isOpen = !SQLOK(2, sqlite3_open(_path.UTF8String, &_database), _database);
        NSLog(@"NVContactGroupData Database open");
        rtn = YES;
    }
    
    return rtn;
}

- (void)close:(BOOL)opened
{
    if (opened)
    {
        SQLOK(3, sqlite3_close(_database), _database);
        NSLog(@"NVContactGroupData Database close");
        _isOpen = NO;
    }
}

- (void)dealloc
{
    [self close:_isOpen];
}

- (void)addContactEmail:(NSString *)email
              firstName:(NSString *)firstName
               lastName:(NSString *)lastName
{
    BOOL opened = self.open;
    NSString *cmd = [NSString stringWithFormat:@"INSERT OR IGNORE INTO Contacts VALUES (null,'%@','%@','%@');", email, firstName, lastName];
    SQLOK(4, sqlite3_exec(_database, (LPSTR)cmd.UTF8String, 0, 0, 0), _database);
    [self close:opened];
}

- (NSArray<NVContact *> *)getContactsArray
{
    NSMutableArray<NVContact *> *contactsArray = NSMutableArray.array;
    BOOL opened = self.open;
    sqlite3_stmt *statement = NULL;
    
    NSString *query = [NSString stringWithFormat:@"SELECT * FROM Contacts ORDER BY last_name ASC, first_name ASC, email ASC;"];
    SQLOK(5, sqlite3_prepare_v2(_database, query.UTF8String, -1, &statement, 0), _database);
    
    while (sqlite3_step(statement) == SQLITE_ROW)
    {
        LPSTR email = (LPSTR)sqlite3_column_text(statement, 1);
        LPSTR firstName = (LPSTR)sqlite3_column_text(statement, 2);
        LPSTR lastName = (LPSTR)sqlite3_column_text(statement, 3);
        NVContact *contact = NVContact.new;
        contact.email = [NSString stringWithUTF8String:email];
        contact.firstName = [NSString stringWithUTF8String:firstName];
        contact.lastName = [NSString stringWithUTF8String:lastName];
        [contactsArray addObject:contact];
    }
    
    SQLOK(6, sqlite3_finalize(statement), _database);
    [self close:opened];
    
    return contactsArray.copy;
}

@end
