//
//  StringFunctions.m
//  CCodeLibrary
//
//  Created by JEFFREY E SMITH on 10/16/15.
//  Copyright © 2015 GSSi. All rights reserved.
//

#import "StringFunctions.h"


NSString* textBeforeColon(NSString *string)
{
    NSRange range = [string rangeOfString:@":"];
    
    if (range.location != NSNotFound)
        string = [string substringToIndex:(range.location)];
    
    return string;
}

NSString* textBefore (NSString *string,NSString* before)
{
    NSRange range = [string rangeOfString:before];
    
    if (range.location != NSNotFound)
        string = [string substringToIndex:(range.location)];
    else
        string = @"";
    return string;
}

NSString* textAfter (NSString *string,NSString* after)
{
    NSRange range = [string rangeOfString:after];
    
    if (range.location != NSNotFound)
        string = [string substringFromIndex:(range.location+after.length)];
    else
        string = @"";
    return string;
}
