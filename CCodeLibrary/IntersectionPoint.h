//  IntersectionPoint.h
//  CCodeLibrary

#import <Foundation/Foundation.h>
typedef NS_ENUM(NSInteger, IntersectionStatus)
{
    InitialStatus,
    ComplexStatus,
    PreliminarySurveyComplete,
    OriginalSurveyComplete,
    ScheduledForRebuild,
    IntersectionRebuilt,
    ResurveyedAfterRebuild,
};


@interface IntersectionPoint : NSObject

@property int intID;
@property short assignedTo;
@property IntersectionStatus status;
@property int nramps;
@property double latitude;
@property double longitude;
@property double dist;

@end

@interface IntersectionElement : NSObject

@property int intID;
@property int elementID;
@property int type;
@property int lev21x;
@property int lev21y;
@property double dist;

@end