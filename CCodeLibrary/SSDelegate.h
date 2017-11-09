//  SSDelegate.h
//  CCodeLibrary

@import Foundation;
#import "NVSpreadsheetVC.h"
#import "NVPopoverTableView.h"

//this is an abstract superclass and should not be instantiated directly!

@interface SSDelegate : NSObject <NVSpreadsheetVCDelegate,NVPopoverTableViewDelegate>

@end
