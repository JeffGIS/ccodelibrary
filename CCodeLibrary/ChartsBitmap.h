//  ChartsBitmap.h
//  CCodeLibrary

#import "DPoint.h"

typedef NS_ENUM(NSInteger, ChartsBitmapOrientation)
{
    ChartsBitmapOrientationLandscape,
    ChartsBitmapOrientationPortrait,
};

typedef NS_ENUM(NSInteger, ChartsBitmapDataType)
{
    ChartsBitmapDataTypeLine,
    ChartsBitmapDataTypeBar,
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

@property ChartsBitmapOrientation chartOrientation;
@property int chartWidth, chartHeight, borderWidth, gridLineWidth, dpi, docMargin;
@property int numHLines, numVLines, leftMargin, rightMargin, topMargin, bottomMargin;
@property (nonatomic) UIColor *gridLineColor, *borderColor, *backgroundColor;
@property (nonatomic) UIColor *chartBackgroundColor, *titleColor;
@property (nonatomic) NSMutableArray <ChartsBitmapDataSet *> *dataSets;
@property (nonatomic, copy) NSString *outputFile, *title;
@property (nonatomic) UIFont *titleFont;

- (CGSize)createChartBitmap;

@end
