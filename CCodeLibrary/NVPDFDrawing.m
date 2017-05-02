//  NVPDFDrawing.m
//  NVTestApp

#import "NVPDFDrawing.h"

@implementation NVPDFDrawing

+ (instancetype)drawingWithID:(NSString *)ID
                         name:(NSString *)name
                         type:(NSString *)type
                         page:(int)page
                    upperLeft:(DPOINT)upperLeft
                   lowerRight:(DPOINT)lowerRight
{
    NVPDFDrawing *drawing = NVPDFDrawing.new;
    drawing.identifier = ID;
    drawing.name = name;
    drawing.type = type;
    drawing.page = page;
    drawing.upperLeft = upperLeft;
    drawing.lowerRight = lowerRight;
    return drawing;
}

@end
