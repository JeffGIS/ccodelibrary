//  NVDocumentManager.m
//  CCodeLibrary

#import "NVDocumentManager.h"
#import "CRAPI.h"

@interface NVDocumentManager () <UIDocumentPickerDelegate>

@property (nonatomic) UIDocumentPickerViewController *documentPicker;

@end

@implementation NVDocumentManager

- (void)exportDocumentFromFilePath:(NSString *)filePath
                          delegate:(id)delegate
                    deleteWhenDone:(BOOL)deleteWhenDone
{
    if (!filePath || !delegate)
    {
        NSLog(@"NVDocumentManager ERROR: cannot set filePath or delegate to nil.");
        return;
    }
    
    _delegate = delegate;
    _filePath = filePath;
    _deleteWhenDone = deleteWhenDone;
    UIViewController *vc = nil;
    
    if ([_delegate isKindOfClass:CRAPI.class])
        vc = UIApplication.sharedApplication.keyWindow.rootViewController;
    
    else if ([_delegate isKindOfClass:UIViewController.class])
        vc = (UIViewController *)_delegate;
    
    else
    {
        UIView *view = (UIView *)_delegate;
        vc = view.parentViewController;
    }
    
    _documentPicker = [[UIDocumentPickerViewController alloc] initWithURL:[NSURL fileURLWithPath:_filePath]
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
        default:break;
    }
    
    if (_deleteWhenDone)
    {
        NSError *error = nil;
        [NSFileManager.defaultManager removeItemAtPath:_filePath error:&error];
        
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
        default:break;
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
