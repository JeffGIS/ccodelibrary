//  NVPopoverTableView.h
//  CCodeLibrary

@import UIKit;

@class NVPopoverTableView;

@protocol NVPopoverTableViewDelegate <NSObject>

- (void)popoverTableView:(NVPopoverTableView *)popoverTableView
    didSelectRowWithText:(NSString *)text
                 atIndex:(NSInteger)index;

@optional
- (void)popoverTableViewDidCancel:(NVPopoverTableView *)popoverTableView;

- (void)popoverTableView:(NVPopoverTableView *)popoverTableView
didReturnWithSelectedRows:(NSArray<NSNumber *> *)selectedRows
               textArray:(NSArray *)selectedTextArray;

@end

@interface NVPopoverTableView : UIView

@property (nonatomic, copy) NSString *title;
@property (nonatomic) UIView *overlayView;
@property (nonatomic, copy) NSArray<UIImage *> *imageArray;
@property BOOL allowsMultipleSelection;
@property (nonatomic, copy) NSString *identifier;

+ (instancetype)showPopoverTableViewInView:(UIView *)view
                                  delegate:(id)delegate
                                     title:(NSString *)title
                                 textArray:(NSArray *)textArray
                             includeCancel:(BOOL)includeCancel;

- (void)hide:(BOOL)animated;

@end
