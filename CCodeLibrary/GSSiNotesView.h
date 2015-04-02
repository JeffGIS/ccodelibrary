//  GSSiNotesView.h
//  CCodeLibrary

#import <UIKit/UIKit.h>

@class GSSiNotesView;

@protocol GSSiNotesViewDelegate <NSObject>

- (void)notesViewdidCancel:(GSSiNotesView *)notesView;

- (void)notesView:(GSSiNotesView *)notesView
     didSaveNotes:(NSString *)notes
             list:(NSArray *)list;

@end

@interface GSSiNotesView : UIView <UITextViewDelegate,UITableViewDataSource,UITableViewDelegate>

@property (nonatomic, weak) id <GSSiNotesViewDelegate> delegate;

+ (GSSiNotesView *)showNotesViewWithView:(UIView *)view
                                delegate:(id)delegate
                            titleSubject:(NSString *)titleSubject;

- (void)hideNotesView:(BOOL)animated;
- (void)bringToFrontOfView:(UIView *)view;

- (void)willRotateWithDuration:(NSTimeInterval)duration
                  tabBarHeight:(CGFloat)tabBarHeight;

@end