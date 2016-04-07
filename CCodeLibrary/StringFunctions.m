//  StringFunctions.m
//  CCodeLibrary

#import "StringFunctions.h"
#import "MathUtil.h"

NSString *textBefore(NSString *string, NSString *before)
{
    if (!string)
        return nil;
    
    if (before)
    {
        NSRange range = [string rangeOfString:before];
        
        if (range.location != NSNotFound)
            string = [string substringToIndex:(range.location)];
    }
    
    return string;
}

NSString *textAfter(NSString *string, NSString *after)
{
    if (!string)
        return nil;
    
    if (after)
    {
        NSRange range = [string rangeOfString:after];
        
        if (range.location != NSNotFound)
            string = [string substringFromIndex:(range.location + after.length)];
    }
    
    return string;
}

NSString *removeEndingReturn(NSString *string)
{
    if (!string)
        return nil;
    
    NSString *end = [NSString stringWithFormat:@"%@", [string substringFromIndex:(string.length - 1)]];
    
    if ([end isEqualToString:@"\r"])
        string = [NSString stringWithFormat:@"%@", [string substringToIndex:(string.length - 1)]];
        
        return string;
}

NSString *textAfterHyphen(NSString *string)
{
    if (!string)
        return nil;
    
    NSRange range = [string rangeOfString:@"-"];
    
    if (range.location != NSNotFound)
        string = [string substringFromIndex:(range.location + 1)];
        
        return string;
}

NSString *textBeforeHyphen(NSString *string)
{
    if (!string)
        return nil;
    
    NSRange range = [string rangeOfString:@"-"];
    
    if (range.location != NSNotFound)
        string = [string substringToIndex:(range.location)];
        
        return string;
}

NSString *textBeforeTab(NSString *string)
{
    if (!string)
        return nil;
    
    NSRange range = [string rangeOfString:@"\t"];
    
    if (range.location != NSNotFound)
        string = [string substringToIndex:(range.location)];
        
        return string;
}

NSString *textAfterTab(NSString *string)
{
    if (!string)
        return nil;
    
    NSRange range = [string rangeOfString:@"\t"];
    
    if (range.location != NSNotFound)
        string = [string substringFromIndex:(range.location + 1)];
        
        return string;
}

NSString *textAfterLastTab(NSString *string)
{
    if (!string)
        return nil;
    
    NSRange range = [string rangeOfString:@"\t"
                                  options:NSBackwardsSearch];
    
    if (range.location != NSNotFound)
        string = [string substringFromIndex:(range.location + 1)];
        
        return string;
}

NSString *textBeforeLastTab(NSString *string)
{
    if (!string)
        return nil;
    
    NSRange range = [string rangeOfString:@"\t"
                                  options:NSBackwardsSearch];
    
    if (range.location != NSNotFound)
        string = [string substringToIndex:range.location];
        
        return string;
}

NSString *textBeforeSecondTabFromEnd(NSString *string)
{
    if (!string)
        return nil;
    
    NSRange range = [string rangeOfString:@"\t"
                                  options:NSBackwardsSearch];
    
    if (range.location != NSNotFound)
    {
        string = [string substringToIndex:range.location];
        
        range = [string rangeOfString:@"\t"
                              options:NSBackwardsSearch];
        
        if (range.location != NSNotFound)
            string = [string substringToIndex:range.location];
    }
    
    return string;
}

NSString *textAfterSecondTabFromEnd(NSString *string)
{
    if (!string)
        return nil;
    
    NSRange range = [string rangeOfString:@"\t"
                                  options:NSBackwardsSearch];
    
    if (range.location != NSNotFound)
    {
        string = [string substringToIndex:range.location];
        
        range = [string rangeOfString:@"\t"
                              options:NSBackwardsSearch];
        
        if (range.location != NSNotFound)
            string = [string substringFromIndex:(range.location + 1)];
    }
    
    return string;
}

NSString *textBeforePipe(NSString *string)
{
    if (!string)
        return nil;
    
    NSRange range = [string rangeOfString:@"|"];
    
    if (range.location != NSNotFound)
        string = [string substringToIndex:(range.location)];
        
        return string;
}

NSString *textAfterPipe(NSString *string)
{
    if (!string)
        return nil;
    
    NSRange range = [string rangeOfString:@"|"];
    
    if (range.location != NSNotFound)
        string = [string substringFromIndex:(range.location + 1)];
        
        return string;
}

NSString *removeTextInsideParentheses(NSString *string)
{
    if (!string)
        return nil;
    
    NSMutableString *mutableString = [NSMutableString stringWithString:string];
    NSRange start = [mutableString rangeOfString:@"("];
    NSRange end = [mutableString rangeOfString:@")"];
    
    if ((start.location != NSNotFound) && (end.location != NSNotFound))
    {
        [mutableString deleteCharactersInRange:(NSRange){(start.location - 1),
            (end.location - start.location + 2)}];
    }
    
    return mutableString.copy;
}

NSString *removeTextInsideParenthesesWithoutSpaces(NSString *string)
{
    if (!string)
        return nil;
    
    NSMutableString *mutableString = [NSMutableString stringWithString:string];
    NSRange start = [mutableString rangeOfString:@"("];
    NSRange end = [mutableString rangeOfString:@")"];
    
    if ((start.location != NSNotFound) && (end.location != NSNotFound))
        [mutableString deleteCharactersInRange:(NSRange){start.location, (end.location - start.location + 1)}];
    
    return mutableString.copy;
}

NSString *removeColonInsideParentheses(NSString *string)
{
    if (!string)
        return nil;
    
    BOOL deleteMode = NO;
    
    for (int i = 0; i < string.length; i++)
    {
        if ([string characterAtIndex:i] == '(')
            deleteMode = YES;
        
        if ([string characterAtIndex:i] == ')')
            deleteMode = NO;
        
        if ([string characterAtIndex:i] == ':' && deleteMode)
        {
            string = [string stringByReplacingCharactersInRange:NSMakeRange(i,1)
                                                     withString:@""];
            
            i--;
        }
    }
    
    return string;
}

NSString *textBeforeParentheses(NSString *string)
{
    if (!string)
        return nil;
    
    NSRange range = [string rangeOfString:@"("];
    
    if (range.location != NSNotFound)
        string = [string substringToIndex:(range.location)];
        
        return string;
}

NSString *textAfterClosingParentheses(NSString *string)
{
    if (!string)
        return nil;
    
    NSRange range = [string rangeOfString:@")" options:NSBackwardsSearch];
    
    if (range.location != NSNotFound)
        string = [string substringFromIndex:(range.location+1)];
        
        return string;
}

NSString *textInsideParentheses(NSString *string)
{
    if (!string)
        return nil;
    
    NSRange start = [string rangeOfString:@"("];
    NSRange end = [string rangeOfString:@")"];
    
    if ((start.location != NSNotFound) && (end.location != NSNotFound))
    {
        string = [string substringToIndex:end.location];
        string = [string substringFromIndex:(start.location + 1)];
    }
    
    return string;
}

NSString *textAfterFirstColon(NSString *string)
{
    if (!string)
        return nil;
    
    NSRange range = [string rangeOfString:@":"];
    
    if (range.location != NSNotFound)
        string = [string substringFromIndex:(range.location + 1)];
        
        return string;
}

NSString *textBeforeColon(NSString *string)
{
    if (!string)
        return nil;
    
    NSRange range = [string rangeOfString:@":"];
    
    if (range.location != NSNotFound)
        string = [string substringToIndex:(range.location)];
        
        return string;
}

NSString *textBeforeComma(NSString *string)
{
    if (!string)
        return nil;
    
    NSRange range = [string rangeOfString:@","];
    
    if (range.location != NSNotFound)
        string = [string substringToIndex:(range.location)];
        
        return string;
}

NSString *textBeforeSlash(NSString *string)
{
    if (!string)
        return nil;
    
    NSRange range = [string rangeOfString:@"/"];
    
    if (range.location != NSNotFound)
        string = [string substringToIndex:(range.location)];
        
        return string;
}

NSString *textAfterSlash(NSString *string)
{
    if (!string)
        return nil;
    
    NSRange range = [string rangeOfString:@"/"];
    
    if (range.location != NSNotFound)
        string = [string substringFromIndex:(range.location + 1)];
        
        return string;
}

NSString *includeTextBeforeLastSlash(NSString *string)
{
    if (!string)
        return nil;
    
    NSRange range = [string rangeOfString:@"/"
                                  options:NSBackwardsSearch];
    
    if (range.location != NSNotFound)
        string = [string substringToIndex:range.location];
        
        return string;
}

NSString *addSpaceAfterComma(NSString *string)
{
    if (!string)
        return nil;
    
    NSMutableString *mutableString = [NSMutableString stringWithString:string];
    NSRange range = [mutableString rangeOfString:@","];
    
    if (range.location != NSNotFound)
    {
        [mutableString insertString:@" "
                            atIndex:(range.location + 1)];
    }
    
    return mutableString.copy;
}

NSString *addSpaceAfterColon(NSString *string)
{
    if (!string)
        return nil;
    
    NSMutableString *mutableString = [NSMutableString stringWithString:string];
    NSRange range = [mutableString rangeOfString:@":"];
    
    if (range.location != NSNotFound)
    {
        [mutableString insertString:@" "
                            atIndex:(range.location + 1)];
    }
    
    return mutableString.copy;
}

NSString *removeOpeningSpaces(NSString *string)
{
    if (!string)
        return nil;
    
    LPSTR pstring = (LPSTR)string.UTF8String;
    
    while (*pstring && *pstring == ' ')
        pstring++;
    
    string = [NSString stringWithUTF8String:pstring];
    
    return string;
}

NSString *removeOpeningReturn(NSString *string)
{
    if (!string)
        return nil;
    
    LPSTR pstring = (LPSTR)string.UTF8String;
    
    while (*pstring && (*pstring == '\n' || *pstring == '\r'))
        pstring++;
    
    string = [NSString stringWithUTF8String:pstring];
    
    return string;
}

NSString *removePIDPrefix(NSString *string)
{
    if (!string)
        return nil;
    
    NSRange range = [string rangeOfString:@"-"];
    
    if (range.location != NSNotFound)
        string = [string substringFromIndex:(range.location + 1)];
        
        return string;
}

NSMutableAttributedString *addLineBreakToLastSpace(NSString *string)
{
    if (!string)
        return nil;
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:string];
    
    [attributedString addAttribute:NSForegroundColorAttributeName
                             value:UIColor.whiteColor
                             range:NSMakeRange(0, attributedString.length)];
    
    NSMutableAttributedString *append = [[NSMutableAttributedString alloc] initWithString:@"   .\n"];
    
    
    [append addAttribute:NSForegroundColorAttributeName
                   value:UIColor.clearColor
                   range:NSMakeRange(0, append.length)];
    
    NSRange range = [string rangeOfString:@" "
                                  options:NSBackwardsSearch];
    
    if (range.location != NSNotFound)
    {
        [attributedString replaceCharactersInRange:NSMakeRange(range.location, 1)
                              withAttributedString:append];
    }
    
    [append deleteCharactersInRange:NSMakeRange((append.length - 1), 1)];
    [attributedString appendAttributedString:append];
    
    return attributedString;
}

NSString *reverseString(NSString *string)
{
    if (!string)
        return nil;
    
    else if ([string isEqualToString:@""])
        return @"";
    
    NSMutableString *reverseString = [[NSMutableString alloc] init];
    
    [string enumerateSubstringsInRange:NSMakeRange(0, string.length)
                               options:NSStringEnumerationReverse|NSStringEnumerationByComposedCharacterSequences
                            usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
                                [reverseString appendString:substring];
                            }];
    
    return reverseString;
}

NSMutableArray *sortByContentsOfParentheses(NSMutableArray *array)
{
    NSMutableArray *newArray = [[NSMutableArray alloc] init];
    int index = 0;
    
    for (int i = 0; i < array.count; i++)
    {
        if (newArray.count == 0)
            [newArray addObject:array[0]];
        
        else
        {
            NSComparisonResult result = [textInsideParentheses(array[i])
                                         compare:textInsideParentheses(newArray[index])
                                         options:(NSCaseInsensitiveSearch|NSDiacriticInsensitiveSearch)];
            
            while (result == NSOrderedDescending)
            {
                index++;
                
                if (index == newArray.count)
                    break;
                
                result = [textInsideParentheses(array[i])
                          compare:textInsideParentheses(newArray[index])
                          options:(NSCaseInsensitiveSearch|NSDiacriticInsensitiveSearch)];
            }
            
            [newArray insertObject:array[i]
                           atIndex:index];
            
            index = 0;
        }
    }
    
    return newArray;
}

uint occurrencesOfCharacter(unichar character, NSString *string)
{
    uint count = 0;
    
    for(int i = 0; i < string.length; i++)
    {
        if ([string characterAtIndex:i] == character)
            count++;
    }
    
    return count;
}