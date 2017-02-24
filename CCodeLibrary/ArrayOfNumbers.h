//
//  ArrayOfNumbers.h
//  CCodeLibrary
//
//  Created by Jeff Smith on 2/21/17.
//  Copyright © 2017 GSSi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ArrayOfNumbers : NSObject

@property NSArray * array;
@property NSArray * multArray;

+ (ArrayOfNumbers*)initWithArray:(NSArray *)array;
+ (ArrayOfNumbers*)initWithArray:(NSArray *)array andMultipliers:(NSArray*)multArray;

- (NSNumber *)meanOf;
- (NSNumber *)standardDeviationOf;

@end
