//  CustomRampTypeBuilder.h
//  CCodeLibrary

@import UIKit;

typedef enum {
    RampElementTypeNone,
    RampElementTypeRamp,
    RampElementTypeFlare,
    RampElementTypeLanding,
    RampElementTypeSdwk
} RampElementType;

@interface CustomRampElement : NSObject

@property RampElementType type;
@property DPOINT position;

@end

@interface CustomRampType : NSObject

@property (nonatomic, copy) NSString *photo;
@property (nonatomic, copy) NSArray<CustomRampElement *> *elements;

@end

@interface CustomRampTypeBuilder : UIViewController

@end
