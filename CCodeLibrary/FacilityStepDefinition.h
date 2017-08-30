//
//  FacilityStepDefinition.h
//  CCodeLibrary
//
//  Created by Jeff Smith on 8/29/17.
//  Copyright © 2017 GSSi. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, FacilityMeasurementType)
{
    FMTYesNo,
    FMTImageList,
    FMTSlope,
    FMTInches,
    FMTFeet,
    FMTCount,
};

@interface FacilityStepDefinition : NSObject

@property NSString * stepID;
@property NSString * sectionID;
@property NSString * link;
@property Bool photoRequired;
@property FacilityMeasurementType measurementType;
@property NSString * prompt;
@property NSString * test;
@property NSString * command;
@property NSArray * choiceList;
@end
