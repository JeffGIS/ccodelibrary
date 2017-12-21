//  RHSearch.h
//  CCodeLibrary

@import Foundation;

@interface RHSearchItem : NSObject

@property (nonatomic, copy) NSString *address, *city, *state, *url;
@property float beds, baths, garage, lotsize, latitude, longitude;
@property int zip, price, sqft, insertTime, modifyTime, updateTime;
@property long long listingID;

@end

@class RHSearch;

@protocol RHSearchDelegate <NSObject>

- (void)searchDidReturnItems:(NSArray<RHSearchItem *> *)items
                   morePages:(BOOL)morePages;

- (void)searchDidReceiveError:(NSString *)error;

@end

@interface RHSearchDatabase : NSObject

- (void)updateDatabaseForSearchItems:(NSArray<RHSearchItem *> *)searchItems;
- (void)deleteOldItems;
- (int)numberOfItems;

@end

@interface RHSearch : NSObject

+ (instancetype)searchWithDelegate:(id<RHSearchDelegate>)delegate;
- (void)getItemsForZip;

@end
