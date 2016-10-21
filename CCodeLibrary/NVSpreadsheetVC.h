//  NVSpreadsheetVC.h
//  CCodeLibrary

@import UIKit;

@class NVSpreadsheetVC;

@protocol NVSpreadsheetVCDelegate <NSObject>

@end

@interface NVSpreadsheetVC : UIViewController

@property (nonatomic, weak) id<NVSpreadsheetVCDelegate> delegate;
@property NSUInteger rows, columns;

+ (instancetype)presentSpreadsheetInViewController:(UIViewController *)viewController
                                           numRows:(NSUInteger)numRows
                                        numColumns:(NSUInteger)numColumns
                                          delegate:(id)delegate;

@end
