//  RHPlayer.h
//  CCodeLibrary

@import UIKit;
#import "RHEditor.h"

@interface RHPlayer : UIViewController

+ (instancetype)playerWithClip:(RHClip *)clip
                      delegate:(id)delegate;

@end
