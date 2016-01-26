//  NVPDFViewer.h
//  CCodeLibrary

@import UIKit;

@interface NVPDFViewer : UIView

+ (instancetype)showPDFViewerInView:(UIView *)view
                       withFileName:(NSString *)fileName
                             tabBar:(UITabBar *)tabBar;

@end