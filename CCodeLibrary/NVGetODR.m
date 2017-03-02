//  NVGetODR.m
//  CCodeLibrary

#import "NVGetODR.h"
#import "UserDefaults.h"

@interface NVGetODR ()

@property (nonatomic, copy) NSString *tag, *type, *sharedPath;
@property (nonatomic)  NSBundleResourceRequest *resourceRequest;
@property (nonatomic, weak) id<NVGetODRDelegate> delegate;

@end

@implementation NVGetODR

+ (instancetype)getResourcesWithTag:(NSString *)tag
                               type:(NSString *)type
                        toDirectory:(NSString *)toDirectory
                           delegate:(id<NVGetODRDelegate>)delegate
{
    if (!tag || !type || !delegate || !toDirectory)
    {
        NSLog(@"NVGetODR ERROR: cannot set tag OR type OR toDirectory OR delegate to nil.");
        return nil;
    }
    
    NVGetODR *getODR = NVGetODR.new;
    getODR.tag = tag;
    getODR.type = type;
    getODR.sharedPath = [NSString stringWithFormat:@"%@/%@.%@", toDirectory, tag, type];
    getODR.delegate = delegate;
    [getODR checkTags];
    return getODR;
}

- (void)checkTags
{
    if ([NSFileManager.defaultManager fileExistsAtPath:_sharedPath])
    {
        [_delegate getResourceDidCompleteWithFilePath:_sharedPath forTag:_tag];
        return;
    }
    
    NSSet *tags = [NSSet setWithObject:_tag];
    _resourceRequest = [[NSBundleResourceRequest alloc] initWithTags:tags];
    
    [_resourceRequest conditionallyBeginAccessingResourcesWithCompletionHandler:^(BOOL resourcesAvailable)
     {
         if (resourcesAvailable)
         {
             [_resourceRequest endAccessingResources];
             NSLog(@"on demand resources loaded successfully");
             [self copyFilesToSharedDirectory];
         }
         
         else
         {
             [_resourceRequest.progress addObserver:self
                                         forKeyPath:@"fractionCompleted"
                                            options:NSKeyValueObservingOptionNew
                                            context:@"observeForrestLoad"];
             
             [_resourceRequest beginAccessingResourcesWithCompletionHandler:^(NSError * __nullable error)
              {
                  [_resourceRequest.progress removeObserver:self
                                                 forKeyPath:@"fractionCompleted"
                                                    context:@"observeForrestLoad"];
                  
                  if (error)
                  {
                      NSString *errorMsg = [NSString stringWithFormat:@"Resource Download ERROR: %@", error.localizedDescription];
                      [_delegate getResourceDidFailWithErrorMsg:errorMsg forTag:_tag];
                  }
                  
                  else
                  {
                      [self copyFilesToSharedDirectory];
                      [_resourceRequest endAccessingResources];
                      NSLog(@"on demand resources downloaded successfully");
                  }
              }];
         }
     }];
}

- (void)copyFilesToSharedDirectory
{
    NSBundle *bundle = NSBundle.mainBundle;
    NSFileManager *fm = NSFileManager.defaultManager;
    NSError *error = nil;
    
    NSString *bundlePath = [bundle pathForResource:_tag ofType:_type];
    [fm copyItemAtPath:bundlePath toPath:_sharedPath error:&error];
    
    if (error)
    {
        NSString *errorMsg = [NSString stringWithFormat:@"Copy File ERROR: %@", error.localizedDescription];
        [_delegate getResourceDidFailWithErrorMsg:errorMsg forTag:_tag];
    }
    
    else
        [_delegate getResourceDidCompleteWithFilePath:_sharedPath forTag:_tag];
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    if ((object == _resourceRequest.progress) && ([keyPath isEqualToString:@"fractionCompleted"]))
    {
        double progress = _resourceRequest.progress.fractionCompleted;
        NSLog(@"ODR progress: %f", progress);
    }
}

@end
