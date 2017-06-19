//  NVSendEmail.m
//  CCodeLibrary

#import "NVSendEmail.h"
@import MessageUI;
#import "NVAlertView.h"
#import "CRAPI.h"
#import "NVContactsViewer.h"

@interface NVSendEmail () <MFMailComposeViewControllerDelegate,NVContactsViewerDelegate>

@property (nonatomic) NSString *subject, *message, *mimeType, *fileName;
@property (nonatomic) UIViewController *controller;
@property (nonatomic) NSData *attachmentData;

@end

@implementation NVSendEmail

+ (void)sendEmailToRecipient:(NSString *)recipient
                  controller:(UIViewController *)controller;
{
    if (!MFMailComposeViewController.canSendMail)
    {
        NVAlertView *alert = [NVAlertView showLargeAlertViewinView:controller.view
                                                          delegate:CRAPI.sharedInstance
                                                             title:@"ERROR: No mail account setup on device."
                                                   buttonTextArray:@[@"OK"]
                                                  destructiveIndex:0];
#pragma unused(alert)
    }
    
    else
    {
        MFMailComposeViewController *composer = MFMailComposeViewController.new;
        composer.mailComposeDelegate = (id)controller;
        composer.toRecipients = @[(recipient)];
        [controller presentViewController:composer animated:YES completion:nil];
    }
}

+ (void)sendEmailWithSubject:(NSString *)subject
                     message:(NSString *)message
              attachmentData:(NSData *)attachmentData
                    mimeType:(NSString *)mimeType
                    fileName:(NSString *)fileName
                  controller:(UIViewController *)controller
{
    if (!MFMailComposeViewController.canSendMail)
    {
        NVAlertView *alert = [NVAlertView showLargeAlertViewinView:controller.view
                                                          delegate:CRAPI.sharedInstance
                                                             title:@"ERROR: No mail account setup on device."
                                                   buttonTextArray:@[@"OK"]
                                                  destructiveIndex:0];
#pragma unused(alert)
    }
    
    else
    {
        NVSendEmail *email = NVSendEmail.new;
        email.subject = subject;
        email.message = message;
        email.attachmentData = attachmentData;
        email.mimeType = mimeType;
        email.fileName = fileName;
        email.controller = controller;
        CRAPI.sharedInstance.currentEmail = email;
        [email createEmail];
    }
}

- (void)createEmail
{
    NVContactsViewer *contacts = [NVContactsViewer contactsViewerWithDelegate:self];
    [_controller presentViewController:contacts animated:YES completion:nil];
}

- (void)contactsViewerDidReturn:(NVContactsViewer *)contactsViewer
{
    [contactsViewer dismissViewControllerAnimated:YES completion:nil];
}

- (void)contactsViewer:(NVContactsViewer *)contactsViewer
       didReturnEmails:(NSArray *)emails
{
    [contactsViewer dismissViewControllerAnimated:YES completion:nil];
    MFMailComposeViewController *composer = MFMailComposeViewController.new;
    composer.mailComposeDelegate = self;
    composer.subject = _subject;
    [composer setMessageBody:_message isHTML:NO];
    composer.toRecipients = emails;
    [composer addAttachmentData:_attachmentData mimeType:_mimeType fileName:_fileName];
    [_controller presentViewController:composer animated:YES completion:nil];
}

- (void)mailComposeController:(MFMailComposeViewController *)controller
          didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError *)error
{
    [controller dismissViewControllerAnimated:YES completion:nil];
    NSString *resultString = @"";
    
    switch (result)
    {
        case MFMailComposeResultCancelled:
            resultString = @"Mail Cancelled";
            break;
        case MFMailComposeResultSaved:
            resultString = @"Mail Saved";
            break;
        case MFMailComposeResultSent:
            resultString = @"Mail Sent";
            break;
        case MFMailComposeResultFailed:
            resultString = [NSString stringWithFormat:@"Mail Send failure:%@", error.localizedDescription];
            break;
        default:
            break;
    }
    
    NVAlertView *alert = [NVAlertView showLargeAlertViewinView:_controller.view
                                                      delegate:CRAPI.sharedInstance
                                                         title:resultString
                                               buttonTextArray:@[@"OK"]
                                              destructiveIndex:0];
#pragma unused(alert)
}

@end
