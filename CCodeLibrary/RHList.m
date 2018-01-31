//  RHList.m
//  CCodeLibrary

#import "RHList.h"
#import "NVSpreadsheetVC.h"
#import "UserDefaults.h"
#import "RHClipEditor.h"
@import AVFoundation;

@interface RHList () <UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, weak) id<NVSpreadsheetVCDelegate> delegate;
@property (nonatomic, copy) NSArray<RHClip *> *clips;
@property (nonatomic) UITableView *tableView;
@property (nonatomic) UIImageView *imageView;
@property (nonatomic) UIButton *returnButton, *editButton;
@property CGFloat fontSize;
@property int propNum;
@property (nonatomic, copy) NSString *vidDir;
@property (nonatomic) UIImage *playImage;
@property SEL playSEL;

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
    
    if (_delegate)
    {
        if ([_delegate respondsToSelector:@selector(clipsForProperty:)])
            _clips = [_delegate clipsForProperty:_propNum];
        
        if ([_delegate respondsToSelector:@selector(vidDirForPropNum:)])
            _vidDir = [_delegate vidDirForPropNum:_propNum];
    }
    
    else {NSLog(@"ERROR: delegate cannot be set to nil.");}
    
    _playImage = [UIImage imageWithContentsOfFile:
                  [NSBundle.mainBundle pathForResource:@"VideoPlayIcon"
                                                ofType:@"png"]];
    
    _playSEL = @selector(playButtonTapped:);
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
    
    _editButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _editButton.translatesAutoresizingMaskIntoConstraints = NO;
    _editButton.backgroundColor = UIColor.clearColor;
    [_editButton setTitle:@"Edit" forState:UIControlStateNormal];
    [_editButton setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    [_editButton setTitleColor:UIColor.lightGrayColor forState:UIControlStateHighlighted];
    _editButton.titleLabel.font = [UIFont boldSystemFontOfSize:_fontSize];
    [self.view addSubview:_editButton];
    [_editButton constrainTrailingToAnchor:self.view.trailingAnchor constant:-10.0];
    [_editButton constrainTopToAnchor:self.view.topAnchor];
    _editButton.hidden = YES;
    
    [_editButton addTarget:self
                    action:@selector(editButtonTapped)
          forControlEvents:UIControlEventTouchUpInside];
    
    _imageView = UIImageView.new;
    _imageView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:_imageView];
    [_imageView constrainTopToAnchor:_returnButton.bottomAnchor];
    [_imageView constrainLeadingToAnchor:self.view.leadingAnchor];
    [_imageView constrainTrailingToAnchor:self.view.trailingAnchor];
    
    _tableView = UITableView.new;
    _tableView.translatesAutoresizingMaskIntoConstraints = NO;
    _tableView.rowHeight = 64.0;
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.delaysContentTouches = NO;
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

- (void)editButtonTapped
{
    RHClip *clip = _clips[_tableView.indexPathForSelectedRow.row];
    
    RHClipEditor *editor = [RHClipEditor editorWithClip:clip
                                               delegate:_delegate];
    
    [self presentViewController:editor animated:YES completion:nil];
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
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                      reuseIdentifier:cellIdentifier];
    }
    
    RHClip *clip = _clips[indexPath.row];
    cell.textLabel.text = clip.title;
    cell.textLabel.font = [UIFont boldSystemFontOfSize:_fontSize * 0.75];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"COST: $%.2f", clip.cost];
    cell.detailTextLabel.font = [UIFont boldSystemFontOfSize:_fontSize * 0.5];
    
    UIButton *playButton = [UIButton buttonWithType:UIButtonTypeCustom];
    playButton.frame = CGRectMake(0.0, 0.0, _tableView.rowHeight, _tableView.rowHeight);
    [playButton setImage:_playImage forState:UIControlStateNormal];
    CGFloat inset = (_tableView.rowHeight * 0.1);
    playButton.imageEdgeInsets = UIEdgeInsetsMake(inset, inset, inset, inset);
    playButton.tag = indexPath.row;
    [playButton addTarget:self action:_playSEL forControlEvents:UIControlEventTouchUpInside];
    cell.accessoryView = playButton;
    
    UIColor *textColor = [RHClip colorForQuality:clip.quality];
    cell.textLabel.textColor = textColor;
    cell.detailTextLabel.textColor = textColor;
    
    if (clip.quality == RHClipQualityNeutral)
        cell.detailTextLabel.text = @"";
    
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
    _editButton.hidden = NO;
}

- (void)playButtonTapped:(UIButton *)button
{
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:button.tag inSection:0];
    
    [_tableView selectRowAtIndexPath:indexPath
                            animated:NO
                      scrollPosition:UITableViewScrollPositionNone];
    
    [self tableView:_tableView didSelectRowAtIndexPath:indexPath];
    
    RHClip *clip = _clips[button.tag];
    RHPlayer *player = [RHPlayer playerWithClip:clip delegate:_delegate];
    [self presentViewController:player animated:YES completion:nil];
}

@end
