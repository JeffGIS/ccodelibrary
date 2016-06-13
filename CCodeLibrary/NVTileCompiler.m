//  NVTileCompiler.m
//  CCodeLibrary

#import "NVTileCompiler.h"
#import "CRAPI.h"
#import "TileGraphics.h"
#import "GSSiDefs.h"
#import "NVAlertView.h"
#import "IntersectionsDatabase.h"

@implementation NVTile

@end

@interface NVTileCompiler () <NSURLSessionDataDelegate,NSURLSessionTaskDelegate>

@property (nonatomic) int intersectionID, zoom, imageCount;
@property (nonatomic) double lat, lon, size;
@property (nonatomic, copy) NSString *imagePath, *cptPath, *maptype;
@property (nonatomic) NSMutableArray *tileDataArray;
@property (nonatomic) UIView *currentView;
@property (nonatomic) UIView *actIndView;

@end

@implementation NVTileCompiler

+ (NVTileCompiler *)compileImageForIntersectionID:(int)intersectionID
                                              lat:(double)lat
                                              lon:(double)lon
                                             zoom:(int)zoom
                                     forceRefresh:(BOOL)forceRefresh
                                         delegate:(id)delegate
                                      currentView:(UIView *)currentView
{
    NVTileCompiler *nvtc = NVTileCompiler.new;
    nvtc.intersectionID = intersectionID;
    nvtc.lat = lat;
    nvtc.lon = lon;
    nvtc.zoom = zoom;
    nvtc.delegate = delegate;
    nvtc.tileDataArray = NSMutableArray.array;
    nvtc.size = 640;
    nvtc.imageCount = 0;
    nvtc.currentView = currentView;
    nvtc.maptype = @"hybrid";
    
    if (forceRefresh)
        [CRAPI.sharedInstance deleteImagesForAllZooms:nvtc.intersectionID];
    
    nvtc.imagePath = [CRAPI.sharedInstance.imageDirectory stringByAppendingPathComponent:
                          [NSString stringWithFormat:@"/Int_%i_%i.jpg", nvtc.intersectionID, nvtc.zoom]];
    
    nvtc.cptPath = [CRAPI.sharedInstance.imageDirectory stringByAppendingPathComponent:
                    [NSString stringWithFormat:@"/Int_%i_%i.cpt", nvtc.intersectionID, nvtc.zoom]];
    
    IntersectionsDatabase *intDB = [IntersectionsDatabase databaseForGeoid:CRAPI.sharedInstance.currentGeoid];
    IntersectionPoint *intPoint = [intDB getCurrentIntersectionPoint:nvtc.intersectionID];
    
    if (intPoint.status == AddedInDetail)
        nvtc.maptype = @"roadmap";
    
    unsigned long long fileSize = [NSFileManager.defaultManager attributesOfItemAtPath:nvtc.imagePath
                                                                                 error:nil].fileSize;
    
    if (fileSize > 0 && !forceRefresh && nvtc.delegate)
    {
        [nvtc.delegate tileCompilerReturnedImagePath:nvtc.imagePath
                                          hideTarget:NO];
    }
    
    else
    {
        if (hasNetwork())
            [nvtc getTileDataAndCount];
        
        else
        {
            [nvtc performSelectorOnMainThread:@selector(presentAlertInCurrentView:)
                                   withObject:@"Network required to download Intersection Image."
                                waitUntilDone:NO];
            
            if (nvtc.delegate)
            {
                [nvtc.delegate tileCompilerReturnedImagePath:[NSBundle.mainBundle pathForResource:@"mapGrid"
                                                                                           ofType:@"png"]
                                                  hideTarget:YES];
            }
        }
    }
    
    return nvtc;
}

- (void)getTileDataAndCount
{
    int worldx = 0, worldy = 0, worldxEnd = 0, worldyEnd = 0;
    int tilex = 0, tiley = 0, tilexLeft, xinc = 0, yinc = 0;
    int xintile = 0, yintile = 0, xintileLeft = 0;
    int xincomposite = 0, yincomposite = 0;
    int nxpixels = 0, nypixels = 0, x = 0, y = 0;
    
    LatLongToPixelXY_old(_lat, _lon, _zoom, &worldx, &worldy);
    
    worldx -= (_size / 2);
    worldy -= (_size / 2);
    worldxEnd = (worldx + _size);
    worldyEnd = (worldy + _size);
    
    PixelXYToTileXY(worldx, worldy, &tilex, &tiley);
    
    tilexLeft = tilex;
    yintile = (worldy % 256);
    yinc = (256 - yintile);
    y = worldy;
    
    while (y < worldyEnd)
    {
        xincomposite = 0;
        x = worldx;
        tilex = tilexLeft;
        xintile = xintileLeft;
        xinc = (256 - xintile);
        
        while (x < worldxEnd)
        {
            nxpixels = min(xinc, (_size - xincomposite));
            nypixels = min(yinc, (_size - yincomposite));
            
            NVTile *tile = [[NVTile alloc] init];
            tile.tilex = tilex;
            tile.tiley = tiley;
            tile.nxpixels = nxpixels;
            tile.nypixels = nypixels;
            tile.xintile = xintile;
            tile.yintile = yintile;
            tile.xincomposite = xincomposite;
            tile.yincomposite = yincomposite;
            tile.mutableData = NSMutableData.data;
            [_tileDataArray addObject:tile];
            
            tilex++;
            x += xinc;
            xinc = 256;
            xincomposite += nxpixels;
            xintile = 0;
        }
        
        tiley++;
        y += yinc;
        yinc = 256;
        yincomposite += nypixels;
        yintile = 0;
    }
    
    [self getTilesFromServer];
}

- (void)getTilesFromServer
{
    if (CRAPI.sharedInstance.currentGeoid == 2743000)
    {
        for (NVTile *tiles in _tileDataArray)
        {
            tiles.filepath = [NSString stringWithFormat:@"%@/%i_%lu_%lu_%lu.jp2",
                              UserDefaults.defaults.sharedFilePath, CRAPI.sharedInstance.currentGeoid,
                              (unsigned long)_zoom, (unsigned long)tiles.tiley, (unsigned long)tiles.tilex];
            
            if ([NSFileManager.defaultManager fileExistsAtPath:tiles.filepath])
                tiles.tileImage = [UIImage imageWithContentsOfFile:tiles.filepath];
            
            else
            {
                NSURLSessionConfiguration *config = NSURLSessionConfiguration.defaultSessionConfiguration;
                config.timeoutIntervalForRequest = 5.0;
                
                NSURLSession *urlSession = [NSURLSession sessionWithConfiguration:config
                                                                         delegate:self
                                                                    delegateQueue:NSOperationQueue.currentQueue];
                
                NSString *url = [NSString stringWithFormat:@"http://gssidata.com/MPLSADA/%lu/%lu/%lu.jp2",
                                 (unsigned long)_zoom, (unsigned long)tiles.tiley, (unsigned long)tiles.tilex];
                
                NSURL *mapUrl = [NSURL URLWithString:[url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
                NSURLSessionDataTask *dataTask = [urlSession dataTaskWithURL:mapUrl];
                
                dataTask.taskDescription = [NSString stringWithFormat:@"%lu",
                                            (unsigned long)[_tileDataArray indexOfObject:tiles]];
                
                [dataTask resume];
            }
        }
    }
    
    else
    {
        NSURLSessionConfiguration *config = NSURLSessionConfiguration.defaultSessionConfiguration;
        config.timeoutIntervalForRequest = 5.0;
        
        NSURLSession *urlSession = [NSURLSession sessionWithConfiguration:config];
        
        NSString *staticMapUrl = [NSString stringWithFormat:
                                  @"https://maps.googleapis.com/maps/api/staticmap?center=%f,%f&zoom=%i&size=640x640&maptype=%@&key=%@",
                                  _lat, _lon, _zoom, _maptype, GOOGLE_API_KEY];
        
        NSURL *mapUrl = [NSURL URLWithString:[staticMapUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        UIImage *image = [UIImage imageWithData: [NSData dataWithContentsOfURL:mapUrl]];
        
        [urlSession finishTasksAndInvalidate];
        [self saveImage:image];
    }
}

- (void)URLSession:(NSURLSession *)session
          dataTask:(NSURLSessionDataTask *)dataTask
    didReceiveData:(NSData *)data
{
    NSUInteger index = dataTask.taskDescription.integerValue;
    NVTile *tile = (NVTile *)_tileDataArray[index];
    [tile.mutableData appendData:data];
    
    if (tile.mutableData.length >= dataTask.countOfBytesExpectedToReceive)
    {
        tile.tileImage = [UIImage imageWithData:tile.mutableData.copy];
        [session finishTasksAndInvalidate];
        _imageCount++;
        
        if (![UIImageJPEGRepresentation(tile.tileImage, 0.8) writeToFile:tile.filepath
                                                              atomically:YES])
        {
            NSLog(@"Tile Image Write ERROR at filepath:%@", tile.filepath);
        }
        
        if (_imageCount == _tileDataArray.count)
            [self compileImage];
    }
}

- (void)URLSession:(NSURLSession *)session
              task:(NSURLSessionTask *)task
didCompleteWithError:(NSError *)error
{
    NSUInteger index = task.taskDescription.integerValue;
    
    if (error)
    {
        NSLog(@"URLSession ERROR (tile %lu):%@", (unsigned long)index,
              error.localizedDescription);
    }
}

- (void)showActivityIndicator
{
    _actIndView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 240.0, 240.0)];
    _actIndView.center = _currentView.center;
    
    _actIndView.backgroundColor = [UIColor colorWithWhite:0.0
                                                    alpha:0.8];
    
    _actIndView.layer.cornerRadius = 20.0;
    [_currentView addSubview:_actIndView];
    
    UIActivityIndicatorView *actInd = [[UIActivityIndicatorView alloc]
                                       initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    
    actInd.transform = CGAffineTransformMakeScale(2.0, 2.0);
    
    actInd.center = CGPointMake((_actIndView.frame.size.width / 2.0),
                                (_actIndView.frame.size.height / 2.0));
    
    [_actIndView addSubview:actInd];
    [actInd startAnimating];
}

- (void)compileImage
{
    UIGraphicsBeginImageContext(CGSizeMake(_size, _size));
    
    for (NVTile *tiles in _tileDataArray)
    {
        CGImageRef subimage = CGImageCreateWithImageInRect(tiles.tileImage.CGImage,
                                                           CGRectMake(tiles.xintile, tiles.yintile,
                                                                      tiles.nxpixels, tiles.nypixels));
        
        UIImage *image = [UIImage imageWithCGImage:subimage];
        CGImageRelease(subimage);
        
        [image drawInRect:CGRectMake(tiles.xincomposite, tiles.yincomposite,
                                     tiles.nxpixels, tiles.nypixels)];
    }
    
    UIImage *compositeImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    [self saveImage:compositeImage];
}

- (void)saveImage:(UIImage *)image
{
    int rtn = [UIImageJPEGRepresentation(image, 0.8) writeToFile:_imagePath
                                                      atomically:YES];
    {
        char txt[1024] = {0};
        double pixelX = 0.0, pixelY = 0.0;
        int factor = pow(2, (21 - _zoom));
        NSError *error = nil;
        
        LatLongToPixelXYd(_lat, _lon, 21, &pixelX, &pixelY);
        
        sprintf(txt, "0 0 %f %f\r\n\
                640 0 %f %f\r\n\
                640 640 %f %f\r\n\
                0 640 %f %f\r\n",
                pixelX - 320 * factor, pixelY + 320 * factor,
                pixelX + 320 * factor, pixelY + 320 * factor,
                pixelX + 320 * factor, pixelY - 320 * factor,
                pixelX - 320 * factor, pixelY - 320 * factor);
        
        NSString *outcontents = [NSString stringWithCString:txt
                                                   encoding:NSUTF8StringEncoding];
        
        if (![outcontents writeToFile:_cptPath
                           atomically:NO
                             encoding:NSUTF8StringEncoding
                                error:&error])
        {
            NSLog(@"Cpt File Write ERROR:%@", error.localizedDescription);
        }
    }
    
    if (!rtn && _currentView)
    {
        [self performSelectorOnMainThread:@selector(presentAlertInCurrentView:)
                               withObject:@"Error getting intersection image. Unable to access server."
                            waitUntilDone:NO];
    }
    
    if (rtn && _delegate)
    {
        [_delegate tileCompilerReturnedImagePath:_imagePath
                                      hideTarget:NO];
    }
}

- (void)presentAlertInCurrentView:(NSString *)message
{
    if (![_currentView viewWithTag:77777])
    {
        NVAlertView *alert = [NVAlertView showLargeAlertViewinView:_currentView
                                                          delegate:_delegate
                                                             title:message
                                                   buttonTextArray:@[@"OK"]
                                                  destructiveIndex:0];
        alert.tag = 77777;
    }
}

@end