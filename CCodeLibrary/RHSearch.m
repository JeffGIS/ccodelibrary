//  RHSearch.m
//  CCodeLibrary

#import "RHSearch.h"

#define MAX_ITEMS 50
#define WEBSITE_URL @"https://www.realtor.com"
#define HTML_SEPARATOR @"js-record-user-activity"

@implementation RHSearchItem

- (NSString *)description
{
    return [NSString stringWithFormat:@"ADDRESS:%@, %@, %@ %@; COORDS:(%f,%f); URL:%@; "
            "PRICE:$%i; SQFT:%i; LOTSIZE:%.2f; BEDS:%.1f; BATHS:%.1f; GARAGE:%.1f",
            _address, _city, _state, _zip, _coordinate.latitude, _coordinate.longitude,
            _url, _price, _sqft, _lotsize, _beds, _baths, _garage];
}

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
    NSString *urlString = [NSString stringWithFormat:@"%@/realestateandhomes-search/%i?pgsz=%i",
                           WEBSITE_URL, zip, MAX_ITEMS];
    
    
    if (_page > 1)
    {
        urlString = [NSString stringWithFormat:@"%@/realestateandhomes-search/%i/pg-%i?pgsz=%i",
                     WEBSITE_URL, zip, _page, MAX_ITEMS];
    }
    
    NSURL *url = [[NSURL alloc] initWithString:urlString];
    NSURLSession *session = NSURLSession.sharedSession;
    
    [[session dataTaskWithURL:(NSURL *)url
            completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
    {
        if (error)
            [_delegate searchDidReceiveError:error.localizedDescription forZip:zip];
        
        else
        {
            NSString *htmlString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            htmlString = textAfter(htmlString, HTML_SEPARATOR);
            
            if (htmlString && htmlString.length)
            {
                NSArray *htmlArray = [htmlString componentsSeparatedByString:HTML_SEPARATOR];
                NSString *substring = @"";
                
                for (NSString *component in htmlArray)
                {
                    RHSearchItem *item = RHSearchItem.new;
                    substring = textBetween(component, @"data-url=\"", @"\"");
                    item.url = [NSString stringWithFormat:@"%@%@", WEBSITE_URL, substring];
                    item.price = textBetween(component, @"data-price=\"", @"\"").intValue;
                    item.address = textBetween(component, @"streetAddress\">", @"</");
                    item.city = textBetween(component, @"addressLocality\">", @"</");
                    item.state = textBetween(component, @"addressRegion\">", @"</");
                    item.zip = textBetween(component, @"postalCode\">", @"</");
                    item.beds = textBetween(component, @"data-value meta-beds\">", @"</").floatValue;
                    substring = textAfter(component, @"property-meta-baths");
                    item.baths = textBetween(substring, @"data-value\">", @"</").floatValue;
                    substring = textAfter(component, @"property-meta-sqft");
                    substring =  textBetween(substring, @"data-value\">", @"</");
                    item.sqft = [substring stringByReplacingOccurrencesOfString:@"," withString:@""].intValue;
                    substring = textAfter(component, @"property-meta-lotsize");
                    item.lotsize = textBetween(substring, @"data-value\">", @"</").floatValue;
                    substring = textAfter(component, @"property-meta-garage");
                    item.garage = textBetween(substring, @"data-value\">", @"</").floatValue;
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
                    [_delegate searchDidReturnItems:_items.copy forZip:zip];
            }
            
            else
                [_delegate searchDidReturnItems:nil forZip:zip];
        }
    }] resume];
}

@end
