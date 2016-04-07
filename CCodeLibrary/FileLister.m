//
//  FileLister.m
//  CCodeLibrary
//
//  Created by Bill Munson on 12/30/15.
//  Copyright © 2015 GSSi. All rights reserved.
//

#import "FileLister.h"
#import "CRAPI.h"

@implementation FileLister

+ (NSInteger) listFilesInDirectory:(NSString *)inPath
                    outputTo:(NSString *)outFile
                         totalSize:(NSInteger*)pTotSize
{
    NSString *entry = @"";
    NSString *documentsDir = @"";
    NSDirectoryEnumerator *enumerator;
    BOOL isDirectory;
    NSInteger fileSize = 0;
    NSInteger totFiles = 0, totSize = 0;
    BOOL rtn;
    BOOL first = TRUE;
    BOOL all = FALSE;
    
    // Create file manager
    NSFileManager *fileMgr = NSFileManager.defaultManager;
    
    // Path to documents directory
    documentsDir = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];

    if (inPath == nil)
        inPath = documentsDir;
    if ([inPath isEqualToString:@"HOME"])
        inPath = NSHomeDirectory();
    if ([inPath isEqualToString:@"ALL"])
    {
        inPath = NSHomeDirectory();
        all = TRUE;
    }
    if ([inPath isEqualToString:@"SHARED"])
        inPath = CRAPI.sharedInstance.sharedFilePath;
    // Change to Documents directory
    
    
    // Get each entry (file or folder)
    NSString * outLine = @"";
Next:
    [fileMgr changeCurrentDirectoryPath:inPath];
    // Enumerator for docs directory
    enumerator = [fileMgr enumeratorAtPath:inPath];
    while ((entry = [enumerator nextObject]) != nil)
    {
        // File or directory
        if ([fileMgr fileExistsAtPath:entry isDirectory:&isDirectory] && isDirectory)
            ;//NSLog (@"Directory - %@", entry);
        else
        {
            totFiles++;
            fileSize = (NSInteger)[NSFileManager.defaultManager attributesOfItemAtPath:entry
                                                                                 error:nil].fileSize;
            
            totSize += fileSize;
            outLine = [NSString stringWithFormat:@"%s\t%ld", entry.UTF8String, (long)fileSize];
            
            if (first)
                rtn = [[NSString stringWithUTF8String:outLine.UTF8String] writeToFile:outFile
                                                                         atomically:YES
                                                                           encoding:NSUTF8StringEncoding
                                                                              error:nil];
            else
            {
                [CRAPI.sharedInstance appendString:outLine
                                            toFile:outFile];
            }
            
            first = FALSE;
        }
    }
    
    if (all)
    {
        inPath = CRAPI.sharedInstance.sharedFilePath;
        all = FALSE;
        [CRAPI.sharedInstance appendString:@"Shared Directory:" toFile:outFile];
        goto Next;
    }

    int outFileSize = (int)[NSFileManager.defaultManager attributesOfItemAtPath:outFile
                                                                          error:nil].fileSize;
    *pTotSize = totSize;
    return totFiles;
}

@end