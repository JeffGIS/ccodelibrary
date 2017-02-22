//
//  ArrayOfNumbers.m
//  CCodeLibrary
//
//  Created by Jeff Smith on 2/21/17.
//  Copyright © 2017 GSSi. All rights reserved.
//

#import "ArrayOfNumbers.h"

@implementation ArrayOfNumbers

- (id)initWithArray:(NSArray *)array
{
    self = [super init];
    
    if (self)
    {
        self.array = array;
    }
    
    return self;
}



- (NSNumber *)meanOf
{
    
    double runningTotal = 0.0;
    
    for(NSNumber *number in _array)
    {
        runningTotal += [number doubleValue];
    }
    
    return [NSNumber numberWithDouble:(runningTotal / [_array count])];
}

- (NSNumber *)standardDeviationOf
{
    if(![_array count]) return nil;
    
    double mean = [[self meanOf] doubleValue];
    double sumOfSquaredDifferences = 0.0;
    
    for(NSNumber *number in _array)
    {
        double valueOfNumber = [number doubleValue];
        double difference = valueOfNumber - mean;
        sumOfSquaredDifferences += difference * difference;
    }
    
    return [NSNumber numberWithDouble:sqrt(sumOfSquaredDifferences / [_array count])];
}
@end
