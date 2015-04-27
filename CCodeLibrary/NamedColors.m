//  NamedColors.m
//  CCodeLibrary

#import "NamedColors.h"
#import "colorsByName.h"

@implementation NamedColors

/*double ColorDist (COLORREF C1, COLORREF C2)
{
    double dist;
    
    
    dist = pow (pow ((double)GetRValue(C1)-(double)GetRValue(C2),2) +
                pow ((double)GetGValue(C1)-(double)GetGValue(C2),2) +
                pow ((double)GetBValue(C1)-(double)GetBValue(C2),2)
                ,0.5e0);
    return dist;
}
*/

-(UIColor*) colorFromIndex:(int)index
{
    UIColor * color=nil;
    if (index >= 0 && index < NUMCOLORNAMES)
    {
        CGFloat red = (CGFloat)R[index]/255.0;
        CGFloat green = (CGFloat)G[index]/255.0;
        CGFloat blue = (CGFloat)B[index]/255.0;
        color = [UIColor colorWithRed:red
                                green:green
                                 blue:blue
                                alpha:1.0];
    }
    return color;
}
-(NSString*) colorNameFromIndex:(int)index
{
    NSString * name=@"";
    if (index >= 0 && index < NUMCOLORNAMES)
    {
        name = [NSString stringWithUTF8String:colorName[index]];
    }
    return name;
}
-(int) getNearestNamedColorIndex:(UIColor*)color
{
    int index=0;
    CGFloat r,g,b,a;
    double minDist = DBL_MAX;
    double d;
    
    [color getRed:&r green:&g blue:&b alpha:&a];
    r *= 255;
    g *= 255;
    b *= 255;
    
    for (int i=0;i<NUMCOLORNAMES;i++)
    {
        d = pow (pow(R[i]-r,2)+
                 pow(G[i]-g,2)+
                 pow(B[i]-b,2),0.5);
        if (d < minDist)
        {
            minDist = d;
            index = i;
        }
    }
    return index;
}
@end
