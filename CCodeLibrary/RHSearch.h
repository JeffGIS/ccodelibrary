//  RHSearch.h
//  CCodeLibrary

@import Foundation;

@interface RHSearchItem : NSObject

@property (nonatomic, copy) NSString *address, *city, *state, *zip;
@property CLLocationCoordinate2D coordinate;

@end

@interface RHSearch : NSObject

- (void)getItemsForZip:(int)zip;

@end
