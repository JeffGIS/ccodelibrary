//  NVPDFDrawing.h
//  NVTestApp

@import Foundation;

#define LCL0700 0.07
#define LCL0875 0.0875
#define LCL1025 0.1025
#define LCL1075 0.1075
#define LCL1200 0.12
#define LCL1275 0.1275
#define LCL1400 0.14
#define LCL1575 0.1575
#define LCL2300 0.23

#define LCR4325 0.4325
#define LCR4750 0.475
#define LCR5050 0.505

#define RCL4925 0.4925
#define RCL5100 0.51
#define RCL5250 0.525
#define RCL5325 0.5325
#define RCL5450 0.545
#define RCL5525 0.5525
#define RCL5625 0.5625
#define RCL5725 0.5725
#define RCL5825 0.5825
#define RCL6000 0.6

#define RCR9025 0.9025
#define RCR9250 0.925
#define RCR9325 0.9325

#define AR077 0.772727
#define AR129 1.294118

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
