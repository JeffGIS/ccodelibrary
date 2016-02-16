//  NVCalendarCell.m
//  CCodeLibrary

#import "NVCalendarCell.h"
#import "UserDefaults.h"
#import "NVColor.h"

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
            self.backgroundColor = UIColor.whiteColor;
        
        if (tag == 1)
        {
            self.backgroundColor = UIColor.clearColor;
            self.textColor = UIColor.whiteColor;
        }
        
        else
            self.textColor = UIColor.blackColor;
            
        
        self.text = text;
        self.tag = tag;
        self.layer.borderColor = UIColor.darkGrayColor.CGColor;
        self.textAlignment = NSTextAlignmentCenter;
        self.adjustsFontSizeToFitWidth = YES;
        
        if (UIDevice.currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPhone)
        {
            self.layer.borderWidth = 1.0;
            self.font = [UIFont boldSystemFontOfSize:18.0];
            
            if (tag == 1)
                self.font = [UIFont boldSystemFontOfSize:24.0];
        }
        
        
        else
        {
            self.layer.borderWidth = 2.0;
            self.font = [UIFont boldSystemFontOfSize:36.0];
            
            if (tag == 1)
                self.font = [UIFont boldSystemFontOfSize:48.0];
        }
    }
    
    return self;
}

- (void)setSelected:(BOOL)selected
{
    _selected = selected;
    
    if (selected)
        self.backgroundColor = NVColor.limeGreenColor;
    
    else
        self.backgroundColor = UIColor.whiteColor;
}

@end