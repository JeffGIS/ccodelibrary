//  GetPlaceAreaFile.h
//  CCodeLibrary

#define AF_OK 0
#define AF_FAILED 101

#import <Foundation/Foundation.h>
#import "FTPDataPull.h"
#import "GSSiPopoverView.h"

@class GetPlaceAreaFile;

@protocol GetPlaceAreaFileDelegate <NSObject>

- (void)getPlaceAreaFile:(GetPlaceAreaFile *)server
              didGetFile:(NSString *)path
              withStatus:(int)status;

@end

@interface GetPlaceAreaFile : NSObject<FTPDataPullDelegate>
@property (nonatomic, weak) id <GetPlaceAreaFileDelegate> delegate;

- (BOOL)getPlaceAreaFile:(GSSiPopoverView*)popover
                forGeoid:(int)geoid;

@end
