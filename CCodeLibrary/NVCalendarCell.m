//  NVCalendarCell.m
//  CCodeLibrary

#import "NVCalendarCell.h"

@interface NVCalendarCell ()

@end

@implementation NVCalendarCell

- (id)initWithText:(NSString *)text
               tag:(NSUInteger)tag
{
    self = [super init];
    
    if (self)
    {
        self.text = text;
        self.tag = tag;
        self.backgroundColor = UIColor.clearColor;
        self.layer.borderColor = UIColor.blackColor.CGColor;
        self.layer.borderWidth = 2.0;
        self.textColor = UIColor.blackColor;
        self.textAlignment = NSTextAlignmentCenter;
        self.font = [UIFont boldSystemFontOfSize:40.0];
    }
    
    return self;
}

@end