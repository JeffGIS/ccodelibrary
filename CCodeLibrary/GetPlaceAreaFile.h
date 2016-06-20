//  GetPlaceAreaFile.h
//  CCodeLibrary

#import <Foundation/Foundation.h>
#import "FTPDataPull.h"
#import "GSSiPopoverView.h"
#import "GSSiEnums.h"

@class GetPlaceAreaFile;

@protocol GetPlaceAreaFileDelegate <NSObject>

- (void)getPlaceAreaFile:(GetPlaceAreaFile *)server
              didGetFile:(NSString *)path
              withStatus:(AreaFileStatus)status
         andStatusString:(NSString*)statusString;

@end

@interface GetPlaceAreaFile : NSObject <FTPDataPullDelegate>

@property (nonatomic, weak) id <GetPlaceAreaFileDelegate> delegate;
@property FTPDataPull *pull;

- (BOOL)getPlaceAreaFile:(GSSiPopoverView*)popover
                forGeoid:(int)geoid;

@end