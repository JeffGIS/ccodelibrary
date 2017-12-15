//  RHSearch.m
//  CCodeLibrary

#import "RHSearch.h"

@implementation RHSearchItem

@end

@interface RHSearch ()

@property (nonatomic) NSMutableArray<RHSearchItem *> *items;

@end

@implementation RHSearch

- (void)getItemsForZip:(int)zip
{
    _items = NSMutableArray.array;
    
    NSString *urlString = [NSString stringWithFormat:@"https://www.realtor.com/realestateandhomes-search/%i?pgsz=50", zip];
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
                    
                    for (NSString *item in htmlArray)
                    {
                        NSString *address = textAfter(item, @"streetAddress");
                        address = textBefore(textAfter(address, @">"), @"</");
                        NSString *city = textAfter(item, @"addressLocality");
                        city = textBefore(textAfter(city, @">"), @"</");
                        NSString *state = textAfter(item, @"addressRegion");
                        state = textBefore(textAfter(state, @">"), @"</");
                        NSString *zip = textAfter(item, @"postalCode");
                        zip = textBefore(textAfter(zip, @">"), @"</");
                        NSString *coordinates = textAfter(item, @"GeoCoordinates");
                        coordinates = textAfter(coordinates, @"content=\"");
                        NSString *latitude = textBefore(coordinates, @"\"");
                        coordinates = textAfter(coordinates, @"content=\"");
                        NSString *longitude = textBefore(coordinates, @"\"");
                        NSLog(@"%@, %@, %@ %@ (%@,%@)", address, city, state, zip, latitude, longitude);
                    }
                }
            }] resume];
}

@end
