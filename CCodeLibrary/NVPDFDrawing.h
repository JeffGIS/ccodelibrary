//  NVPDFDrawing.h
//  NVTestApp

@import Foundation;

#define ASPECT_RATIO 0.783
#define LEFT_COL_LEFT 0.1025
#define LEFT_COL_RIGHT 0.505

@interface NVPDFDrawing : NSObject

@property (nonatomic, copy) NSString *identifier, *name, *type;
@property int page;
@property DPOINT upperLeft, lowerRight;

+ (instancetype)drawingWithID:(NSString *)ID
                         name:(NSString *)name
                         type:(NSString *)type
                         page:(int)page
                    upperLeft:(DPOINT)upperLeft
                   lowerRight:(DPOINT)lowerRight;

@end
