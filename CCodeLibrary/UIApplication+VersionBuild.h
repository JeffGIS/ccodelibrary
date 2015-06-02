//  UIApplication+VersionBuild.h
//  CCodeLibrary

#import <UIKit/UIKit.h>

@interface UIApplication (VersionBuild)

+ (NSString *)appVersion;
+ (NSString *)appBuild;
+ (NSString *)appVersionBuild;

@end