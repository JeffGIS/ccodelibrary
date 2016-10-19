//  NSIndexPath+NVSpreadsheet.m
//  CCodeLibrary

#import "NSIndexPath+NVSpreadsheet.h"

@implementation NSIndexPath (NVSpreadsheet)

- (NSInteger)nvSpreadsheetRow
{
    return self.section;
}

- (NSInteger)nvSpreadsheetColumn
{
    return self.row;
}

@end
