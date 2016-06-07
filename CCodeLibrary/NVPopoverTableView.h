//  NVPopoverTableView.h
//  CCodeLibrary

@import UIKit;

@class NVPopoverTableView;

@protocol NVPopoverTableViewDelegate <NSObject>

- (void)popoverTableView:(NVPopoverTableView *)popoverTableView
    didSelectRowWithText:(NSString *)text
                 atIndex:(NSInteger)index;

- (void)popoverTableViewDidCancel:(NVPopoverTableView *)popoverTableView;

@end

@interface NVPopoverTableView : UIView

@property (nonatomic, copy) NSString *title;

+ (instancetype)showPopoverTableViewInView:(UIView *)view
                                  delegate:(id)delegate
                                     title:(NSString *)title
                                 textArray:(NSArray *)textArray
                             includeCancel:(BOOL)includeCancel;

- (void)hide:(BOOL)animated;

@end