//  NVSpreadsheetVC.h
//  CCodeLibrary

@import UIKit;

@class NVSpreadsheetVC;

@protocol NVSpreadsheetVCDelegate <NSObject>

- (BOOL) openPropertyList;
- (void) closePropertyList;
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

- (void)spreadsheetDidEditColumnHeaderText:(NSString *)text
                                   atIndex:(NSInteger)index;

@end

@interface NVSpreadsheetVC : UIViewController

@property (nonatomic, weak) id<NVSpreadsheetVCDelegate> delegate;
@property BOOL flipped;

@end
