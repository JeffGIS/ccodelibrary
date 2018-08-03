//  NVPDFDefCreatorVC.h
//  CCodeLibrary

@import UIKit;
#import "NVPDFDrawing.h"

@interface NVPDFDefDatabase : NSObject

+ (instancetype)staticDatabase;
- (NSArray<NVPDFDrawing *> *)drawings;
- (int)count;

@end

@interface NVPDFDefCreatorVC : UIViewController

@end
