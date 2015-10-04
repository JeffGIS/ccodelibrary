//  NVSpreadsheetView.h
//  CCodeLibrary

#import <UIKit/UIKit.h>

@class NVSpreadsheetView;

@protocol NVSpreadsheetViewDelegate <NSObject>

- (void)ssvDidEditColumnHeaderAtIndex:(NSUInteger)index;

@end

@interface NVSpreadsheetView : UIView <UIScrollViewDelegate,UITextFieldDelegate>

@property (nonatomic, weak) id <NVSpreadsheetViewDelegate> delegate;
@property BOOL editable, selectable;
@property NSUInteger rows, columns;
@property CGFloat rowHeight, columnWidth;

+ (NVSpreadsheetView *)showSpreadsheetWithRows:(NSUInteger)rows
                                       columns:(NSUInteger)columns
                                          view:(UIView *)view
                                         frame:(CGRect)frame
                                      editable:(BOOL)editable
                                    selectable:(BOOL)selectable
                                      delegate:(id)delegate;

- (void)setRowHeaderText:(NSArray *)rowHeaderText;
- (void)setColumnHeaderText:(NSArray *)columnHeaderText;

- (void)setText:(NSString *)text
   forCellAtRow:(NSUInteger)row
         column:(NSUInteger)column;

- (void)willRotateWithDuration:(NSTimeInterval)duration
                  tabBarHeight:(CGFloat)tabBarHeight;

@end