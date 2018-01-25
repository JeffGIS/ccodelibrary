//  RHList.m
//  CCodeLibrary

#import "RHList.h"
#import "NVSpreadsheetVC.h"
#import "UserDefaults.h"
@import AVFoundation;

@interface RHList () <UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, weak) id<NVSpreadsheetVCDelegate> delegate;
@property (nonatomic, copy) NSArray<RHClip *> *clips;
@property (nonatomic) UITableView *tableView;
@property (nonatomic) UIImageView *imageView;
@property (nonatomic) UIButton *returnButton;
@property int propNum;
@property (nonatomic) UIFont *font;
@property (nonatomic, copy) NSString *vidDir;

@end

@implementation RHList

+ (instancetype)listWithPropNum:(int)propNum
                       delegate:(id)delegate
{
    RHList *list = RHList.new;
    list.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    list.propNum = propNum;
    list.delegate = delegate;
    return list;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (_delegate && [_delegate respondsToSelector:@selector(clipsForProperty:)])
        _clips = [_delegate clipsForProperty:_propNum];
    
    if (_delegate)
    {
        if ([_delegate respondsToSelector:@selector(clipsForProperty:)])
            _clips = [_delegate clipsForProperty:_propNum];
        
        if ([_delegate respondsToSelector:@selector(vidDirForPropNum:)])
            _vidDir = [_delegate vidDirForPropNum:_propNum];
    }
    
    else {NSLog(@"ERROR: ClipsForProperty method not implemented by delegate");}
    
    _font = [UIFont boldSystemFontOfSize:32.0];
    
    _returnButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _returnButton.translatesAutoresizingMaskIntoConstraints = NO;
    _returnButton.backgroundColor = UIColor.clearColor;
    [_returnButton setTitle:@"< Return" forState:UIControlStateNormal];
    [_returnButton setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    [_returnButton setTitleColor:UIColor.lightGrayColor forState:UIControlStateHighlighted];
    _returnButton.titleLabel.font = _font;
    [self.view addSubview:_returnButton];
    [_returnButton constrainLeadingToAnchor:self.view.leadingAnchor constant:10.0];
    [_returnButton constrainTopToAnchor:self.view.topAnchor];
    
    [_returnButton addTarget:self
                      action:@selector(returnButtonTapped)
            forControlEvents:UIControlEventTouchUpInside];
    
    _imageView = UIImageView.new;
    _imageView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:_imageView];
    [_imageView constrainTopToAnchor:_returnButton.bottomAnchor];
    [_imageView constrainLeadingToAnchor:self.view.leadingAnchor];
    [_imageView constrainTrailingToAnchor:self.view.trailingAnchor];
    
    _tableView = UITableView.new;
    _tableView.translatesAutoresizingMaskIntoConstraints = NO;
    _tableView.rowHeight = 48.0;
    _tableView.dataSource = self;
    _tableView.delegate = self;
    [self.view addSubview:_tableView];
    [_tableView constrainBottomToAnchor:self.view.bottomAnchor];
    [_tableView constrainLeadingToAnchor:self.view.leadingAnchor];
    [_tableView constrainTrailingToAnchor:self.view.trailingAnchor];
    [_tableView constrainTopToAnchor:_imageView.bottomAnchor];
    [_tableView constrainHeightToAnchor:_imageView.heightAnchor multiplier:2.0];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)returnButtonTapped
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
    return _clips.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"CustomCell";
    
    UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:cellIdentifier];
    }
    
    RHClip *clip = _clips[indexPath.row];
    cell.textLabel.text = clip.title;
    cell.textLabel.textColor = UIColor.blackColor;
    cell.textLabel.font = _font;
    
    if (clip.quality == RHClipQualityCon)
        cell.textLabel.textColor = UIColor.redColor;
    
    else if (clip.quality == RHClipQualityPro)
        cell.textLabel.textColor = UserDefaults.defaults.darkGreen;
    
    else
        cell.textLabel.textColor = UIColor.blackColor;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    RHClip *clip = _clips[indexPath.row];
    NSString *fileName = clip.videoFileName;
    
    NSURL *url = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/%@",
                                         _vidDir, fileName]];
    
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:url options:nil];
    double midPoint = ((clip.endTime + clip.startTime) / 2.0);
    
    AVAssetImageGenerator *generator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    generator.requestedTimeToleranceAfter =  kCMTimeZero;
    generator.requestedTimeToleranceBefore =  kCMTimeZero;
    
    CMTime time = CMTimeMake((midPoint * 1000), 1000);
    NSError *error = nil;
    
    CGImageRef imageRef = [generator copyCGImageAtTime:time
                                            actualTime:NULL
                                                 error:&error];
    
    if (!error)
        _imageView.image = [[UIImage alloc] initWithCGImage:imageRef];
    
    else {NSLog(@"CGImageRef ERROR: %@", error.localizedDescription);}
    
    CGImageRelease(imageRef);
    
}

@end
