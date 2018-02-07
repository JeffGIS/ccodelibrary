//  RHSearch.m
//  CCodeLibrary

#import "RHSearch.h"
#import "UserDefaults.h"
#import "SQLiteLib.h"
#import "CRAPI.h"

#define MAX_ITEMS 50
#define WEBSITE_URL @"https://www.realtor.com"
#define HTML_SEPARATOR @"js-record-user-activity"
#define TABLE_NAME @"RHSearch"

@implementation RHSearchItem

- (NSString *)description
{
    return [NSString stringWithFormat:@"ID:%lli; ADDRESS:%@, %@, %@ %i; COORDS:(%f,%f); "
            "PRICE:$%i; SQFT:%i; LOTSIZE:%.2f; BEDS:%.1f; BATHS:%.1f; GARAGE:%.1f; URL:%@",
            _listingID, _address, _city, _state, _zip, _latitude, _longitude,
            _price, _sqft, _lotsize, _beds, _baths, _garage, _url];
}

- (BOOL)isEqual:(id)object
{
    if (!object || ![object isKindOfClass:self.class])
        return NO;
    
    else
    {
        RHSearchItem *item = (RHSearchItem *)object;
        
        if (item.price == _price && item.sqft == _sqft && item.lotsize == _lotsize &&
            item.beds == _beds && item.baths == _baths && item.garage == _garage &&
            item.latitude == _latitude && item.longitude == _longitude &&
            [item.address isEqualToString:_address] && [item.url isEqualToString:_url])
        {
            return YES;
        }
        
        else
            return NO;
    }
}

@end

@interface RHSearchDatabase ()

@property (nonatomic, copy) NSString *path;
@property sqlite3nv *database;
@property BOOL isOpen;

@end

@implementation RHSearchDatabase

- (id)init
{
    self = [super init];
    
    if (self)
    {
        _path = [NSString stringWithFormat:@"%@/%@Database.sqlite3",
                 UserDefaults.defaults.localFilePath, TABLE_NAME];
        
        BOOL opened = self.open;
        
        NSString *cmd = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (listing_id INTEGER PRIMARY KEY, "
        "insert_time INTEGER, modify_time INTEGER, update_time INTEGER, price INTEGER, sqft INTEGER, zip INTEGER, "
        "latitude REAL, longitude REAL, lotsize REAL, beds REAL, baths REAL, garage REAL, "
        "address TEXT, city TEXT, state TEXT, url TEXT);", TABLE_NAME];
        
        SQLOK(__FILE__,__LINE__, SQLiteExec(_database, cmd.UTF8String, 0, 0, 0), _database);
        [self close:opened];
    }
    
    return self;
}

- (BOOL)open
{
    BOOL rtn = NO;
    
    if (!_isOpen)
    {
        _isOpen = !SQLOK(__FILE__,__LINE__, SQLite_Open(_path.UTF8String, &_database), _database);
        rtn = YES;
    }
    
    return rtn;
}

- (void)close:(BOOL)opened
{
    if (opened)
    {
        SQLOK(__FILE__,__LINE__, SQLite_Close(&_database), _database);
        _isOpen = NO;
    }
}

- (void)dealloc
{
    [self close:_isOpen];
}

- (void)startTransaction
{
    [self open];
    SQLOK(__FILE__,__LINE__,SQLiteExec(_database, "BEGIN", 0, 0, 0), _database);
}

- (void)commitTransaction
{
    SQLOK(__FILE__,__LINE__,SQLiteExec(_database, "COMMIT", 0, 0, 0),_database);
}

- (RHSearchItem *)searchItemWithListingID:(long long)listingID
{
    RHSearchItem *item = nil;
    BOOL opened = self.open;
    sqlite3_stmt *statement = NULL;
    
    NSString *query = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE listing_id=%lli;",
                       TABLE_NAME, listingID];
    
    SQLOK(__FILE__,__LINE__, SQLitePrepare(_database, query.UTF8String, -1, &statement, 0), _database);
    
    if (sqlite3_step(statement) == SQLITE_ROW)
    {
        int iCol = 0;
        item = RHSearchItem.new;
        item.listingID = listingID;
        item.insertTime = sqlite3_column_int(statement, ++iCol);
        item.modifyTime = sqlite3_column_int(statement, ++iCol);
        item.updateTime = sqlite3_column_int(statement, ++iCol);
        item.price = sqlite3_column_int(statement, ++iCol);
        item.sqft = sqlite3_column_int(statement, ++iCol);
        item.zip = sqlite3_column_int(statement, ++iCol);
        item.latitude = sqlite3_column_double(statement, ++iCol);
        item.longitude = sqlite3_column_double(statement, ++iCol);
        item.lotsize = sqlite3_column_double(statement, ++iCol);
        item.beds = sqlite3_column_double(statement, ++iCol);
        item.baths = sqlite3_column_double(statement, ++iCol);
        item.garage = sqlite3_column_double(statement, ++iCol);
        item.address = [NSString stringWithUTF8String:(LPSTR)sqlite3_column_text(statement, ++iCol)];
        item.city = [NSString stringWithUTF8String:(LPSTR)sqlite3_column_text(statement, ++iCol)];
        item.state = [NSString stringWithUTF8String:(LPSTR)sqlite3_column_text(statement, ++iCol)];
        item.url = [NSString stringWithUTF8String:(LPSTR)sqlite3_column_text(statement, ++iCol)];
    }
    
    SQLOK(__FILE__,__LINE__,SQLiteFinalize(statement), _database);
    [self close:opened];
    
    return item;
}

- (int)numberOfItems
{
    int count = 0;
    BOOL opened = self.open;
    sqlite3_stmt *statement = NULL;
    
    NSString *query = [NSString stringWithFormat:@"SELECT Count(*) FROM %@;", TABLE_NAME];
    
    SQLOK(__FILE__,__LINE__, SQLitePrepare(_database, query.UTF8String, -1, &statement, 0), _database);
    
    if (sqlite3_step(statement) == SQLITE_ROW)
        count = sqlite3_column_int(statement, 0);
    
    SQLOK(__FILE__,__LINE__,SQLiteFinalize(statement), _database);
    [self close:opened];
    
    return count;
}

- (void)updateDatabaseForSearchItems:(NSArray<RHSearchItem *> *)searchItems
{
    for (RHSearchItem *searchItem in searchItems)
    {
        if (searchItem.listingID)
        {
            RHSearchItem *item = [self searchItemWithListingID:searchItem.listingID];
            
            if (item)
            {
                if ([item isEqual:searchItem])
                    [self updateItem:item];
                
                else
                    [self modifyItem:searchItem];
            }
            
            else
                [self addItem:searchItem];
        }
    }
}

- (void)updateItem:(RHSearchItem *)item
{
    BOOL opened = self.open;
    
    NSString *prefix = [NSString stringWithFormat:@"UPDATE %@ SET update_time=%i WHERE listing_id=",
                        TABLE_NAME, CRAPI.sharedInstance.rhUpdateTime];
    
    NSString *cmd = [NSString stringWithFormat:@"%@%lli", prefix, item.listingID];
    
    SQLOK(__FILE__,__LINE__, SQLiteExec(_database, (LPSTR)cmd.UTF8String, 0, 0, 0), _database);
    
    cmd = [cmd stringByReplacingOccurrencesOfString:prefix withString:@"b"];
    cmd = [cmd stringByAppendingString:@"\r\n"];
    [CRAPI.sharedInstance.rhSearchSqlCommands appendString:cmd];
    [self close:opened];
}

- (void)modifyItem:(RHSearchItem *)item
{
    BOOL opened = self.open;
    int time = CRAPI.sharedInstance.rhUpdateTime;
    
    NSString *cmd = [NSString stringWithFormat:@"UPDATE %@ SET modify_time=%i, update_time=%i, price=%i, "
                     "sqft=%i, zip=%i, latitude=%f, longitude=%f, lotsize=%.2f, beds=%.1f, baths=%.1f, "
                     "garage=%.1f, address='%@', city='%@', state='%@', url='%@' WHERE listing_id=%lli",
                     TABLE_NAME, time, time, item.price, item.sqft, item.zip, item.latitude, item.longitude,
                     item.lotsize, item.beds, item.baths, item.garage, item.address, item.city, item.state,
                     item.url, item.listingID];
    
    SQLOK(__FILE__,__LINE__, SQLiteExec(_database, (LPSTR)cmd.UTF8String, 0, 0, 0), _database);
    cmd = [cmd stringByAppendingString:@"\r\n"];
    [CRAPI.sharedInstance.rhSearchSqlCommands appendString:cmd];
    [self close:opened];
}

- (void)addItem:(RHSearchItem *)item
{
    BOOL opened = self.open;
    int time = CRAPI.sharedInstance.rhUpdateTime;
    NSString *prefix = [NSString stringWithFormat:@"INSERT INTO %@ VALUES", TABLE_NAME];
    
    NSString *cmd = [NSString stringWithFormat:
    @"%@(%lli,%i,%i,%i,%i,%i,%i,%f,%f,%.2f,%.1f,%.1f,%.1f,'%@','%@','%@','%@');",
    prefix, item.listingID, time, time, time, item.price, item.sqft, item.zip,
    item.latitude, item.longitude, item.lotsize, item.beds, item.baths, item.garage,
    item.address, item.city, item.state, item.url];
    
    SQLOK(__FILE__,__LINE__, SQLiteExec(_database, (LPSTR)cmd.UTF8String, 0, 0, 0), _database);
    
    cmd = [cmd stringByReplacingOccurrencesOfString:prefix withString:@"a"];
    cmd = [cmd stringByAppendingString:@"\r\n"];
    [CRAPI.sharedInstance.rhSearchSqlCommands appendString:cmd];
    [self close:opened];
}

- (void)deleteOldItems
{
    BOOL opened = self.open;
    
    NSString *cmd = [NSString stringWithFormat:@"DELETE FROM %@ WHERE update_time != %i;",
                     TABLE_NAME, CRAPI.sharedInstance.rhUpdateTime];
    
    SQLOK(__FILE__,__LINE__, SQLiteExec(_database, (LPSTR)cmd.UTF8String, 0, 0, 0), _database);
    
    [self close:opened];
}

@end

@interface RHSearch ()

@property (nonatomic, weak) id<RHSearchDelegate> delegate;
@property (nonatomic) NSMutableArray<RHSearchItem *> *items;
@property (nonatomic) NSURLSession *session;
@property int page;

@end

@implementation RHSearch

+ (instancetype)searchWithDelegate:(id<RHSearchDelegate>)delegate
{
    RHSearch *search = RHSearch.new;
    search.delegate = delegate;
    search.page = 1;
    search.items = NSMutableArray.array;
    search.session = NSURLSession.sharedSession;
    
    return search;
}

- (void)getItemsForZip
{
    [NSThread sleepForTimeInterval:RH_QUERY_INTERVAL];
    
    int zip = CRAPI.sharedInstance.rhCurrentZip;
    
    NSString *urlString = [NSString stringWithFormat:@"%@/realestateandhomes-search/%i?pgsz=%i",
                           WEBSITE_URL, zip, MAX_ITEMS];
    
    
    if (_page > 1)
    {
        urlString = [NSString stringWithFormat:@"%@/realestateandhomes-search/%i/pg-%i?pgsz=%i",
                     WEBSITE_URL, zip, _page, MAX_ITEMS];
    }
    
    NSURL *url = [[NSURL alloc] initWithString:urlString];
    
    [[_session dataTaskWithURL:(NSURL *)url
             completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
    {
        if (error)
            [_delegate searchDidReceiveError:error.localizedDescription];
        
        else
        {
            NSString *htmlString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            htmlString = textAfter(htmlString, HTML_SEPARATOR);
            
            if (htmlString && htmlString.length)
            {
                NSArray *htmlArray = [htmlString componentsSeparatedByString:HTML_SEPARATOR];
                NSString *substring = @"", *subcomponent = @"";
                
                for (NSString *component in htmlArray)
                {
                    RHSearchItem *item = RHSearchItem.new;
                    subcomponent = textBefore(component, @"longitude\">");
                    item.listingID = textBetween(subcomponent, @"data-listingid=\"", @"\"").longLongValue;
                    item.url = textBetween(subcomponent, @"data-url=\"/realestateandhomes-detail/", @"\"");
                    item.price = textBetween(subcomponent, @"data-price=\"", @"\"").intValue;
                    item.address = textBetween(subcomponent, @"streetAddress\">", @"</");
                    item.city = textBetween(subcomponent, @"addressLocality\">", @"</");
                    item.state = textBetween(subcomponent, @"addressRegion\">", @"</");
                    item.zip = textBetween(subcomponent, @"postalCode\">", @"</").intValue;
                    item.beds = textBetween(subcomponent, @"data-value meta-beds\">", @"</").floatValue;
                    substring = textAfter(subcomponent, @"property-meta-baths");
                    item.baths = textBetween(substring, @"data-value\">", @"</").floatValue;
                    substring = textAfter(subcomponent, @"property-meta-sqft");
                    substring =  textBetween(substring, @"data-value\">", @"</");
                    item.sqft = [substring stringByReplacingOccurrencesOfString:@"," withString:@""].intValue;
                    substring = textAfter(subcomponent, @"property-meta-lotsize");
                    item.lotsize = textBetween(substring, @"data-value\">", @"</").floatValue;
                    substring = textAfter(subcomponent, @"property-meta-garage");
                    item.garage = textBetween(substring, @"data-value\">", @"</").floatValue;
                    substring = textAfter(subcomponent, @"GeoCoordinates");
                    substring = textAfter(substring, @"content=\"");
                    item.latitude = textBefore(substring, @"\"").floatValue;
                    substring = textAfter(substring, @"content=\"");
                    item.longitude = textBefore(substring, @"\"").floatValue;
                    [_items addObject:item];
                }
                
                if (htmlArray.count == MAX_ITEMS)
                {
                    [_delegate searchDidReturnItems:_items.copy
                                          morePages:YES];
                    
                    _items = NSMutableArray.array;
                    _page++;
                    [self getItemsForZip];
                }
                
                else
                {
                    [_delegate searchDidReturnItems:_items.copy
                                          morePages:NO];
                }
            }
            
            else
            {
                [_delegate searchDidReturnItems:nil
                                      morePages:NO];
            }
        }
    }] resume];
}

@end
