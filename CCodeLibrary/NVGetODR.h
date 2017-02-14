//  NVGetODR.h
//  CCodeLibrary

@class NVGetODR;

@protocol NVGetODRDelegate <NSObject>

- (void)getResourceDidCompleteWithFilePath:(NSString *)filePath
                                    forTag:(NSString *)tag;

- (void)getResourceDidFailWithErrorMsg:(NSString *)errorMsg
                                forTag:(NSString *)tag;

@end

@interface NVGetODR : NSObject

+ (instancetype)getResourcesWithTag:(NSString *)tag
                               type:(NSString *)type
                        toDirectory:(NSString *)toDirectory
                           delegate:(id<NVGetODRDelegate>)delegate;

@end
