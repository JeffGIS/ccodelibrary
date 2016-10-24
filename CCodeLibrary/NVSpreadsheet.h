//  NVSpreadsheet.h
//  CCodeLibrary

@import UIKit;

@class NVSpreadsheet;

@protocol NVSpreadsheetDataSource <NSObject>

@optional
- (CGSize)spreadsheetView:(NVSpreadsheet *)spreadsheetView
   sizeForItemAtIndexPath:(NSIndexPath *)indexPath;

- (NSInteger)numberOfRowsInSpreadsheetView:(NVSpreadsheet *)spreadsheetView;
- (NSInteger)numberOfColumnsInSpreadsheetView:(NVSpreadsheet *)spreadsheetView;

- (UICollectionViewCell *)spreadsheetView:(NVSpreadsheet *)spreadsheetView
                   cellForItemAtIndexPath:(NSIndexPath *)indexPath;

@end

@protocol NVSpreadsheetDelegate <NSObject>

- (void)spreadsheetView:(NVSpreadsheet *)spreadsheetView
didSelectItemAtIndexPath:(NSIndexPath *)indexPath;

@end

@interface NVSpreadsheet : UIView

@property (nonatomic, weak) id<NVSpreadsheetDelegate> delegate;
@property (nonatomic, weak) id<NVSpreadsheetDataSource> dataSource;

- (id)initWithNumberOfHeaderRows:(NSUInteger)headerRowCount
           numberOfHeaderColumns:(NSUInteger)headerColumnCount
                           frame:(CGRect)frame;

- (void)registerCellClass:(Class)cellClass
forCellWithReuseIdentifier:(NSString *)identifier;

- (UICollectionViewCell *)dequeueReusableCellWithReuseIdentifier:(NSString *)identifier
                                                    forIndexPath:(NSIndexPath *)indexPath;

- (void)deselectItemAtIndexPath:(NSIndexPath *)indexPath
                       animated:(BOOL)animated;

- (void)reloadData;
- (void)returnToOrigin;

@property UIEdgeInsets scrollIndicatorInsets;
@property BOOL showsHorizontalScrollIndicator, showsVerticalScrollIndicator, bounces;

- (void)flashScrollIndicators;

@end
