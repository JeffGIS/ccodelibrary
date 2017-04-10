//  NVSpreadsheetVC.h
//  CCodeLibrary

@import UIKit;

@class NVSpreadsheetVC;

@protocol NVSpreadsheetVCDelegate <NSObject>

- (BOOL) openList;
- (void) closeList;
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
- (NSString *)propFieldDescriptionFilePathAtRow:(NSInteger)row;

- (void)spreadsheetDidMapItForRow:(NSInteger)row
                           column:(NSInteger)column
                 tabBarController:(UITabBarController *)tabBarController;

@optional
- (BOOL)spreadsheetCanEditRowHeaderTextAtIndex:(NSInteger)index;
- (NSString *)spreadsheetRowHeaderTextPrefix:(NSInteger)index;
- (BOOL)spreadsheetCanEditColumnHeaderTextAtIndex:(NSInteger)index;

- (void)spreadsheetDidEditRowHeaderText:(NSString *)text
                                atIndex:(NSInteger)index;

- (void)spreadsheetDidEditColumnHeaderText:(NSString *)text
                                   atIndex:(NSInteger)index;

- (BOOL)spreadsheetSortOnRow:(NSInteger)row;

@end

@interface NVSpreadsheetVC : UIViewController

@property (nonatomic, weak) id<NVSpreadsheetVCDelegate> delegate;
@property BOOL flipped;

@end
