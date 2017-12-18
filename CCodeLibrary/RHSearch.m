//  RHSearch.m
//  CCodeLibrary

#import "RHSearch.h"

#define MAX_ITEMS 50

@implementation RHSearchItem

@end

@interface RHSearch ()

@property (nonatomic, weak) id<RHSearchDelegate> delegate;
@property (nonatomic) NSMutableArray<RHSearchItem *> *items;
@property int page;

@end

@implementation RHSearch

+ (instancetype)searchWithDelegate:(id<RHSearchDelegate>)delegate
{
    RHSearch *search = RHSearch.new;
    search.items = NSMutableArray.array;
    search.delegate = delegate;
    search.page = 1;
    
    return search;
}

- (void)getItemsForZip:(int)zip
{
    if (!_delegate)
    {
        NSLog(@"RHSearch ERROR: Delegate is required");
        return;
    }
    
    NSString *urlString = [NSString stringWithFormat:@"https://www.realtor.com/realestateandhomes-search/%i/pg-%i?pgsz=%i",
                           zip, _page, MAX_ITEMS];
    
    NSURL *url = [[NSURL alloc] initWithString:urlString];
    NSURLSession *session = NSURLSession.sharedSession;
    
    [[session dataTaskWithURL:url
            completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                if (error)
                    NSLog(@"RHSearch ERROR : %@ (zip = %i)", error.localizedDescription, zip);
                
                else
                {
                    NSString *htmlString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                    NSString *separator = @"js-record-user-activity";
                    htmlString = textAfter(htmlString, separator);
                    NSArray *htmlArray = [htmlString componentsSeparatedByString:separator];
                    NSString *substring = @"";
                    
                    for (NSString *component in htmlArray)
                    {
                        RHSearchItem *item = RHSearchItem.new;
                        substring = textAfter(component, @"streetAddress");
                        substring = textBefore(textAfter(substring, @">"), @"</");
                        item.address = substring;
                        substring = textAfter(component, @"addressLocality");
                        substring = textBefore(textAfter(substring, @">"), @"</");
                        item.city = substring;
                        substring = textAfter(component, @"addressRegion");
                        substring = textBefore(textAfter(substring, @">"), @"</");
                        item.state = substring;
                        substring = textAfter(component, @"postalCode");
                        substring = textBefore(textAfter(substring, @">"), @"</");
                        item.zip = substring;
                        substring = textAfter(component, @"GeoCoordinates");
                        substring = textAfter(substring, @"content=\"");
                        double latitude = textBefore(substring, @"\"").doubleValue;
                        substring = textAfter(substring, @"content=\"");
                        double longitude = textBefore(substring, @"\"").doubleValue;
                        item.coordinate = CLLocationCoordinate2DMake(latitude, longitude);
                        [_items addObject:item];
                    }
                    
                    if (htmlArray.count == MAX_ITEMS)
                    {
                        _page++;
                        [self getItemsForZip:zip];
                    }
                    
                    else
                        [_delegate searchDidReturnItems:_items.copy];
                }
            }] resume];
}

@end
