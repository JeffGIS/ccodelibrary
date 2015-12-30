//
//  FileLister.h
//  CCodeLibrary
//
//  Created by Bill Munson on 12/30/15.
//  Copyright © 2015 GSSi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MessageUI/MessageUI.h>

@interface FileLister : NSObject

+ (NSInteger) listFilesInDirectory:(NSString *)inPath
                          outputTo:(NSString *)outFile
                         totalSize:(NSInteger*)pTotSize;

@end
