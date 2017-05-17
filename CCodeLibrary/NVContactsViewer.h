//  NVContactsViewer.h
//  CCodeLibrary

@import UIKit;

@class NVContactsViewer;

@protocol NVContactsViewerDelegate <NSObject>

- (void)contactsViewerDidReturn:(NVContactsViewer *)contactsViewer;

- (void)contactsViewer:(NVContactsViewer *)contactsViewer
       didReturnEmails:(NSArray *)emails;

@end

@interface NVContactsViewer : UIViewController

@property (nonatomic, weak) id <NVContactsViewerDelegate> delegate;

+ (instancetype)contactsViewerWithDelegate:(id)delegate;

@end
