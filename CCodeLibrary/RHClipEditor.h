//  RHClipEditor.h
//  CCodeLibrary

@import UIKit;
#import "RHClip.h"

@interface RHClipEditor : UIViewController

+ (instancetype)editorWithClip:(RHClip *)clip
                      delegate:(id)delegate;

@end
