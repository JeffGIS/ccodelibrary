//  NVCalendarCell.m
//  CCodeLibrary

#import "NVCalendarCell.h"
#import "UserDefaults.h"

@interface NVCalendarCell ()

@end

@implementation NVCalendarCell

- (id)initWithText:(NSString *)text
               tag:(NSUInteger)tag
           numDays:(NSInteger)numDays
{
    self = [super init];
    
    if (self)
    {
        if ([text isEqualToString:@"0"] || [text isEqualToString:@"-1"] || [text isEqualToString:@"-2"] ||
            [text isEqualToString:@"-3"] || [text isEqualToString:@"-4"] || [text isEqualToString:@"-5"] ||
            text.integerValue > numDays)
        {
            self.backgroundColor = UIColor.darkGrayColor;
            text = @"";
        }
        
        else if (tag < 9)
            self.backgroundColor = UserDefaults.defaults.appleGray;
        
        else
            self.backgroundColor = UIColor.clearColor;
        
        self.text = text;
        self.tag = tag;
        self.layer.borderColor = UIColor.blackColor.CGColor;
        self.textColor = UIColor.blackColor;
        self.textAlignment = NSTextAlignmentCenter;
        self.adjustsFontSizeToFitWidth = YES;
        
        if (UIDevice.currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPhone)
        {
            self.layer.borderWidth = 1.0;
            self.font = [UIFont boldSystemFontOfSize:18.0];
        }
        
        
        else
        {
            self.layer.borderWidth = 2.0;
            self.font = [UIFont boldSystemFontOfSize:36.0];
        }
    }
    
    return self;
}

@end