//  NVStaticMapView.h
//  CCodeLibrary

#import <UIKit/UIKit.h>
#import "CCodeTypes.h"

@interface NVStaticMapView : UIImageView

+ (NVStaticMapView *)showStaticMapInView:(UIView *)view
                          withCoordinate:(LLPOINT)coordinate
                                    zoom:(CGFloat)zoom
                                  tabBar:(UITabBar *)tabBar
                                   label:(NSString *)label;

@end