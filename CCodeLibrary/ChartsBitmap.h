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
@property int chartWidth, chartHeight, borderWidth, lineWidth;
@property int numHorLines, numVertLines, xMargin, topMargin, bottomMargin;
@property (nonatomic) UIColor *lineColor, *barColor, *borderColor, *backgroundColor;
@property (nonatomic, copy) NSString *outputFile;

- (CGSize)createChartBitmap;

@end
