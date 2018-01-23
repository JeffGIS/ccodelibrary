//  RHViewController.m
//  CCodeLibrary

#import "RHViewController.h"
#import "RHPlayer.h"
#import "RHRecorder.h"
#import "RHEditor.h"
#import "UserDefaults.h"
#import "CRAPI.h"
@import MobileCoreServices;
#import "NVSpreadsheetVC.h"

@interface RHViewController () <NVAlertViewDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>

@property (nonatomic, weak) id<NVSpreadsheetVCDelegate> delegate;
@property (nonatomic, copy) NSString *dir;
@property (nonatomic, copy) NSArray<NSString *> *files;
@property (nonatomic) NVAlertView *alert;

@end

@implementation RHViewController

+ (instancetype)controllerWithDelegate:(id)delegate
{
    RHViewController *rhvc = RHViewController.new;
    rhvc.delegate = delegate;
    return rhvc;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    NSError *error = nil;
    _dir = [_delegate vidDirForPropNum:_propNum];
    
    NSArray *files = [NSFileManager.defaultManager contentsOfDirectoryAtPath:_dir
                                                                       error:&error];
    NSMutableArray *movFiles = NSMutableArray.array;
    
    for (NSString *file in files)
    {
        if ([file.pathExtension isEqualToString:@"mov"])
            [movFiles addObject:file];
    }
    
    _files = movFiles.copy;
    [self showTopLevelAlert];
}

- (void)showTopLevelAlert
{
    NSMutableArray *options = NSMutableArray.array;
    [options addObject:@"Capture New Video|1"];
    
    if (_files.count)
        [options addObject:@"Edit Existing Video|2"];
    
    [options addObject:@"Import Video from Photos|3"];
    
    NSString *title = [NSString stringWithFormat:@"Video Options for\n%d", _propNum];
    
    _alert = [NVAlertView showLargeAlertViewinView:self.view
                                          delegate:self
                                             title:title
                                   buttonTextArray:options.copy
                                  destructiveIndex:0];
    
    _alert.identifier = @"TopLevelAlert";
    [_alert showTabBar];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [_alert hideLargeAlertView:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)alertView:(NVAlertView *)alertView
didTapButtonAtIndex:(NSInteger)buttonIndex
{
    [alertView hideLargeAlertView:NO];
    
    if ([alertView.identifier isEqualToString:@"TopLevelAlert"])
    {
        switch (buttonIndex)
        {
            case 1:{//new
                RHRecorder *recorder = [RHRecorder recorderWithPropNum:_propNum delegate:_delegate];
                [self presentViewController:recorder animated:YES completion:nil];
                break;}
            case 2:{//edit
                NSMutableArray *text = NSMutableArray.array;
                [text addObject:@"Cancel"];
                [text addObjectsFromArray:_files];
                
                _alert = [NVAlertView showLargeAlertViewinView:self.view
                                                      delegate:self
                                                         title:@"Select RiteHome Video File"
                                               buttonTextArray:text.copy
                                              destructiveIndex:1];
                
                _alert.identifier = @"RHEditorSelect";
                [_alert showTabBar];
                break;}
            case 3:{//import
                UIImagePickerController *picker = UIImagePickerController.new;
                picker.delegate = self;
                picker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
                picker.mediaTypes = [[NSArray alloc] initWithObjects:(NSString *)kUTTypeMovie, nil];
                picker.modalPresentationStyle = UIModalPresentationPopover;
                UIPopoverPresentationController *controller = picker.popoverPresentationController;
                controller.sourceView = self.view;
                [self presentViewController:picker animated:YES completion:nil];
                break;}
            default:break;
        }
    }
    
    else if ([alertView.identifier isEqualToString:@"RHEditorSelect"])
    {
        if (buttonIndex)
        {
            NSString *file =_files[buttonIndex - 1];
            NSString *path = [NSString stringWithFormat:@"%@/%@", _dir, file];
            CRAPI.sharedInstance.rhVideoURL = [NSURL fileURLWithPath:path isDirectory:NO];
            RHEditor *editor = [RHEditor editorWithPropNum:_propNum delegate:_delegate];
            [self presentViewController:editor animated:YES completion:nil];
        }
        
        else
            [self showTopLevelAlert];
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker
didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    [picker dismissViewControllerAnimated:NO completion:nil];
    CRAPI.sharedInstance.rhVideoURL = info[UIImagePickerControllerMediaURL];
    RHEditor *editor = [RHEditor editorWithPropNum:_propNum delegate:_delegate];
    [self presentViewController:editor animated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

@end
