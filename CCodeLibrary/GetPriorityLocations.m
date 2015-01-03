//  GetPriorityLocations.m
//  CCodeLibrary

#import "GetPriorityLocations.h"

@implementation GetPriorityLocations

static GetPriorityLocations *_getLocations;

+ (GetPriorityLocations *)getLocations
{
    if (!_getLocations)
        _getLocations = [[GetPriorityLocations alloc] init];
    
    return _getLocations;
}

- (NSArray *)priorityLocationKeywords
{
    NSArray *priorityKeywords = @[@"school", @"medical", @"hospital", @"library", @"employment", @"post office",
                                  @"government", @"hotel", @"nursing home", @"assisted living"];
    
    return priorityKeywords;
}

- (NSArray *)priorityLocationTypes
{
    NSArray *priorityTypes = @[@"Schools", @"Medical Facilities", @"Hospitals", @"Libraries", @"Employment Centers", @"Post Offices",
                               @"Government Centers", @"Hotels", @"Nursing Homes", @"Assisted Living Centers"];
    
    return priorityTypes;
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
    }
    
    if (imageView.image)
        cell.accessoryView = imageView;
    
    else
        cell.accessoryView = nil;
}

- (void)priorityLocationArrayForBounds:(dbounds)bounds
                           popoverView:(GSSiPopoverView *)popover
{
    PointInAreaClass *pia = [[PointInAreaClass alloc] init];
    
    CGFloat longSpan = fabs(bounds.xmn - bounds.xmx);
    CGFloat latSpan = fabs(bounds.ymx - bounds.ymn);
    
    NSMutableArray *locationArray = [[NSMutableArray alloc] init];
    NSMutableArray *namesArray = [[NSMutableArray alloc] init];
    NSMutableArray *latitudesArray = [[NSMutableArray alloc] init];
    NSInteger divisor = (NSInteger)roundf(((latSpan + longSpan) / 2.0) * 60);
    divisor = min(divisor, 5);
    __block NSInteger count = 0;
    NSArray *priorityKeywords = [self priorityLocationKeywords];
    NSArray *priorityTypes = [self priorityLocationTypes];
    NSInteger totalQueries = (divisor * divisor * priorityKeywords.count);
    NSLog(@"Total queries = %li (%li sections * %lu types)",
          (long)totalQueries, (long)(divisor * divisor), (unsigned long)priorityKeywords.count);
    
    for (int ptc = 0; ptc < priorityKeywords.count; ptc++)
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
                request.naturalLanguageQuery = priorityTypes[ptc];
                MKLocalSearch *search = [[MKLocalSearch alloc] initWithRequest:request];
                
                [search startWithCompletionHandler:^(MKLocalSearchResponse *response, NSError *error) {
                    if (error)
                        NSLog(@"MKLocalSearch Error (%@:%i:%i) - %@", priorityTypes[ptc], i, j, error.localizedDescription);
                    
                    {
                        popover.popoverLabel.text = [NSString stringWithFormat:@"Importing %@", priorityTypes[ptc]];
                        
                        for (MKMapItem *item in response.mapItems)
                        {
                            PriorityLocation *pLoc = [[PriorityLocation alloc] init];
                            pLoc.coordinate = [(CLCircularRegion *)item.placemark.region center];
                            pLoc.radius = [(CLCircularRegion *)item.placemark.region radius];
                            pLoc.name = [UserDefaults.defaults removeOpeningSpaces:item.name.capitalizedString];
                            NSString *latitude = [NSString stringWithFormat:@"%f", pLoc.coordinate.latitude];
                            DPOINT dp;
                            dp.x = pLoc.coordinate.longitude;
                            dp.y = pLoc.coordinate.latitude;
                            
                            if (([pia DPointInArea:&dp]) &&
                                (![namesArray containsObject:pLoc.name] || ![latitudesArray containsObject:latitude]))
                            {
                                //this condition will be replaced with the DPointInArea BOOL
                                if (pLoc.coordinate.latitude <= bounds.ymx &&
                                    pLoc.coordinate.latitude >= (bounds.ymx - latSpan) &&
                                    pLoc.coordinate.longitude >= bounds.xmn &&
                                    pLoc.coordinate.longitude <= (bounds.xmn + longSpan))
                                {
                                    switch (ptc)
                                    {
                                        case 0:
                                            pLoc.type = [NSNumber numberWithInteger:PriorityLocationTypeSchool];
                                            break;
                                            
                                        case 1:
                                        case 2:
                                            pLoc.type = [NSNumber numberWithInteger:PriorityLocationTypeMedical];
                                            break;
                                            
                                        case 3:
                                            pLoc.type = [NSNumber numberWithInteger:PriorityLocationTypeLibrary];
                                            break;
                                            
                                        case 4:
                                            pLoc.type = [NSNumber numberWithInteger:PriorityLocationTypeEmployment];
                                            break;
                                            
                                        case 5:
                                            pLoc.type = [NSNumber numberWithInteger:PriorityLocationTypePostOffice];
                                            break;
                                            
                                        case 6:
                                            pLoc.type = [NSNumber numberWithInteger:PriorityLocationTypeGovernment];
                                            break;
                                            
                                        case 7:
                                            pLoc.type = [NSNumber numberWithInteger:PriorityLocationTypeHotel];
                                            break;
                                            
                                        case 8:
                                        case 9:
                                            pLoc.type = [NSNumber numberWithInteger:PriorityLocationTypeSeniorResidential];
                                            break;
                                    }
                                    
                                    int index = 0;
                                    
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
                    }
                    
                    count++;
                    popover.progressView.progress = ((CGFloat)count / (CGFloat)totalQueries);
                    
                    if (count == totalQueries)
                    {
                        if (self.delegate)
                            [self.delegate didFinishPriorityLocationArray:locationArray];
                    }
                }];
            }
        }
    }
}

@end