//
//  ArrayOfNumbers.m
//  CCodeLibrary
//
//  Created by Jeff Smith on 2/21/17.
//  Copyright © 2017 GSSi. All rights reserved.
//

#import "ArrayOfNumbers.h"

@implementation ArrayOfNumbers

+ (ArrayOfNumbers*)initWithArray:(NSArray *)array
{
    ArrayOfNumbers * aon = ArrayOfNumbers.new;
    aon.array = array;
    return aon;
}

+ (ArrayOfNumbers*)initWithArray:(NSArray *)array andMultipliers:(NSArray*)multArray;
{
    
    ArrayOfNumbers * aon = ArrayOfNumbers.new;
    
    aon.array = array;
    aon.multArray = multArray;
    
    return aon;
}

- (NSNumber *)meanOf
{
    
    double runningTotal = 0.0;
    int n = 0;
    double totNumValues = 0;
    
    for(NSNumber *number in _array)
    {
        double dmult = 1;
        if (_multArray)
        {
            NSNumber* mult = _multArray[n];
            dmult = mult.doubleValue;
            totNumValues += dmult;
        }
        runningTotal += ([number doubleValue] * dmult);
        n++;
    }
    if (!totNumValues)
        return nil;
    return [NSNumber numberWithDouble:(runningTotal / totNumValues)];
}

- (NSNumber *)standardDeviationOf
{
    if(![_array count]) return nil;
    double dmult = 1;
    int n = 0;
    double totNumValues = 0;
    double mean = [[self meanOf] doubleValue];
    double sumOfSquaredDifferences = 0.0;
    
    for(NSNumber *number in _array)
    {
        double valueOfNumber = [number doubleValue];
        double difference = valueOfNumber - mean;
        if (_multArray)
        {
            NSNumber* mult = _multArray[n];
            dmult = mult.doubleValue;
            totNumValues += dmult;
        }
        sumOfSquaredDifferences += ((difference * difference) * dmult);
        n++;
    }
    if (!totNumValues)
        return nil;
    return [NSNumber numberWithDouble:sqrt(sumOfSquaredDifferences / totNumValues)];
}
@end
