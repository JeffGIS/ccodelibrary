//  NVSpreadsheetView.h
//  CCodeLibrary

#import <UIKit/UIKit.h>

@interface NVSpreadsheetView : UIView <UIScrollViewDelegate>

@property BOOL editable, selectable;
@property NSUInteger rows, columns;
@property CGFloat rowHeight, columnWidth;

+ (NVSpreadsheetView *)showSpreadsheetWithRows:(NSUInteger)rows
                                       columns:(NSUInteger)columns
                                          view:(UIView *)view
                                         frame:(CGRect)frame
                                      editable:(BOOL)editable
                                    selectable:(BOOL)selectable;

- (void)setRowHeaderText:(NSArray *)rowHeaderText;
- (void)setColumnHeaderText:(NSArray *)columnHeaderText;

- (void)setText:(NSString *)text
   forCellAtRow:(NSUInteger)row
         column:(NSUInteger)column;

- (void)willRotateWithDuration:(NSTimeInterval)duration
                  tabBarHeight:(CGFloat)tabBarHeight;

@end