//  NVPDFDefCreatorVC.h
//  CCodeLibrary

@import UIKit;
#import "NVPDFDrawing.h"

@interface NVPDFDefDatabase : NSObject

+ (instancetype)staticDatabase;
- (NSArray<NVPDFDrawing *> *)drawings;

- (NVPDFDrawing *)drawingWithType:(NSString *)type
                       identifier:(NSString *)identifier;

- (int)count;

@end

@interface NVPDFDefCreatorVC : UIViewController

@end
