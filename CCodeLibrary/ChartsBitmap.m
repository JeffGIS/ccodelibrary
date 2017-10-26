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
        _circleFillColor = UIColor.whiteColor;
        
        //default widths
        _barWidth = 60;
        _lineWidth = 8;
        _circleBorderWidth = _lineWidth;
        _circleRadius = (_circleBorderWidth * 2.5);
        
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
        //300 DPI, 11 X 8.5 inch page, 1/2 inch margins
        _dpi = 300;
        _chartWidth = (_dpi * 10);
        _chartHeight = (_dpi * 7.5);
        _leftMargin = (_dpi / 2.5);
        _rightMargin = ((_dpi / 2) - _leftMargin);
        _topMargin = (_dpi / 3);
        _bottomMargin =  (_dpi - _topMargin);
        
        //reference line every 1/2 inch
        _chartAreaWidth = (_chartWidth - _leftMargin - _rightMargin);
        _chartAreaHeight = (_chartHeight - _topMargin - _bottomMargin);
        _numHLines = (_chartAreaHeight / (_dpi / 2));
        _numVLines = (_chartAreaWidth / (_dpi / 2));
        
        //default colors
        _gridLineColor = UIColor.lightGrayColor;
        _borderColor = UIColor.blackColor;
        _backgroundColor = [UIColor colorWithWhite:0.95 alpha:1.0];
        _chartBackgroundColor = UIColor.whiteColor;
        _titleColor = UIColor.blackColor;
        
        _defaultColors = @[UIColor.blueColor, UIColor.redColor, UIColor.greenColor, UIColor.orangeColor,
                           UIColor.purpleColor, UIColor.cyanColor, UIColor.brownColor, UIColor.magentaColor];
        
        //default widths
        _borderWidth = 8;
        _gridLineWidth = 3;
        _offset = 4;
        
        //default ouput file path
        _outputFile = [NSString stringWithFormat:@"%@/test.bmp", NSTemporaryDirectory()];
        
        //default fonts
        _titleFont = [UIFont boldSystemFontOfSize:76.0];
        _gridFontSize = 36;
        
        //initialize data sets array
        _dataSets = NSMutableArray.array;
        
        //default settings
        _useOffset = YES;
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
        
        double minX = DBL_MAX, maxX = 0, minY = 0, maxY = 0;
        
        for (ChartsBitmapDataSet *dataSet in _dataSets)
        {
            for (DPoint *point in dataSet.data)
            {
                minX = MIN(minX, point.x);
                maxX = MAX(maxX, point.x);
                minY = MIN(minY, point.y);
                maxY = MAX(maxY, point.y);
            }
        }
        
        double xRange = (maxX - minX);
        double yRange = (maxY - minY);
        double xFactor = 1, yFactor = 1;
        
        switch (_format)
        {
            case ChartsBitmapDataFormatDayOfWeek:
                _numVLines = 7;
                break;
            case ChartsBitmapDataFormatHourOfDay:
                _numVLines = 13;
                break;
            case ChartsBitmapDataFormatYears:
                _numVLines = (xRange + 1);
                break;
            default:
                break;
        }
        
        _chartAreaWidth = (_chartWidth - _leftMargin - _rightMargin);
        _chartAreaHeight = (_chartHeight - _topMargin - _bottomMargin);
        
        int hLineSpacing = (int)round(_chartAreaHeight / (CGFloat)_numHLines);
        int vLineSpacing = (int)round(_chartAreaWidth / (CGFloat)_numVLines);
        int hLineOffset = (hLineSpacing / 2);
        int vLineOffset = (vLineSpacing / 2);
        
        if (_format == ChartsBitmapDataFormatHourOfDay)
            xRange = 24;
        
        if (xRange > 0)
            xFactor = ((_chartAreaWidth - vLineSpacing) / xRange);
        
        if (yRange > 0)
            yFactor = ((_chartAreaHeight - hLineSpacing) / yRange);

        rect = CGRectMake(_leftMargin, _topMargin, _chartAreaWidth, _chartAreaHeight);
        
        CGContextSetFillColorWithColor(context, _chartBackgroundColor.CGColor);
        CGContextFillRect(context, rect);
        
        CGContextSetStrokeColorWithColor(context, _gridLineColor.CGColor);
        CGContextSetLineWidth(context, _gridLineWidth);
        
        for (int i = 0; i < _numHLines; i++)
        {
            CGFloat spacing = (((i + 1) * hLineSpacing) + _topMargin - hLineOffset);
            CGContextMoveToPoint(context, _leftMargin, spacing);
            CGContextAddLineToPoint(context, (_chartWidth - _rightMargin), spacing);
            CGContextStrokePath(context);
        }
        
        for (int i = 0; i < _numVLines; i++)
        {
            CGFloat spacing = (((i + 1) * vLineSpacing) + _leftMargin - vLineOffset);
            CGContextMoveToPoint(context, spacing, _topMargin);
            CGContextAddLineToPoint(context, spacing, (_chartHeight - _bottomMargin));
            CGContextStrokePath(context);
        }
        
        for (int i = 0; i < _dataSets.count; i++)
        {
            ChartsBitmapDataSet *dataSet = _dataSets[i];
            
            if (!dataSet.color)
                dataSet.color = _defaultColors[i % _defaultColors.count];
            
            int offset = 0;
            
            if (_useOffset)
                offset = (i * _offset);
            
            switch (dataSet.type)
            {
                case ChartsBitmapDataTypeLine:
                    CGContextSetStrokeColorWithColor(context, dataSet.color.CGColor);
                    CGContextSetLineWidth(context, dataSet.lineWidth);
                    CGContextSetLineJoin(context, kCGLineJoinRound);
                    
                    CGContextMoveToPoint(context,
                         (_leftMargin + ((dataSet.data[0].x - minX) * xFactor) + vLineOffset + offset),
                         (_topMargin + _chartAreaHeight - (dataSet.data[0].y * yFactor)) - hLineOffset - offset);
                    
                    for (int i = 1; i < dataSet.data.count; i++)
                    {
                        CGContextAddLineToPoint(context,
                            (_leftMargin + ((dataSet.data[i].x - minX) * xFactor) + vLineOffset + offset),
                            (_topMargin + _chartAreaHeight - (dataSet.data[i].y * yFactor) - hLineOffset - offset));
                    }
                    
                    CGContextStrokePath(context);
                    
                    CGContextSetFillColorWithColor(context, dataSet.circleFillColor.CGColor);
                    CGContextSetStrokeColorWithColor(context, dataSet.color.CGColor);
                    CGContextSetLineWidth(context, dataSet.circleBorderWidth);
                    
                    for (int i = 0; i < dataSet.data.count; i++)
                    {
                        CGPoint point = CGPointMake(
                            (_leftMargin + ((dataSet.data[i].x - minX) * xFactor) + vLineOffset + offset),
                            (_topMargin + _chartAreaHeight - (dataSet.data[i].y * yFactor) - hLineOffset - offset));
                        
                        rect = CGRectMake
                        ((point.x - (dataSet.circleRadius / 2)),
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
                        rect = CGRectMake
                        ((_leftMargin + ((point.x - minX) * xFactor) - (dataSet.barWidth / 2) + vLineOffset),
                         (_topMargin + _chartAreaHeight - (point.y * yFactor) - hLineOffset),
                         dataSet.barWidth, ((point.y * yFactor) - hLineOffset));
                        
                        CGContextFillRect(context, rect);
                    }
                    break;
                default:break;
            }
        }
        
        CGContextSetFillColorWithColor(context, _backgroundColor.CGColor);
        rect = CGRectMake(0.0, 0.0, _chartWidth, _topMargin);
        CGContextFillRect(context, rect);
        rect = CGRectMake(0.0, 0.0, _leftMargin, _chartHeight);
        CGContextFillRect(context, rect);
        rect = CGRectMake(0.0, (_chartHeight - _bottomMargin), _chartWidth, _bottomMargin);
        CGContextFillRect(context, rect);
        rect = CGRectMake((_chartWidth - _rightMargin), 0.0, _rightMargin, _chartHeight);
        CGContextFillRect(context, rect);
        
        rect = CGRectMake
        ((_leftMargin - (_borderWidth / 2)), (_topMargin - (_borderWidth / 2)),
         (_chartAreaWidth + _borderWidth), (_chartAreaHeight + _borderWidth));
        
        CGContextSetStrokeColorWithColor(context, _borderColor.CGColor);
        CGContextSetLineWidth(context, _borderWidth);
        CGContextAddRect(context, rect);
        CGContextStrokePath(context);
        
        CGContextScaleCTM(context, 1.0, -1.0);
        
        CTFontRef fontRef = CTFontCreateWithName((CFStringRef)@"CourierNewPS-BoldMT", _gridFontSize, NULL);
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
        
        NSArray *daysArray = @[@"Sun", @"Mon", @"Tues", @"Wed", @"Thurs", @"Fri", @"Sat"];
        
        NSArray *hoursArray = @[@"12am", @"2am", @"4am", @"6am", @"8am", @"10am",
                                @"12pm", @"2pm", @"4pm", @"6pm", @"8pm", @"10pm", @"12am"];
        
        for (int i = 0; i < _numVLines; i++)
        {
            switch (_format)
            {
                case ChartsBitmapDataFormatDayOfWeek:
                    text = [[NSAttributedString alloc] initWithString:daysArray[i]
                                                           attributes:textAttributes];
                    break;
                case ChartsBitmapDataFormatHourOfDay:
                    text = [[NSAttributedString alloc] initWithString:hoursArray[i]
                                                           attributes:textAttributes];
                    break;
                case ChartsBitmapDataFormatYears:
                    value = [NSString stringWithFormat:@"%i", (int)(minX + i)];
                    
                    text = [[NSAttributedString alloc] initWithString:value
                                                           attributes:textAttributes];
                    break;
                default:{
                    double gridValue = (xRange / (double)(_numVLines - 1));
                    value = [NSString stringWithFormat:@"%.1f", (minX + (i * gridValue))];
                    
                    text = [[NSAttributedString alloc] initWithString:value
                                                           attributes:textAttributes];
                    break;}
            }
            
            rect = CGRectMake((_leftMargin + (i * vLineSpacing)),
                              (-_chartHeight + _bottomMargin - gridFontHeight - (_borderWidth * 2)),
                              vLineSpacing, gridFontHeight);
            
            path = CGPathCreateWithRect(rect, NULL);
            framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)text);
            frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, text.length), path, NULL);
            
            CTFrameDraw(frame, context);
            
            CFRelease(path);
            CFRelease(framesetter);
            CFRelease(frame);
        }
        
        style.alignment = NSTextAlignmentRight;
        
        textAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                          (__bridge id)fontRef, kCTFontAttributeName,
                          style, kCTParagraphStyleAttributeName,
                          textColor, kCTForegroundColorAttributeName, nil];
        
        double gridValue = (yRange / (double)(_numHLines - 1));
        
        for (int i = 0; i < _numHLines; i++)
        {
            value = [NSString stringWithFormat:@"%.1f", (i * gridValue)];
            
            text = [[NSAttributedString alloc] initWithString:value
                                                   attributes:textAttributes];
            
            rect = CGRectMake((_leftMargin - hLineSpacing - (_borderWidth * 2)),
                              (-_chartHeight + _bottomMargin + (i * hLineSpacing) + hLineOffset),
                              hLineSpacing, gridFontHeight);
            
            path = CGPathCreateWithRect(rect, NULL);
            framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)text);
            
            CGSize frameSize = CTFramesetterSuggestFrameSizeWithConstraints(framesetter, CFRangeMake(0, text.length),
                                                                            NULL, rect.size, NULL);
            
            rect = CGRectMake(rect.origin.x, rect.origin.y - (frameSize.height / 2),
                              rect.size.width, frameSize.height);
            
            path = CGPathCreateWithRect(rect, NULL);
            framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)text);
            frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, text.length), path, NULL);
            
            CTFrameDraw(frame, context);
            
            CFRelease(path);
            CFRelease(framesetter);
            CFRelease(frame);
        }
        
        int xOrigin = _leftMargin;
        int yOrigin = (-_chartHeight + _bottomMargin - (gridFontHeight * 2) - (_borderWidth * 2));
        
        style.alignment = NSTextAlignmentLeft;
        
        textAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                          (__bridge id)fontRef, kCTFontAttributeName,
                          style, kCTParagraphStyleAttributeName,
                          textColor, kCTForegroundColorAttributeName, nil];
        
        for (ChartsBitmapDataSet *dataSet in _dataSets)
        {
            CGContextSetFillColorWithColor(context, dataSet.color.CGColor);
            
            text = [[NSAttributedString alloc] initWithString:dataSet.title
                                                   attributes:textAttributes];
            
            rect = CGRectMake(xOrigin, yOrigin, _chartAreaWidth, gridFontHeight);
            path = CGPathCreateWithRect(rect, NULL);
            framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)text);
            
            CGSize frameSize = CTFramesetterSuggestFrameSizeWithConstraints(framesetter, CFRangeMake(0, text.length),
                                                                            NULL, rect.size, NULL);
            
            rect = CGRectMake(xOrigin, yOrigin, frameSize.height, frameSize.height);
            CGContextFillRect(context, rect);
            
            xOrigin += (frameSize.height + _borderWidth);
            rect = CGRectMake(xOrigin, yOrigin, frameSize.width, frameSize.height);
            path = CGPathCreateWithRect(rect, NULL);
            framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)text);
            frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, text.length), path, NULL);
            
            CTFrameDraw(frame, context);
            
            xOrigin += (frameSize.width + (_borderWidth * 2));
            
            CFRelease(path);
            CFRelease(framesetter);
            CFRelease(frame);
        }

        CFRelease(fontRef);
        
        if (_title && _title.length)
        {
            fontRef = (__bridge CTFontRef)_titleFont;
            int titleFontHeight = (int)round(CTFontGetBoundingBox(fontRef).size.height);
            int offset = ((_topMargin - titleFontHeight) / 2);
            textColor = _titleColor.CGColor;
            
            style.alignment = NSTextAlignmentCenter;
            
            textAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                              (__bridge id)fontRef, kCTFontAttributeName,
                              style, kCTParagraphStyleAttributeName,
                              textColor, kCTForegroundColorAttributeName, nil];
            
            text = [[NSAttributedString alloc] initWithString:_title
                                                   attributes:textAttributes];
            
            rect = CGRectMake(_leftMargin, -(titleFontHeight + offset), _chartAreaWidth, titleFontHeight);
            
            path = CGPathCreateWithRect(rect, NULL);
            framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)text);
            frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, text.length), path, NULL);
            
            CTFrameDraw(frame, context);
            
            CFRelease(path);
            CFRelease(framesetter);
            CFRelease(frame);
        }
        
        WriteBitmapDataToFile((LPSTR)_outputFile.UTF8String, _chartWidth, _chartHeight, colorSpace, bmData);
        //UIImage *image = [UIImage imageWithContentsOfFile:_outputFile];
        
        CGColorSpaceRelease(colorSpace);
        
        if (context)
            CGContextRelease(context);
        
        if(bmData)
            free(bmData);
        
        return CGSizeMake(_chartWidth, _chartHeight);
    }
    
    else return CGSizeZero;
}

@end
