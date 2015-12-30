//  NVColorSet.h
//  CCodeLibrary

@import UIKit;
#import "NVColor.h"

typedef NS_ENUM(NSInteger, NVColorType)
{
    NVColorTypeDefault,
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

typedef NS_ENUM(NSInteger, NVColorOption)
{
    NVColorOptionDefault,
    NVColorOptionReds,
    NVColorOptionGreens,
    NVColorOptionBlues,
    NVColorOptionRandom,
    NVColorOptionCustom,
};

@interface NVColorSet : NSObject

+ (NSArray *)randomColorArrayOfType:(NVColorType)type
                      numComponents:(NSUInteger)numComponents;

+ (NSArray *)colorOptions;
+ (NSArray *)randomColorPaletteOptions;

@end