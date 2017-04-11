//  NVSpreadsheet.h
//  CCodeLibrary

@import UIKit;

#define COLUMN_HEADER 1
#define ROW_HEADER 2

@class NVSpreadsheet;

@protocol NVSpreadsheetDataSource <NSObject>

- (CGSize)spreadsheetView:(NVSpreadsheet *)spreadsheetView
   sizeForItemAtIndexPath:(NSIndexPath *)indexPath;

- (NSInteger)numberOfRowsInSpreadsheetView:(NVSpreadsheet *)spreadsheetView;
- (NSInteger)numberOfColumnsInSpreadsheetView:(NVSpreadsheet *)spreadsheetView;

- (UICollectionViewCell *)spreadsheetView:(NVSpreadsheet *)spreadsheetView
                   cellForItemAtIndexPath:(NSIndexPath *)indexPath;

- (CGSize)gridContainerSize;
- (BOOL)spreadsheetIsFlipped;
- (NSString *)spreadsheetViewRowHeaderPrefixAtIndex:(NSInteger)index;

@end

@protocol NVSpreadsheetDelegate <NSObject>

- (BOOL)spreadsheetViewCanEditHeaderOfType:(int)type
                                   atIndex:(NSInteger)index;

- (void)spreadsheetView:(NVSpreadsheet *)spreadsheetView
didSelectItemAtIndexPath:(NSIndexPath *)indexPath;

- (void)spreadsheetViewDidEditColumnHeaderText:(NSString *)text
                                       atIndex:(NSInteger)index;

- (void)spreadsheetViewDidEditRowHeaderText:(NSString *)text
                                    atIndex:(NSInteger)index;

- (void)spreadsheetViewInEditingMode:(BOOL)editingMode;

@end

@interface NVSpreadsheet : UIView

@property (nonatomic, weak) id<NVSpreadsheetDelegate> delegate;
@property (nonatomic, weak) id<NVSpreadsheetDataSource> dataSource;
@property UIEdgeInsets scrollIndicatorInsets;
@property BOOL showsHorizontalScrollIndicator, showsVerticalScrollIndicator;
@property (nonatomic) BOOL bounces;

- (id)initWithNumberOfHeaderRows:(NSUInteger)headerRowCount
           numberOfHeaderColumns:(NSUInteger)headerColumnCount
                           frame:(CGRect)frame;

- (void)registerCellClass:(Class)cellClass
forCellWithReuseIdentifier:(NSString *)identifier;

- (UICollectionViewCell *)dequeueReusableCellWithReuseIdentifier:(NSString *)identifier
                                                    forIndexPath:(NSIndexPath *)indexPath;

- (void)reloadData;
- (void)flashScrollIndicators;
- (void)goToTop;
- (void)goToBottom;
- (void)goToLeftSide;
- (void)goToRightSide;
- (void)goToUpperLeft;
- (void)goToUpperRight;
- (void)goToLowerLeft;
- (void)goToLowerRight;

@end
