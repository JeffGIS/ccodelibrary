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

@optional

- (void)notesView:(GSSiNotesView *)notesView
didFindMatchBetweenNote:(NSString *)note
    andItemInList:(NSString *)itemInList;

- (NSArray *)arrayOfPickableNotesItemsForNotesView:(GSSiNotesView *)notesView;

@end

@interface GSSiNotesView : UIView <UITextViewDelegate,UITableViewDataSource,UITableViewDelegate,GSSiAlertDelegate>

@property (nonatomic, weak) id <GSSiNotesViewDelegate> delegate;

+ (GSSiNotesView *)showNotesViewWithView:(UIView *)view
                                delegate:(id)delegate
                                   title:(NSString *)title
                            currentValue:(NSString *)value
                        allowAutoCorrect:(BOOL)autoCorrect;

- (void)hideNotesView:(BOOL)animated;
- (void)bringToFrontOfView:(UIView *)view;

- (void)willRotateWithDuration:(NSTimeInterval)duration
        toInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
                  tabBarHeight:(CGFloat)tabBarHeight;

@end