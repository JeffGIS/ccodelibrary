//  NVSpreadsheetCell.m
//  CCodeLibrary

#import "NVSpreadsheetCell.h"

@implementation NVCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self)
    {
        if (UIDevice.currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPhone)
        {
            _textLabel.font = [UIFont boldSystemFontOfSize:12.0];
            _idSize = 12.0;
        }
        
        else
        {
            _textLabel.font = [UIFont boldSystemFontOfSize:18.0];
            _idSize = 16.0;
        }
    }
    
    return self;
}

- (void)setSelected:(BOOL)selected
{
    [super setSelected:selected];
    
    if (selected)
        [self.contentView setBackgroundColor:UIColor.lightGrayColor];
    
    else
        [self.contentView setBackgroundColor:UIColor.clearColor];
}

- (void)setHighlighted:(BOOL)highlighted
{
    [super setHighlighted:highlighted];
    
    if (highlighted)
        [self.contentView setBackgroundColor:UIColor.lightGrayColor];
    
    else
        [self.contentView setBackgroundColor:UIColor.clearColor];
}

@end

@implementation NVGridCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self)
    {
        CGRect rect = CGRectMake(0.0, 0.0, frame.size.width, frame.size.height);
        self.textLabel = [[UILabel alloc] initWithFrame:rect];
        self.textLabel.backgroundColor = UIColor.clearColor;
        self.textLabel.textAlignment = NSTextAlignmentCenter;
        self.textLabel.adjustsFontSizeToFitWidth = YES;
        self.textLabel.numberOfLines = 0;
        self.textLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self.contentView addSubview:self.textLabel];
    }
    
    return self;
}

@end

@implementation NVTopRowCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self)
    {
        CGRect rect = CGRectMake((self.idSize + 2.0), 0.0, (frame.size.width - (self.idSize + 6.0)), frame.size.height);
        self.textLabel = [[UILabel alloc] initWithFrame:rect];
        self.textLabel.backgroundColor = UIColor.clearColor;
        self.textLabel.textAlignment = NSTextAlignmentCenter;
        self.textLabel.adjustsFontSizeToFitWidth = YES;
        self.textLabel.font = [UIFont boldSystemFontOfSize:18.0];
        self.textLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self.contentView addSubview:self.textLabel];
        
        self.idLabel = [[UILabel alloc] initWithFrame:CGRectMake(1.0, 1.0, self.idSize, self.idSize)];
        self.idLabel.backgroundColor = UIColor.clearColor;
        self.idLabel.adjustsFontSizeToFitWidth = YES;
        self.idLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self.contentView addSubview:self.idLabel];
    }
    
    return self;
}

@end

@implementation NVLeftColumnCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self)
    {
        if (UIDevice.currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPhone)
        {
            self.textLabel.font = [UIFont boldSystemFontOfSize:14.0];
            self.idSize = 12.0;
        }
        
        else
        {
            self.textLabel.font = [UIFont boldSystemFontOfSize:20.0];
            self.idSize = 16.0;
        }
        
        CGRect rect = CGRectMake((self.idSize + 2.0), 0.0, (frame.size.width - (self.idSize + 6.0)), frame.size.height);
        self.textLabel = [[UILabel alloc] initWithFrame:rect];
        self.textLabel.backgroundColor = UIColor.clearColor;
        
        if (UIDevice.currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPhone)
            self.textLabel.font = [UIFont boldSystemFontOfSize:14.0];
        
        else
            self.textLabel.font = [UIFont boldSystemFontOfSize:20.0];
        
        self.textLabel.adjustsFontSizeToFitWidth = YES;
        self.textLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self.contentView addSubview:self.textLabel];
        
        self.idLabel = [[UILabel alloc] initWithFrame:CGRectMake(1.0, 1.0, self.idSize, self.idSize)];
        self.idLabel.backgroundColor = UIColor.clearColor;
        self.idLabel.adjustsFontSizeToFitWidth = YES;
        self.idLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self.contentView addSubview:self.idLabel];
    }
    
    return self;
}

@end
