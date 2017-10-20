//  ChartsBitmap.m
//  CCodeLibrary

#import "ChartsBitmap.h"
@import CoreText;
#import "PointInArea.h"
#import "UserDefaults.h"

@implementation ChartsBitmapDataSet

- (id)init
{
    self = [super init];
    
    if (self)
    {
        //defaults to line chart
        _type = ChartsBitmapDataTypeLine;
        
        //default colors
        _color = UIColor.blueColor;
        _circleFillColor = UIColor.whiteColor;
        
        //default widths
        _barWidth = 60;
        _lineWidth = 10;
        _circleBorderWidth = 10;
        _circleRadius = 40;
        
        //initialize data array
        _data = NSMutableArray.array;
    }
    
    return self;
}

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
        _numHLines = 12;
        _numVLines = 19;
        
        //default colors
        _gridLineColor = UIColor.lightGrayColor;
        _borderColor = UIColor.blackColor;
        _backgroundColor = [UIColor colorWithWhite:0.95 alpha:1.0];
        _chartBackgroundColor = UIColor.whiteColor;
        _titleColor = UIColor.blackColor;
        
        //default widths
        _borderWidth = 8;
        _gridLineWidth = 4;
        
        //default ouput file path
        _outputFile = [NSString stringWithFormat:@"%@/TestChart.bmp",
                       UserDefaults.defaults.localFilePath];
        
        //default fonts
        _titleFont = [UIFont boldSystemFontOfSize:84.0];
        
        //initialize data sets array
        _dataSets = NSMutableArray.array;
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
        CGRect rect = CGRectZero;
        
        int chartAreaWidth = (_chartWidth - (_xMargin * 2));
        int chartAreaHeight = (_chartHeight - _topMargin - _bottomMargin);
        
        rect = CGRectMake(_xMargin, _topMargin, chartAreaWidth, chartAreaHeight);
        
        CGContextSetFillColorWithColor(context, _chartBackgroundColor.CGColor);
        CGContextFillRect(context, rect);
        
        CGFloat hLineSpacing = (chartAreaHeight / (CGFloat)(_numHLines + 1));
        CGFloat vLineSpacing = (chartAreaWidth / (CGFloat)(_numVLines + 1));
        
        CGContextSetStrokeColorWithColor(context, _gridLineColor.CGColor);
        CGContextSetLineWidth(context, _gridLineWidth);
        
        for (int i = 0; i < _numHLines; i++)
        {
            CGFloat spacing = (((i + 1) * hLineSpacing) + _topMargin);
            CGContextMoveToPoint(context, _xMargin, spacing);
            CGContextAddLineToPoint(context, (_chartWidth - _xMargin), spacing);
            CGContextStrokePath(context);
        }
        
        for (int i = 0; i < _numVLines; i++)
        {
            CGFloat spacing = (((i + 1) * vLineSpacing) + _xMargin);
            CGContextMoveToPoint(context, spacing, _topMargin);
            CGContextAddLineToPoint(context, spacing, (_chartHeight - _bottomMargin));
            CGContextStrokePath(context);
        }
        
        for (ChartsBitmapDataSet *dataSet in _dataSets)
        {
            switch (dataSet.type)
            {
                case ChartsBitmapDataTypeLine:
                    CGContextSetStrokeColorWithColor(context, dataSet.color.CGColor);
                    CGContextSetLineWidth(context, dataSet.lineWidth);
                    
                    CGContextMoveToPoint(context, (_xMargin + dataSet.data[0].x),
                                         (_topMargin + chartAreaHeight - dataSet.data[0].y));
                    
                    for (int i = 1; i < dataSet.data.count; i++)
                    {
                        CGContextAddLineToPoint(context, (_xMargin + dataSet.data[i].x),
                                                (_topMargin + chartAreaHeight - dataSet.data[i].y));
                    }
                    
                    CGContextStrokePath(context);
                    
                    CGContextSetFillColorWithColor(context, dataSet.circleFillColor.CGColor);
                    CGContextSetStrokeColorWithColor(context, dataSet.color.CGColor);
                    CGContextSetLineWidth(context, dataSet.circleBorderWidth);
                    
                    for (int i = 0; i < dataSet.data.count; i++)
                    {
                        CGPoint point = CGPointMake((_xMargin + dataSet.data[i].x),
                                                    (_topMargin + chartAreaHeight - dataSet.data[i].y));
                        
                        rect = CGRectMake((point.x - (dataSet.circleRadius / 2)),
                                          (point.y - (dataSet.circleRadius / 2)),
                                          dataSet.circleRadius, dataSet.circleRadius);
                        
                        CGContextFillEllipseInRect(context, rect);
                        CGContextStrokeEllipseInRect(context, rect);
                    }
                    
                    break;
                case ChartsBitmapDataTypeBar:
                    CGContextSetFillColorWithColor(context, dataSet.color.CGColor);
                    
                    for (DPoint *point in dataSet.data)
                    {
                        rect = CGRectMake((_xMargin + point.x - (dataSet.barWidth / 2)),
                                          (_topMargin + chartAreaHeight - point.y),
                                          dataSet.barWidth, point.y);
                        
                        CGContextFillRect(context, rect);
                    }
                    break;
                default:break;
            }
        }
        
        CGContextSetFillColorWithColor(context, _backgroundColor.CGColor);
        rect = CGRectMake(0.0, 0.0, _chartWidth, _topMargin);
        CGContextFillRect(context, rect);
        rect = CGRectMake(0.0, 0.0, _xMargin, _chartHeight);
        CGContextFillRect(context, rect);
        rect = CGRectMake(0.0, (_chartHeight - _bottomMargin), _chartWidth, _bottomMargin);
        CGContextFillRect(context, rect);
        rect = CGRectMake((_chartWidth - _xMargin), 0.0, _xMargin, _chartHeight);
        CGContextFillRect(context, rect);
        
        rect = CGRectMake((_xMargin - (_borderWidth / 2)), (_topMargin - (_borderWidth / 2)),
                          (chartAreaWidth + _borderWidth), (chartAreaHeight + _borderWidth));
        
        CGContextSetStrokeColorWithColor(context, _borderColor.CGColor);
        CGContextSetLineWidth(context, _borderWidth);
        CGContextAddRect(context, rect);
        CGContextStrokePath(context);
        
        if (_title && _title.length)
        {
            CTFontRef fontRef = (__bridge CTFontRef)_titleFont;
            int fontHeight = (int)round(CTFontGetBoundingBox(fontRef).size.height);
            int offset = ((_bottomMargin - fontHeight) / 2);
            CGColorRef textColor = _titleColor.CGColor;
            
            CGContextTranslateCTM(context, 0.0, fontHeight);
            CGContextScaleCTM(context, 1.0, -1.0);
            
            NSMutableParagraphStyle *style = NSParagraphStyle.defaultParagraphStyle.mutableCopy;
            style.alignment = NSTextAlignmentCenter;
            
            NSDictionary *textAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                            (__bridge id)fontRef, kCTFontAttributeName,
                                            style, kCTParagraphStyleAttributeName,
                                            textColor, kCTForegroundColorAttributeName, nil];
            
            NSAttributedString *text = [[NSAttributedString alloc] initWithString:_title
                                                                       attributes:textAttributes];
            
            rect = CGRectMake(_xMargin, (-_chartHeight + _bottomMargin - offset),
                              chartAreaWidth, fontHeight);
            
            CGPathRef path = CGPathCreateWithRect(rect, NULL);
            CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)text);
            CTFrameRef frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, text.length), path, NULL);
            
            CTFrameDraw(frame, context);
            
            CFRelease(path);
            CFRelease(framesetter);
            CFRelease(frame);
            CFRelease(fontRef);
        }
        
        WriteBitmapDataToFile((LPSTR)_outputFile.UTF8String, _chartWidth, _chartHeight, colorSpace, bmData);
        UIImage *image = [UIImage imageWithContentsOfFile:_outputFile];
        
        CGColorSpaceRelease(colorSpace);
        CGContextRelease(context);
        
        return CGSizeMake(_chartWidth, _chartHeight);
    }
    
    else return CGSizeZero;
}

@end
