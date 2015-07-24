//  FTPDirectoryCreate.h
//  CCodeLibrary

#import <Foundation/Foundation.h>
#import "GSSiEnums.h"

@class FTPDirectoryCreate;

@protocol FTPDirectoryCreateDelegate <NSObject>

- (void)FTPDirectoryCreateDidCompleteWithStatus:(FTPStatus)status
                                   statusString:(NSString *)statusString
                                      directory:(NSString *)directory;

@end

@interface FTPDirectoryCreate : NSObject <NSStreamDelegate>

@property (nonatomic, weak) id <FTPDirectoryCreateDelegate> delegate;

+ (FTPDirectoryCreate *)createDirectories:(NSArray *)directories
                              inFTPDomain:(NSString *)ftpDomain
                                directory:(NSString *)directory
                                 username:(NSString *)username
                                 password:(NSString *)password
                                     port:(NSString *)port
                                 delegate:(id)delegate;

@end