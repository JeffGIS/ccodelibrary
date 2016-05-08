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
    
    return (freeSpace - 209715200);//correction for storage reserved by the system
}

+ (uint64_t)totalStorageSpace
{
    NSError *error = nil;
    uint64_t totalSpace = 0;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    
    NSDictionary *dictionary = [NSFileManager.defaultManager attributesOfFileSystemForPath:paths.lastObject
                                                                                     error:&error];
    
    if (dictionary)
        totalSpace = [[dictionary objectForKey: NSFileSystemSize] unsignedLongLongValue];
    
    else
        NSLog(@"Error Obtaining File System Info (Domain:%@, Code:%ld)", error.domain, (long)error.code);
    
    return totalSpace;
}

+ (int)pctBatteryRemaining
{
    UIDevice *device = UIDevice.currentDevice;
    device.batteryMonitoringEnabled = YES;
    
    return (int)roundf(device.batteryLevel * 100);
}

@end