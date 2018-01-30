//  RHClipEditor.m
//  CCodeLibrary

#import "RHClipEditor.h"
#import "NVSpreadsheetVC.h"

@interface RHClipEditor ()

@property (nonatomic, weak) id<NVSpreadsheetVCDelegate> delegate;
@property (nonatomic) RHClip *currentClip;
@property (nonatomic) UIButton *returnButton;
@property CGFloat fontSize;

@end

@implementation RHClipEditor

+ (instancetype)editorWithClip:(RHClip *)clip
                      delegate:(id)delegate
{
    RHClipEditor *editor = RHClipEditor.new;
    editor.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    editor.delegate = delegate;
    editor.currentClip = clip;
    return editor;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _fontSize = 36.0;
    
    _returnButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _returnButton.translatesAutoresizingMaskIntoConstraints = NO;
    _returnButton.backgroundColor = UIColor.clearColor;
    [_returnButton setTitle:@"< Return" forState:UIControlStateNormal];
    [_returnButton setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    [_returnButton setTitleColor:UIColor.lightGrayColor forState:UIControlStateHighlighted];
    _returnButton.titleLabel.font = [UIFont boldSystemFontOfSize:_fontSize];
    [self.view addSubview:_returnButton];
    [_returnButton constrainLeadingToAnchor:self.view.leadingAnchor constant:10.0];
    [_returnButton constrainTopToAnchor:self.view.topAnchor];
    
    [_returnButton addTarget:self
                      action:@selector(returnButtonTapped)
            forControlEvents:UIControlEventTouchUpInside];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)returnButtonTapped
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
