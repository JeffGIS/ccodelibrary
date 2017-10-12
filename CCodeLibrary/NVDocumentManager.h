//  NVDocumentManager.h
//  CCodeLibrary

@import UIKit;

@class NVDocumentManager;

@protocol NVDocumentManagerDelegate <NSObject>

@optional
- (void)documentManagerDidCompleteWithMessage:(NSString *)message
                                     filepath:(NSString *)filepath;

@end

@interface NVDocumentManager : NSObject

@property (nonatomic, weak) id <NVDocumentManagerDelegate> delegate;
@property (nonatomic, copy) NSString *filePath;
@property BOOL deleteWhenDone;

- (void)exportDocumentFromFilePath:(NSString *)filePath
                          delegate:(id)delegate
                    deleteWhenDone:(BOOL)deleteWhenDone;

- (void)importFileWithDelegate:(id)delegate;
- (NSArray *)directoriesInDirectory:(NSString *)directory;

@end
