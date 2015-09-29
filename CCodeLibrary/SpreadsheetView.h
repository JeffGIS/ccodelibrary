//  SpreadsheetView.h
//  GMMobile

#import <UIKit/UIKit.h>

@interface SpreadsheetView : UIScrollView <UITextFieldDelegate>

@property (nonatomic) NSUInteger rowHeight, columnWidth;

+ (SpreadsheetView *)spreadsheetViewWithRows:(NSUInteger)rows
                                     columns:(NSUInteger)columns
                                        view:(UIView *)view
                                       frame:(CGRect)frame
                                returnHidden:(BOOL)returnHidden;

- (void)willRotateWithDuration:(NSTimeInterval)duration
                  tabBarHeight:(CGFloat)tabBarHeight;

- (void)setTextArray:(NSArray *)textArray
    forColumnAtIndex:(NSUInteger)columnIndex;

- (void)setTextArray:(NSArray *)textArray
       forRowAtIndex:(NSUInteger)rowIndex;

- (void)setText:(NSString *)text
   forCellAtRow:(NSUInteger)row
         column:(NSUInteger)column;

@end