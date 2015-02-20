//  GSSiAlertController.m
//  CCodeLibrary

#import "GSSiAlertController.h"

@implementation GSSiAlertController

- (id)initWithViewController:(UIViewController *)viewController
{
    self = [super init];
    
    if (self)
        _viewController = viewController;
    
    return self;
}

- (void)showAlertWithTitle:(NSString *)title
                   message:(NSString *)message
         cancelButtonTitle:(NSString *)cancelButtonTitle
         otherButtonTitles:(NSArray *)otherButtonTitles
 destructiveButtonPosition:(NSUInteger)destructiveButtonPosition;
{
    if (UIAlertController.class)
    {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:title
                                                                       message:message
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:cancelButtonTitle
                                                               style:UIAlertActionStyleCancel
                                                             handler:^(UIAlertAction *action){
                                                                 
                                                                 [alert dismissViewControllerAnimated:YES
                                                                                           completion:nil];
                                                                 
                                                                 if (_delegate)
                                                                 {
                                                                     [_delegate gssiAlert:self
                                                                     clickedButtonAtIndex:0];
                                                                 }
                                                             }];
        
        [alert addAction:cancelAction];
        
        for (int i = 0; i < otherButtonTitles.count; i++)
        {
            UIAlertAction *otherAction;
            
            if (i == (destructiveButtonPosition - 1))
            {
                otherAction = [UIAlertAction actionWithTitle:otherButtonTitles[i]
                                                       style:UIAlertActionStyleDestructive
                                                     handler:^(UIAlertAction *action){
                                                         
                                                         [alert dismissViewControllerAnimated:YES
                                                                                   completion:nil];
                                                         
                                                         if (_delegate)
                                                             [_delegate gssiAlert:self
                                                             clickedButtonAtIndex:(i + 1)];
                                                     }];
            }
            
            else
            {
                otherAction = [UIAlertAction actionWithTitle:otherButtonTitles[i]
                                                       style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction *action){
                                                         
                                                         [alert dismissViewControllerAnimated:YES
                                                                                   completion:nil];
                                                         
                                                         if (_delegate)
                                                             [_delegate gssiAlert:self
                                                             clickedButtonAtIndex:(i + 1)];
                                                     }];
            }
            
            [alert addAction:otherAction];
        }
        
        [_viewController presentViewController:alert
                                      animated:YES
                                    completion:nil];
    }
    
    else
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title
                                                            message:message
                                                           delegate:self
                                                  cancelButtonTitle:cancelButtonTitle
                                                  otherButtonTitles:nil];
        
        for (int i = 0; i < otherButtonTitles.count; i++)
            [alertView addButtonWithTitle:otherButtonTitles[i]];
        
        [alertView show];
    }
}

- (void)alertView:(UIAlertView *)alertView
clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (_delegate)
    {
        [_delegate gssiAlert:self
        clickedButtonAtIndex:buttonIndex];
    }
}

@end