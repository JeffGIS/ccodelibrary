//  NVTextDrawing.m
//  CCodeLibrary

#import "NVTextDrawing.h"

@implementation NVTextDrawing

+ (void)getTextContainerPoints:(LPDPOINT)llpoints
              attributedString:(NSAttributedString *)attributedString
{
    NSTextStorage *textStorage = [[NSTextStorage alloc] initWithAttributedString:attributedString];
    NSLayoutManager *layoutManager = [[NSLayoutManager alloc] init];
    [textStorage addLayoutManager:layoutManager];
    NSTextContainer *textContainer = [[NSTextContainer alloc] initWithSize:CGSizeMake(768.0, 1024.0)];
    textContainer.lineFragmentPadding = 0;
    [layoutManager addTextContainer:textContainer];
    
    NSRange glyphRange = {0};
    
    for (int i = 0; i < attributedString.length; i++)
    {
        NSRange range = {i,1};
        
        [layoutManager characterRangeForGlyphRange:range
                                  actualGlyphRange:&glyphRange];
        
        CGRect glyphRect = [layoutManager boundingRectForGlyphRange:glyphRange
                                                    inTextContainer:textContainer];
        
        
        DPOINT center = {(glyphRect.origin.x + (glyphRect.size.width / 2.0)),
                        (glyphRect.origin.y + (glyphRect.size.height / 2.0))};
        
        NSLog(@"%f,%f", center.x, center.y);
        
        llpoints[i] = center;
    }
}

@end