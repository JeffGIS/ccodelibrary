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

- (NSNumber *)meanOf;
- (NSNumber *)standardDeviationOf;

@end
