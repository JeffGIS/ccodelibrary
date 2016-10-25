//  NVSpreadsheet.h
//  CCodeLibrary

@import UIKit;

@class NVSpreadsheet;

@protocol NVSpreadsheetDataSource <NSObject>

- (CGSize)spreadsheetView:(NVSpreadsheet *)spreadsheetView
   sizeForItemAtIndexPath:(NSIndexPath *)indexPath;

- (NSInteger)numberOfRowsInSpreadsheetView:(NVSpreadsheet *)spreadsheetView;
- (NSInteger)numberOfColumnsInSpreadsheetView:(NVSpreadsheet *)spreadsheetView;
- (NSInteger)numActiveColumns;

- (UICollectionViewCell *)spreadsheetView:(NVSpreadsheet *)spreadsheetView
                   cellForItemAtIndexPath:(NSIndexPath *)indexPath;

- (BOOL)spreadsheetIsFlipped;

@end

@protocol NVSpreadsheetDelegate <NSObject>

- (void)spreadsheetView:(NVSpreadsheet *)spreadsheetView
didSelectItemAtIndexPath:(NSIndexPath *)indexPath;

- (void)spreadsheetViewDidEditTopRowText:(NSString *)text
                                 atIndex:(NSInteger)index;

@end

@interface NVSpreadsheet : UIView

@property (nonatomic, weak) id<NVSpreadsheetDelegate> delegate;
@property (nonatomic, weak) id<NVSpreadsheetDataSource> dataSource;
@property UIEdgeInsets scrollIndicatorInsets;
@property BOOL showsHorizontalScrollIndicator, showsVerticalScrollIndicator, bounces;

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
- (void)flipLongPressGesture:(BOOL)flipped;
- (void)flashScrollIndicators;

@end
