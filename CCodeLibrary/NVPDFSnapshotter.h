//  NVPDFSnapshotter.h
//  CCodeLibrary

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface NVPDFSnapshotter : NSObject

+ (NSData *)pdfFromViews:(NSArray *)views;

@end