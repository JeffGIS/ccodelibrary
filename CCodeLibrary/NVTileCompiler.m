//  NVTileCompiler.m
//  CCodeLibrary

#import "NVTileCompiler.h"
#import "CRAPI.h"
#import "TileGraphics.h"
#import "GSSiDefs.h"
#import "NVAlertView.h"

@implementation NVTile

@end

@interface NVTileCompiler () <NSURLSessionDataDelegate,NSURLSessionTaskDelegate>

@property (nonatomic) int zoom, imageCount;
@property (nonatomic) double size;
@property (nonatomic, copy) NSString *imagePath, *cptPath, *maptype;
@property (nonatomic) NSMutableArray *tileDataArray;
@property (nonatomic) UIView *currentView;
@property (nonatomic) MPIntersection *currentIntersection;

@end

@implementation NVTileCompiler

+ (NVTileCompiler *)compileImageForIntersection:(MPIntersection *)intersection
                                           zoom:(int)zoom
                                   forceRefresh:(BOOL)forceRefresh
                                       delegate:(id)delegate
                                    currentView:(UIView *)currentView
{
    if (!delegate || !currentView || !intersection || !zoom)
    {
        NSLog(@"NVTileCompiler ERROR:Cannot set delegate, currentView, intersection or zoom to nil");
        return nil;
    }
    
    if (![delegate respondsToSelector:@selector(tileCompilerReturnedImagePath:cptPath:hideTarget:)])
    {
        NSLog(@"NVTileCompiler ERROR:Delegate must respond to all selectors in protocol");
        return nil;
    }
    
    NVTileCompiler *nvtc = NVTileCompiler.new;
    nvtc.currentIntersection = intersection;
    nvtc.zoom = zoom;
    nvtc.delegate = delegate;
    nvtc.tileDataArray = NSMutableArray.array;
    nvtc.size = 640;
    nvtc.imageCount = 0;
    nvtc.currentView = currentView;
    nvtc.maptype = @"hybrid";
    
    if (forceRefresh)
        [CRAPI.sharedInstance deleteImagesForAllZooms:nvtc.currentIntersection.intID];
    
    nvtc.imagePath = [CRAPI.sharedInstance.imageDirectory stringByAppendingPathComponent:
                      [NSString stringWithFormat:@"/Int_%i_%i.jpg", nvtc.currentIntersection.intID, nvtc.zoom]];
    
    nvtc.cptPath = [CRAPI.sharedInstance.imageDirectory stringByAppendingPathComponent:
                    [NSString stringWithFormat:@"/Int_%i_%i.cpt", nvtc.currentIntersection.intID, nvtc.zoom]];
    
    if (nvtc.currentIntersection.status == AddedInDetail)
        nvtc.maptype = @"roadmap";
    
    unsigned long long fileSize = [NSFileManager.defaultManager attributesOfItemAtPath:nvtc.imagePath
                                                                                 error:nil].fileSize;
    
    if (fileSize > 0 && !forceRefresh)
    {
        [nvtc.delegate tileCompilerReturnedImagePath:nvtc.imagePath
                                             cptPath:nvtc.cptPath
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
            
            [nvtc saveCptFile];
            
            [nvtc.delegate tileCompilerReturnedImagePath:[NSBundle.mainBundle pathForResource:@"mapGrid"
                                                                                       ofType:@"png"]
                                                 cptPath:nvtc.cptPath
                                              hideTarget:YES];
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
    
    LatLongToPixelXY_old(_currentIntersection.lat, _currentIntersection.lon, _zoom, &worldx, &worldy);
    
    worldx -= (_size / 2);
    worldy -= (_size / 2);
    worldxEnd = (worldx + _size);
    worldyEnd = (worldy + _size);
    
    PixelXYToTileXY(worldx, worldy, &tilex, &tiley);
    
    tilexLeft = tilex;
    xintileLeft = worldx % 256;
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
            //we were setting the tile filepath and checking to see if the tiles are in storage here
            
            /*tiles.filepath = [NSString stringWithFormat:@"%@/%i_%lu_%lu_%lu.jp2",
                              UserDefaults.defaults.sharedFilePath, CRAPI.sharedInstance.currentGeoid,
                              (unsigned long)_zoom, (unsigned long)tiles.tiley, (unsigned long)tiles.tilex];
            
            if ([NSFileManager.defaultManager fileExistsAtPath:tiles.filepath])
                tiles.tileImage = [UIImage imageWithContentsOfFile:tiles.filepath];
            
            else*/
            {
                NSURLSessionConfiguration *config = NSURLSessionConfiguration.defaultSessionConfiguration;
                config.timeoutIntervalForRequest = 5.0;
                
                NSURLSession *urlSession = [NSURLSession sessionWithConfiguration:config
                                                                         delegate:self
                                                                    delegateQueue:NSOperationQueue.currentQueue];
                
                NSString *url = [NSString stringWithFormat:@"http://gssiserver3.com/MPLSADA/%lu/%lu/%lu.jp2",
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
                                  _currentIntersection.lat, _currentIntersection.lon, _zoom, _maptype, GOOGLE_API_KEY];
        
        NSURL *mapUrl = [NSURL URLWithString:[staticMapUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        UIImage *image = [UIImage imageWithData: [NSData dataWithContentsOfURL:mapUrl]];
        
        [urlSession finishTasksAndInvalidate];
        
        if (image)
            [self saveImage:image];
        
        else
        {
            [self performSelectorOnMainThread:@selector(presentAlertInCurrentView:)
                                   withObject:@"Intersection Image Unavailable."
                                waitUntilDone:NO];
            
            [self saveCptFile];
            
            [_delegate tileCompilerReturnedImagePath:[NSBundle.mainBundle pathForResource:@"mapGrid"
                                                                                   ofType:@"png"]
                                             cptPath:_cptPath
                                          hideTarget:YES];
        }
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
        
        //we were writing the tile to file here
        
        /*if (![UIImageJPEGRepresentation(tile.tileImage, 0.8) writeToFile:tile.filepath
                                                              atomically:YES])
        {
            NSLog(@"Tile Image Write ERROR at filepath:%@", tile.filepath);
        }*/
        
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
        [session finishTasksAndInvalidate];
        
        [self performSelectorOnMainThread:@selector(presentAlertInCurrentView:)
                               withObject:@"Intersection Image Unavailable."
                            waitUntilDone:NO];
        
        [self saveCptFile];
        
        [_delegate tileCompilerReturnedImagePath:[NSBundle.mainBundle pathForResource:@"mapGrid"
                                                                               ofType:@"png"]
                                         cptPath:_cptPath
                                      hideTarget:YES];
    }
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

- (void)saveCptFile
{
    char txt[1024] = {0};
    double pixelX = 0.0, pixelY = 0.0;
    int factor = pow(2, (21 - _zoom));
    NSError *error = nil;
    
    LatLongToPixelXYd(_currentIntersection.lat, _currentIntersection.lon, 21, &pixelX, &pixelY);
    
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

- (void)saveImage:(UIImage *)image
{
    int rtn = [UIImageJPEGRepresentation(image, 0.8) writeToFile:_imagePath
                                                      atomically:YES];
    
    [self saveCptFile];
    
    if (!rtn && _currentView)
    {
        [self performSelectorOnMainThread:@selector(presentAlertInCurrentView:)
                               withObject:@"Error getting intersection image. Unable to access server."
                            waitUntilDone:NO];
    }
    
    if (rtn)
    {
        [_delegate tileCompilerReturnedImagePath:_imagePath
                                         cptPath:_cptPath
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