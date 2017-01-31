//  GetPriorityLocations.m
//  CCodeLibrary

#import "GetPriorityLocations.h"
#import "GSSiDefs.h"
#import "CRAPI.h"

#define kBgQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)

@interface GetPriorityLocations ()

@property (nonatomic, copy) NSArray *keywords, *types;
@property (nonatomic, copy) NSString *query, *keyword;
@property (nonatomic) BOOL hasToken;
@property (nonatomic) NSMutableArray *nearbySearchArray;
@property (nonatomic) GSSiPopoverView *popoverView;
@property (nonatomic) CGFloat radius;
@property (nonatomic) CLLocationCoordinate2D target;

@end

@implementation GetPriorityLocations

static GetPriorityLocations *_getLocations;

+ (GetPriorityLocations *)getLocations
{
    if (!_getLocations)
        _getLocations = [[GetPriorityLocations alloc] init];
    
    return _getLocations;
}

+ (BOOL) writePriorityLocationsToDatabase
{
    BOOL rtn = TRUE;
    NSMutableArray *contents = GetPriorityLocations.getPriorityLocations;
    CurbRampData *crd = [CurbRampData databaseForGeoid:CRAPI.sharedInstance.currentGeoid
                                                create:NO];
    [crd incrementLastDataFileNum];
    BOOL opened = [crd startTransaction];
    [crd createPriorityLocationsTable:YES];
    int iRef = 1;
    NSArray *catname = [self categoryNames];
    for (PriorityLocation *pl in contents)
    {
        NSString *cat = catname[pl.type.integerValue];
        NSString *name = [pl.name stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
        
        NSString *cmd = [NSString stringWithFormat:@"INSERT INTO PriorityLocations VALUES (%i,'%@',%@, '%@', %f, %f, %f,%i);",iRef++,name,pl.type,cat,pl.coordinate.latitude,pl.coordinate.longitude,pl.radius,pl.offset];
        [crd executeCmd:(LPSTR)cmd.UTF8String sendToServer:YES from:1];
    }
    if (opened)
        [crd commitTransaction];
    [crd close:opened];
    
    return rtn;
}

+ (void)savePriorityLocations:(NSMutableArray *)contents
{
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:contents];
    
    [UserDefaults.defaults saveNSData:data
                               forKey:[NSString stringWithFormat:@"PriorityLocationsFor%i",
                                       CRAPI.sharedInstance.currentGeoid]];
}

+ (NSMutableArray *)getPriorityLocations
{
    NSData *data = [UserDefaults.defaults NSDataForKey:[NSString stringWithFormat:@"PriorityLocationsFor%i",
                                                        CRAPI.sharedInstance.currentGeoid]];
    
    
    NSMutableArray *contents = [NSMutableArray arrayWithArray:[NSKeyedUnarchiver unarchiveObjectWithData:data]];
    return contents;
}

- (id)init
{
    if ((self = [super init]))
    {
        _keywords = @[@"Schools", @"Hospitals", @"Medical", @"Libraries", @"Employment",
                      @"Post Offices", @"Government", @"Hotels", @"Nursing Homes", @"Assisted Living"];
    }
    
    return self;
}
+ (NSArray *)categoryNames
{
    return @[@"Default", @"Schools", @"Medical Facilities", @"Libraries", @"Employment Centers",
             @"Post Offices", @"Government Buildings", @"Hotels", @"Senior Residential", @"Custom"];
}


- (void)drawAccessoryImageForType:(NSInteger)type
                             cell:(UITableViewCell *)cell
{
    CGFloat size = (cell.frame.size.height * 0.8);
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake((cell.frame.size.width - size), (size / 2.0), size, size)];
    
    switch (type)
    {
        case PriorityLocationTypeSchool:
            imageView.image = [UIImage imageWithContentsOfFile:[NSBundle.mainBundle pathForResource:@"school"
                                                                                             ofType:@"png"]];
            break;
            
        case PriorityLocationTypeMedical:
            imageView.image = [UIImage imageWithContentsOfFile:[NSBundle.mainBundle pathForResource:@"medical"
                                                                                             ofType:@"png"]];
            break;
            
        case PriorityLocationTypeLibrary:
            imageView.image = [UIImage imageWithContentsOfFile:[NSBundle.mainBundle pathForResource:@"library"
                                                                                             ofType:@"png"]];
            break;
            
        case PriorityLocationTypeEmployment:
            imageView.image = [UIImage imageWithContentsOfFile:[NSBundle.mainBundle pathForResource:@"employment"
                                                                                             ofType:@"png"]];
            break;
            
        case PriorityLocationTypePostOffice:
            imageView.image = [UIImage imageWithContentsOfFile:[NSBundle.mainBundle pathForResource:@"postOffice"
                                                                                             ofType:@"png"]];
            break;
            
        case PriorityLocationTypeGovernment:
            imageView.image = [UIImage imageWithContentsOfFile:[NSBundle.mainBundle pathForResource:@"government"
                                                                                             ofType:@"png"]];
            break;
            
        case PriorityLocationTypeHotel:
            imageView.image = [UIImage imageWithContentsOfFile:[NSBundle.mainBundle pathForResource:@"hotel"
                                                                                             ofType:@"png"]];
            break;
            
        case PriorityLocationTypeSeniorResidential:
            imageView.image = [UIImage imageWithContentsOfFile:[NSBundle.mainBundle pathForResource:@"seniorResidential"
                                                                                             ofType:@"png"]];
            break;
            
        case PriorityLocationTypeCustom:
            imageView.image = [UIImage imageWithContentsOfFile:[NSBundle.mainBundle pathForResource:@"custom"
                                                                                             ofType:@"png"]];
    }
    
    if (imageView.image)
        cell.accessoryView = imageView;
    
    else
        cell.accessoryView = nil;
}

- (NSNumber *)assignTypeForPtc:(NSInteger)ptc
{
    NSNumber *type;
    
    switch (ptc)
    {
        case 0:
            type = [NSNumber numberWithInteger:PriorityLocationTypeSchool];
            break;
            
        case 1:
        case 2:
            type = [NSNumber numberWithInteger:PriorityLocationTypeMedical];
            break;
            
        case 3:
            type = [NSNumber numberWithInteger:PriorityLocationTypeLibrary];
            break;
            
        case 4:
            type = [NSNumber numberWithInteger:PriorityLocationTypeEmployment];
            break;
            
        case 5:
            type = [NSNumber numberWithInteger:PriorityLocationTypePostOffice];
            break;
            
        case 6:
            type = [NSNumber numberWithInteger:PriorityLocationTypeGovernment];
            break;
            
        case 7:
            type = [NSNumber numberWithInteger:PriorityLocationTypeHotel];
            break;
            
        case 8:
        case 9:
            type = [NSNumber numberWithInteger:PriorityLocationTypeSeniorResidential];
            break;
    }
    
    return type;
}

- (void)priorityLocationArrayForBounds:(dbounds)bounds
                               popover:(GSSiPopoverView *)popover
{
    _popoverView = popover;
    PointInAreaClass *pia = [[PointInAreaClass alloc] init];
    
    CGFloat longSpan = fabs(bounds.xmn - bounds.xmx);
    CGFloat latSpan = fabs(bounds.ymx - bounds.ymn);
    
    NSMutableArray *locationArray = NSMutableArray.array;
    NSMutableArray *namesArray = NSMutableArray.array;
    NSMutableArray *latitudesArray = NSMutableArray.array;
    NSUInteger divisor = 2;
    __block NSInteger count = 0;
    NSUInteger totalQueries = (divisor * divisor * _keywords.count);
    
    for (int ptc = 0; ptc < _keywords.count; ptc++)
    {
        for (int i = 0; i < divisor; i++)
        {
            for (int j = 0; j < divisor; j++)
            {
                CLLocationCoordinate2D center = {(bounds.ymx - (latSpan / (divisor * 2.0)) - ((latSpan / divisor) * i)),
                    (bounds.xmn + (longSpan / (divisor * 2.0)) + ((longSpan / divisor * j)))};
                
                MKCoordinateRegion region = {center, {(latSpan / divisor), (longSpan / divisor)}};
                
                MKLocalSearchRequest *request = [[MKLocalSearchRequest alloc] init];
                request.region = region;
                request.naturalLanguageQuery = _keywords[ptc];
                MKLocalSearch *search = [[MKLocalSearch alloc] initWithRequest:request];
                
                [search startWithCompletionHandler:^(MKLocalSearchResponse *response, NSError *error) {
                    if (error)
                    {
                        NSLog(@"MKLocalSearch Error (%@:%i:%i) - %@",
                              _keywords[ptc], i, j, error.localizedDescription);
                    }
                    
                    _popoverView.popoverLabel.text = [NSString stringWithFormat:@"Importing\n%@", _keywords[ptc]];
                    
                    for (MKMapItem *item in response.mapItems)
                    {
                        PriorityLocation *pLoc = [[PriorityLocation alloc] init];
                        pLoc.coordinate = [(CLCircularRegion *)item.placemark.region center];
                        
                        DPOINT dp;
                        dp.x = pLoc.coordinate.longitude;
                        dp.y = pLoc.coordinate.latitude;
                        
                        if ([pia DPointInArea:&dp])
                        {
                            pLoc.radius = [(CLCircularRegion *)item.placemark.region radius];
                            pLoc.offset = DEFAULT_OFFSET;
                            pLoc.name = removeOpeningSpaces(item.name.capitalizedString);
                            
                            NSString *latitude = [NSString stringWithFormat:@"%f",
                                                  pLoc.coordinate.latitude];
                            
                            if ((![namesArray containsObject:pLoc.name]) ||
                                (![latitudesArray containsObject:latitude]))
                            {
                                pLoc.type = [self assignTypeForPtc:ptc];
                                
                                NSInteger index = 0;
                                
                                if (namesArray.count > 0)
                                {
                                    NSComparisonResult result = [pLoc.name compare:[namesArray objectAtIndex:index]
                                                                           options:(NSCaseInsensitiveSearch|NSDiacriticInsensitiveSearch)];
                                    
                                    while (result == NSOrderedDescending)
                                    {
                                        index++;
                                        
                                        if (index == namesArray.count)
                                            break;
                                        
                                        result = [pLoc.name compare:[namesArray objectAtIndex:index]
                                                            options:(NSCaseInsensitiveSearch|NSDiacriticInsensitiveSearch)];
                                    }
                                }
                                
                                [latitudesArray addObject:latitude];
                                
                                [namesArray insertObject:pLoc.name
                                                 atIndex:index];
                                
                                [locationArray insertObject:pLoc
                                                    atIndex:index];
                            }
                        }
                    }
                    
                    count++;
                    [_popoverView updateProgress:((CGFloat)count / (CGFloat)totalQueries)];
                    
                    if (count == totalQueries)
                    {
                        if (self.delegate)
                        {
                            [GetPriorityLocations savePriorityLocations:locationArray];
                            [self.delegate didFinishPriorityLocationArray:locationArray];
                        }
                    }
                }];
            }
        }
    }
}

- (void)customPriorityLocationSearchForKeyword:(NSString *)keyword
                                        target:(CLLocationCoordinate2D)target
                                        radius:(CGFloat)radius
                                       popover:(GSSiPopoverView *)popover
{
    _nearbySearchArray = NSMutableArray.array;
    _popoverView = popover, _keyword = keyword;
    _radius = radius, _target = target;
    _popoverView.progressLabel.hidden = YES;
    
    keyword = [keyword stringByAppendingString:[NSString stringWithFormat:@" %@",
                                                CRAPI.sharedInstance.currentCityNameAndState]];
    
    keyword = [keyword stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    _query = [NSString stringWithFormat:
              @"https://maps.googleapis.com/maps/api/place/textsearch/json?location=%f,%f&radius=%f&query=%@&key=%@",
              _target.latitude, _target.longitude, _radius, keyword, GOOGLE_SERVER_KEY];
    
    [self performCustomSearchForQuery:_query];
}

- (void)performCustomSearchForQuery:(NSString *)query
{
    NSURL *queryURL = [NSURL URLWithString:query];
    
    dispatch_async(kBgQueue, ^{
        NSData *data = [NSData dataWithContentsOfURL:queryURL];
        
        [self performSelectorOnMainThread:@selector(nearbySearchResults:)
                               withObject:data
                            waitUntilDone:YES];
    });
}

- (void)nearbySearchResults:(NSData *)responseData
{
    PointInAreaClass *pia = [[PointInAreaClass alloc] init];
    NSError *error;
    CGFloat lat, lon;
    
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:responseData
                                                         options:kNilOptions
                                                           error:&error];
    
    if (error)
        NSLog(@"Google Nearby Search Error: %@", error.localizedDescription);
    
    NSArray *results = [json objectForKey:@"results"];
    NSString *status = [json objectForKey:@"status"];
    NSString *nextPageToken = [json objectForKey:@"next_page_token"];
    
    if ([status isEqualToString:@"OK"])
    {
        for (int i = 0; i < results.count; i++)
        {
            lat = [[[[[results objectAtIndex:i] objectForKey:@"geometry"] objectForKey:@"location"] valueForKey:@"lat"] floatValue];
            lon = [[[[[results objectAtIndex:i] objectForKey:@"geometry"] objectForKey:@"location"] valueForKey:@"lng"] floatValue];
            
            DPOINT dp;
            dp.x = lon;
            dp.y = lat;
            
            //if ([pia DPointInArea:&dp])
            {
                PriorityLocation *pLoc = [[PriorityLocation alloc] init];
                pLoc.coordinate = CLLocationCoordinate2DMake(lat, lon);
                pLoc.name = [[results objectAtIndex:i] objectForKey:@"name"];
                [_nearbySearchArray addObject:pLoc];
                
                _popoverView.popoverLabel.text = [NSString stringWithFormat:@"Searching for\n%@\n(%lu results so far)",
                                                  _keyword, (unsigned long)_nearbySearchArray.count];
            }
        }

        if (nextPageToken)
        {
            _hasToken = YES;
            _query = [NSString stringWithFormat:
                      @"https://maps.googleapis.com/maps/api/place/nearbysearch/json?pagetoken=%@&key=%@",
                      nextPageToken, GOOGLE_SERVER_KEY];
            
            [self performSelector:@selector(performNextPageSearch)
                       withObject:self
                       afterDelay:2.0];
        }
        
        else
        {
            _popoverView.progressLabel.hidden = NO;
            
            if (self.delegate)
                [self.delegate didFinishCustomNearbySearchArray:_nearbySearchArray];
        }
    }
    
    else if ([status isEqualToString:@"INVALID_REQUEST"] && _hasToken)
    {
        [self performSelector:@selector(performNextPageSearch)
                   withObject:self
                   afterDelay:1.0];
    }
    
    else if ([status isEqualToString:@"ZERO_RESULTS"])
    {
        if (self.delegate)
            [self.delegate didFinishWithZeroResults];
    }
    
    else
        NSLog(@"Google Nearby Search Error: %@", status);
}

- (void)performNextPageSearch
{
    [self performCustomSearchForQuery:_query];
}

- (void)addCustomPriorityLocationToList:(PriorityLocation *)pLoc
{
    NSMutableArray *contents = GetPriorityLocations.getPriorityLocations;
    NSInteger index = 0;
    PriorityLocation *pLocs = contents[index];
    
    NSComparisonResult result = [pLoc.name compare:pLocs.name
                                           options:(NSCaseInsensitiveSearch|NSDiacriticInsensitiveSearch)];
        
    while (result == NSOrderedDescending)
    {
        index++;
        
        if (index == contents.count)
            break;
        
        PriorityLocation *pLocs = contents[index];
        
        result = [pLoc.name compare:pLocs.name
                            options:(NSCaseInsensitiveSearch|NSDiacriticInsensitiveSearch)];
    }
    
    if (index == contents.count)
        [contents addObject:pLoc];
    
    else
    {
        [contents insertObject:pLoc
                       atIndex:index];
    }
    
    [GetPriorityLocations savePriorityLocations:contents];
}

- (void)tryMKLocalSearch:(NSString *)keyword
                  region:(MKCoordinateRegion)region
                  popover:(GSSiPopoverView *)popover
{
    PointInAreaClass *pia = [[PointInAreaClass alloc] init];
    NSMutableArray *contents = [[NSMutableArray alloc] init];
    
    MKLocalSearchRequest *request = [[MKLocalSearchRequest alloc] init];
    request.region = region;
    request.naturalLanguageQuery = keyword;
    MKLocalSearch *search = [[MKLocalSearch alloc] initWithRequest:request];
    
    [search startWithCompletionHandler:^(MKLocalSearchResponse *response, NSError *error) {
        if (error)
            NSLog(@"MKLocalSearch Error (%@) - %@", keyword, error.localizedDescription);
    
        for (MKMapItem *item in response.mapItems)
        {
            PriorityLocation *pLoc = [[PriorityLocation alloc] init];
            pLoc.coordinate = [(CLCircularRegion *)item.placemark.region center];
                
            DPOINT dp;
            dp.x = pLoc.coordinate.longitude;
            dp.y = pLoc.coordinate.latitude;
                
            if ([pia DPointInArea:&dp])
            {
                pLoc.radius = [(CLCircularRegion *)item.placemark.region radius];
                pLoc.offset = DEFAULT_OFFSET;
                pLoc.name = removeOpeningSpaces(item.name);
                [contents addObject:pLoc];
            }
        }
        
        if (self.delegate)
        {
            [GetPriorityLocations savePriorityLocations:contents];
            [self.delegate didFinishCustomNearbySearchArray:contents];
        }
    }];
}

- (void)changePriorityLocationOffset:(NSInteger)offset
                      forPLocAtIndex:(NSInteger)index
{
    NSMutableArray *contents = GetPriorityLocations.getPriorityLocations;
    PriorityLocation *pLoc = contents[index];
    pLoc.offset = offset;
    
    [contents replaceObjectAtIndex:index
                        withObject:pLoc];
    
    if (self.delegate)
    {
        [GetPriorityLocations savePriorityLocations:contents];
        [self.delegate didFinishPriorityLocationArray:contents];
    }
}

- (void)changePriorityLocationOffset:(NSInteger)offset
                             forType:(NSInteger)type
{
    NSMutableArray *contents = GetPriorityLocations.getPriorityLocations;
    NSNumber *pLocType = [NSNumber numberWithInteger:type];
    
    for (int i = 0; i < contents.count; i++)
    {
        PriorityLocation *pLoc = contents[i];
        
        if (pLoc.type == pLocType)
        {
            pLoc.offset = offset;
            
            [contents replaceObjectAtIndex:i
                                withObject:pLoc];
        }
    }
    
    if (self.delegate)
    {
        [GetPriorityLocations savePriorityLocations:contents];
        [self.delegate didFinishPriorityLocationArray:contents];
    }
}

- (void)changeGlobalPriorityLocationOffset:(NSInteger)offset
{
    NSMutableArray *contents = GetPriorityLocations.getPriorityLocations;
    
    for (int i = 0; i < contents.count; i++)
    {
        PriorityLocation *pLoc = contents[i];
        pLoc.offset = offset;
        
        [contents replaceObjectAtIndex:i
                            withObject:pLoc];
    }
    
    if (self.delegate)
    {
        [GetPriorityLocations savePriorityLocations:contents];
        [self.delegate didFinishPriorityLocationArray:contents];
    }
}

- (void)removePLocFromListAtIndex:(NSInteger)index
{
    NSMutableArray *contents = GetPriorityLocations.getPriorityLocations;
    [contents removeObjectAtIndex:index];
    
    if (self.delegate)
    {
        [GetPriorityLocations savePriorityLocations:contents];
        [self.delegate didFinishPriorityLocationArray:contents];
    }
}

@end
