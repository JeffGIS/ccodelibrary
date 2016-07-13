//  NVEmailFileList.m
//  CCodeLibrary

#import "NVEmailFileList.h"
#import "NVAlertView.h"
#import "FileLister.h"
#import <MessageUI/MessageUI.h>
#import "CRAPI.h"

@interface NVEmailFileList () <MFMailComposeViewControllerDelegate>

@property (nonatomic) UIView *parentView;

@end

@implementation NVEmailFileList

+ (instancetype)sendFileList:(UIViewController *)viewController
{
    NVEmailFileList *nvefl = NVEmailFileList.new;
    nvefl.parentView = viewController.view;
    
    NSInteger totSize = 0;
    NSString *documentsDir = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    
    NSString *txtfile = [NSString stringWithFormat:@"%@/filelist.txt", documentsDir];
    
    NSInteger nFiles = [FileLister listFilesInDirectory:@"ALL"
                                               outputTo:txtfile
                                              totalSize:&totSize];
    
    if (MFMailComposeViewController.canSendMail)
    {
        MFMailComposeViewController *composer = [[MFMailComposeViewController alloc] init];
        composer.mailComposeDelegate = nvefl;
        composer.subject = @"File list from GMMobile";
        
        [composer setMessageBody:[NSString stringWithFormat:@"%li files (%li bytes) included in list from %@(%i)",
                                  (long)nFiles, (long)totSize, UIDevice.currentDevice.name,CRAPI.sharedInstance.GSSiPadNumber]
                          isHTML:NO];
        
        [composer setToRecipients:[NSArray arrayWithObjects:@"jeffgis@aol.com", @"wildbillmunson@gmail.com", nil]];
        
        [composer addAttachmentData:[NSData dataWithContentsOfFile:txtfile]
                           mimeType:@"application/csvm+json"
                           fileName:@"filelist.txt"];
        
        [viewController presentViewController:composer
                                     animated:YES
                                   completion:nil];
    }
    
    else
    {
        NVAlertView *alert = [NVAlertView showLargeAlertViewinView:nvefl.parentView
                                                          delegate:CRAPI.sharedInstance
                                                             title:@"ERROR:No mail account setup on device."
                                                   buttonTextArray:@[@"OK"]
                                                  destructiveIndex:0];
#pragma unused(alert)
    }
    
    return nvefl;
}

- (void)mailComposeController:(MFMailComposeViewController *)controller
          didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError *)error
{
    NSString *message = @"";
    
    switch (result)
    {
        case MFMailComposeResultCancelled:
            message = @"Mail cancelled";
            break;
            
        case MFMailComposeResultSaved:
            message = @"Mail saved";
            break;
            
        case MFMailComposeResultSent:
            message = @"Mail sent";
            break;
            
        case MFMailComposeResultFailed:
            message = [NSString stringWithFormat:@"Mail send failure:%@", error.localizedDescription];
            break;
            
        default:
            break;
    }
    
    NVAlertView *alert = [NVAlertView showLargeAlertViewinView:_parentView
                                                      delegate:CRAPI.sharedInstance
                                                         title:message
                                               buttonTextArray:@[@"OK"]
                                              destructiveIndex:0];
#pragma unused(alert)
    
    [controller dismissViewControllerAnimated:YES
                                   completion:nil];
}

@end