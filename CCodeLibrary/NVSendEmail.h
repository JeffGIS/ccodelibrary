//  NVSendEmail.h
//  CCodeLibrary

@import UIKit;

@interface NVSendEmail : NSObject

+ (void)sendEmailWithSubject:(NSString *)subject
                     message:(NSString *)message
              attachmentData:(NSData *)attachmentData
                    mimeType:(NSString *)mimeType
                    fileName:(NSString *)fileName
                  controller:(UIViewController *)controller;

+ (void)sendEmailToRecipient:(NSString *)recipient
                  controller:(UIViewController *)controller;

@end
