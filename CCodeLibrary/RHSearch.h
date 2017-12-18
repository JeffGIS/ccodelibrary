//  RHSearch.h
//  CCodeLibrary

@import Foundation;

@interface RHSearchItem : NSObject

@property (nonatomic, copy) NSString *address, *city, *state, *zip;
@property CLLocationCoordinate2D coordinate;

@end

@class RHSearch;

@protocol RHSearchDelegate <NSObject>

- (void)searchDidReturnItems:(NSArray<RHSearchItem *> *)items;

@end

@interface RHSearch : NSObject

+ (instancetype)searchWithDelegate:(id<RHSearchDelegate>)delegate;
- (void)getItemsForZip:(int)zip;

@end
