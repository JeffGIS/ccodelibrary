//  RHClipEditor.h
//  CCodeLibrary

@import UIKit;
#import "RHClip.h"

@class RHClipEditor;

@protocol RHClipEditorDelegate <NSObject>

- (void)clipEditorDidReturn:(RHClipEditor *)clipEditor;

@end

@interface RHClipEditor : UIViewController

+ (instancetype)editorWithClip:(RHClip *)clip
                      delegate:(id)delegate
             presenterDelegate:(id)delegate;

@end
