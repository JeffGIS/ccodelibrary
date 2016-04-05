//  NVSpreadsheetView.h
//  CCodeLibrary

@import UIKit;

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

- (void)ssvDidSetFlipped:(BOOL)flipped;
- (void)ssvDidRequestWebViewAtURL:(NSString *)URL;

- (NSString *)ssvGetTitleText;
- (NSArray *)ssvGetFileList;
- (void)ssvSetCurrentFile:(NSString *)file;
- (BOOL)ssvDeleteCurrentFile;
- (void)ssvCreateWasTapped;
- (BOOL)ssvDidEditTitleText:(NSString *)text;

@end

@interface NVSpreadsheetView : UIView <UIScrollViewDelegate,UITextFieldDelegate>

@property (nonatomic, weak) id <NVSpreadsheetViewDelegate> delegate;
@property (nonatomic) NSUInteger rows, columns, activeColumns, activeRows;
@property (nonatomic) CGFloat rowHeight, columnWidth;
@property BOOL flipped;

+ (NVSpreadsheetView *)showSpreadsheetWithRows:(NSUInteger)rows
                                       columns:(NSUInteger)columns
                                          view:(UIView *)view
                                       flipped:(BOOL)flipped
                                      delegate:(id)delegate;

- (void)setRowHeaderText:(NSArray *)rowHeaderText;
- (void)setColumnHeaderText:(NSArray *)columnHeaderText;

- (void)setText:(NSString *)text
   forCellAtRow:(NSUInteger)row
         column:(NSUInteger)column;

- (void)clearContents;

@end