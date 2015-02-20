//  GSSiAlertController.m
//  CCodeLibrary

#import "GSSiAlertController.h"

@interface GSSiAlertController ()

@property (nonatomic, weak) UIViewController *viewController;

@end

@implementation GSSiAlertController

//need to pass in current viewController instance to allow UIAlertController presentation
- (id)initWithViewController:(UIViewController *)viewController
{
    self = [super init];
    
    if (self)
        _viewController = viewController;
    
    return self;
}

//creates both UIAlertController (iOS 8) and UIAlertView (iOS 7 and earlier)
- (void)showAlertWithTitle:(NSString *)title
                   message:(NSString *)message
         cancelButtonTitle:(NSString *)cancelButtonTitle//this parameter cannot be nil
         otherButtonTitles:(NSArray *)otherButtonTitles//this is an array, not nil-terminated list of strings
 destructiveButtonPosition:(NSUInteger)destructiveButtonPosition;//1-indexed position (use 0 if none)
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
                                                                     clickedButtonAtIndex:0];//cancel button always at index 0
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
                                                             clickedButtonAtIndex:(i + 1)];//other buttons at index 1 and higher
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
                                                             clickedButtonAtIndex:(i + 1)];//other buttons at index 1 and higher
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

//cancel button is always at index 0; other buttons are 1 and higher
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