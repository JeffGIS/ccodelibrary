//  NVSpreadsheet.h
//  CCodeLibrary

@import UIKit;

@class NVSpreadsheet;

@protocol NVSpreadsheetDataSource <NSObject>

- (CGSize)spreadsheetView:(NVSpreadsheet *)spreadsheetView
   sizeForItemAtIndexPath:(NSIndexPath *)indexPath;

- (NSInteger)numberOfRowsInSpreadsheetView:(NVSpreadsheet *)spreadsheetView;
- (NSInteger)numberOfColumnsInSpreadsheetView:(NVSpreadsheet *)spreadsheetView;

- (UICollectionViewCell *)spreadsheetView:(NVSpreadsheet *)spreadsheetView
                   cellForItemAtIndexPath:(NSIndexPath *)indexPath;

- (BOOL)spreadsheetIsFlipped;
- (CGSize)gridContainerSize;

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
- (void)flipLongPressGesture:(BOOL)flipped;
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
