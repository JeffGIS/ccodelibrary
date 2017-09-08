//  FacilitiesStepValue.h
//  CCodeLibrary

@import Foundation;

@interface FacilitiesStepValue : NSObject

@property NSString * stepValueID;
@property NSString * stepDefinitionID;
@property NSString * value;
@property NSString * prompt;
@property NSString * header;
@property NSArray  * photoIDs;
@property NSString * comment;
@property int needPhoto;
@property int numPhotos;
@property int completionStatus;

@end
