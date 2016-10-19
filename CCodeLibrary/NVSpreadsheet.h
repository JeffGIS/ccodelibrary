//  NVSpreadsheet.h
//  CCodeLibrary

@import UIKit;

@class NVSpreadsheet;

@protocol NVSpreadsheetDataSource <NSObject>

@optional
- (CGSize)spreadsheetView:(NVSpreadsheet *)spreadsheetView
   sizeForItemAtIndexPath:(NSIndexPath *)indexPath;

@required
- (NSInteger)numberOfRowsInSpreadsheetView:(NVSpreadsheet *)spreadsheetView;
- (NSInteger)numberOfColumnsInSpreadsheetView:(NVSpreadsheet *)spreadsheetView;

- (UICollectionViewCell *)spreadsheetView:(NVSpreadsheet *)spreadsheetView
                   cellForItemAtIndexPath:(NSIndexPath *)indexPath;

@end

@protocol NVSpreadsheetDelegate <NSObject>

@optional
- (void)spreadsheetView:(NVSpreadsheet *)spreadsheetView
didSelectItemAtIndexPath:(NSIndexPath *)indexPath;

- (BOOL)spreadsheetView:(NVSpreadsheet *)spreadsheetView
shouldShowMenuForItemAtIndexPath:(NSIndexPath *)indexPath;

- (BOOL)spreadsheetView:(NVSpreadsheet *)spreadsheetView
       canPerformAction:(SEL)action
     forItemAtIndexPath:(NSIndexPath *)indexPath
             withSender:(id)sender;

- (void)spreadsheetView:(NVSpreadsheet *)spreadsheetView
          performAction:(SEL)action
     forItemAtIndexPath:(NSIndexPath *)indexPath
             withSender:(id)sender;

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

@property UIEdgeInsets scrollIndicatorInsets;
@property BOOL showsHorizontalScrollIndicator, showsVerticalScrollIndicator, bounces;

- (void)flashScrollIndicators;

@end
