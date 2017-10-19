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
        _xMargin = 75;
        _topMargin = 75;
        _bottomMargin = 225;
        
        //reference line every 1/2 inch
        _numHorLines = 12;
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
        
        int chartAreaWidth = (_chartWidth - (_xMargin * 2));
        int chartAreaHeight = (_chartHeight - _topMargin - _bottomMargin);
        
        CGFloat hLineSpacing = (chartAreaHeight / (CGFloat)(_numHorLines + 1));
        CGFloat vLineSpacing = (chartAreaWidth / (CGFloat)(_numVertLines + 1));
        
        CGContextSetStrokeColorWithColor(context, _lineColor.CGColor);
        CGContextSetLineWidth(context, _lineWidth);
        
        for (int i = 0; i < _numHorLines; i++)
        {
            CGFloat spacing = (((i + 1) * hLineSpacing) + _topMargin);
            CGContextMoveToPoint(context, _xMargin, spacing);
            CGContextAddLineToPoint(context, (_chartWidth - _xMargin), spacing);
            CGContextStrokePath(context);
        }
        
        for (int i = 0; i < _numVertLines; i++)
        {
            CGFloat spacing = (((i + 1) * vLineSpacing) + _xMargin);
            CGContextMoveToPoint(context, spacing, _topMargin);
            CGContextAddLineToPoint(context, spacing, (_chartHeight - _bottomMargin));
            CGContextStrokePath(context);
        }
        
        rect = CGRectMake(_xMargin, _topMargin, chartAreaWidth, chartAreaHeight);
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
