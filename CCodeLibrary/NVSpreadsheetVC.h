//  NVSpreadsheetVC.h
//  CCodeLibrary

@import UIKit;

@class NVSpreadsheetVC;

@protocol NVSpreadsheetVCDelegate <NSObject>

- (NSString *)headerTextForColumn:(NSUInteger)column;
- (NSString *)headerTextForRow:(NSUInteger)row;

- (NSString *)textForColumn:(NSUInteger)column
                        row:(NSUInteger)row;

@end

@interface NVSpreadsheetVC : UIViewController

@property (nonatomic, weak) id<NVSpreadsheetVCDelegate> delegate;
@property NSUInteger rows, columns;

+ (instancetype)presentSpreadsheetInViewController:(UIViewController *)viewController
                                           numRows:(NSUInteger)numRows
                                        numColumns:(NSUInteger)numColumns
                                          delegate:(id)delegate;

@end
