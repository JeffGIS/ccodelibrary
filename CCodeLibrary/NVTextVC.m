//  NVTextVC.m
//  CCodeLibrary

#import "NVTextVC.h"

@interface NVTextVC ()

@property (nonatomic) NSString *textFilePath;

@end

@implementation NVTextVC

- (id)initWithTextFromFileAtPath:(NSString *)filePath
{
    self = [super init];
    
    if (self)
    {
        _textFilePath = filePath;
    }
    
    return self;
}

- (void)loadView
{
    UIView *view = [[UIView alloc] initWithFrame:UIScreen.mainScreen.bounds];
    self.view = view;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

@end