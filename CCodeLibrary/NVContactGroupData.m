//  NVContactGroupData.m
//  CCodeLibrary

#import "NVContactGroupData.h"
#import "UserDefaults.h"
#import "SQLiteLib.h"
#import "SharedDefaults.h"

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
        "email CHAR(64), first_name CHAR(64), last_name CHAR(64), UNIQUE(first_name, last_name, email));"
        "CREATE TABLE IF NOT EXISTS ContactGroups (id INTEGER PRIMARY KEY AUTOINCREMENT,"
        "group_name CHAR(64), contact_id INT, UNIQUE(group_name, contact_id))";
        
        SQLOK(__FILE__,__LINE__, sqlite3_exec(_database, cmd.UTF8String, 0, 0, 0), _database);
        [self close:opened];
    }
    
    return self;
}


- (BOOL)open
{
    BOOL rtn = NO;
    
    if (!_isOpen)
    {
        _isOpen = !SQLOK(__FILE__,__LINE__, sqlite3_open(_path.UTF8String, &_database), _database);
        //NSLog(@"NVContactGroupData Database open");
        rtn = YES;
    }
    
    return rtn;
}

- (void)close:(BOOL)opened
{
    if (opened)
    {
        SQLOK(__FILE__,__LINE__, sqlite3_close(_database), _database);
        //NSLog(@"NVContactGroupData Database close");
        _isOpen = NO;
    }
}

- (void)dealloc
{
    [self close:_isOpen];
}

- (void)addEmail:(NSString *)email
       firstName:(NSString *)firstName
        lastName:(NSString *)lastName
  toContactGroup:(NSString *)contactGroup
{
    BOOL opened = self.open;
    
    NSString *cmd = [NSString stringWithFormat:@"INSERT OR IGNORE INTO Contacts VALUES (null,'%@','%@','%@');",
                     email, firstName, lastName];
    
    SQLOK(__FILE__,__LINE__, sqlite3_exec(_database, (LPSTR)cmd.UTF8String, 0, 0, 0), _database);
    
    sqlite3_stmt *statement = NULL;
    int emailID = -1;
    
    NSString *query = [NSString stringWithFormat:@"SELECT id FROM Contacts WHERE email='%@' AND first_name='%@' AND last_name='%@'",
                       email, firstName, lastName];
    
    SQLOK(__FILE__,__LINE__, SQLitePrepare(_database, query.UTF8String, -1, &statement, 0), _database);
    
    if (sqlite3_step(statement) == SQLITE_ROW)
        emailID = sqlite3_column_int(statement, 0);
    
    SQLOK(__FILE__,__LINE__, SQLiteFinalize(statement), _database);
    
    cmd = [NSString stringWithFormat:@"INSERT INTO ContactGroups VALUES (null,'%@',%i);",
           contactGroup, emailID];
    
    SQLOK(__FILE__,__LINE__, sqlite3_exec(_database, (LPSTR)cmd.UTF8String, 0, 0, 0), _database);
    [self close:opened];
}

- (void)removeEmail:(NSString *)email
          firstName:(NSString *)firstName
           lastName:(NSString *)lastName
   fromContactGroup:(NSString *)contactGroup
{
    BOOL opened = self.open;
    sqlite3_stmt *statement = NULL;
    int emailID = -1;
    
    NSString *query = [NSString stringWithFormat:@"SELECT id FROM Contacts WHERE email='%@' AND first_name='%@' AND last_name='%@'",
                       email, firstName, lastName];
    
    SQLOK(__FILE__,__LINE__, SQLitePrepare(_database, query.UTF8String, -1, &statement, 0), _database);
    
    if (sqlite3_step(statement) == SQLITE_ROW)
        emailID = sqlite3_column_int(statement, 0);
    
    SQLOK(__FILE__,__LINE__,SQLiteFinalize(statement), _database);
    
    NSString *cmd = [NSString stringWithFormat:@"DELETE FROM ContactGroups WHERE group_name='%@' AND contact_id='%i'",
                     contactGroup, emailID];
    
    SQLOK(__FILE__,__LINE__, sqlite3_exec(_database, (LPSTR)cmd.UTF8String, 0, 0, 0), _database);
    [self close:opened];
}

- (void)removeContactGroup:(NSString *)contactGroup
{
    BOOL opened = self.open;
    
    NSString *cmd = [NSString stringWithFormat:@"DELETE FROM ContactGroups WHERE group_name='%@'",
                     contactGroup];
    
    SQLOK(__FILE__,__LINE__, sqlite3_exec(_database, (LPSTR)cmd.UTF8String, 0, 0, 0), _database);
    [self close:opened];
}

- (NSArray *)getContactGroupsArray
{
    NSMutableArray *contactGroupsArray = NSMutableArray.array;
    BOOL opened = self.open;
    sqlite3_stmt *statement = NULL;
    
    NSString *query = [NSString stringWithFormat:@"SELECT DISTINCT group_name FROM ContactGroups ORDER BY group_name ASC;"];
    SQLOK(__FILE__,__LINE__, SQLitePrepare(_database, query.UTF8String, -1, &statement, 0), _database);
    
    while (sqlite3_step(statement) == SQLITE_ROW)
    {
        LPSTR groupName = (LPSTR)sqlite3_column_text(statement, 0);
        [contactGroupsArray addObject:[NSString stringWithUTF8String:groupName]];
    }
    
    SQLOK(__FILE__,__LINE__, SQLiteFinalize(statement), _database);
    [self close:opened];
    
    return contactGroupsArray.copy;
}

- (NSArray<NVContact *> *)getContactsArray
{
    NSMutableArray<NVContact *> *contactsArray = NSMutableArray.array;
    BOOL opened = self.open;
    sqlite3_stmt *statement = NULL;
    
    NSString *query = [NSString stringWithFormat:@"SELECT * FROM Contacts ORDER BY first_name ASC, last_name ASC, email ASC;"];
    SQLOK(__FILE__,__LINE__, SQLitePrepare(_database, query.UTF8String, -1, &statement, 0), _database);
    
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
    
    SQLOK(__FILE__,__LINE__, SQLiteFinalize(statement), _database);
    [self close:opened];
    
    return contactsArray.copy;
}

- (NSArray<NVContact *> *)getContactsArrayInContactGroup:(NSString *)contactGroup
{
    NSMutableArray<NVContact *> *contactsArray = NSMutableArray.array;
    BOOL opened = self.open;
    sqlite3_stmt *statement = NULL;
    
    NSString *query = [NSString stringWithFormat:@"SELECT * FROM Contacts, ContactGroups "
                       "WHERE ContactGroups.contact_id=Contacts.id AND group_name='%@' "
                       "ORDER BY first_name ASC, last_name ASC, email ASC;",
                       contactGroup];
    
    SQLOK(__FILE__,__LINE__, SQLitePrepare(_database, query.UTF8String, -1, &statement, 0), _database);
    
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
    
    SQLOK(__FILE__,__LINE__, SQLiteFinalize(statement), _database);
    [self close:opened];
    
    return contactsArray.copy;
}

@end
