//  NVInventoryViewController.m
//  CCodeLibrary

#import "NVInventoryViewController.h"
#import "UserDefaults.h"

@interface NVInventoryViewController ()

@property (nonatomic) UIImageView *backgroundImage;
@property (nonatomic) UIButton *cancelButton, *doneButton;
@property (nonatomic) UIButton *addRampButton, *addSignalButton, *addXWalkButton;
@property (nonatomic) UIButton *editItemButton, *rampTypeButton;

@end

@implementation NVInventoryViewController

+ (NVInventoryViewController *)showInventoryViewControllerForIntersection:(MPIntersection *)intersection
                                                                 delegate:(id)delegate
                                                                     from:(NSInteger)from;
{
    NVInventoryViewController *inventoryVC = [[NVInventoryViewController alloc] init];
    inventoryVC.currentIntersection = intersection;
    inventoryVC.delegate = delegate;
    inventoryVC.from = from;
    
    if ([delegate isKindOfClass:UIViewController.class])
    {
        [delegate presentViewController:inventoryVC
                               animated:YES
                             completion:nil];
    }
    
    return inventoryVC;
}

- (void)loadView
{
    UIView *view = [[UIView alloc] initWithFrame:UIScreen.mainScreen.bounds];
    view.backgroundColor = UIColor.blackColor;
    self.view = view;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _backgroundImage = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 98.0, 768.0, 768.0)];
    _backgroundImage.clipsToBounds = YES;
    _backgroundImage.backgroundColor = UIColor.whiteColor;
    [self.view addSubview:_backgroundImage];
    
    [self setupButton:_doneButton
                frame:CGRectMake(224.0, 16.0, 320.0, 74.0)
             selector:@selector(done:)
                title:@"Done"
             fontSize:56.0];
    
    [self setupButton:_cancelButton
                frame:CGRectMake(20.0, 16.0, 148.0, 74.0)
             selector:@selector(cancel:)
                title:@"Cancel"
             fontSize:40.0];
    
    [self setupBottomButtons];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)setupBottomButtons
{
    CGFloat height = 90.0, width = 132.0, top = 874.0;
    CGFloat outBorder = 16.0;
    CGFloat inBorder = ((768.0 - ((width * 5.0) + (outBorder * 2.0))) / 4.0);
    
    [self setupButton:_addRampButton
                frame:CGRectMake(outBorder, top, width, height)
             selector:@selector(addRamp:)
                title:@"Add\nRamp"
             fontSize:32.0];
    
    [self setupButton:_addSignalButton
                frame:CGRectMake((outBorder + width + inBorder), top, width, height)
             selector:@selector(addSignal:)
                title:@"Add\nSignal"
             fontSize:32.0];
    
    [self setupButton:_addXWalkButton
                frame:CGRectMake((outBorder + ((width + inBorder) * 2.0)), top, width, height)
             selector:@selector(addXWalk:)
                title:@"Add\nXWalk"
             fontSize:32.0];
    
    [self setupButton:_editItemButton
                frame:CGRectMake((outBorder + ((width + inBorder) * 3.0)), top, width, height)
             selector:@selector(editItem:)
                title:@"Edit\nItem"
             fontSize:32.0];
    
    [self setupButton:_rampTypeButton
                frame:CGRectMake((outBorder + ((width + inBorder) * 4.0)), top, width, height)
             selector:@selector(rampType:)
                title:@"Ramp\nType"
             fontSize:32.0];
}

- (void)setupButton:(UIButton *)button
              frame:(CGRect)frame
           selector:(SEL)selector
              title:(NSString *)title
           fontSize:(CGFloat)fontSize
{
    button = [[UIButton alloc] initWithFrame:frame];
    
    button.backgroundColor = UserDefaults.defaults.appleBlue;
    button.layer.cornerRadius = 10.0;
    button.titleLabel.textAlignment = NSTextAlignmentCenter;
    button.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    button.layer.borderColor = UIColor.whiteColor.CGColor;
    button.layer.borderWidth = 2.0;
    button.titleLabel.font = [UIFont boldSystemFontOfSize:fontSize];
    button.titleLabel.numberOfLines = 2;
    
    [button setTitleColor:UIColor.whiteColor
                 forState:UIControlStateNormal];
    
    [button setTitleColor:UIColor.redColor
                 forState:UIControlStateHighlighted];
    
    [button setTitle:title
            forState:UIControlStateNormal];
    
    [button addTarget:self
               action:selector
     forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:button];
}

- (void)done:(UIButton *)button
{
    [_currentIntersection setRampsXWalkAndSignal];
    
    if (_delegate)
    {
        [_delegate inventoryViewController:self
                           didSetInventory:_currentIntersection];
    }
}

- (void)cancel:(UIButton *)button
{
    NVLargeAlertView *alert = [NVLargeAlertView showLargeAlertViewinView:self.view
                                                                delegate:self
                                                                   title:@"Do you really want to cancel all changes to this intersection?"
                                                           topButtonText:@"NO"
                                                        bottomButtonText:@"YES"
                                                        destructiveIndex:NVLargeAlertIndexBottomButton];
#pragma unused(alert)
}

- (void)largeAlertView:(NVLargeAlertView *)largeAlertView
   didTapButtonAtIndex:(NVLargeAlertIndex)buttonIndex
{
    [largeAlertView hideLargeAlertView:YES];
    
    switch (buttonIndex)
    {
        case NVLargeAlertIndexTopButton:
            break;
            
        case NVLargeAlertIndexBottomButton:
            [self dismissViewControllerAnimated:YES
                                     completion:nil];
            break;
            
        default:
            break;
    }
}

- (void)addRamp:(UIButton *)button
{
    
}

- (void)addSignal:(UIButton *)button
{
    
}

- (void)addXWalk:(UIButton *)button
{
    
}

- (void)editItem:(UIButton *)button
{
    
}

- (void)rampType:(UIButton *)button
{
    
}

@end