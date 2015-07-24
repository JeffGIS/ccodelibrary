//  FTPDirectoryList.h
//  CCodeLibrary

#import <Foundation/Foundation.h>
#import "GSSiEnums.h"

@class FTPDirectoryList;

@protocol FTPDirectoryListDelegate <NSObject>

- (void)FTPDirectoryListDidCompleteWithStatus:(FTPStatus)status
                                 statusString:(NSString *)statusString
                                directoryList:(NSData *)directoryList;

@end

@interface FTPDirectoryList : NSObject <NSURLConnectionDataDelegate>

@property (nonatomic, weak) id <FTPDirectoryListDelegate> delegate;

+ (FTPDirectoryList *)getListingFromFTPDomain:(NSString *)ftpDomain
                                    directory:(NSString *)directory
                                     username:(NSString *)username
                                     password:(NSString *)password
                                         port:(NSString *)port
                                     delegate:(id)delegate;

@end