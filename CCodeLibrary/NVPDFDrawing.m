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

- (NSString *)description
{
    return [NSString stringWithFormat:@"PAGE:%d, TYPE:%@, ID:%@, NAME:%@, ULX:%.4f, ULY:%.4f, LRX:%.4f, LRY:%.4f",
            _page, _type, _identifier, _name, _upperLeft.x, _upperLeft.y, _lowerRight.x, _lowerRight.y];
}

@end
