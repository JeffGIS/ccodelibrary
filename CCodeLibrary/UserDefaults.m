//  UserDefaults.m
//  CCodeLibrary

#import "UserDefaults.h"
#import "MathUtil.h"
#import "PriorityLocation.h"
#import "PointInAreaClass.h"
#import "GSSiEnums.h"
#import "CRAPI.h"
#import "GSSiDefs.h"
#import "CurbRampData.h"

#define degreesToRadians(x) (M_PI * x / 180.0)
#define radiansToDegrees(x) (x * 180.0 / M_PI)

@implementation UserDefaults

static UserDefaults *_defaults;

+ (UserDefaults *)defaults
{
    if (!_defaults)
        _defaults = [[UserDefaults alloc] init];
    
    return _defaults;
}

- (id)init
{
    if ((self = [super init]))
        _defaults = NSUserDefaults.standardUserDefaults;

    return self;
}

-(void) doSync
{
    if (![_defaults synchronize])
    {
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Write Error"
                                                                       message:@"Failed to write.\nCheck free space"
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action) {}];
        
        [alert addAction:defaultAction];
        //[self presentViewController:alert animated:YES completion:nil];
    }
}
- (UIColor *)colorForKey:(NSString *)key
{
    CGFloat red = [_defaults floatForKey:[NSString stringWithFormat:@"%@Red", key]];
    CGFloat green = [_defaults floatForKey:[NSString stringWithFormat:@"%@Green", key]];
    CGFloat blue = [_defaults floatForKey:[NSString stringWithFormat:@"%@Blue", key]];

    UIColor *defaultColor = [UIColor colorWithRed:(red / 255.0)
                                            green:(green / 255.0)
                                             blue:(blue / 255.0)
                                            alpha:1.0];
    
    return defaultColor;
}

- (NSInteger)integerForKey:(NSString *)key
{
    NSInteger defaultInteger = [_defaults integerForKey:key];
    return defaultInteger;
}

- (BOOL)boolForKey:(NSString *)key
{
    BOOL defaultBoolean = [_defaults boolForKey:key];
    return defaultBoolean;
}

- (NSString *)stringForKey:(NSString *)key
{
    NSString *defaultString = [_defaults stringForKey:key];
    return defaultString;
}

- (NSArray *)arrayForKey:(NSString *)key
{
    NSArray *defaultArray = [_defaults arrayForKey:key];
    return defaultArray;
}

- (CGFloat)CGFloatForKey:(NSString *)key
{
    CGFloat defaultFloat = [_defaults floatForKey:key];
    return defaultFloat;
}

- (NSData *)NSDataForKey:(NSString *)key
{
    NSData *data = [_defaults objectForKey:key];
    return data;
}

- (NSArray *)locationList
{
    NSArray *locationList = [_defaults arrayForKey:@"LocationList"];
    return locationList;
}

- (NSArray *)iPadList
{
    NSArray *iPadList = [_defaults arrayForKey:@"iPadList"];
    return iPadList;
}

- (NSArray *)geoidList
{
    NSArray *geoidList = [_defaults arrayForKey:@"GeoidsArray"];
    return geoidList;
}

- (UIColor *)appleBlue
{
    UIColor *appleBlue = [UIColor colorWithRed:0.0
                                         green:(122.0 / 255.0)
                                          blue:1.0
                                         alpha:1.0];
    
    return appleBlue;
}

- (UIColor *)lightBlue
{
    UIColor *lightBlue = [UIColor colorWithRed:(204.0 / 255.0)
                                         green:(229.0 / 255.0)
                                          blue:1.0
                                         alpha:1.0];
    
    return lightBlue;
}

- (UIColor *)green
{
    UIColor *green = [UIColor colorWithRed:(160.0 / 255.0)
                                     green:(197.0 / 255.0)
                                      blue:(129.0 / 255.0)
                                     alpha:1.0];
    
    return green;
}

- (UIColor *)darkGreen
{
    UIColor *darkGreen = [UIColor colorWithRed:0.0
                                         green:0.6
                                          blue:0.0
                                         alpha:1.0];
    
    return darkGreen;
}

- (UIColor *)appleGray
{
    UIColor *appleGray = [UIColor colorWithRed:(224.0 / 255.0)
                                         green:(224.0 / 255.0)
                                          blue:(224.0 / 255.0)
                                         alpha:1.0];
    
    return appleGray;
}

- (UIColor *)polygonFillColor
{
    UIColor *polygonFillColor = [UIColor colorWithRed:1.0
                                                green:1.0
                                                 blue:0.0
                                                alpha:0.35];
    
    return polygonFillColor;
}

- (Colors *)defaultColors
{
    Colors *defaultColors = [[Colors alloc] init];
    
    defaultColors.backgroundColor = [UIColor colorWithRed:(240.0 / 255.0)
                                                    green:(255.0 / 255.0)
                                                     blue:(200.0 / 255.0)
                                                    alpha:1.0];
    
    defaultColors.enabledColor = UIColor.blackColor;
    
    defaultColors.disabledColor = [UIColor colorWithRed:(120.0 / 255.0)
                                                  green:(125.0 / 255.0)
                                                   blue:(105.0 / 255.0)
                                                  alpha:1.0];
    
    defaultColors.titleColor = UIColor.whiteColor;
    defaultColors.textColor = UIColor.blackColor;
    defaultColors.highlightedColor = UIColor.lightGrayColor;
    
    return defaultColors;
}

- (UIImage *)checkmark
{
    UIImage *checkmark = [UIImage imageWithContentsOfFile:[NSBundle.mainBundle pathForResource:@"checkmark"
                                                                                        ofType:@"png"]];
    
    return checkmark;
}

- (UIImage *)triangleImage
{
    UIImage *triangleImage = [UIImage imageWithContentsOfFile:[NSBundle.mainBundle pathForResource:@"triangle"
                                                                                            ofType:@"png"]];
    
    return triangleImage;
}

- (UIImage *)redCircle
{
    UIImage *redCircle = [UIImage imageWithContentsOfFile:[NSBundle.mainBundle pathForResource:@"redCircle"
                                                                                        ofType:@"png"]];
    
    return redCircle;
}

- (UIImage *)imageTarget
{
    UIImage *blackImageTarget = [UIImage imageWithContentsOfFile:[NSBundle.mainBundle pathForResource:@"crosshairs160"
                                                                                               ofType:@"png"]];
    
    UIImage *whiteImageTarget = [self invertImage:blackImageTarget];
    return whiteImageTarget;
}

- (UIImage *)yellowArrow
{
    UIImage *yellowArrow = [UIImage imageWithContentsOfFile:[NSBundle.mainBundle pathForResource:@"yellowArrow"
                                                                                          ofType:@"png"]];
    
    return yellowArrow;
}

- (UIImage *)whiteArrow
{
    UIImage *whiteArrow = [UIImage imageWithContentsOfFile:[NSBundle.mainBundle pathForResource:@"whiteArrow"
                                                                                          ofType:@"png"]];
    
    return whiteArrow;
}

- (UIImage *)redArrow
{
    UIImage *redArrow = [UIImage imageWithContentsOfFile:[NSBundle.mainBundle pathForResource:@"redArrow"
                                                                                       ofType:@"png"]];
    
    return redArrow;
}

- (UIImage *)deleteButton
{
    UIImage *deleteButton = [UIImage imageWithContentsOfFile:[NSBundle.mainBundle pathForResource:@"deleteButton"
                                                                                           ofType:@"png"]];
    
    return deleteButton;
}

- (UIImage *)googleMapsImage
{
    UIImage *googleMapsImage = [UIImage imageWithContentsOfFile:[NSBundle.mainBundle pathForResource:@"googleMaps"
                                                                                              ofType:@"png"]];
    
    return googleMapsImage;
}

- (UIImage *)redSliderThumb
{
    UIImage *redSliderThumb = [UIImage imageWithContentsOfFile:[NSBundle.mainBundle pathForResource:@"redSliderThumb"
                                                                                             ofType:@"png"]];
    
    return redSliderThumb;
}

- (UIImage *)metalSliderRight
{
    UIImage *metalSliderRight = [UIImage imageWithContentsOfFile:[NSBundle.mainBundle pathForResource:@"metalSliderRight"
                                                                                               ofType:@"png"]];
    
    return metalSliderRight;
}

- (UIImage *)metalSliderLeft
{
    UIImage *metalSliderLeft = [UIImage imageWithContentsOfFile:[NSBundle.mainBundle pathForResource:@"metalSliderLeft"
                                                                                              ofType:@"png"]];
    
    return metalSliderLeft;
}

- (UIImage *)redSliderThumbPhone
{
    UIImage *redSliderThumbPhone = [UIImage imageWithContentsOfFile:[NSBundle.mainBundle pathForResource:@"redSliderThumbPhone"
                                                                                                  ofType:@"png"]];
    
    return redSliderThumbPhone;
}

- (UIImage *)metalSliderRightPhone
{
    UIImage *metalSliderRightPhone = [UIImage imageWithContentsOfFile:[NSBundle.mainBundle pathForResource:@"metalSliderRightPhone"
                                                                                                    ofType:@"png"]];
    
    return metalSliderRightPhone;
}

- (UIImage *)metalSliderLeftPhone
{
    UIImage *metalSliderLeftPhone = [UIImage imageWithContentsOfFile:[NSBundle.mainBundle pathForResource:@"metalSliderLeftPhone"
                                                                                                   ofType:@"png"]];
    
    return metalSliderLeftPhone;
}

- (NSString *)googleKey
{
    NSString *googleKey = @"AIzaSyB7XIgauC5W-veOVKKdTvkYTO5zQxquw9Q";
    return googleKey;
}

- (UIImage *)invertImage:(UIImage *)image
{
    UIGraphicsBeginImageContext(image.size);
    CGContextSetBlendMode(UIGraphicsGetCurrentContext(), kCGBlendModeCopy);
    CGRect imageRect = CGRectMake(0.0, 0.0, image.size.width, image.size.height);
    [image drawInRect:imageRect];
    
    CGContextSetBlendMode(UIGraphicsGetCurrentContext(), kCGBlendModeDifference);
    CGContextTranslateCTM(UIGraphicsGetCurrentContext(), 0.0, image.size.height);
    CGContextScaleCTM(UIGraphicsGetCurrentContext(), 1.0, -1.0);
    CGContextClipToMask(UIGraphicsGetCurrentContext(), imageRect, image.CGImage);
    CGContextSetFillColorWithColor(UIGraphicsGetCurrentContext(), UIColor.whiteColor.CGColor);
    CGContextFillRect(UIGraphicsGetCurrentContext(), CGRectMake(0.0, 0.0, image.size.width, image.size.height));
    UIImage *returnImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return returnImage;
}

- (void)disableWebKitDiskImageCache
{
    [_defaults setBool:NO
                forKey:@"WebKitDiskImageCacheEnabled"];
    
    [self doSync];
}

- (NSString *)sharedFilePath
{
    NSFileManager *fileManager = NSFileManager.defaultManager;
    NSURL *groupContainerURL = [fileManager containerURLForSecurityApplicationGroupIdentifier:APP_GROUP_ID];
    
    [groupContainerURL setResourceValue:[NSNumber numberWithBool:YES]
                                 forKey:NSURLIsExcludedFromBackupKey
                                  error:nil];
    NSString * path = groupContainerURL.relativePath;
    if (getUseMasterID())
        path = [path stringByAppendingString:@"/MASTER"];
    
    return path;
}

- (NSString *)localFilePath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = paths.firstObject;
    if (getUseMasterID())
        documentsDirectory = [documentsDirectory stringByAppendingString:@"/MASTER"];
    return documentsDirectory;
}

- (NSArray *)realtorList
{
    return @[@"http://www.edinarealty.com", @"http://www.remax.com", @"http://www.trulia.com", @"http://www.zillow.com/homes"];
}

- (void)saveColorWithRed:(CGFloat)red
                   green:(CGFloat)green
                    blue:(CGFloat)blue
                  forKey:(NSString *)key
{
    [_defaults setFloat:red
                 forKey:[NSString stringWithFormat:@"%@Red", key]];
    
    [_defaults setFloat:green
                 forKey:[NSString stringWithFormat:@"%@Green", key]];
    
    [_defaults setFloat:blue
                 forKey:[NSString stringWithFormat:@"%@Blue", key]];
    
    [self doSync];
}

- (void)saveColor:(UIColor *)color
           forKey:(NSString *)key
{
    CGFloat red, green, blue, alpha;
    
    [color getRed:&red
            green:&green
             blue:&blue
            alpha:&alpha];
    
    [_defaults setFloat:(red * 255.0)
                 forKey:[NSString stringWithFormat:@"%@Red", key]];
    
    [_defaults setFloat:(green * 255.0)
                 forKey:[NSString stringWithFormat:@"%@Green", key]];
    
    [_defaults setFloat:(blue * 255.0)
                 forKey:[NSString stringWithFormat:@"%@Blue", key]];
    
    [self doSync];
}

- (void)saveInteger:(int)integer
             forKey:(NSString *)key
{
    [_defaults setInteger:integer
                   forKey:key];
    
    [self doSync];
}

- (void)saveNSInteger:(NSInteger)integer
               forKey:(NSString *)key
{
    [_defaults setInteger:integer
                   forKey:key];
    
    [self doSync];
}

- (void)saveBool:(BOOL)boolean
          forKey:(NSString *)key
{
    [_defaults setBool:boolean
                forKey:key];
    
    [self doSync];
}

- (void)saveString:(NSString *)string
            forKey:(NSString *)key
{
    [_defaults setObject:string
                  forKey:key];
    
    [self doSync];
}

- (void)saveArray:(NSArray *)array
           forKey:(NSString *)key
{
    [_defaults setObject:array
                  forKey:key];
    
    [self doSync];
}

- (void)saveCGFloat:(CGFloat)CGFloat
             forKey:(NSString *)key
{
    [_defaults setFloat:CGFloat
                 forKey:key];
    
    [self doSync];
}

- (void)saveNSData:(NSData *)data
            forKey:(NSString *)key
{
    [_defaults setObject:data
                  forKey:key];
    
    [self doSync];
}

- (void)setStatus:(int)status
         forGeoid:(int)geoid
{
    NSArray *namesArray = [_defaults arrayForKey:@"NamesArray"];
    NSArray *statesArray = [_defaults arrayForKey:@"StatesArray"];
    NSArray *geoidsArray = [_defaults arrayForKey:@"GeoidsArray"];
    NSArray *bounds_wArray = [_defaults arrayForKey:@"Bounds_wArray"];
    NSArray *bounds_sArray = [_defaults arrayForKey:@"Bounds_sArray"];
    NSArray *bounds_eArray = [_defaults arrayForKey:@"Bounds_eArray"];
    NSArray *bounds_nArray = [_defaults arrayForKey:@"Bounds_nArray"];
    NSMutableArray *statusArray = [[NSMutableArray alloc] initWithArray:[_defaults arrayForKey:@"StatusArray"]];
    
    NSUInteger geoidNumber = [geoidsArray indexOfObject:[NSNumber numberWithInt:geoid]];
    
    [statusArray replaceObjectAtIndex:geoidNumber
                           withObject:[NSNumber numberWithInt:status]];
    
    NSArray *locationList = [[NSArray alloc] initWithObjects:namesArray, statesArray, geoidsArray,
                             bounds_wArray, bounds_sArray, bounds_eArray, bounds_nArray, statusArray, nil];
    
    [_defaults setObject:statusArray
                  forKey:@"StatusArray"];
    
    [_defaults setObject:locationList
                  forKey:@"LocationList"];
    
    [self doSync];
}

- (void)addLocationToListWithName:(NSString *)name
                            state:(NSString *)state
                            geoid:(int)geoid
                          dataset:(int)dataset
                         bounds_w:(CGFloat)bounds_w
                         bounds_s:(CGFloat)bounds_s
                         bounds_e:(CGFloat)bounds_e
                         bounds_n:(CGFloat)bounds_n
{
    NSMutableArray *namesArray = [[NSMutableArray alloc] initWithArray:[_defaults arrayForKey:@"NamesArray"]];
    NSMutableArray *statesArray = [[NSMutableArray alloc] initWithArray:[_defaults arrayForKey:@"StatesArray"]];
    NSMutableArray *geoidsArray = [[NSMutableArray alloc] initWithArray:[_defaults arrayForKey:@"GeoidsArray"]];
    NSMutableArray *bounds_wArray = [[NSMutableArray alloc] initWithArray:[_defaults arrayForKey:@"Bounds_wArray"]];
    NSMutableArray *bounds_sArray = [[NSMutableArray alloc] initWithArray:[_defaults arrayForKey:@"Bounds_sArray"]];
    NSMutableArray *bounds_eArray = [[NSMutableArray alloc] initWithArray:[_defaults arrayForKey:@"Bounds_eArray"]];
    NSMutableArray *bounds_nArray = [[NSMutableArray alloc] initWithArray:[_defaults arrayForKey:@"Bounds_nArray"]];
    
    geoid += (dataset * 100000000);
    if (![geoidsArray containsObject:[NSNumber numberWithInt:geoid]])
    {
        int index = 0;
        
        if (namesArray.count > 0)
        {
            NSComparisonResult result = [name compare:[namesArray objectAtIndex:index]
                                              options:(NSCaseInsensitiveSearch|NSDiacriticInsensitiveSearch)];
        
            while (result == NSOrderedDescending)
            {
                index++;
                
                if (index == namesArray.count)
                    break;
           
                result = [name compare:[namesArray objectAtIndex:index]
                               options:(NSCaseInsensitiveSearch|NSDiacriticInsensitiveSearch)];
            }
        }
        
        [namesArray insertObject:name
                         atIndex:index];
        
        [statesArray insertObject:state
                          atIndex:index];
        
        [geoidsArray insertObject:[NSNumber numberWithInt:geoid]
                          atIndex:index];
        
        [bounds_wArray insertObject:[NSNumber numberWithFloat:bounds_w]
                            atIndex:index];
        
        [bounds_sArray insertObject:[NSNumber numberWithFloat:bounds_s]
                            atIndex:index];
        
        [bounds_eArray insertObject:[NSNumber numberWithFloat:bounds_e]
                            atIndex:index];
        
        [bounds_nArray insertObject:[NSNumber numberWithFloat:bounds_n]
                            atIndex:index];
    
        NSArray *locationList = [[NSArray alloc] initWithObjects:namesArray, statesArray, geoidsArray,
                                 bounds_wArray, bounds_sArray, bounds_eArray, bounds_nArray, nil];
    
        [_defaults setObject:namesArray
                      forKey:@"NamesArray"];
    
        [_defaults setObject:statesArray
                      forKey:@"StatesArray"];
    
        [_defaults setObject:geoidsArray
                      forKey:@"GeoidsArray"];
    
        [_defaults setObject:bounds_wArray
                      forKey:@"Bounds_wArray"];
        
        [_defaults setObject:bounds_sArray
                      forKey:@"Bounds_sArray"];
    
        [_defaults setObject:bounds_eArray
                      forKey:@"Bounds_eArray"];
    
        [_defaults setObject:bounds_nArray
                      forKey:@"Bounds_nArray"];
    
        [_defaults setObject:locationList
                      forKey:@"LocationList"];
        
        NSString *key = [NSString stringWithFormat:@"iPads:%i", geoid];
        
        NSString *managerDevice = [NSString stringWithFormat:@"%@(%@)",
                                   vendorUUIDString(),
                                   UIDevice.currentDevice.name];
        
        NSArray *iPadArray = [NSArray arrayWithObject:managerDevice];
        
        [_defaults setObject:iPadArray
                      forKey:key];
    
        [self doSync];
    }
}

- (void)resetPlacesLists
{
    NSMutableArray *namesArray = [[NSMutableArray alloc] init];
    NSMutableArray *statesArray = [[NSMutableArray alloc] init];
    NSMutableArray *geoidsArray = [[NSMutableArray alloc] init];
    NSMutableArray *bounds_wArray = [[NSMutableArray alloc] init];
    NSMutableArray *bounds_sArray = [[NSMutableArray alloc] init];
    NSMutableArray *bounds_eArray = [[NSMutableArray alloc] init];
    NSMutableArray *bounds_nArray = [[NSMutableArray alloc] init];
    NSArray *locationList = [[NSArray alloc] init];
    
    [_defaults setObject:namesArray
                  forKey:@"NamesArray"];
    
    [_defaults setObject:statesArray
                  forKey:@"StatesArray"];
    
    [_defaults setObject:geoidsArray
                  forKey:@"GeoidsArray"];
    
    [_defaults setObject:bounds_wArray
                  forKey:@"Bounds_wArray"];
    
    [_defaults setObject:bounds_sArray
                  forKey:@"Bounds_sArray"];
    
    [_defaults setObject:bounds_eArray
                  forKey:@"Bounds_eArray"];
    
    [_defaults setObject:bounds_nArray
                  forKey:@"Bounds_nArray"];
    
    [_defaults setObject:locationList
                  forKey:@"LocationList"];
    
    [self doSync];
    
}

- (void)removeLocationFromListAtIndex:(NSUInteger)index
{
    NSMutableArray *namesArray = [[NSMutableArray alloc] initWithArray:[_defaults arrayForKey:@"NamesArray"]];
    NSMutableArray *statesArray = [[NSMutableArray alloc] initWithArray:[_defaults arrayForKey:@"StatesArray"]];
    NSMutableArray *geoidsArray = [[NSMutableArray alloc] initWithArray:[_defaults arrayForKey:@"GeoidsArray"]];
    NSMutableArray *bounds_wArray = [[NSMutableArray alloc] initWithArray:[_defaults arrayForKey:@"Bounds_wArray"]];
    NSMutableArray *bounds_sArray = [[NSMutableArray alloc] initWithArray:[_defaults arrayForKey:@"Bounds_sArray"]];
    NSMutableArray *bounds_eArray = [[NSMutableArray alloc] initWithArray:[_defaults arrayForKey:@"Bounds_eArray"]];
    NSMutableArray *bounds_nArray = [[NSMutableArray alloc] initWithArray:[_defaults arrayForKey:@"Bounds_nArray"]];
    NSArray *locationList;
    
    [namesArray removeObjectAtIndex:index];
    
    if (namesArray.count == 0)
    {
        namesArray = statesArray = geoidsArray = bounds_wArray =
        bounds_sArray = bounds_eArray = bounds_nArray = nil;
        
        locationList = nil;
    }
    
    else
    {
        [statesArray removeObjectAtIndex:index];
        [geoidsArray removeObjectAtIndex:index];
        [bounds_wArray removeObjectAtIndex:index];
        [bounds_sArray removeObjectAtIndex:index];
        [bounds_eArray removeObjectAtIndex:index];
        [bounds_nArray removeObjectAtIndex:index];
        
        locationList = [[NSArray alloc] initWithObjects:namesArray, statesArray, geoidsArray,
                        bounds_wArray, bounds_sArray, bounds_eArray, bounds_nArray, nil];
    }
    
    [_defaults setObject:namesArray
                  forKey:@"NamesArray"];
    
    [_defaults setObject:statesArray
                  forKey:@"StatesArray"];
    
    [_defaults setObject:geoidsArray
                  forKey:@"GeoidsArray"];
    
    [_defaults setObject:bounds_wArray
                  forKey:@"Bounds_wArray"];
    
    [_defaults setObject:bounds_sArray
                  forKey:@"Bounds_sArray"];
    
    [_defaults setObject:bounds_eArray
                  forKey:@"Bounds_eArray"];
    
    [_defaults setObject:bounds_nArray
                  forKey:@"Bounds_nArray"];
    
    [_defaults setObject:locationList
                  forKey:@"LocationList"];
    
    [self doSync];
}

- (UIColor *)lightColorForColor:(UIColor *)color
{
    CGFloat red, green, blue, alpha;
    
    [color getRed:&red
            green:&green
             blue:&blue
            alpha:&alpha];
    
    CGFloat lightRed = (1.0 - ((1.0 - red) / 3.0));
    CGFloat lightGreen = (1.0 - ((1.0 - green) / 3.0));
    CGFloat lightBlue = (1.0 - ((1.0 - blue) / 3.0));
    
    UIColor *lightColor = [UIColor colorWithRed:lightRed
                                          green:lightGreen
                                           blue:lightBlue
                                          alpha:1.0];
    
    return lightColor;
}

- (UIColor *)darkColorForColor:(UIColor *)color
{
    CGFloat red, green, blue, alpha;
    
    [color getRed:&red
            green:&green
             blue:&blue
            alpha:&alpha];
    
    CGFloat darkRed = (red / 3.0);
    CGFloat darkGreen = (green / 3.0);
    CGFloat darkBlue = (blue / 3.0);
    
    UIColor *darkColor = [UIColor colorWithRed:darkRed
                                         green:darkGreen
                                          blue:darkBlue
                                         alpha:1.0];
    
    return darkColor;
}

- (BOOL)pickAdjustedTextColorForColor1:(UIColor *)color1
                                color2:(UIColor *)color2
{
    BOOL rtn = NO;
    CGFloat red1, green1, blue1, alpha1;
    CGFloat red2, green2, blue2, alpha2;
    
    [color1 getRed:&red1
             green:&green1
              blue:&blue1
             alpha:&alpha1];
    
    [color2 getRed:&red2
             green:&green2
              blue:&blue2
             alpha:&alpha2];
    
    CGFloat RGB1 = (red1 + green1 + blue1);
    CGFloat RGB2 = (red2 + green2 + blue2);
    
    if (RGB2 > RGB1)
        rtn = YES;
    
    else
        rtn = NO;
    
    return rtn;
}

- (CGFloat)getTotalRGBforColor:(UIColor *)color
{
    CGFloat red, green, blue, alpha;
    
    [color getRed:&red
            green:&green
             blue:&blue
            alpha:&alpha];
    
    CGFloat RGB = (red + green + blue);
    
    return RGB;
}

- (void)shakeButton:(UIButton *)button
{
    CATransform3D transform = CATransform3DMakeRotation(0.08, 0.0, 0.0, 1.0);
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform"];
    animation.toValue = [NSValue valueWithCATransform3D:transform];
    animation.autoreverses = YES;
    animation.duration = 0.1;
    animation.repeatCount =  HUGE_VALF;
    animation.delegate = self;
    
    [button.layer addAnimation:animation
                        forKey:@"shakeAnimation"];
}

- (void)deleteFilesForGeoid:(int)geoid
{
    NSFileManager *fileManager = NSFileManager.defaultManager;
    NSError *error = nil;
    BOOL success = NO, isDir = NO;
    
    //delete PlaceArea.bin file
    NSString *fileName = [NSString stringWithFormat:@"Place_%7.7i_Area.bin", geoid];
    NSString *filePath = [[self sharedFilePath] stringByAppendingPathComponent:fileName];
    
    if ([fileManager fileExistsAtPath:filePath])
    {
        success = [fileManager removeItemAtPath:filePath
                                          error:&error];
        
        if (success)
            NSLog(@"Deleted %@ from device", fileName);
        
        else
            NSLog(@"Could not delete %@:%@ ", fileName, error.localizedDescription);
    }
    
    else
        NSLog(@"%@ was not pulled. No need to delete", fileName);
    
    //delete CurbRamp Database file
    CurbRampData *crd = [CurbRampData databaseForGeoid:geoid
                                                create:NO];
    
    [crd clear];

    //delete IntersectionImages directory
    fileName = [NSString stringWithFormat:@"%i/IntersectionImages", geoid];
    filePath = [[self sharedFilePath] stringByAppendingPathComponent:fileName];
    
    if ([fileManager fileExistsAtPath:filePath
                          isDirectory:&isDir])
    {
        if (isDir)
        {
            success = [fileManager removeItemAtPath:filePath
                                              error:&error];

            if (success)
                NSLog(@"Deleted %@ from device", fileName);
            
            else
                NSLog(@"Could not delete %@:%@ ", fileName, error.localizedDescription);
        }
    }
    
    else
        NSLog(@"%@ was never created", fileName);
}

- (UIImage *)imageWithColor:(UIColor *)color
                  andFrame:(CGRect)frame
{
    {
        UIGraphicsBeginImageContext(frame.size);
        
        UIBezierPath *bezPath = [UIBezierPath bezierPathWithRect:
                                 CGRectMake(0.0, 0.0, frame.size.width, frame.size.height)];
        
        [color setFill];
        [bezPath fill];
        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return image;
    }
}

- (NSArray *)mapStatusOptions
{
    return @[@"Prelim Completion Status", @"Detail Completion Status", @"Ramp Issues", @"Data Quality"];
}

- (NSArray *)mapAssignOptions
{
    return @[@"Assign Prelim Intersections", @"Assign Detail Intersections"];
}

UIImage *grayscaleImage(UIImage *image)
{
    CGRect imageRect = CGRectMake(0, 0, image.size.width, image.size.height);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
    
    CGContextRef context = CGBitmapContextCreate(nil, image.size.width, image.size.height,
                                                 8, 0, colorSpace, (CGBitmapInfo)kCGImageAlphaNone);
    
    CGContextDrawImage(context, imageRect, image.CGImage);
    CGImageRef imageRef = CGBitmapContextCreateImage(context);
    UIImage *grayscaleImage = [UIImage imageWithCGImage:imageRef];
    CGColorSpaceRelease(colorSpace);
    CGContextRelease(context);
    CFRelease(imageRef);
    
    return grayscaleImage;
}

CLLocationDirection getHeading(CLLocationCoordinate2D fromCoord,
                               CLLocationCoordinate2D toCoord)
{
    CGFloat fLat = degreesToRadians(fromCoord.latitude);
    CGFloat fLng = degreesToRadians(fromCoord.longitude);
    CGFloat tLat = degreesToRadians(toCoord.latitude);
    CGFloat tLng = degreesToRadians(toCoord.longitude);
    
    CGFloat degree = radiansToDegrees(atan2(sin(tLng - fLng) * cos(tLat),
                                            cos(fLat) * sin(tLat) - sin(fLat) * cos(tLat) * cos(tLng - fLng)));
    
    if (degree >= 0.0)
        return (CLLocationDirection)degree;
    
    else
        return (CLLocationDirection)(360.0 + degree);
}

@end
