//  NVDocumentManager.h
//  CCodeLibrary

@import UIKit;

@class NVTileCompiler;

@protocol NVDocumentManagerDelegate <NSObject>

@optional
- (void)documentManagerDidCompleteWithMessage:(NSString *)message
                                     filepath:(NSString *)filepath;

@end

@interface NVDocumentManager : NSObject

@property (nonatomic, weak) id <NVDocumentManagerDelegate> delegate;

- (void)exportDocumentFromFilepath:(NSString *)filepath
                          delegate:(id)delegate
                    deleteWhenDone:(BOOL)deleteWhenDone;

- (void)importFileWithDelegate:(id)delegate;

@end