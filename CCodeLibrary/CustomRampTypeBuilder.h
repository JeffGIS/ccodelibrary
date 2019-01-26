//  CustomRampTypeBuilder.h
//  CCodeLibrary

typedef enum {
    RampElementTypeNone,
    RampElementTypeRamp,
    RampElementTypeFlare,
    RampElementTypeLanding,
    RampElementTypeSdwk
} RampElementType;
@import UIKit;

@interface CustomRampElement : NSObject

@end

@interface CustomRampType : NSObject

@end

@interface CustomRampTypeBuilder : UIViewController

@end
