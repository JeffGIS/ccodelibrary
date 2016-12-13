//  UIDevice+Storage.h
//  CCodeLibrary

@import UIKit;

@interface UIDevice (Storage)

+ (uint64_t)availableStorageSpace;
+ (uint64_t)totalStorageSpace;
+ (int)pctBatteryRemaining;
+ (void)reportMemoryWarning;

@end
