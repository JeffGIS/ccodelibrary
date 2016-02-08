//  NVDocumentManager.m
//  CCodeLibrary

#import "NVDocumentManager.h"

@interface NVDocumentManager () <UIDocumentPickerDelegate>

@property (nonatomic) UIDocumentPickerViewController *documentPicker;

@end

@implementation NVDocumentManager

- (void)exportDocumentFromFilepath:(NSString *)filepath
                                  delegate:(id)delegate
{
    if (!filepath || ![delegate isKindOfClass:UIViewController.class])
        return;
    
    _delegate = delegate;
    
    _documentPicker = [[UIDocumentPickerViewController alloc] initWithURL:[NSURL fileURLWithPath:filepath]
                                                                   inMode:UIDocumentPickerModeExportToService];
    
    _documentPicker.delegate = self;
    _documentPicker.modalPresentationStyle = UIModalPresentationFormSheet;
    
    [delegate presentViewController:_documentPicker
                           animated:NO
                         completion:nil];
}

- (void)documentPicker:(UIDocumentPickerViewController *)controller
  didPickDocumentAtURL:(NSURL *)url
{
    if ([_delegate respondsToSelector:@selector(documentManagerDidComplete)])
        [_delegate documentManagerDidComplete];
}

- (void)documentPickerWasCancelled:(UIDocumentPickerViewController *)controller
{
    if ([_delegate respondsToSelector:@selector(documentManagerWasCancelled)])
        [_delegate documentManagerWasCancelled];
}

@end