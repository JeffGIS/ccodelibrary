//  NVSecretAlertView.h
//  CCodeLibrary

#import "NVAlertView.h"

@interface NVSecretAlertView : NVAlertView

+ (NVSecretAlertView *)showSecretAlertViewinView:(UIView *)view
                                        delegate:(id)delegate
                                           title:(NSString *)title
                                 buttonTextArray:(NSArray *)buttonTextArray
                                      UUIDString:(NSString *)UUIDString;

@end
