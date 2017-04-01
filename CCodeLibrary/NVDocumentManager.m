//  NVDocumentManager.m
//  CCodeLibrary

#import "NVDocumentManager.h"

@interface NVDocumentManager () <UIDocumentPickerDelegate>

@property (nonatomic) UIDocumentPickerViewController *documentPicker;
@property (nonatomic, copy) NSString *filepath;
@property BOOL deleteWhenDone;

@end

@implementation NVDocumentManager

- (void)exportDocumentFromFilepath:(NSString *)filepath
                          delegate:(id)delegate
                    deleteWhenDone:(BOOL)deleteWhenDone
{
    if (!filepath || !([delegate isKindOfClass:UIViewController.class] ||
                       [delegate isKindOfClass:UIView.class]))
    {
        return;
    }
    
    _delegate = delegate;
    _filepath = filepath;
    _deleteWhenDone = deleteWhenDone;
    UIViewController *vc = nil;
    
    if ([_delegate isKindOfClass:UIViewController.class])
        vc = (UIViewController *)_delegate;
    
    else
    {
        UIView *view = (UIView *)_delegate;
        vc = view.parentViewController;
    }
    
    _documentPicker = [[UIDocumentPickerViewController alloc] initWithURL:[NSURL fileURLWithPath:_filepath]
                                                                   inMode:UIDocumentPickerModeExportToService];
    
    _documentPicker.delegate = self;
    _documentPicker.modalPresentationStyle = UIModalPresentationFormSheet;
    
    [vc presentViewController:_documentPicker
                     animated:NO
                   completion:nil];
}

- (void)importFileWithDelegate:(id)delegate
{
    if (([delegate isKindOfClass:UIViewController.class] ||
         [delegate isKindOfClass:UIView.class]))
    {
        return;
    }
    
    _delegate = delegate;
    UIViewController *vc = nil;
    
    if ([_delegate isKindOfClass:UIViewController.class])
        vc = (UIViewController *)_delegate;
    
    else
    {
        UIView *view = (UIView *)_delegate;
        vc = view.parentViewController;
    }
    
    _documentPicker = [[UIDocumentPickerViewController alloc] initWithDocumentTypes:@[@"public.content", @"public.composite-content", @"public.data"]
                                                                             inMode:UIDocumentPickerModeImport];
    
    _documentPicker.delegate = self;
    _documentPicker.modalPresentationStyle = UIModalPresentationFormSheet;
    
    [vc presentViewController:_documentPicker
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
    
    if (_deleteWhenDone)
    {
        NSError *error = nil;
        
        [NSFileManager.defaultManager removeItemAtPath:_filepath
                                                 error:&error];
        
        if (error)
            NSLog(@"Export to Cloud Delete Local File When Done ERROR:%@", error);
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

- (NSArray *)directoriesInDirectory:(NSString *)directory
{
    NSFileManager *fm = NSFileManager.defaultManager;
    NSError *error = nil;
    NSArray *files = [fm contentsOfDirectoryAtPath:directory error:&error];
    NSMutableArray *directoryList = NSMutableArray.new;
    
    for (NSString *file in files)
    {
        NSString *path = [directory stringByAppendingPathComponent:file];
        BOOL isDir = NO;
        
        [fm fileExistsAtPath:path
                 isDirectory:(&isDir)];
        
        if (isDir)
        {
            NSArray *dirContents = [fm contentsOfDirectoryAtPath:path error:&error];
            
            if (dirContents.count)
                [directoryList addObject:file];
        }
    }
    
    return directoryList;
}

@end
