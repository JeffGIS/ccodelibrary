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

- (void)importFileWithDelegate:(id)delegate
{
    if (![delegate isKindOfClass:UIViewController.class])
        return;
    
    _delegate = delegate;
    
    _documentPicker = [[UIDocumentPickerViewController alloc] initWithDocumentTypes:@[@"public.content", @"public.composite-content", @"public.data"]
                                                                             inMode:UIDocumentPickerModeImport];
    
    _documentPicker.delegate = self;
    _documentPicker.modalPresentationStyle = UIModalPresentationFormSheet;
    
    [delegate presentViewController:_documentPicker
                           animated:NO
                         completion:nil];
}

- (void)documentPicker:(UIDocumentPickerViewController *)controller
  didPickDocumentAtURL:(NSURL *)url
{
    NSString *message = @"";
    
    switch (controller.documentPickerMode)
    {
        case UIDocumentPickerModeImport:
            message = @"Import Document Completed";
            break;
            
        case UIDocumentPickerModeExportToService:
            message = @"Export Document Completed";
            break;
            
        case UIDocumentPickerModeMoveToService:
            message = @"Move Document Completed";
            break;
            
        case UIDocumentPickerModeOpen:
            message = @"Open Document Completed";
            break;
    }
    
    if ([_delegate respondsToSelector:@selector(documentManagerDidCompleteWithMessage:filepath:)])
    {
        [_delegate documentManagerDidCompleteWithMessage:message
                                                filepath:url.path];
    }
}

- (void)documentPickerWasCancelled:(UIDocumentPickerViewController *)controller
{
    NSString *message = @"";
    
    switch (controller.documentPickerMode)
    {
        case UIDocumentPickerModeImport:
            message = @"Import Document Cancelled";
            break;
            
        case UIDocumentPickerModeExportToService:
            message = @"Export Document Cancelled";
            break;
            
        case UIDocumentPickerModeMoveToService:
            message = @"Move Document Cancelled";
            break;
            
        case UIDocumentPickerModeOpen:
            message = @"Open Document Cancelled";
            break;
    }
    
    if ([_delegate respondsToSelector:@selector(documentManagerDidCompleteWithMessage:filepath:)])
    {
        [_delegate documentManagerDidCompleteWithMessage:message
                                                filepath:nil];
    }
}

@end