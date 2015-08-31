//  NVTextDrawing.m
//  CCodeLibrary

#import "NVTextDrawing.h"

@implementation NVTextDrawing

+ (void)getTextContainerPoints:(LPDPOINT)textPoints
              attributedString:(NSAttributedString *)attributedString
{
    NSArray *textLines = [attributedString.string componentsSeparatedByString:@"\n"];
    
    NSTextStorage *textStorage = [[NSTextStorage alloc] initWithAttributedString:attributedString];
    NSLayoutManager *layoutManager = [[NSLayoutManager alloc] init];
    [textStorage addLayoutManager:layoutManager];
    NSTextContainer *textContainer = [[NSTextContainer alloc] initWithSize:CGSizeMake(768.0, 1024.0)];
    textContainer.lineFragmentPadding = 0;
    [layoutManager addTextContainer:textContainer];

    NSRange glyphRange = {0,1};
    NSUInteger location = 0;
    
    for (int i = 0; i < textLines.count; i++)
    {
        NSUInteger length = [textLines[i] length];
        
        NSRange range = {location, length};
        
        [layoutManager characterRangeForGlyphRange:range
                                  actualGlyphRange:&glyphRange];
        
        CGRect glyphRect = [layoutManager boundingRectForGlyphRange:glyphRange
                                                    inTextContainer:textContainer];
        
        DPOINT minXY = {glyphRect.origin.x, glyphRect.origin.y};
        DPOINT maxXY = {glyphRect.size.width + minXY.x, glyphRect.size.height + minXY.y};
        
        textPoints[i * 2] = minXY;
        textPoints[(i * 2) + 1] = maxXY;
        
        location += (length + 1);
    }
    
    for (int i = 0; i < attributedString.length; i++)
    {
        NSRange range = {i,1};
        
        [layoutManager characterRangeForGlyphRange:range
                                  actualGlyphRange:&glyphRange];
        
        CGRect glyphRect = [layoutManager boundingRectForGlyphRange:glyphRange
                                                    inTextContainer:textContainer];
        
        
        DPOINT center = {(glyphRect.origin.x + (glyphRect.size.width / 2.0)),
                        (glyphRect.origin.y + (glyphRect.size.height / 2.0))};
        
        textPoints[i + (textLines.count * 2)] = center;
    }
}

@end