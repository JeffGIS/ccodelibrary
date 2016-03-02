//  UIDevice+Storage.m
//  CCodeLibrary

#import "UIDevice+Storage.h"

@implementation UIDevice (Storage)

+ (uint64_t)availableStorageSpace
{
    NSError *error = nil;
    uint64_t freeSpace = 0;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    
    NSDictionary *dictionary = [NSFileManager.defaultManager attributesOfFileSystemForPath:paths.lastObject
                                                                                     error:&error];
    
    if (dictionary)
        freeSpace = [[dictionary objectForKey: NSFileSystemFreeSize] unsignedLongLongValue];
    
    else
        NSLog(@"Error Obtaining File System Info (Domain:%@, Code:%ld)", error.domain, (long)error.code);
    
    return freeSpace;
}

@end