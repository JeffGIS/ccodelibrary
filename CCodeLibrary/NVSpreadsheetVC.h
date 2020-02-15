//  NVSpreadsheetVC.h
//  CCodeLibrary

@import UIKit;
#import "GSSiEnums.h"
#import "RiteHome.h"

@class NVSpreadsheetVC;

@protocol NVSpreadsheetVCDelegate <NSObject>

- (SpreadsheetTypes) getSpreadSheetType;
- (BOOL)openList:(NVSpreadsheetVC*)vc;
- (void)closeList;
- (NSString *)currentListName;
- (NSString *)headerTextForColumn:(NSUInteger)column;
- (NSString *)headerTextForRow:(NSUInteger)row;

- (NSString *)textForColumn:(NSUInteger)column
                        row:(NSUInteger)row;

- (NSInteger)numRowsInSpreadsheet;
- (NSInteger)numColumnsInSpreadsheet;
- (NSInteger)numSelectableRows;
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
                            from:(NVSpreadsheetVC *)fromVC
                 tabBarController:(UITabBarController *)tabBarController;

- (void)deleteRows:(NSArray *)arrayOfRows;
- (NSString *)filePathForHelpFile;

- (void)copyRows:(NSArray *)arrayOfRows
          toList:(NSString *)listName;
- (NSMutableArray*) getOptionsForCell:(NSInteger)row
                               column:(NSInteger)column;

@optional
- (NSArray *)clipsForProperty:(int)propNum;
- (BOOL)addVideoClip:(RHClip *)clip;
- (NSInteger)getPropNumForRow:(NSInteger)row;
- (NSString *)vidDirForPropNum:(int)propNum;
- (BOOL)spreadsheetCanEditRowHeaderTextAtIndex:(NSInteger)index;
- (NSString *)spreadsheetRowHeaderTextPrefixAtIndex:(NSInteger)index;
- (BOOL)spreadsheetCanEditColumnHeaderTextAtIndex:(NSInteger)index;

- (void)spreadsheetDidEditRowHeaderText:(NSString *)text
                                atIndex:(NSInteger)index;

- (void)spreadsheetDidEditColumnHeaderText:(NSString *)text
                                   atIndex:(NSInteger)index;

- (BOOL)spreadsheetSortOnRow:(NSInteger)row;
- (NSArray *) getSelectedRowKeys:(NSArray*)selectedRows;
- (NSMutableArray *) selectRowsUsingKeys:(NSArray*)selectedRowKeys;
- (void)getTimeLine:(NVSpreadsheetVC *)parentController;

- (NSString *)spreadsheetGetReportForRow:(NSInteger)row
                                  column:(NSInteger)column;
- (NSArray *)getSearchStrings;
- (SpreadsheetAction)actionForTapOnRowHeader;
- (SpreadsheetAction)actionForTwoTouchLongPressOnRowHeader;
- (SpreadsheetAction)actionForOneTouchLongPressOnColumnHeader;
- (SpreadsheetAction)actionForTwoTouchLongPressOnColumnHeader;
- (void)setCurrentFieldList:(NSString *)fieldList;
- (void)setCurrentPropList:(NSString *)propList;
- (NSInteger)getAutoSelectRow;
- (UIColor*)backgroundColorForCell:(NSInteger)row
                            column:(NSInteger)column;
- (void)displayPropHistory:(int)propNum
                    overVC:(UIViewController*)vc;
@end

@interface NVSpreadsheetVC : UIViewController

@property (nonatomic, weak) id<NVSpreadsheetVCDelegate> delegate;
@property (nonatomic) BOOL flipped;
@property (nonatomic) NVWebView *nvRealtorwv;

- (NSArray *)retrieveSearchStrings;
- (void)updateSelectedRowsAtIndex:(NSInteger)index;
- (void)autoSelectRow:(NSTimer*)timer;

@end
