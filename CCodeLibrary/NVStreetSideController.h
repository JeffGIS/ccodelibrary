//  NVStreetSideController.h
//  CCodeLibrary

@import UIKit;

@interface NVStreetSideController : UIViewController

+ (instancetype)presentStreetSideInController:(UIViewController *)controller
                          lookingAtCoordinate:(CLLocationCoordinate2D)coordinate;

@end
