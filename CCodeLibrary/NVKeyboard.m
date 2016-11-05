//  NVKeyboard.m
//  CCodeLibrary

#import "NVKeyboard.h"
#import "UserDefaults.h"

#define BACKSPACE 21
#define UPPERCASE_LEFT 32
#define UPPERCASE_RIGHT 42
#define DISMISS_KEYBOARD 51

typedef NS_ENUM(NSInteger, NVKeyboardButtonType)
{
    NVKeyboardButtonTypeText,
    NVKeyboardButtonTypeFunction,
};

@interface NVKeyboardButton()

@property NVKeyboardButtonType type;

@end

@implementation NVKeyboardButton

+ (instancetype)buttonWithText:(NSString *)text
{
    NVKeyboardButton *button = NVKeyboardButton.new;
    button.type = NVKeyboardButtonTypeText;
    button.backgroundColor = UIColor.whiteColor;
    [button setTitle:text forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont boldSystemFontOfSize:26.0];
    
    return button;
}

+ (instancetype)functionButton
{
    NVKeyboardButton *button = NVKeyboardButton.new;
    button.type = NVKeyboardButtonTypeFunction;
    button.backgroundColor = UIColor.lightGrayColor;
    button.imageView.contentMode = UIViewContentModeScaleAspectFit;
    button.titleLabel.font = [UIFont systemFontOfSize:24.0];
    button.imageEdgeInsets = UIEdgeInsetsMake(8.0, 8.0, 8.0, 8.0);
    
    return button;
}

- (id)init
{
    self = [super init];
    
    if (self)
    {
        self.translatesAutoresizingMaskIntoConstraints = NO;
        self.layer.cornerRadius = 6.0;
        [self setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
    }
    
    return self;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches
           withEvent:(UIEvent *)event
{
    self.backgroundColor = UIColor.blackColor;
    [self setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    
    switch (self.tag)
    {
        case BACKSPACE:
            [self setImage:[(NVKeyboard *)self.superview whiteBackspace] forState:UIControlStateNormal];
            break;
        
        case UPPERCASE_LEFT:
        case UPPERCASE_RIGHT:
            [self setImage:[(NVKeyboard *)self.superview whiteUpArrow] forState:UIControlStateNormal];
            break;
        
        case DISMISS_KEYBOARD:
            [self setImage:[(NVKeyboard *)self.superview whiteKeyboard] forState:UIControlStateNormal];
            break;
            
        default:
            break;
    }
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches
           withEvent:(UIEvent *)event
{
    [self setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
    
    if (_type == NVKeyboardButtonTypeText)
        self.backgroundColor = UIColor.whiteColor;
    
    else
    {
        self.backgroundColor = UIColor.lightGrayColor;
        
        switch (self.tag)
        {
            case BACKSPACE:
                [self setImage:[(NVKeyboard *)self.superview blackBackspace] forState:UIControlStateNormal];
                break;
            
            case UPPERCASE_LEFT:
            case UPPERCASE_RIGHT:
                [self setImage:[(NVKeyboard *)self.superview blackUpArrow] forState:UIControlStateNormal];
                break;
            
            case DISMISS_KEYBOARD:
                [self setImage:[(NVKeyboard *)self.superview blackKeyboard] forState:UIControlStateNormal];
                
            default:
                break;
        }
    }
    
    UITouch *touch = event.allTouches.anyObject;
    CGPoint loc = [touch locationInView:self.superview];
    
    if (CGRectContainsPoint(self.frame, loc))
    {
        switch (self.tag)
        {
            case UPPERCASE_LEFT:
            case UPPERCASE_RIGHT:
                [(NVKeyboard *)self.superview switchCase];
                break;
            
            case DISMISS_KEYBOARD:
                [(NVKeyboard *)self.superview hide];
                break;
                
            default:
                break;
        }
    }
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches
           withEvent:(UIEvent *)event
{
    UITouch *touch = event.allTouches.anyObject;
    CGPoint loc = [touch locationInView:self.superview];
    
    if (CGRectContainsPoint(self.frame, loc))
    {
        self.backgroundColor = UIColor.blackColor;
        [self setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
        
        switch (self.tag)
        {
            case BACKSPACE:
                [self setImage:[(NVKeyboard *)self.superview whiteBackspace] forState:UIControlStateNormal];
                break;
            
            case UPPERCASE_LEFT:
            case UPPERCASE_RIGHT:
                [self setImage:[(NVKeyboard *)self.superview whiteUpArrow] forState:UIControlStateNormal];
                break;
            
            case DISMISS_KEYBOARD:
                [self setImage:[(NVKeyboard *)self.superview whiteKeyboard] forState:UIControlStateNormal];
                
            default:
                break;
        }
    }
    
    else
    {
        [self setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
        
        if (_type == NVKeyboardButtonTypeText)
            self.backgroundColor = UIColor.whiteColor;
        
        else
        {
            self.backgroundColor = UIColor.lightGrayColor;
            
            switch (self.tag)
            {
                case BACKSPACE:
                    [self setImage:[(NVKeyboard *)self.superview blackBackspace] forState:UIControlStateNormal];
                    break;
                
                case UPPERCASE_LEFT:
                case UPPERCASE_RIGHT:
                    [self setImage:[(NVKeyboard *)self.superview blackUpArrow] forState:UIControlStateNormal];
                    break;
                
                case DISMISS_KEYBOARD:
                    [self setImage:[(NVKeyboard *)self.superview blackKeyboard] forState:UIControlStateNormal];
                    
                default:
                    break;
            }
        }
    }
}

@end

@interface NVKeyboard ()

@property (nonatomic, weak) id <NVKeyboardDelegate> delegate;
@property BOOL isUpperCase;

@end

@implementation NVKeyboard

+ (instancetype)showKeyboardInView:(UIView *)view
                          delegate:(id)delegate
{
    if (!delegate || !view)
    {
        NSLog(@"NVKeyboard ERROR:Cannot set delegate or view to nil");
        return nil;
    }
    
    NVKeyboard *keyboard = NVKeyboard.new;
    keyboard.translatesAutoresizingMaskIntoConstraints = NO;
    keyboard.backgroundColor = UserDefaults.defaults.appleBlue;
    keyboard.delegate = delegate;
    keyboard.isUpperCase = NO;
    keyboard.alpha = 0.0;
    
    keyboard.blackKeyboard = [UIImage imageWithContentsOfFile:[NSBundle.mainBundle pathForResource:@"dismissKeyboard"
                                                                                            ofType:@"png"]];
    
    keyboard.whiteKeyboard = [UserDefaults.defaults invertImage:[UIImage imageWithContentsOfFile:[NSBundle.mainBundle pathForResource:@"dismissKeyboard"
                                                                                                                               ofType:@"png"]]];
    
    keyboard.blackUpArrow = [UIImage imageWithContentsOfFile:[NSBundle.mainBundle pathForResource:@"upArrow"
                                                                                           ofType:@"png"]];
    
    keyboard.whiteUpArrow = [UserDefaults.defaults invertImage:[UIImage imageWithContentsOfFile:[NSBundle.mainBundle pathForResource:@"upArrow"
                                                                                                                              ofType:@"png"]]];
    
    keyboard.blackBackspace = [UIImage imageWithContentsOfFile:[NSBundle.mainBundle pathForResource:@"backspace"
                                                                                             ofType:@"png"]];
    
    keyboard.whiteBackspace = [UserDefaults.defaults invertImage:[UIImage imageWithContentsOfFile:[NSBundle.mainBundle pathForResource:@"backspace"
                                                                                                                                ofType:@"png"]]];
    
    [view addSubview:keyboard];
    [keyboard constrainHeightToConstant:348.0];
    [keyboard constrainLeadingToAnchor:view.leadingAnchor];
    [keyboard constrainTrailingToAnchor:view.trailingAnchor];
    [keyboard constrainBottomToAnchor:view.bottomAnchor];
    
    CGFloat spacing = 8.0, height = 60.0;
    int counter = 1, firstOfLastRow = 1;
    NSArray *row = @[@"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9", @"0"];
    NVKeyboardButton *button = nil;
    
    for (int i = 0; i < row.count; i++)
    {
        button = [NVKeyboardButton buttonWithText:row[i]];
        button.tag = counter++;
        [keyboard addSubview:button];
        [button constrainHeightToConstant:height];
        [button constrainTopToAnchor:keyboard.topAnchor constant:spacing];
        
        if (i == 0)
            [button constrainLeadingToAnchor:keyboard.leadingAnchor constant:spacing];
        
        else
        {
            [button constrainLeadingToAnchor:[keyboard viewWithTag:(counter - 2)].trailingAnchor constant:spacing];
            [button constrainWidthToAnchor:[keyboard viewWithTag:(counter - 2)].widthAnchor];
        }
        
        if (i == (row.count - 1))
            [button constrainTrailingToAnchor:keyboard.trailingAnchor constant:-spacing];
    }
    
    row = @[@"q", @"w", @"e", @"r", @"t", @"y", @"u", @"i", @"o", @"p"];
    
    for (int i = 0; i < row.count; i++)
    {
        button = [NVKeyboardButton buttonWithText:row[i]];
        button.tag = counter++;
        [keyboard addSubview:button];
        [button constrainHeightToConstant:height];
        [button constrainTopToAnchor:[keyboard viewWithTag:firstOfLastRow].bottomAnchor constant:spacing];
        
        if (i == 0)
            [button constrainLeadingToAnchor:keyboard.leadingAnchor constant:(spacing * 2.5)];
        
        else
        {
            [button constrainLeadingToAnchor:[keyboard viewWithTag:(counter - 2)].trailingAnchor constant:spacing];
            [button constrainWidthToAnchor:[keyboard viewWithTag:(counter - 2)].widthAnchor];
        }
    }
    
    button = NVKeyboardButton.functionButton;
    button.tag = counter++;
    [button setImage:keyboard.blackBackspace forState:UIControlStateNormal];
    
    [keyboard addSubview:button];
    [button constrainHeightToConstant:height];
    [button constrainTopToAnchor:[keyboard viewWithTag:firstOfLastRow].bottomAnchor constant:spacing];
    [button constrainLeadingToAnchor:[keyboard viewWithTag:(counter - 2)].trailingAnchor constant:spacing];
    [button constrainWidthToAnchor:[keyboard viewWithTag:(counter - 2)].widthAnchor];
    [button constrainTrailingToAnchor:keyboard.trailingAnchor constant:-spacing];
    
    firstOfLastRow = 11;
    row = @[@"a", @"s", @"d", @"f", @"g", @"h", @"j", @"k", @"l"];
    
    for (int i = 0; i < row.count; i++)
    {
        button = [NVKeyboardButton buttonWithText:row[i]];
        button.tag = counter++;
        [keyboard addSubview:button];
        [button constrainHeightToConstant:height];
        [button constrainTopToAnchor:[keyboard viewWithTag:firstOfLastRow].bottomAnchor constant:spacing];
        
        if (i == 0)
            [button constrainLeadingToAnchor:keyboard.leadingAnchor constant:(spacing * 4.0)];
        
        else
        {
            [button constrainLeadingToAnchor:[keyboard viewWithTag:(counter - 2)].trailingAnchor constant:spacing];
            [button constrainWidthToAnchor:[keyboard viewWithTag:(counter - 2)].widthAnchor];
        }
    }
    
    button = NVKeyboardButton.functionButton;
    button.tag = counter++;
    [button setTitle:@"return" forState:UIControlStateNormal];
    
    [keyboard addSubview:button];
    [button constrainHeightToConstant:height];
    [button constrainTopToAnchor:[keyboard viewWithTag:firstOfLastRow].bottomAnchor constant:spacing];
    [button constrainLeadingToAnchor:[keyboard viewWithTag:(counter - 2)].trailingAnchor constant:spacing];
    [button constrainWidthToAnchor:[keyboard viewWithTag:(counter - 2)].widthAnchor multiplier:1.75];
    [button constrainTrailingToAnchor:keyboard.trailingAnchor constant:-spacing];
    
    firstOfLastRow = 22;
    row = @[@"z", @"x", @"c", @"v", @"b", @"n", @"m", @"@", @"."];
    
    button = NVKeyboardButton.functionButton;
    button.tag = counter++;
    [button setImage:keyboard.blackUpArrow forState:UIControlStateNormal];
    
    [keyboard addSubview:button];
    [button constrainHeightToConstant:height];
    [button constrainTopToAnchor:[keyboard viewWithTag:firstOfLastRow].bottomAnchor constant:spacing];
    [button constrainLeadingToAnchor:keyboard.leadingAnchor constant:spacing];
    
    for (int i = 0; i < row.count; i++)
    {
        button = [NVKeyboardButton buttonWithText:row[i]];
        button.tag = counter++;
        [keyboard addSubview:button];
        [button constrainHeightToConstant:height];
        [button constrainTopToAnchor:[keyboard viewWithTag:firstOfLastRow].bottomAnchor constant:spacing];
        [button constrainLeadingToAnchor:[keyboard viewWithTag:(counter - 2)].trailingAnchor constant:spacing];
        [button constrainWidthToAnchor:[keyboard viewWithTag:(counter - 2)].widthAnchor];
    }
    
    button = NVKeyboardButton.functionButton;
    button.tag = counter++;
    [button setImage:keyboard.blackUpArrow forState:UIControlStateNormal];
    
    [keyboard addSubview:button];
    [button constrainHeightToConstant:height];
    [button constrainTopToAnchor:[keyboard viewWithTag:firstOfLastRow].bottomAnchor constant:spacing];
    [button constrainLeadingToAnchor:[keyboard viewWithTag:(counter - 2)].trailingAnchor constant:spacing];
    [button constrainWidthToAnchor:[keyboard viewWithTag:(counter - 2)].widthAnchor];
    [button constrainTrailingToAnchor:keyboard.trailingAnchor constant:-spacing];
    
    firstOfLastRow = 32;
    row = @[@",", @"'", @"!", @"?", @" ", @"#", @"-", @"_"];
    
    for (int i = 0; i < row.count; i++)
    {
        button = [NVKeyboardButton buttonWithText:row[i]];
        button.tag = counter++;
        [keyboard addSubview:button];
        [button constrainHeightToConstant:height];
        [button constrainTopToAnchor:[keyboard viewWithTag:firstOfLastRow].bottomAnchor constant:spacing];
        
        if (i == 0)
            [button constrainLeadingToAnchor:keyboard.leadingAnchor constant:spacing];
        
        else
        {
            [button constrainLeadingToAnchor:[keyboard viewWithTag:(counter - 2)].trailingAnchor constant:spacing];
            
            if ([row[i] isEqualToString:@" "])
                [button constrainWidthToAnchor:[keyboard viewWithTag:(counter - 2)].widthAnchor multiplier:4.0];
            
            else if ([row[i] isEqualToString:@"#"])
                [button constrainWidthToAnchor:[keyboard viewWithTag:(counter - 3)].widthAnchor];
            
            else
                [button constrainWidthToAnchor:[keyboard viewWithTag:(counter - 2)].widthAnchor];
        }
    }
    
    button = NVKeyboardButton.functionButton;
    button.tag = counter++;
    [button setImage:keyboard.blackKeyboard forState:UIControlStateNormal];
    
    [keyboard addSubview:button];
    [button constrainHeightToConstant:height];
    [button constrainTopToAnchor:[keyboard viewWithTag:firstOfLastRow].bottomAnchor constant:spacing];
    [button constrainLeadingToAnchor:[keyboard viewWithTag:(counter - 2)].trailingAnchor constant:spacing];
    [button constrainWidthToAnchor:[keyboard viewWithTag:(counter - 2)].widthAnchor];
    [button constrainTrailingToAnchor:keyboard.trailingAnchor constant:-spacing];
    
    [UIView animateWithDuration:0.25
                     animations:^{
                         keyboard.alpha = 1.0;
                     }];
    
    return keyboard;
}

- (void)hide
{
    [UIView animateWithDuration:0.25
                     animations:^{
                         self.alpha = 0.0;
                     } completion:^(BOOL finished) {
                         [self removeFromSuperview];
                     }];
}

- (void)switchCase
{
    for (NVKeyboardButton *buttons in self.subviews)
    {
        if ([buttons isKindOfClass:NVKeyboardButton.class])
        {
            if (buttons.type == NVKeyboardButtonTypeText)
            {
                if (_isUpperCase)
                    [buttons setTitle:buttons.currentTitle.lowercaseString forState:UIControlStateNormal];
                
                else
                    [buttons setTitle:buttons.currentTitle.uppercaseString forState:UIControlStateNormal];
            }
        }
    }
    
    _isUpperCase = !_isUpperCase;
}

@end
