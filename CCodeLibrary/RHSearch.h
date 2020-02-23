//  RHSearch.h
//  CCodeLibrary

@import Foundation;
#import "FTPDataPull.h"
#import "GSSiPopoverView.h"

@interface RHSearchItem : NSObject

@property (nonatomic, copy) NSString *address, *city, *state, *url;
@property float beds, baths, garage, lotsize, latitude, longitude;
@property int zip, price, sqft, insertTime, modifyTime, updateTime, status;
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

@protocol RHGoogleSearchDelegate <NSObject>

- (void)GoogleSearchDidReturnString:(NSString *)str;

- (void)GoogleSearchDidReceiveError:(NSString *)error;

@end
@interface RHGoogleSearch : NSObject <FTPDataPullDelegate,GSSiPopoverViewDelegate>
+ (void) GOOGLEPropertySearch:(NSString*) searchAddress
                   usePopover:(GSSiPopoverView *) popover
                     delegate:(id<RHGoogleSearchDelegate>)delegate;
@property (nonatomic, weak) id<RHGoogleSearchDelegate> delegate;
@property (nonatomic) GSSiPopoverView * popover;
@end
