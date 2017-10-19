//  ChartsBitmap.m
//  CCodeLibrary

#import "ChartsBitmap.h"
@import CoreText;
#import "PointInArea.h"
#import "UserDefaults.h"

@interface ChartsBitmap ()

@end

@implementation ChartsBitmap

- (id)init
{
    self = [super init];
    
    if (self)
    {
        //defaults to landscape
        _chartOrientation = ChartsBitmapOrientationLandscape;
        
        //300 DPI, 11 X 8.5 inch page, 1/2 inch margins
        _chartWidth = 3150;
        _chartHeight = 2250;
        _margin = 150;
        
        //reference line every 1/2 inch
        _numHorLines = 13;
        _numVertLines = 19;
        
        //default colors
        _lineColor = UIColor.lightGrayColor;
        _barColor = UIColor.greenColor;
        _borderColor = UIColor.blackColor;
        _backgroundColor = UIColor.whiteColor;
        
        //default line widths
        _borderWidth = 10;
        _lineWidth = 4.0;
        
        //default ouput file path
        _outputFile = [NSString stringWithFormat:@"%@/TestChart.bmp",
                       UserDefaults.defaults.localFilePath];
    }
    
    return self;
}

- (CGSize)createChartBitmap
{
    if (_outputFile && _outputFile.length)
    {
        void *bmData = NULL;
        
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
        CGContextRef context = createBitmapContext(_chartWidth, _chartHeight, colorSpace, &bmData);
        CGContextSetAllowsAntialiasing(context, YES);
        CGContextSetShouldAntialias(context, YES);
        CGRect rect = CGRectMake(0.0, 0.0, _chartWidth, _chartHeight);
        
        CGContextSetFillColorWithColor(context, _backgroundColor.CGColor);
        CGContextFillRect(context, rect);
        
        int chartAreaWidth = (_chartWidth - (_margin * 2));
        int chartAreaHeight = (_chartHeight - (_margin * 2));
        
        CGFloat hLineSpacing = (chartAreaHeight / (CGFloat)_numHorLines);
        CGFloat vLineSpacing = (chartAreaWidth / (CGFloat)_numVertLines);
        
        CGContextSetStrokeColorWithColor(context, _lineColor.CGColor);
        CGContextSetLineWidth(context, _lineWidth);
        
        for (int i = 0; i < _numHorLines; i++)
        {
            CGFloat spacing = ((i + 1) * hLineSpacing);
            CGContextMoveToPoint(context, _margin, spacing);
            CGContextAddLineToPoint(context, (_chartWidth - _margin), spacing);
            CGContextStrokePath(context);
        }
        
        for (int i = 1; i < _numVertLines; i++)
        {
            CGFloat spacing = ((i + 1) * vLineSpacing);
            CGContextMoveToPoint(context, spacing, _margin);
            CGContextAddLineToPoint(context, spacing, (_chartHeight - _margin));
            CGContextStrokePath(context);
        }
        
        rect = CGRectMake(_margin, _margin, chartAreaWidth, chartAreaHeight);
        CGContextSetStrokeColorWithColor(context, _borderColor.CGColor);
        CGContextSetLineWidth(context, _borderWidth);
        CGContextAddRect(context, rect);
        CGContextStrokePath(context);
        
        WriteBitmapDataToFile((LPSTR)_outputFile.UTF8String, _chartWidth, _chartHeight, colorSpace, bmData);
        UIImage *image = [UIImage imageWithContentsOfFile:_outputFile];
        
        CGColorSpaceRelease(colorSpace);
        CGContextRelease(context);
        
        return CGSizeMake(_chartWidth, _chartHeight);
    }
    
    else return CGSizeZero;
}

@end
