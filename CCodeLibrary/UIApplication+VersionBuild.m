//  UIApplication+VersionBuild.m
//  CCodeLibrary

#import "UIApplication+VersionBuild.h"

@implementation UIApplication (VersionBuild)

+ (NSString *)appVersion
{
    return [NSBundle.mainBundle objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
}

+ (NSString *)appBuild
{
    return [NSBundle.mainBundle objectForInfoDictionaryKey:(NSString *)kCFBundleVersionKey];
}

+ (NSString *)appVersionBuild
{
    NSString *versionBuild = [NSString stringWithFormat: @"%@ (%@)",
                              [self appVersion], [self appBuild]];
    
    return versionBuild;
}

@end