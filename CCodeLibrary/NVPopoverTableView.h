//  NVPopoverTableView.h
//  CCodeLibrary

@import UIKit;

@class NVPopoverTableView;

@protocol NVPopoverTableViewDelegate <NSObject>

@end

@interface NVPopoverTableView : UIView

+ (instancetype)showPopoverTableViewInView:(UIView *)view
                                  delegate:(id)delegate
                                     title:(NSString *)title
                                 textArray:(NSArray *)textArray;

@end