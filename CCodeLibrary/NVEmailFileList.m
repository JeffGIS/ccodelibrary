//  NVEmailFileList.m
//  CCodeLibrary

#import "NVEmailFileList.h"
#import "FileLister.h"
#import "CRAPI.h"
#import "NVSendEmail.h"

@interface NVEmailFileList ()

@property (nonatomic) UIView *parentView;

@end

@implementation NVEmailFileList

+ (void)sendFileList:(UIViewController *)viewController
{
    NVEmailFileList *nvefl = NVEmailFileList.new;
    nvefl.parentView = viewController.view;
    NSInteger totSize = 0;
    NSString *documentsDir = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    NSString *txtfile = [NSString stringWithFormat:@"%@/filelist.txt", documentsDir];
    
    NSInteger nFiles = [FileLister listFilesInDirectory:@"ALL"
                                               outputTo:txtfile
                                              totalSize:&totSize];
    
    NSString *message = [NSString stringWithFormat:@"%li files (%li bytes) included in list from %@(%i)",
                         (long)nFiles, (long)totSize, UIDevice.currentDevice.name, CRAPI.sharedInstance.GSSiPadNumber];
    
    [NVSendEmail sendEmailWithSubject:@"File list from GMMobile"
                              message:message
                       attachmentData:[NSData dataWithContentsOfFile:txtfile]
                             mimeType:@"application/csvm+json"
                             fileName:@"filelist.txt"
                           controller:viewController];
}

@end
