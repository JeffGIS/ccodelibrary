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
        _circleRadius = 30;
        
        //initialize data array
        _data = NSMutableArray.array;
    }
    
    return self;
}

@end

@interface ChartsBitmap ()

@property int chartAreaWidth, chartAreaHeight;

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
        _dpi = 300;
        _docMargin = (_dpi / 2);
        _chartWidth = ((_dpi * 11) - (_docMargin * 2));
        _chartHeight = ((_dpi * 8.5) - (_docMargin * 2));
        _xMargin = (_dpi / 4);
        _topMargin = (_dpi / 4);
        _bottomMargin =  (_xMargin * 3);
        
        //reference line every 1/2 inch
        _chartAreaWidth = (_chartWidth - (_xMargin * 2));
        _chartAreaHeight = (_chartHeight - _topMargin - _bottomMargin);
        _numHLines = (_chartAreaHeight / (_dpi / 2));
        _numVLines = (_chartAreaWidth / (_dpi / 2));
        
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
        _titleFont = [UIFont boldSystemFontOfSize:76.0];
        
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
        
        _chartAreaWidth = (_chartWidth - (_xMargin * 2));
        _chartAreaHeight = (_chartHeight - _topMargin - _bottomMargin);
        
        rect = CGRectMake(_xMargin, _topMargin, _chartAreaWidth, _chartAreaHeight);
        
        CGContextSetFillColorWithColor(context, _chartBackgroundColor.CGColor);
        CGContextFillRect(context, rect);
        
        int hLineSpacing = (int)round(_chartAreaHeight / (CGFloat)_numHLines);
        int vLineSpacing = (int)round(_chartAreaWidth / (CGFloat)_numVLines);
        int hLineOffset = (hLineSpacing / 2);
        
        CGContextSetStrokeColorWithColor(context, _gridLineColor.CGColor);
        CGContextSetLineWidth(context, _gridLineWidth);
        
        for (int i = 0; i < _numHLines; i++)
        {
            CGFloat spacing = (((i + 1) * hLineSpacing) + _topMargin - hLineOffset);
            CGContextMoveToPoint(context, _xMargin, spacing);
            CGContextAddLineToPoint(context, (_chartWidth - _xMargin), spacing);
            CGContextStrokePath(context);
        }
        
        for (int i = 0; i < _numVLines; i++)
        {
            CGFloat spacing = (((i + 1) * vLineSpacing) + _xMargin - hLineOffset);
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
                                         (_topMargin + _chartAreaHeight - dataSet.data[0].y));
                    
                    for (int i = 1; i < dataSet.data.count; i++)
                    {
                        CGContextAddLineToPoint(context, (_xMargin + dataSet.data[i].x),
                                                (_topMargin + _chartAreaHeight - dataSet.data[i].y));
                    }
                    
                    CGContextStrokePath(context);
                    
                    CGContextSetFillColorWithColor(context, dataSet.circleFillColor.CGColor);
                    CGContextSetStrokeColorWithColor(context, dataSet.color.CGColor);
                    CGContextSetLineWidth(context, dataSet.circleBorderWidth);
                    
                    for (int i = 0; i < dataSet.data.count; i++)
                    {
                        CGPoint point = CGPointMake((_xMargin + dataSet.data[i].x),
                                                    (_topMargin + _chartAreaHeight - dataSet.data[i].y));
                        
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
                                          (_topMargin + _chartAreaHeight - point.y),
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
                          (_chartAreaWidth + _borderWidth), (_chartAreaHeight + _borderWidth));
        
        CGContextSetStrokeColorWithColor(context, _borderColor.CGColor);
        CGContextSetLineWidth(context, _borderWidth);
        CGContextAddRect(context, rect);
        CGContextStrokePath(context);
        
        CGContextScaleCTM(context, 1.0, -1.0);
        
        CTFontRef fontRef = CTFontCreateWithName((CFStringRef)@"CourierNewPS-BoldMT", 36.0, NULL);
        CGRect fontRect = CTFontGetBoundingBox(fontRef);
        int gridFontHeight = (int)round(fontRect.size.height);
        CGColorRef textColor = UIColor.blackColor.CGColor;
        
        NSMutableParagraphStyle *style = NSParagraphStyle.defaultParagraphStyle.mutableCopy;
        style.alignment = NSTextAlignmentCenter;
        
        NSDictionary *textAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                        (__bridge id)fontRef, kCTFontAttributeName,
                                        style, kCTParagraphStyleAttributeName,
                                        textColor, kCTForegroundColorAttributeName, nil];
        
        NSString *value = nil;
        NSAttributedString *text = nil;
        CGPathRef path = NULL;
        CTFramesetterRef framesetter = NULL;
        CTFrameRef frame = NULL;
        
        for (int i = 0; i < _numVLines; i++)
        {
            value = [NSString stringWithFormat:@"%i", (150 * i)];
            
            text = [[NSAttributedString alloc] initWithString:value
                                                   attributes:textAttributes];
            
            rect = CGRectMake((_xMargin + (i * hLineSpacing)),
                              (-_chartHeight + (gridFontHeight * 2)),
                              hLineSpacing, gridFontHeight);
            
            path = CGPathCreateWithRect(rect, NULL);
            framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)text);
            frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, text.length), path, NULL);
            
            CTFrameDraw(frame, context);
            
            CFRelease(path);
            CFRelease(framesetter);
            CFRelease(frame);
        }

        CFRelease(fontRef);
        
        if (_title && _title.length)
        {
            fontRef = (__bridge CTFontRef)_titleFont;
            int titleFontHeight = (int)round(CTFontGetBoundingBox(fontRef).size.height);
            int offset = ((_bottomMargin - titleFontHeight) / 2);
            textColor = _titleColor.CGColor;
            
            textAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                              (__bridge id)fontRef, kCTFontAttributeName,
                              style, kCTParagraphStyleAttributeName,
                              textColor, kCTForegroundColorAttributeName, nil];
            
            text = [[NSAttributedString alloc] initWithString:_title
                                                   attributes:textAttributes];
            
            rect = CGRectMake(_xMargin, (offset - _chartHeight - (gridFontHeight / 2)),
                              _chartAreaWidth, titleFontHeight);
            
            path = CGPathCreateWithRect(rect, NULL);
            framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)text);
            frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, text.length), path, NULL);
            
            CTFrameDraw(frame, context);
            
            CFRelease(path);
            CFRelease(framesetter);
            CFRelease(frame);
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
