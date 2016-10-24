//  NVSpreadsheetCell.m
//  CCodeLibrary

#import "NVSpreadsheetCell.h"

@implementation NVGridCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self)
    {
        CGRect rect = CGRectMake(0.0, 0.0, frame.size.width, frame.size.height);
        _textLabel = [[UILabel alloc] initWithFrame:rect];
        _textLabel.backgroundColor = UIColor.clearColor;
        _textLabel.textAlignment = NSTextAlignmentCenter;
        _textLabel.adjustsFontSizeToFitWidth = YES;
        _textLabel.numberOfLines = 0;
        _textLabel.font = [UIFont systemFontOfSize:18.0];
        _textLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self.contentView addSubview:_textLabel];
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

@end

@implementation NVTopRowCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self)
    {
        CGRect rect = CGRectMake(0.0, 0.0, frame.size.width, frame.size.height);
        _textLabel = [[UILabel alloc] initWithFrame:rect];
        _textLabel.backgroundColor = UIColor.clearColor;
        _textLabel.textAlignment = NSTextAlignmentCenter;
        _textLabel.adjustsFontSizeToFitWidth = YES;
        _textLabel.font = [UIFont boldSystemFontOfSize:18.0];
        _textLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self.contentView addSubview:_textLabel];
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
        CGRect rect = CGRectMake(10.0, 0.0, (frame.size.width - 20.0), frame.size.height);
        _textLabel = [[UILabel alloc] initWithFrame:rect];
        _textLabel.backgroundColor = UIColor.clearColor;
        _textLabel.font = [UIFont boldSystemFontOfSize:20.0];
        _textLabel.adjustsFontSizeToFitWidth = YES;
        _textLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self.contentView addSubview:_textLabel];
    }
    
    return self;
}

@end
