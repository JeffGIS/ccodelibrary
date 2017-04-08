//  FileLister.m
//  CCodeLibrary

#import "FileLister.h"
#import "CRAPI.h"

@implementation FileLister

+ (NSInteger)listFilesInDirectory:(NSString *)inPath
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
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.timeStyle = NSDateFormatterShortStyle;
    dateFormatter.dateStyle = NSDateFormatterShortStyle;
    NSFileManager *fileMgr = NSFileManager.defaultManager;
    documentsDir = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];

    if (inPath == nil)
        inPath = documentsDir;
    else if ([inPath isEqualToString:@"HOME"])
        inPath = NSHomeDirectory();
    else if ([inPath isEqualToString:@"ALL"])
    {
        inPath = NSHomeDirectory();
        all = TRUE;
    }
    else if ([inPath isEqualToString:@"SHARED"])
        inPath = CRAPI.sharedInstance.sharedFilePath;
    
    NSString *outLine = @"";
Next:
    [fileMgr changeCurrentDirectoryPath:inPath];
    enumerator = [fileMgr enumeratorAtPath:inPath];
    while ((entry = [enumerator nextObject]) != nil)
    {
        if (![fileMgr fileExistsAtPath:entry isDirectory:&isDirectory] || !isDirectory)
        {
            totFiles++;
            fileSize = (NSInteger)[NSFileManager.defaultManager attributesOfItemAtPath:entry error:nil].fileSize;
            NSDate *modDate = (NSDate *)[fileMgr attributesOfItemAtPath:entry error:nil].fileModificationDate;
            NSString *mod = [dateFormatter stringFromDate:modDate];
            totSize += fileSize;
            outLine = [NSString stringWithFormat:@"%s\t%ld\t%@", entry.UTF8String, (long)fileSize,mod];
            
            if (first)
                rtn = [[NSString stringWithUTF8String:outLine.UTF8String] writeToFile:outFile
                                                                         atomically:YES
                                                                           encoding:NSUTF8StringEncoding
                                                                              error:nil];
            else
                [CRAPI.sharedInstance appendString:outLine toFile:outFile];
            
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
    
    *pTotSize = totSize;
    return totFiles;
}

@end
