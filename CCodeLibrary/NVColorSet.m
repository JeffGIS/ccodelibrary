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
            
        default:
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

+ (NSArray *)colorOptions
{
    return @[@"Cancel", @"Reds", @"Greens", @"Blues", @"Random", @"Custom"];
}

+ (NSArray *)randomColorPaletteOptions
{
    return @[@"Cancel", @"All", @"Light", @"Medium", @"Dark",
             @"Pastel", @"Bold", @"Neutral", @"Warm", @"Cool"];
}

+ (NSArray *)bluesArrayWithNumComponents:(NSUInteger)numComponents
{
    NSMutableArray *colorArray = NSMutableArray.array;
    CGFloat blue = 153.0, red = 0.0, green = 0.0;
    NSUInteger partialCount = (numComponents / 4);
    NSUInteger remainder = (numComponents - partialCount);
    CGFloat incBlue = ((255.0 - blue) / partialCount);
    CGFloat incRed = (204.0 / remainder);
    CGFloat incGreen = (229.0 / remainder);
    
    for (int i = 0; i < partialCount; i++)
    {
        UIColor *color = [UIColor colorWithRed:(red / 255.0)
                                         green:(green / 255.0)
                                          blue:(blue / 255.0)
                                         alpha:1.0];
        
        blue += incBlue;
        
        [colorArray addObject:color];
    }
    
    for (int i = 0; i < remainder; i++)
    {
        UIColor *color = [UIColor colorWithRed:(red / 255.0)
                                         green:(green / 255.0)
                                          blue:(blue / 255.0)
                                         alpha:1.0];
        
        red += incRed;
        green += incGreen;
        
        [colorArray addObject:color];
    }
    
    return colorArray.copy;
}

+ (NSArray *)redsArrayWithNumComponents:(NSUInteger)numComponents
{
    NSMutableArray *colorArray = NSMutableArray.array;
    CGFloat red = 153.0, blue = 0.0, green = 0.0;
    NSUInteger partialCount = (numComponents / 3);
    NSUInteger remainder = (numComponents - partialCount);
    CGFloat incRed = ((255.0 - red) / partialCount);
    CGFloat incGreen = (204.0 / remainder);
    CGFloat incBlue = (229.0 / remainder);
    
    for (int i = 0; i < partialCount; i++)
    {
        UIColor *color = [UIColor colorWithRed:(red / 255.0)
                                         green:(green / 255.0)
                                          blue:(blue / 255.0)
                                         alpha:1.0];
        
        red += incRed;
        
        [colorArray addObject:color];
    }
    
    for (int i = 0; i < remainder; i++)
    {
        UIColor *color = [UIColor colorWithRed:(red / 255.0)
                                         green:(green / 255.0)
                                          blue:(blue / 255.0)
                                         alpha:1.0];
        
        blue += incBlue;
        green += incGreen;
        
        [colorArray addObject:color];
    }
    
    return colorArray.copy;
}

+ (NSArray *)greensArrayWithNumComponents:(NSUInteger)numComponents
{
    NSMutableArray *colorArray = NSMutableArray.array;
    CGFloat green = 102.0, red = 0.0, blue = 0.0;
    NSUInteger partialCount = (numComponents / 1.5);
    NSUInteger remainder = (numComponents - partialCount);
    CGFloat incGreen = ((255.0 - green) / partialCount);
    CGFloat incBlue = (204.0 / remainder);
    CGFloat incRed = (229.0 / remainder);
    
    for (int i = 0; i < partialCount; i++)
    {
        UIColor *color = [UIColor colorWithRed:(red / 255.0)
                                         green:(green / 255.0)
                                          blue:(blue / 255.0)
                                         alpha:1.0];
        
        green += incGreen;
        
        [colorArray addObject:color];
    }
    
    for (int i = 0; i < remainder; i++)
    {
        UIColor *color = [UIColor colorWithRed:(red / 255.0)
                                         green:(green / 255.0)
                                          blue:(blue / 255.0)
                                         alpha:1.0];
        
        red += incRed;
        blue += incBlue;
        
        [colorArray addObject:color];
    }
    
    return colorArray.copy;
}

@end