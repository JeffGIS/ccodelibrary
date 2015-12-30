//  NVColorSet.m
//  CCodeLibrary

#import "NVColorSet.h"

@implementation NVColorSet

+ (NSArray *)randomColorArrayOfType:(NVColorType)type
                      numComponents:(NSUInteger)numComponents
{
    NSArray *colorArray = NSArray.array;
    
    switch (type)
    {
        case NVColorTypeAll:
            colorArray = NVColor.allColors;
            break;
            
        case NVColorTypeLight:
            colorArray = NVColor.lightColors;
            break;
            
        case NVColorTypeMedium:
            colorArray = NVColor.mediumColors;
            break;
            
        case NVColorTypeDark:
            colorArray = NVColor.darkColors;
            break;
            
        case NVColorTypePastel:
            colorArray = NVColor.pastelColors;
            break;
            
        case NVColorTypeBold:
            colorArray = NVColor.boldColors;
            break;
            
        case NVColorTypeNeutral:
            colorArray = NVColor.neutralColors;
            break;
            
        case NVColorTypeWarm:
            colorArray = NVColor.warmColors;
            break;
            
        case NVColorTypeCool:
            colorArray = NVColor.coolColors;
            break;
    }
    
    NSUInteger randomIndex = 0;
    NVColor *randomColor = nil;
    NSMutableArray *randomColorArray = NSMutableArray.array;
    
    for (int i = 0; i < numComponents; i++)
    {
        randomIndex = arc4random() % colorArray.count;
        randomColor = (NVColor *)colorArray[randomIndex];
        
        while ([randomColorArray containsObject:randomColor])
        {
            randomIndex = arc4random() % colorArray.count;
            randomColor = (NVColor *)colorArray[randomIndex];
        }
        
        [randomColorArray addObject:colorArray[randomIndex]];
    }
    
    return randomColorArray.copy;
}

@end