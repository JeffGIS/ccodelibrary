//  RHSearch.h
//  CCodeLibrary

@import Foundation;

@interface RHSearchItem : NSObject

@property (nonatomic, copy) NSString *address, *city, *state, *zip, *url;
@property CLLocationCoordinate2D coordinate;

@end

@class RHSearch;

@protocol RHSearchDelegate <NSObject>

- (void)searchDidReturnItems:(NSArray<RHSearchItem *> *)items
                      forZip:(int)zip;

- (void)searchDidReceiveError:(NSString *)error
                       forZip:(int)zip;

@end

@interface RHSearch : NSObject

+ (instancetype)searchWithDelegate:(id<RHSearchDelegate>)delegate;
- (void)getItemsForZip:(int)zip;

@end
