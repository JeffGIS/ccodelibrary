//  GetAssignments.h
//  CCodeLibrary

#import <Foundation/Foundation.h>
#import "FTPDataPull.h"
#import "GSSiPopoverView.h"
#import "GSSiEnums.h"

@class GetAssignments;

@protocol GetAssignmentsDelegate <NSObject>

- (void)getAssignments:(GetAssignments *)server
            didGetFile:(NSString *)path
            withStatus:(int)status;

@end

@interface GetAssignments : NSObject <FTPDataPullDelegate>

@property (nonatomic, weak) id <GetAssignmentsDelegate> delegate;

- (BOOL)getAssignments:(GSSiPopoverView *)popover
              forGeoid:(int)geoid
          underManager:(int)manager;

@end