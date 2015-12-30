//  NVColorSet.h
//  CCodeLibrary

@import UIKit;
#import "NVColor.h"

typedef NS_ENUM(NSInteger, NVColorType)
{
    NVColorTypeAll,
    NVColorTypeLight,
    NVColorTypeMedium,
    NVColorTypeDark,
    NVColorTypePastel,
    NVColorTypeBold,
    NVColorTypeNeutral,
    NVColorTypeWarm,
    NVColorTypeCool,
};

@interface NVColorSet : NSObject

+ (NSArray *)randomColorArrayOfType:(NVColorType)type
                      numComponents:(NSUInteger)numComponents;

@end