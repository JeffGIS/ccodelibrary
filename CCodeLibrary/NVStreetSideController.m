//  NVStreetSideController.m
//  CCodeLibrary

#import "NVStreetSideController.h"
#import "GSSiDefs.h"
#import "NVAlertView.h"
#import "CRAPI.h"

@interface NVStreetSideController () <UIWebViewDelegate>

@property (nonatomic) CLLocationCoordinate2D location;
@property (nonatomic) UIWebView *webView;
@property (nonatomic) NSTimer *timer;

@end

@implementation NVStreetSideController

+ (instancetype)presentStreetSideInController:(UIViewController *)controller
                          lookingAtCoordinate:(CLLocationCoordinate2D)coordinate
{
    NVStreetSideController *nvssc = NVStreetSideController.new;
    nvssc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    nvssc.location = coordinate;
    [controller presentViewController:nvssc animated:YES completion:nil];
    return nvssc;
}

- (void)loadView
{
    UIView *view = [[UIView alloc] initWithFrame:UIScreen.mainScreen.bounds];
    self.view = view;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSString *html = [NSString stringWithFormat:@"<!DOCTYPE html><html><head><style>"
                      "body{width:100vw;height:100vh;border:0px;margin:0px;padding:0px}"
                      "</style></head><body>"
                      "<div id='printoutPanel' style='display:none';></div>"
                      "<div id='myMap'></div>"
                      "<script type='text/javascript'>"
                      "window.amd = function(){};"
                      "window.amd.define = function(){};"
                      "function loadMapScenario(){"
                      "var pidCoords=new Microsoft.Maps.Location(%f, %f);"
                      "var map=new Microsoft.Maps.Map(document.getElementById('myMap'),{"
                      "credentials:'%@',"
                      "enableHighDpi:true,"
                      "zoom:18,"
                      "pitch:0,"
                      "streetsideOptions:{"
                      "onErrorLoading:onErrorLoading,"
                      "overviewMapMode:Microsoft.Maps.OverviewMapMode.hidden,"
                      "showCurrentAddress:false,"
                      "showExitButton:false,"
                      "locationToLookAt:pidCoords},"
                      "mapTypeId:Microsoft.Maps.MapTypeId.streetside,"
                      "center:pidCoords});"
                      "Microsoft.Maps.Events.addHandler(map,'viewchangeend',function()"
                      "{document.getElementById('printoutPanel').innerHTML='Load Complete';});"
                      "function onErrorLoading(){"
                      "document.getElementById('printoutPanel').innerHTML='No Streetview';}}</script>"
                      "<script type='text/javascript' src="
                      "'https://www.bing.com/api/maps/mapcontrol?branch=release&callback=loadMapScenario' async defer>"
                      "</script></body></html>", _location.latitude, _location.longitude, BING_API_KEY];
    
    _webView = UIWebView.new;
    _webView.translatesAutoresizingMaskIntoConstraints = NO;
    _webView.delegate = self;
    [self.view addSubview:_webView];
    [_webView constrainToView:self.view leading:0.0 trailing:0.0 top:0.0 bottom:0.0];
    
    UIButton *dismissPan = [UIButton buttonWithType:UIButtonTypeCustom];
    dismissPan.translatesAutoresizingMaskIntoConstraints = NO;
    dismissPan.backgroundColor = UIColor.clearColor;
    dismissPan.titleLabel.textAlignment = NSTextAlignmentCenter;
    
    if (UIDevice.currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPhone)
        dismissPan.titleLabel.font = [UIFont boldSystemFontOfSize:28.0];
    
    else
        dismissPan.titleLabel.font = [UIFont boldSystemFontOfSize:40.0];
    
    dismissPan.titleLabel.layer.shadowColor = UIColor.blackColor.CGColor;
    dismissPan.titleLabel.layer.shadowOpacity = 1.0;
    dismissPan.titleLabel.layer.shadowRadius = 4.0;
    dismissPan.titleLabel.layer.shadowOffset = CGSizeZero;
    [dismissPan setTitle:@"< Return" forState:UIControlStateNormal];
    [dismissPan setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    [dismissPan setTitleColor:UIColor.lightGrayColor forState:UIControlStateHighlighted];
    
    [self.view addSubview:dismissPan];
    [dismissPan constrainLeadingToAnchor:self.view.leadingAnchor constant:20.0];
    [dismissPan constrainTopToAnchor:self.view.topAnchor constant:10.0];
    
    [dismissPan addTarget:self
                   action:@selector(dismissPanTapped:)
         forControlEvents:UIControlEventTouchUpInside];
    
    [_webView loadHTMLString:html baseURL:nil];
    
    _timer = [NSTimer scheduledTimerWithTimeInterval:0.5
                                              target:self
                                            selector:@selector(checkForCompletion)
                                            userInfo:nil
                                             repeats:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)dismissPanTapped:(UIButton *)button
{
    [_timer invalidate];
    
    [self dismissViewControllerAnimated:YES
                             completion:nil];
}

- (void)webView:(UIWebView *)webView
didFailLoadWithError:(NSError *)error
{
    [_timer invalidate];
    
    NVAlertView *alert = [NVAlertView showLargeAlertViewinView:self.view
                                                      delegate:CRAPI.sharedInstance
                                                         title:[NSString stringWithFormat:@"Bing Streetside Load ERROR: %@",
                                                                error.localizedDescription]
                                               buttonTextArray:@[@"OK"]
                                              destructiveIndex:0];
#pragma unused(alert)
}

- (void)checkForCompletion
{
    NSString *printoutPanelHtml = [_webView stringByEvaluatingJavaScriptFromString:
                                   @"document.getElementById('printoutPanel').innerHTML"];
    
    if ([printoutPanelHtml isEqualToString:@"No Streetview"])
    {
        [_timer invalidate];
        
        NVAlertView *alert = [NVAlertView showLargeAlertViewinView:self.view
                                                          delegate:CRAPI.sharedInstance
                                                             title:@"Bing Streetside is not available for this location."
                                                   buttonTextArray:@[@"OK"]
                                                  destructiveIndex:0];
#pragma unused(alert)
    }
    
    else if ([printoutPanelHtml isEqualToString:@"Load Complete"])
        [_timer invalidate];
}

@end
