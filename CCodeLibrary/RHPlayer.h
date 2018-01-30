//  RHPlayer.h
//  CCodeLibrary

@import UIKit;
#import "RHEditor.h"
#import "RHClip.h"

@interface RHPlayer : UIViewController

+ (instancetype)playerWithClip:(RHClip *)clip
                      delegate:(id)delegate;

@end
