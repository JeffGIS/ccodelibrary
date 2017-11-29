//  ChartsBitmap.h
//  CCodeLibrary

#import "DPoint.h"

typedef NS_ENUM(NSInteger, ChartsBitmapDataType)
{
    ChartsBitmapDataTypeLine,
    ChartsBitmapDataTypeBar,
};

typedef NS_ENUM(NSInteger, ChartsBitmapDataFormat)
{
    ChartsBitmapDataFormatNone,
    ChartsBitmapDataFormatHourOfDay,
    ChartsBitmapDataFormatDayOfWeek,
    ChartsBitmapDataFormatYears,
};

@import Foundation;

@interface ChartsBitmapDataSet : NSObject

@property ChartsBitmapDataType type;
@property int lineWidth, barWidth, circleRadius, circleBorderWidth;
@property (nonatomic) NSMutableArray <DPoint *> *data;
@property (nonatomic, copy) NSString *title;
@property (nonatomic) UIColor *color, *circleFillColor;

@end

@interface ChartsBitmap : NSObject

@property ChartsBitmapDataFormat format;
@property int chartWidth, chartHeight, borderWidth, gridLineWidth, dpi, docMargin, offset;
@property int numHLines, numVLines, leftMargin, rightMargin, topMargin, bottomMargin, gridFontSize;
@property (nonatomic) UIColor *gridLineColor, *borderColor, *backgroundColor;
@property (nonatomic) UIColor *chartBackgroundColor, *titleColor;
@property (nonatomic) NSMutableArray <ChartsBitmapDataSet *> *dataSets;
@property (nonatomic, copy) NSString *outputFile, *title;
@property (nonatomic) UIFont *titleFont;
@property (nonatomic, copy) NSArray <UIColor *> *colors;
@property (nonatomic, copy) NSArray <NSArray<NSNumber *> *> *patterns;
@property BOOL useOffset;

- (CGSize)createChartBitmap;

@end
