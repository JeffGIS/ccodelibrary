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

@end

@interface NVPopoverTableView : UIView

@property (nonatomic, copy) NSString *title;
@property (nonatomic) UIView *overlayView;
@property (nonatomic, copy) NSArray<UIImage *> *imageArray;

+ (instancetype)showPopoverTableViewInView:(UIView *)view
                                  delegate:(id)delegate
                                     title:(NSString *)title
                                 textArray:(NSArray *)textArray
                             includeCancel:(BOOL)includeCancel;

- (void)hide:(BOOL)animated;

@end
