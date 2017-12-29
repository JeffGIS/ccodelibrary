//  RHPlayer.m
//  CCodeLibrary

#import "RHPlayer.h"
@import AVFoundation;
#import "CRAPI.h"
#import "RHController.h"

@interface RHPlayer () <RHControllerDelegate>

@property BOOL isPlaying;
@property (nonatomic) NSTimer *timer;
@property int seconds, minutes;
@property RHController *controller;

@end

@implementation RHPlayer

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [NSNotificationCenter.defaultCenter addObserver:self
                                           selector:@selector(resignedActive:)
                                               name:@"didResignActive"
                                             object:nil];
}

- (void)resignedActive:(id)selector
{
    [self stopSession];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self setupVideoPlayer];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self stopSession];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationLandscapeRight;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskLandscapeRight;
}

- (BOOL)shouldAutorotate
{
    return NO;
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)stopSession
{
    [CRAPI.sharedInstance.peerConnect stopBrowsing];
    
    _isPlaying = NO;
}

- (void)setupVideoPlayer
{
    _isPlaying = NO;
    
    _controller = RHController.new;
    [_controller showInView:self.view delegate:self];
}

- (void)controllerDidTapPlayRecordButton
{
    
}

- (void)controllerDidTapConnectButton
{
    [CRAPI.sharedInstance.peerConnect startBrowsing];
}

- (void)controllerDidTapReturnButton
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
