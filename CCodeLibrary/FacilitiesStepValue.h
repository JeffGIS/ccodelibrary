//
//  FacilitiesStepValue.h
//  CCodeLibrary
//
//  Created by Jeff Smith on 8/29/17.
//  Copyright © 2017 GSSi. All rights reserved.
//

#import <Foundation/Foundation.h>

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
