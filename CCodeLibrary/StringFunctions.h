//  StringFunctions.h
//  CCodeLibrary

@import UIKit;

NSString *textBefore(NSString *string, NSString *before);
NSString *textAfter(NSString *string, NSString *after);
NSString *removeEndingReturn(NSString *string);
NSString *textAfterHyphen(NSString *string);
NSString *textBeforeHyphen(NSString *string);
NSString *textBeforeTab(NSString *string);
NSString *textAfterTab(NSString *string);
NSString *textAfterLastTab(NSString *string);
NSString *textBeforeLastTab(NSString *string);
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
NSMutableAttributedString *addLineBreakToLastSpace(NSString *string);
NSString *reverseString(NSString *string);
NSMutableArray *sortByContentsOfParentheses(NSMutableArray *array);
uint occurrencesOfCharacter(unichar character, NSString *string);