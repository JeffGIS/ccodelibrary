//  NVSpreadsheetVC.h
//  CCodeLibrary

@import UIKit;

@class NVSpreadsheetVC;

@protocol NVSpreadsheetVCDelegate <NSObject>

- (NSString *)headerTextForColumn:(NSUInteger)column;
- (NSString *)headerTextForRow:(NSUInteger)row;

- (NSString *)textForColumn:(NSUInteger)column
                        row:(NSUInteger)row;

- (NSInteger)numRowsInSpreadsheet;
- (NSInteger)numColumnsInSpreadsheet;
- (NSString *)titleTextForSpreadsheet;
- (NSArray *)spreadsheetDidGetLists;
- (void)spreadsheetDidEditTitleText:(NSString *)titleText;
- (void)spreadsheetDidSetCurrentList:(NSString *)file;
- (void)spreadsheetDidDeleteCurrentList;
- (void)spreadsheetDidCreateList;

- (void)spreadsheetDidEditColumnHeaderText:(NSString *)text
                                   atIndex:(NSInteger)index;

@end

@interface NVSpreadsheetVC : UIViewController

@property (nonatomic, weak) id<NVSpreadsheetVCDelegate> delegate;
@property BOOL flipped;

@end
