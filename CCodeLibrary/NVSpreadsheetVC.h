//  NVSpreadsheetVC.h
//  CCodeLibrary

@import UIKit;
#import "GSSiEnums.h"

@interface TimeLine : NSObject
@property int time;
@property double value;
@end

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

- (void)deleteRows:(NSArray *)arrayOfRows;

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
- (void)getTimeLine:(UIViewController *)parentController;

- (NSString *)spreadsheetGetReportForRow:(NSInteger)row
                                  column:(NSInteger)column;
- (NSArray *) getSearchStrings;
- (SpreadsheetAction)actionForTapOnRowHeader;
- (SpreadsheetAction)actionForTwoTouchLongPressOnRowHeader;

@end

@interface NVSpreadsheetVC : UIViewController

@property (nonatomic, weak) id<NVSpreadsheetVCDelegate> delegate;
@property BOOL flipped;

@end
