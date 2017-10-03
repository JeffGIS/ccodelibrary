//  NVSpreadsheetVC.h
//  CCodeLibrary

@import UIKit;
#import "GSSiEnums.h"

@class NVSpreadsheetVC;

@protocol NVSpreadsheetVCDelegate <NSObject>

- (SpreadsheetTypes) getSpreadSheetType;
- (BOOL)openList;
- (void)closeList;
- (NSString *)currentListName;
- (NSString *)headerTextForColumn:(NSUInteger)column;
- (NSString *)headerTextForRow:(NSUInteger)row;

- (NSString *)textForColumn:(NSUInteger)column
                        row:(NSUInteger)row;

- (NSInteger)numRowsInSpreadsheet;
- (NSInteger)numColumnsInSpreadsheet;
- (NSArray *)spreadsheetDidGetLists;
- (void)spreadsheetDidEditTitleText:(NSString *)titleText;
- (void)spreadsheetDidSetCurrentList:(NSString *)file;
- (void)spreadsheetDidDeleteCurrentList;
- (void)spreadsheetDidCreateList;
- (NSString *)propFieldDescriptionFilePathAtRow:(NSInteger)row;

- (void)spreadsheetDidMapItForRow:(NSInteger)row
                           column:(NSInteger)column
                 tabBarController:(UITabBarController *)tabBarController;

- (void)spreadsheetDidZoomForRow:(NSInteger)row
                           column:(NSInteger)column
                 tabBarController:(UITabBarController *)tabBarController;

- (void)deleteRows:(NSArray *)arrayOfRows;
- (NSString *)filePathForHelpFile;

- (void)copyRows:(NSArray *)arrayOfRows
          toList:(NSString *)listName;

@optional
- (BOOL)spreadsheetCanEditRowHeaderTextAtIndex:(NSInteger)index;
- (NSString *)spreadsheetRowHeaderTextPrefixAtIndex:(NSInteger)index;
- (BOOL)spreadsheetCanEditColumnHeaderTextAtIndex:(NSInteger)index;

- (void)spreadsheetDidEditRowHeaderText:(NSString *)text
                                atIndex:(NSInteger)index;

- (void)spreadsheetDidEditColumnHeaderText:(NSString *)text
                                   atIndex:(NSInteger)index;

- (BOOL)spreadsheetSortOnRow:(NSInteger)row;
- (void)getTimeLine:(NVSpreadsheetVC *)parentController;

- (NSString *)spreadsheetGetReportForRow:(NSInteger)row
                                  column:(NSInteger)column;
- (NSArray *)getSearchStrings;
- (SpreadsheetAction)actionForTapOnRowHeader;
- (SpreadsheetAction)actionForTwoTouchLongPressOnRowHeader;
- (SpreadsheetAction)actionForOneTouchLongPressOnColumnHeader;
- (SpreadsheetAction)actionForTwoTouchLongPressOnColumnHeader;

@end

@interface NVSpreadsheetVC : UIViewController

@property (nonatomic, weak) id<NVSpreadsheetVCDelegate> delegate;
@property BOOL flipped;

- (NSArray *)retrieveSearchStrings;

@end
