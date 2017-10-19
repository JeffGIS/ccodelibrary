//  ChartsBitmap.h
//  CCodeLibrary

typedef NS_ENUM(NSInteger, ChartsBitmapOrientation)
{
    ChartsBitmapOrientationLandscape,
    ChartsBitmapOrientationPortrait,
};

@import Foundation;

@interface ChartsBitmap : NSObject

@property ChartsBitmapOrientation chartOrientation;
@property int chartWidth, chartHeight, borderWidth, lineWidth, numHorLines, numVertLines, margin;
@property (nonatomic) UIColor *lineColor, *barColor, *borderColor, *backgroundColor;
@property (nonatomic, copy) NSString *outputFile;

- (CGSize)createChartBitmap;

@end
