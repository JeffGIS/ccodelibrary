//  StringFunctions.m
//  CCodeLibrary

#import "UserDefaults.h"
#import "shr.h"
#import "StringFunctions.h"
#import "Reachability.h"
#import <sys/utsname.h>
#import "NVAlertView.h"
#import "CRAPI.h"

static BOOL useMasterID = FALSE;
static BOOL useDemoID = FALSE;
static int useIDInc = 0;

UIColor *UIColorFromInt (unsigned int ival)
{
    UIColor *uiColor;
#pragma pack(1)
    typedef struct {unsigned char r,g,b,a;} RGBC;
#pragma pack()
    RGBC *rgbc = (RGBC*)&ival;
    double r=rgbc->r/255.0,g=rgbc->g/255.0,b=rgbc->b/255.0,a=1;
    uiColor = [UIColor colorWithRed:r green:g blue:b alpha:a];
    return uiColor;
}

BOOL hasNetwork(void)
{
    Reachability *reachability = [Reachability reachabilityWithHostName:@"www.google.com"];
    NetworkStatus remoteHostStatus = reachability.currentReachabilityStatus;
    
    if (!remoteHostStatus)
        return NO;
    
    else
        return YES;
}

NSString *deviceSystemInfo(void)
{
    struct utsname systemInfo;
    uname(&systemInfo);
    
    NSString *deviceSystemInfo = [NSString stringWithCString:systemInfo.machine
                                                    encoding:NSUTF8StringEncoding];
    
    deviceSystemInfo = [deviceSystemInfo stringByReplacingOccurrencesOfString:@","
                                                                   withString:@"|"];
    
    return deviceSystemInfo;
}

NSString *deviceCarrier(void)
{
    CTTelephonyNetworkInfo *networkInfo = CTTelephonyNetworkInfo.new;
    CTCarrier *carrier = networkInfo.subscriberCellularProvider;
    NSString *carrierName =  carrier.carrierName;
    NSString *mobileNetworkCode = carrier.mobileNetworkCode;
    
    if (!carrierName)
        carrierName = @"NONE";
    
    if (!mobileNetworkCode)
        mobileNetworkCode = @"NONE";
    
    NSString *rtn = [NSString stringWithFormat:@"%@|%@", carrierName, mobileNetworkCode];
    
    return rtn;
}

NSString *deviceInfo(void)
{
    UIDevice *device = UIDevice.currentDevice;
    NSString *carrier = deviceCarrier();
    int floatSize = sizeof(CGFloat);
#ifdef DEBUG
    floatSize = -floatSize;
#endif
    NSString * dname = [device.name stringByReplacingOccurrencesOfString:@"," withString:@""];
    return [NSString stringWithFormat:@"%@,%@,%@|%@|%llu|%llu|%@|%i",
            vendorUUIDString(), dname, device.systemVersion, deviceSystemInfo(),
            UIDevice.availableStorageSpace, UIDevice.totalStorageSpace, carrier, floatSize];
}

void SetUseMasterID(BOOL reset)
{
#ifdef DEBUG
    useMasterID = YES;
    if (reset)
    {
        NSString * path = UserDefaults.defaults.sharedFilePath;
        BOOL success = [NSFileManager.defaultManager removeItemAtPath:path
                                                                error:nil];
        path = UserDefaults.defaults.localFilePath;
        success = [NSFileManager.defaultManager removeItemAtPath:path
                                                                error:nil];
    }
#endif
    return;
}

BOOL getUseMasterID (void)
{
    return useMasterID;
}

void SetUseDemoID (BOOL set)
{
    useDemoID = set;
    return;
}

BOOL getUseDemoID (void)
{
    return useDemoID;
}

void SetVendoIDInc (int inc)
{
    useIDInc = inc;
}

NSString *vendorUUIDString(void)
{
    NSString *replacement = [NSString stringWithFormat:@"%4.4i",useIDInc];
    
    NSString *rtn = UIDevice.currentDevice.identifierForVendor.UUIDString;
   // rtn = @"5478594B-6562-4020-BF60-435AE1102289";
    if (useDemoID)
    {
        rtn = @"DEMODEMO-DEMO-DEMO-DEMO-VENDRIDSTRNG";
    }
    else if (useMasterID)
    {
        rtn = @"MSTRMSTR-MSTR-MSTR-MSTR-VENDRIDSTRNG";
    }
    else if (useIDInc)
    {
        NSRange range = NSMakeRange((rtn.length - replacement.length), replacement.length);
        NSMutableString *tempString = [NSMutableString stringWithString:rtn];
        [tempString replaceCharactersInRange:range withString:replacement];
        rtn = tempString.copy;
    }
    
    return rtn;
}

NSString *textBefore(NSString *string, NSString *before)
{
    if (!string)
        return nil;
    
    else if (!string.length)
        return string;
    
    if (before)
    {
        NSRange range = [string rangeOfString:before];
        
        if (range.location != NSNotFound)
            string = [string substringToIndex:(range.location)];
    }
    
    return string;
}

NSString *textUpTo(NSString *string, NSString *upto)
{
    if (!string)
        return nil;
    
    else if (!string.length)
        return string;
    
    if (upto)
    {
        NSRange range = [string rangeOfString:upto];
        
        if (range.location != NSNotFound)
            string = [string substringToIndex:(range.location+upto.length)];
    }
    
    return string;
}

NSString *textAfter(NSString *string, NSString *after)
{
    if (!string)
        return nil;
    
    else if (!string.length)
        return string;
    
    NSString * rtn = @"";
    if (after)
    {
        NSRange range = [string rangeOfString:after];
        
        if (range.location != NSNotFound)
            rtn = [string substringFromIndex:(range.location + after.length)];
    }
    return rtn;
}

NSString *removeEndingReturn(NSString *string)
{
    if (!string)
        return nil;
    
    else if (!string.length)
        return string;
    
    NSString *end = [NSString stringWithFormat:@"%@", [string substringFromIndex:(string.length - 1)]];
    
    if ([end isEqualToString:@"\r"])
        string = [NSString stringWithFormat:@"%@", [string substringToIndex:(string.length - 1)]];
        
        return string;
}

NSString *textAfterHyphen(NSString *string)
{
    if (!string)
        return nil;
    
    else if (!string.length)
        return string;
    
    NSRange range = [string rangeOfString:@"-"];
    
    if (range.location != NSNotFound)
        string = [string substringFromIndex:(range.location + 1)];
    
    return string;
}

NSString *textBeforeHyphen(NSString *string)
{
    if (!string)
        return nil;
    
    else if (!string.length)
        return string;
    
    NSRange range = [string rangeOfString:@"-"];
    
    if (range.location != NSNotFound)
        string = [string substringToIndex:(range.location)];
        
        return string;
}

NSString *textBeforeTab(NSString *string)
{
    if (!string)
        return nil;
    
    else if (!string.length)
        return string;
    
    NSRange range = [string rangeOfString:@"\t"];
    
    if (range.location != NSNotFound)
        string = [string substringToIndex:(range.location)];
        
        return string;
}

NSString *textAfterTab(NSString *string)
{
    if (!string)
        return nil;
    
    else if (!string.length)
        return string;
    
    NSRange range = [string rangeOfString:@"\t"];
    
    if (range.location != NSNotFound)
        string = [string substringFromIndex:(range.location + 1)];
        
        return string;
}

NSString *textAfterLastTab(NSString *string)
{
    if (!string)
        return nil;
    
    else if (!string.length)
        return string;
    
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
    
    else if (!string.length)
        return string;
    
    NSRange range = [string rangeOfString:@"\t"
                                  options:NSBackwardsSearch];
    
    if (range.location != NSNotFound)
        string = [string substringToIndex:range.location];
    
    return string;
}

NSString *textAfterLastChar(NSString *string,NSString* c)
{
    if (!string)
        return nil;
    
    else if (!string.length)
        return string;
    
    NSRange range = [string rangeOfString:c
                                  options:NSBackwardsSearch];
    
    if (range.location != NSNotFound)
        string = [string substringFromIndex:(range.location + 1)];
    
    return string;
}

NSString *textBeforeLastChar(NSString *string,NSString* c)
{
    if (!string)
        return nil;
    
    else if (!string.length)
        return string;
    
    NSRange range = [string rangeOfString:c
                                  options:NSBackwardsSearch];
    
    if (range.location != NSNotFound)
        string = [string substringToIndex:range.location];
    
    return string;
}

NSString *textAfterLastSpace(NSString *string)
{
    if (!string)
        return nil;
    
    else if (!string.length)
        return string;
    
    NSRange range = [string rangeOfString:@" "
                                  options:NSBackwardsSearch];
    
    if (range.location != NSNotFound)
        string = [string substringFromIndex:(range.location + 1)];
    
    return string;
}

NSString *textBeforeSecondTabFromEnd(NSString *string)
{
    if (!string)
        return nil;
    
    else if (!string.length)
        return string;
    
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
    
    else if (!string.length)
        return string;
    
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
    
    else if (!string.length)
        return string;
    
    NSRange range = [string rangeOfString:@"|"];
    
    if (range.location != NSNotFound)
        string = [string substringToIndex:(range.location)];
        
        return string;
}

NSString *textAfterPipe(NSString *string)
{
    if (!string)
        return nil;
    
    else if (!string.length)
        return string;
    
    NSRange range = [string rangeOfString:@"|"];
    
    if (range.location != NSNotFound)
        string = [string substringFromIndex:(range.location + 1)];
        
        return string;
}

NSString *removeTextInsideParentheses(NSString *string)
{
    if (!string)
        return nil;
    
    else if (!string.length)
        return string;
    
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
    
    else if (!string.length)
        return string;
    
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
    
    else if (!string.length)
        return string;
    
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
    
    else if (!string.length)
        return string;
    
    NSRange range = [string rangeOfString:@"("];
    
    if (range.location != NSNotFound)
        string = [string substringToIndex:(range.location)];
        
        return string;
}

NSString *textAfterClosingParentheses(NSString *string)
{
    if (!string)
        return nil;
    
    else if (!string.length)
        return string;
    
    NSRange range = [string rangeOfString:@")" options:NSBackwardsSearch];
    
    if (range.location != NSNotFound)
        string = [string substringFromIndex:(range.location+1)];
        
        return string;
}

NSString *textInsideParentheses(NSString *string)
{
    
    if (!string)
        return nil;
    
    else if (!string.length)
        return string;
    
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
    
    else if (!string.length)
        return string;
    
    NSRange range = [string rangeOfString:@":"];
    
    if (range.location != NSNotFound)
        string = [string substringFromIndex:(range.location + 1)];
        
        return string;
}

NSString *textBeforeColon(NSString *string)
{
    if (!string)
        return nil;
    
    else if (!string.length)
        return string;
    
    NSRange range = [string rangeOfString:@":"];
    
    if (range.location != NSNotFound)
        string = [string substringToIndex:(range.location)];
        
        return string;
}

NSString *textBeforeComma(NSString *string)
{
    if (!string)
        return nil;
    
    else if (!string.length)
        return string;
    
    NSRange range = [string rangeOfString:@","];
    
    if (range.location != NSNotFound)
        string = [string substringToIndex:(range.location)];
        
        return string;
}

NSString *textBeforeSlash(NSString *string)
{
    if (!string)
        return nil;
    
    else if (!string.length)
        return string;
    
    NSRange range = [string rangeOfString:@"/"];
    
    if (range.location != NSNotFound)
        string = [string substringToIndex:(range.location)];
        
        return string;
}

NSString *textAfterSlash(NSString *string)
{
    if (!string)
        return nil;
    
    else if (!string.length)
        return string;
    
    NSRange range = [string rangeOfString:@"/"];
    
    if (range.location != NSNotFound)
        string = [string substringFromIndex:(range.location + 1)];
        
        return string;
}

NSString *includeTextBeforeLastSlash(NSString *string)
{
    if (!string)
        return nil;
    
    else if (!string.length)
        return string;
    
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
    
    else if (!string.length)
        return string;
    
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
    
    else if (!string.length)
        return string;
    
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
    
    else if (!string.length)
        return string;
    
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
    
    else if (!string.length)
        return string;
    
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
    
    else if (!string.length)
        return string;
    
    NSRange range = [string rangeOfString:@"-"];
    
    if (range.location != NSNotFound)
        string = [string substringFromIndex:(range.location + 1)];
        
        return string;
}

NSMutableAttributedString *addLineBreakToLastSpace(NSString *string)
{
    if (!string)
        return nil;
    
    else if (!string.length)
        return string.copy;
    
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
    
    else if (!string.length)
        return string;
    
    else if ([string isEqualToString:@""])
        return @"";
    int len = (int)string.length;
    LPSTR newStr = malloc (len);
    newStr += len;
    *newStr-- = 0;
    LPCSTR oldStr = string.UTF8String;
    while (len--)
    {
        *newStr-- = *oldStr++;
    }
    NSString *reverseString = [NSString stringWithUTF8String:newStr];
/*    NSMutableString *reverseString = [[NSMutableString alloc] init];
    
    [string enumerateSubstringsInRange:NSMakeRange(0, string.length)
                               options:NSStringEnumerationReverse|NSStringEnumerationByComposedCharacterSequences
                            usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
                                [reverseString appendString:substring];
                            }];
*/
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

NSString * splitLine (NSString * line)
{
    NSString *splitLines = nil;
    LPSTR tx = (LPSTR)line.UTF8String;
    int midp = (int)line.length / 2;
    int spliti = 0;
    int mind = INT_MAX;
    int d;
    int i=0;
    
    while (tx[i])
    {
        if (tx[i] == ' ')
        {
            d = abs (i - midp);
            if (d < mind)
            {
                mind = d;
                spliti = i;
            }
        }
        i++;
    }
    if (spliti)
    {
        tx[spliti] = 0;
        splitLines = [NSString stringWithFormat:@"%s\n%s",tx,&tx[spliti+1]];
        tx[spliti] = ' ';
    }
    return splitLines;
}
NSString * splitLongestLine (NSString * text)
{
    NSString * splitText = nil;
    NSString * line;
    NSArray *textLines = [text componentsSeparatedByString:@"\n"];
    int nLines = (int)textLines.count;
    if (nLines)
    {
        int maxLen = 0;
        int maxi = 0;
        for (int i=0;i<nLines;i++)
        {
            line = textLines[i];
            int len = (int)line.length;
            if (len > maxLen)
            {
                maxLen = max (len,maxLen);
                maxi = i;
            }
        }
        line = textLines[maxi];
        NSString * newLine = splitLine (line);
        if (newLine)
        {
            char delim[2] = {0};
            splitText = @"";
            for (int i = 0;i<maxi;i++)
            {
                line = textLines[i];
                splitText = [NSString stringWithFormat:@"%@%s%@",splitText,delim,line];
                delim[0] = '\n';
            }
            splitText = [NSString stringWithFormat:@"%@%s%@",splitText,delim,newLine];
            delim[0] = '\n';
            for (int i = maxi+1;i<nLines;i++)
            {
                line = textLines[i];
                splitText = [NSString stringWithFormat:@"%@%s%@",splitText,delim,line];
                delim[0] = '\n';
            }
        
        }
    }
    return splitText;
}

BOOL appendStringToFile (NSString * str,NSString * filePath)
{
    BOOL rtn;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if(![fileManager fileExistsAtPath:filePath])
    {
        rtn = [str writeToFile:filePath
              atomically:YES
                encoding:NSUTF8StringEncoding
                   error:nil];
    }
    
    else
    {
        NSString *newLine = [NSString stringWithFormat:@"\r\n%@", str];
        NSFileHandle *myHandle = [NSFileHandle fileHandleForWritingAtPath:filePath];
        [myHandle seekToEndOfFile];
        [myHandle writeData:[newLine dataUsingEncoding:NSUTF8StringEncoding]];
        [myHandle closeFile];
        rtn = YES;
    }
    
    return rtn;
}

NSString *urlSearchStringForPID(NSString *PID)
{
    if (!PID || !PID.length || ![PID containsString:@"-"])
    {
        NSLog(@"urlSearchStringForPID ERROR:invalid PID");
        return nil;
    }
    
    NSArray *pidArray = [PID componentsSeparatedByString:@"-"];
    
    if (!pidArray || pidArray.count != 2)
    {
        NSLog(@"urlSearchStringForPID ERROR:invalid PID");
        return nil;
    }
    
    NSString *url = @"NONE";
    NSString *countyCode = pidArray[0];
    NSMutableString *propCode = [NSMutableString stringWithString:pidArray[1]];
    
    if (!countyCode || countyCode.length != 3|| !propCode || !propCode.length)
    {
        NSLog(@"urlSearchStringForPID ERROR:invalid PID");
        return nil;
    }
    
    if ([countyCode isEqualToString:@"019"])//Carver County
    {
        [propCode insertString:@"." atIndex:2];
        url = [NSString stringWithFormat:@"mn-carver.manatron.com/Tabs/TaxSearch/ParcelDetail.aspx?p=%@", propCode.copy];
    }
    
    else if ([countyCode isEqualToString:@"053"])//Hennepin County
        url = [NSString stringWithFormat:@"www16.co.hennepin.mn.us/pins/printdetails.jsp?pid=%@", propCode.copy];
    
    else if ([countyCode isEqualToString:@"123"])//Ramsey County
        url = [NSString stringWithFormat:@"rrinfo.co.ramsey.mn.us/public/characteristic/Parcel.aspx?scrn=Quick&pin=%@", propCode.copy];
    
    else if ([countyCode isEqualToString:@"163"])//Washington County
    {
        [propCode insertString:@"." atIndex:9];
        [propCode insertString:@"." atIndex:7];
        [propCode insertString:@"." atIndex:5];
        [propCode insertString:@"." atIndex:2];
        url = [NSString stringWithFormat:@"mn-washington.manatron.com/Tabs/TaxSearch/AccountDetail.aspx?p=%@", propCode.copy];
    }
    
    return url;
}

BOOL countySupportsLookupForPID(NSString *PID)
{
    if (!PID || !PID.length || ![PID containsString:@"-"])
    {
        NSLog(@"urlSearchStringForPID ERROR:invalid PID");
        return NO;
    }
    
    NSString *countyCode = textBeforeHyphen(PID);
    
    if (!countyCode || countyCode.length != 3)
    {
        NSLog(@"urlSearchStringForPID ERROR:invalid PID");
        return NO;
    }
    
    BOOL rtn = NO;
    
    if ([countyCode isEqualToString:@"019"] || [countyCode isEqualToString:@"053"] ||
        [countyCode isEqualToString:@"123"] || [countyCode isEqualToString:@"163"])
    {
        rtn = YES;
    }
    
    return rtn;
}

CLLocationCoordinate2D locationWithBearing(double bearing, double distanceFeet, CLLocationCoordinate2D origin)
{
    bearing *= DEGtoRAD;
    
    CLLocationCoordinate2D location = {0};
    double distRadians = (distanceFeet / 20908129.3);
    
    double lat1 = ((origin.latitude * M_PI) / 180.0);
    double lon1 = ((origin.longitude * M_PI) / 180.0);
    
    double lat2 = asin(sin(lat1) * cos(distRadians) + cos(lat1) * sin(distRadians) * cos(bearing));
    
    double lon2 = (lon1 + atan2(sin(bearing) * sin(distRadians) * cos(lat1),
                                 cos(distRadians) - sin(lat1) * sin(lat2)));
    
    location.latitude = (lat2 * 180 / M_PI);
    location.longitude = (lon2 * 180 / M_PI);
    
    return location;
}

BOOL isGSSiDevice(void)
{
    NSString *deviceName = UIDevice.currentDevice.name;
    BOOL rtn = NO;
    
    if ([deviceName containsString:@"GSSi"] ||
        [deviceName isEqualToString:@"Jeff's iPhone"] ||
        [deviceName isEqualToString:@"BILLiPhone"])
    {
        rtn = YES;
    }
    
    return rtn;
}
NSString *stringWithID(char * string,int ID)
{
    NSString * rtn = [NSString stringWithFormat:@"%s\x03%i",string,ID];
    return rtn;
}
NSString *stringWithoutID(NSString *string)
{
    return textBefore(string, @"\x03");
}
NSString *paddedString(NSString *str)
{
    return [NSString stringWithFormat:@"%@ ",str];
}

BOOL nameInList(NSString *name,NSArray *list)
{
    for (NSString *curName in list)
    {
        if ([name isEqualToString:[curName lastPathComponent]])
            return YES;
    }
    return NO;
}

LLPOINT LLPOINTFromString (NSString* string)
{
    if (!string)
        string = @"";
    
    LLPOINT pt;
    LPSTR str = malloc (string.length+4);
    strcpy (str,string.UTF8String);
    LPSTR space = strchr (str,' ');
    if (space)
        *space++ = 0;
    else
        space = str;
    pt.lat = atof (str);
    pt.lon = atof (space);
    free (str);
    return pt;
}

NSString * stringToBlob(NSString* str)
{
    if (!str)
        str = @"";
        NSString * blob=@"";
        NSInteger sln = str.length;
        NSInteger lblb = 0;
        if (sln)
        {
            LPSTR blb = malloc (sln*2+4);
            LPSTR cstr = (LPSTR)str.UTF8String;
            for (NSInteger i = 0;i<sln;i++)
            {
                sprintf (&blb[lblb],"%2.2x",cstr[i]);
                lblb += 2;
            }
            blb[lblb] = 0;
            blob = [NSString stringWithUTF8String:blb];
            free (blb);
        }
    return blob;
}

NSString * llpointsToBlob(LLPOINT* pPoints,int nPnts)
{
    NSString * blob=@"";
    NSInteger lBlob = 0;
    LPSTR pBlob = malloc(nPnts * sizeof(LLPOINT)*2 +4);
    for (NSInteger i = 0; i < nPnts; i++)
    {
        NSInteger  j;
        LPBYTE pInts = (LPBYTE)&pPoints[i];
        //unsigned char c;
        for (j = 0; j < sizeof(LLPOINT); j++, pInts++, lBlob += 2)
        {
            //c = *pInts;
            sprintf(&pBlob[lBlob], "%2.2x", *pInts);
        }
    }
    pBlob[lBlob] = 0;
    blob = [NSString stringWithUTF8String:pBlob];
    free (pBlob);
    return blob;
}
NSString * DPOINTSToBlob(DPOINT* pPoints,int nPnts)
{
    NSString * blob=@"";
    NSInteger lBlob = 0;
    LPSTR pBlob = malloc(nPnts * sizeof(DPOINT)*2 +4);
    for (NSInteger i = 0; i < nPnts; i++)
    {
        NSInteger  j;
        LPBYTE pInts = (LPBYTE)&pPoints[i];
        for (j = 0; j < sizeof(DPOINT); j++, pInts++, lBlob += 2)
        {
            sprintf(&pBlob[lBlob], "%2.2x", *pInts);
        }
    }
    pBlob[lBlob] = 0;
    blob = [NSString stringWithUTF8String:pBlob];
    free (pBlob);
    return blob;
}
NSString * doubleToBlob(double val)
{
    NSString * blob=@"";
    NSInteger lBlob = 0;
    LPSTR pBlob = malloc(sizeof(double)*2+4);
    NSInteger  j;
    LPBYTE pInts = (LPBYTE)&val;
    //unsigned char c;
    for (j = 0; j < sizeof(double); j++, pInts++, lBlob += 2)
    {
        //c = *pInts;
        sprintf(&pBlob[lBlob], "%2.2x", *pInts);
    }
    pBlob[lBlob] = 0;
    blob = [NSString stringWithUTF8String:pBlob];
    free (pBlob);
    return blob;
}
NSString * floatToBlob(float val)
{
    NSString * blob=@"";
    NSInteger lBlob = 0;
    LPSTR pBlob = malloc(sizeof(float)*2+4);
    NSInteger  j;
    LPBYTE pInts = (LPBYTE)&val;
    //unsigned char c;
    for (j = 0; j < sizeof(float); j++, pInts++, lBlob += 2)
    {
        //c = *pInts;
        sprintf(&pBlob[lBlob], "%2.2x", *pInts);
    }
    pBlob[lBlob] = 0;
    blob = [NSString stringWithUTF8String:pBlob];
    free (pBlob);
    return blob;
}
NSString * intToBlob(int val)
{
    NSString * blob=@"";
    NSInteger lBlob = 0;
    LPSTR pBlob = malloc(sizeof(int)*2+4);
    NSInteger  j;
    LPBYTE pInts = (LPBYTE)&val;
    //unsigned char c;
    for (j = 0; j < sizeof(int); j++, pInts++, lBlob += 2)
    {
        //c = *pInts;
        sprintf(&pBlob[lBlob], "%2.2x", *pInts);
    }
    pBlob[lBlob] = 0;
    blob = [NSString stringWithUTF8String:pBlob];
    free (pBlob);
    return blob;
}

NSString * ExpandString (NSString * string)
{
    NSString * rtn;
    LPSTR str = malloc (USHRT_MAX);
    strcpy (str,string.UTF8String);
    ExpandText (str);
    rtn = [NSString stringWithUTF8String:str];
    free (str);
    return rtn;
}

BOOL stringContainsCaseInsenitiveString (NSString * str, NSString * substr)
{
    BOOL rtn = YES;
    if (!str || !substr ||
        [str rangeOfString:substr options:NSCaseInsensitiveSearch].location == NSNotFound)
        rtn = NO;
    return rtn;
}

int numberOfOccurencesOfStringInString (NSString *str,NSString *substr)
{
    if (!str || !substr)
        return 0;
    int count = 0;
    NSInteger length = [str length];
    NSRange range = NSMakeRange(0, length);
    while(range.location != NSNotFound)
    {
        range = [str rangeOfString: substr options:0 range:range];
        if(range.location != NSNotFound)
        {
            range = NSMakeRange(range.location + range.length, length - (range.location + range.length));
            count++;
        }
    }
    return count;
}
LPSTR _fullpath (LPSTR fullpath,LPSTR path,int maxpath)
{
    return fullpath;
}
void _splitpath (LPSTR PathName,LPSTR drive,LPSTR dir,LPSTR fname,LPSTR ext)
{
    NSString * str = [NSString stringWithUTF8String:PathName];
    
    NSArray *array = [str pathComponents];
    *drive = 0;
    *dir = 0;
    fname = 0;
    ext = 0;
    
    int i = (int)array.count;
    NSString *element;
    if (i-- > 0)
    {
        element = array[i];
        strcpy (ext,element.UTF8String);
    }
    if (i-- > 0)
    {
        element = array[i];
        strcpy (fname,element.UTF8String);
    }
    if (i-- > 0)
    {
        element = array[i];
        strcpy (dir,element.UTF8String);
    }
    return;
}
DWORD GetTempPath (int len,LPSTR OutStr)
{
    NSURL * path = [NSFileManager.defaultManager temporaryDirectory];
    NSString * cpath = [path absoluteString];
    strncpy (OutStr,cpath.UTF8String,len);
    return 0;
}
void ShowAlert(LPCSTR text)
{
    NSString * txt = [NSString stringWithUTF8String:text];
    showAlert(txt);
}

void showAlert(NSString *text)
{
    [NVAlertView showLargeAlertViewinView:UIApplication.sharedApplication.keyWindow
                                 delegate:CRAPI.sharedInstance
                                    title:text
                          buttonTextArray:@[@"OK"]
                         destructiveIndex:0];
}
