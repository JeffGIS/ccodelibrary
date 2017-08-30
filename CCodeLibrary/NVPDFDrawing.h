//  NVPDFDrawing.h
//  NVTestApp

@import Foundation;

#define LEFT_COL_LEFT 0.1025
#define LEFT_COL_RIGHT 0.505
#define LEFT_COL_LEFT_2 0.105
#define LEFT_COL_RIGHT_2 0.475
#define RIGHT_COL_LEFT 0.525
#define RIGHT_COL_RIGHT 0.9325

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
