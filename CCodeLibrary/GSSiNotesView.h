//  GSSiNotesView.h
//  CCodeLibrary

#import <UIKit/UIKit.h>
#import "GSSiAlertController.h"

@class GSSiNotesView;

@protocol GSSiNotesViewDelegate <NSObject>

- (void)notesViewDidCancel:(GSSiNotesView *)notesView;

- (void)notesView:(GSSiNotesView *)notesView
     didSaveNotes:(NSString *)notes
             list:(NSArray *)list;

- (void)notesView:(GSSiNotesView *)notesView
didFindMatchBetweenNote:(NSString *)note
    andItemInList:(NSString *)itemInList;

@end

@interface GSSiNotesView : UIView <UITextViewDelegate,UITableViewDataSource,UITableViewDelegate,GSSiAlertDelegate>

@property (nonatomic, weak) id <GSSiNotesViewDelegate> delegate;

+ (GSSiNotesView *)showNotesViewWithView:(UIView *)view
                                delegate:(id)delegate
                            titleSubject:(NSString *)titleSubject;

- (void)hideNotesView:(BOOL)animated;
- (void)bringToFrontOfView:(UIView *)view;

- (void)willRotateWithDuration:(NSTimeInterval)duration
                  tabBarHeight:(CGFloat)tabBarHeight;

@end