//  StringFunctions.h
//  CCodeLibrary
#ifndef StringFunctions_h
#define StringFunctions_h

@import UIKit;
@import CoreTelephony;
@import CoreLocation;
#import "CCodeTypes.h"
#import "MathUtil.h"
#import "UIDevice+Storage.h"
#import "ChartsBitmap.h"

int __attribute__ ((noinline)) debugMessage (LPCSTR mess);

NSString *deviceSystemInfo(void);
NSString *deviceCarrier(void);
NSString *deviceInfo(void);
void SetUseMasterID(BOOL reset);
void SetUseDemoID(BOOL set);
void SetVendoIDInc(int inc);
BOOL getUseMasterID(void);
BOOL getUseDemoID(void);
NSString *vendorUUIDString(void);
NSString *stringWithID(char * string,int ID);
NSString *stringWithoutID(NSString *string);
NSString *paddedString(NSString * str);
NSString *textBefore(NSString *string, NSString *before);
NSString *textAfter(NSString *string, NSString *after);
NSString *textUpTo(NSString *string, NSString *upto);
NSString *truncateString (NSString *string);
NSString *removeEndingReturn(NSString *string);
NSString *textAfterHyphen(NSString *string);
NSString *textBeforeHyphen(NSString *string);
NSString *textBeforeTab(NSString *string);
NSString *textAfterTab(NSString *string);
NSString *textAfterLastTab(NSString *string);
NSString *textBeforeLastTab(NSString *string);
NSString *textAfterLastChar(NSString *string,NSString* c);
NSString *textBeforeLastChar(NSString *string,NSString* c);
NSString *textAfterLastSpace(NSString *string);
NSString *textBeforeSecondTabFromEnd(NSString *string);
NSString *textAfterSecondTabFromEnd(NSString *string);
NSString *textBeforePipe(NSString *string);
NSString *textAfterPipe(NSString *string);
NSString *removeTextInsideParentheses(NSString *string);
NSString *removeTextInsideParenthesesWithoutSpaces(NSString *string);
NSString *removeColonInsideParentheses(NSString *string);
NSString *textBeforeParentheses(NSString *string);
NSString *textAfterClosingParentheses(NSString *string);
NSString *textInsideParentheses(NSString *string);
NSString *textAfterFirstColon(NSString *string);
NSString *textBeforeColon(NSString *string);
NSString *textBeforeComma(NSString *string);
NSString *textBeforeSlash(NSString *string);
NSString *textAfterSlash(NSString *string);
NSString *includeTextBeforeLastSlash(NSString *string);
NSString *addSpaceAfterComma(NSString *string);
NSString *addSpaceAfterColon(NSString *string);
NSString *removeOpeningSpaces(NSString *string);
NSString *removeOpeningReturn(NSString *string);
NSString *removePIDPrefix(NSString *string);
NSString * ExpandString (NSString * string);
NSMutableAttributedString *addLineBreakToLastSpace(NSString *string);
NSString *reverseString(NSString *string);
NSString *splitLongestLine(NSString * text);
NSMutableArray *sortByContentsOfParentheses(NSMutableArray *array);
uint occurrencesOfCharacter(unichar character, NSString *string);
BOOL appendStringToFile(NSString *str, NSString *filePath);
NSString *urlSearchStringForPID(NSString *PID);
BOOL countySupportsLookupForPID(NSString *PID);
CLLocationCoordinate2D locationWithBearing(double bearing, double distanceFeet, CLLocationCoordinate2D origin);
BOOL isGSSiDevice(void);
BOOL nameInList(NSString *name, NSArray *list);
LLPOINT LLPOINTFromString(NSString* string);
NSString *stringToBlob(NSString *str);
NSString *llpointsToBlob(LLPOINT *pPoints, int nPnts);
NSString *DPOINTSToBlob(DPOINT *pPoints, int nPnts);
NSString *doubleToBlob(double val);
NSString *floatToBlob(float val);
NSString *intToBlob(int val);
BOOL stringContainsCaseInsenitiveString(NSString * str, NSString *substr);
int numberOfOccurencesOfStringInString(NSString *str, NSString *substr);
UIColor *UIColorFromInt (unsigned int ival);
BOOL hasNetwork(void);
void ShowTheAlert(LPCSTR text);
void showAlert(NSString *text);
void UploadToTheCloud (LPCSTR filePath, BOOL deleteWhenDone);
void uploadToCloud(NSString *filePath, BOOL deleteWhenDone);

#endif
