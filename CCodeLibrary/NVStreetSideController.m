//  NVStreetSideController.m
//  CCodeLibrary

#import "NVStreetSideController.h"
#import "GSSiDefs.h"

@interface NVStreetSideController ()

@property (nonatomic) CLLocationCoordinate2D location;

@end

@implementation NVStreetSideController

+ (instancetype)presentStreetSideInController:(UIViewController *)controller
                          lookingAtCoordinate:(CLLocationCoordinate2D)coordinate
{
    NVStreetSideController *nvssc = NVStreetSideController.new;
    nvssc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    nvssc.location = coordinate;
    
    [controller presentViewController:nvssc
                             animated:YES
                           completion:nil];
    
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
    
    NSString *html = [NSString stringWithFormat:@"\
<!DOCTYPE html><html>\
<head><style>\
body{width:100vw;height:100vh;border:0px;margin:0px;padding:0px}\
</style></head>\
<body>\
<div id='myMap'></div>\
<script type='text/javascript'>\
window.amd = function(){};\
window.amd.define = function(){};\
function loadMapScenario(){\
var pidCoords=new Microsoft.Maps.Location(%f, %f);\
var map=new Microsoft.Maps.Map(document.getElementById('myMap'),{\
credentials:'%@',\
enableHighDpi:true,\
zoom:18,\
pitch:0,\
streetsideOptions:{\
overviewMapMode:Microsoft.Maps.OverviewMapMode.hidden,\
showCurrentAddress:false,\
showExitButton:false,\
locationToLookAt:pidCoords},\
mapTypeId:Microsoft.Maps.MapTypeId.streetside,\
center:pidCoords});}\
</script>\
<script type='text/javascript' src='https://www.bing.com/api/maps/mapcontrol?branch=release&callback=loadMapScenario' async defer>\
</script>\
</body></html>", _location.latitude, _location.longitude, BING_API_KEY];
    
    UIWebView *bingPanView = UIWebView.new;
    bingPanView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:bingPanView];
    [bingPanView constrainToView:self.view leading:0.0 trailing:0.0 top:0.0 bottom:self.tabBarController.tabBar.frame.size.height];
    
    UIButton *dismissPan = [UIButton buttonWithType:UIButtonTypeCustom];
    dismissPan.translatesAutoresizingMaskIntoConstraints = NO;
    dismissPan.backgroundColor = UIColor.clearColor;
    dismissPan.titleLabel.textAlignment = NSTextAlignmentCenter;
    dismissPan.titleLabel.font = [UIFont boldSystemFontOfSize:40.0];
    dismissPan.titleLabel.layer.shadowColor = UIColor.blackColor.CGColor;
    dismissPan.titleLabel.layer.shadowOpacity = 1.0;
    dismissPan.titleLabel.layer.shadowRadius = 3.0;
    dismissPan.titleLabel.layer.shadowOffset = CGSizeZero;
    
    [dismissPan setTitle:@"< Return" forState:UIControlStateNormal];
    [dismissPan setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    [dismissPan setTitleColor:UIColor.lightGrayColor forState:UIControlStateHighlighted];
    
    [self.view addSubview:dismissPan];
    [dismissPan constrainLeadingToAnchor:self.view.leadingAnchor constant:20.0];
    [dismissPan constrainTopToAnchor:self.view.topAnchor constant:20.0];
    
    [dismissPan addTarget:self
                   action:@selector(dismissPanTapped:)
         forControlEvents:UIControlEventTouchUpInside];
    
    [bingPanView loadHTMLString:html baseURL:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)dismissPanTapped:(UIButton *)button
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
