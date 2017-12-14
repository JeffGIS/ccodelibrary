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
    
    [NSNotificationCenter.defaultCenter addObserver:self
                                           selector:@selector(becameActive:)
                                               name:@"didBecomeActive"
                                             object:nil];
}

- (void)resignedActive:(id)selector
{
    [CRAPI.sharedInstance.peerConnect stopBrowsing];
}

- (void)becameActive:(id)selector
{
    [CRAPI.sharedInstance.peerConnect startBrowsing];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [CRAPI.sharedInstance.peerConnect startBrowsing];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [CRAPI.sharedInstance.peerConnect stopBrowsing];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
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

@end
