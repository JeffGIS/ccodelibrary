//  NVSpreadsheetCell.m
//  CCodeLibrary

#import "NVSpreadsheetCell.h"

@implementation NVGridCell

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
        
        CGRect rect = CGRectMake(0.0, 0.0, frame.size.width, frame.size.height);
        _textLabel = [[UILabel alloc] initWithFrame:rect];
        _textLabel.backgroundColor = UIColor.clearColor;
        _textLabel.textAlignment = NSTextAlignmentCenter;
        _textLabel.adjustsFontSizeToFitWidth = YES;
        _textLabel.numberOfLines = 0;
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
        
        CGRect rect = CGRectMake((_idSize + 2.0), 0.0, (frame.size.width - (_idSize + 6.0)), frame.size.height);
        _textLabel = [[UILabel alloc] initWithFrame:rect];
        _textLabel.backgroundColor = UIColor.clearColor;
        _textLabel.textAlignment = NSTextAlignmentCenter;
        _textLabel.adjustsFontSizeToFitWidth = YES;
        _textLabel.font = [UIFont boldSystemFontOfSize:18.0];
        _textLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self.contentView addSubview:_textLabel];
        
        _idLabel = [[UILabel alloc] initWithFrame:CGRectMake(1.0, 1.0, _idSize, _idSize)];
        _idLabel.backgroundColor = UIColor.clearColor;
        _idLabel.adjustsFontSizeToFitWidth = YES;
        _idLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self.contentView addSubview:_idLabel];
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
             _textLabel.font = [UIFont boldSystemFontOfSize:14.0];
            _idSize = 12.0;
        }
        
        else
        {
            _textLabel.font = [UIFont boldSystemFontOfSize:20.0];
            _idSize = 16.0;
        }
        
        CGRect rect = CGRectMake((_idSize + 2.0), 0.0, (frame.size.width - (_idSize + 6.0)), frame.size.height);
        _textLabel = [[UILabel alloc] initWithFrame:rect];
        _textLabel.backgroundColor = UIColor.clearColor;
        
        if (UIDevice.currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPhone)
            _textLabel.font = [UIFont boldSystemFontOfSize:14.0];
        
        else
            _textLabel.font = [UIFont boldSystemFontOfSize:20.0];
        
        _textLabel.adjustsFontSizeToFitWidth = YES;
        _textLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self.contentView addSubview:_textLabel];
        
        _idLabel = [[UILabel alloc] initWithFrame:CGRectMake(1.0, 1.0, _idSize, _idSize)];
        _idLabel.backgroundColor = UIColor.clearColor;
        _idLabel.adjustsFontSizeToFitWidth = YES;
        _idLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self.contentView addSubview:_idLabel];
    }
    
    return self;
}

@end
