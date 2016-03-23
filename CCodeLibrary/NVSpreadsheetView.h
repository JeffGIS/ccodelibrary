//  NVSpreadsheetView.h
//  CCodeLibrary

#import <UIKit/UIKit.h>

@class NVSpreadsheetView;

@protocol NVSpreadsheetViewDelegate <NSObject>

@optional
- (void)ssvDidEditColumnHeaderText:(NSString *)text
                           atIndex:(NSUInteger)index;

- (void)ssvDidEditRowHeaderText:(NSString *)text
                        atIndex:(NSUInteger)index;

- (void)ssvDidEditText:(NSString *)text
          forCellAtRow:(NSUInteger)row
                column:(NSUInteger)column;

- (void)ssvCellWasTappedAtRowIndex:(NSUInteger)rowIndex
                       columnIndex:(NSUInteger)columnIndex;

@end

@interface NVSpreadsheetView : UIView <UIScrollViewDelegate,UITextFieldDelegate>

@property (nonatomic, weak) id <NVSpreadsheetViewDelegate> delegate;
@property BOOL editable, selectable;
@property NSUInteger rows, columns, activeColumns, activeRows;
@property CGFloat rowHeight, columnWidth;

+ (NVSpreadsheetView *)showSpreadsheetWithRows:(NSUInteger)rows
                                       columns:(NSUInteger)columns
                                          view:(UIView *)view
                                      editable:(BOOL)editable
                                    selectable:(BOOL)selectable
                                      delegate:(id)delegate;

- (void)setRowHeaderText:(NSArray *)rowHeaderText;
- (void)setColumnHeaderText:(NSArray *)columnHeaderText;

- (void)setText:(NSString *)text
   forCellAtRow:(NSUInteger)row
         column:(NSUInteger)column;

- (void)clearContents;

@end