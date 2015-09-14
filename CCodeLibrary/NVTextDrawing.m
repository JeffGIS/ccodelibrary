//  NVTextDrawing.m
//  CCodeLibrary

#import "NVTextDrawing.h"

@implementation NVTextDrawing

+ (NSUInteger)getTextContainerPoints:(LPDPOINT)textPoints
                            numLines:(NSInteger *)pnLines
                             totArea:(CGFloat *)totArea
               averageCharacterWidth:(CGFloat *)aveCharWidth
               averageCharacterHeight:(CGFloat *)aveCharHeight
                    attributedString:(NSAttributedString *)attributedString
{
    NSArray *textLines = [attributedString.string componentsSeparatedByString:@"\n"];
    *pnLines = textLines.count;
    NSTextStorage *textStorage = [[NSTextStorage alloc] initWithAttributedString:attributedString];
    NSLayoutManager *layoutManager = [[NSLayoutManager alloc] init];
    [textStorage addLayoutManager:layoutManager];
    NSTextContainer *textContainer = [[NSTextContainer alloc] initWithSize:CGSizeMake(2048.0, 2048.0)];
    textContainer.lineFragmentPadding = 0.0;
    [layoutManager addTextContainer:textContainer];

    NSRange glyphRange = {0,1};
    NSUInteger location = 0, nPoints = 0;
    CGFloat totWidth = 0, totHeight = 0;
    NSInteger totChar = 0;
    *totArea = 0;
    
    for (int i = 0; i < textLines.count; i++)
    {
        NSString *textLineString = textLines[i];
        NSUInteger length = textLineString.length;
        NSRange range = {location, length};
        
        [layoutManager characterRangeForGlyphRange:range
                                  actualGlyphRange:&glyphRange];
        
        CGRect glyphRect = [layoutManager boundingRectForGlyphRange:glyphRange
                                                    inTextContainer:textContainer];
        
        DPOINT minXY = {glyphRect.origin.x, glyphRect.origin.y};
        DPOINT maxXY = {glyphRect.size.width + minXY.x, glyphRect.size.height + minXY.y};
        
        textPoints[nPoints++] = minXY;
        textPoints[nPoints++] = maxXY;
        
        location += (length + 1);
        (*totArea) += (maxXY.x - minXY.x) * (maxXY.y - minXY.y);
        totWidth += maxXY.x - minXY.x;
        totHeight += maxXY.y - minXY.y;
        totChar += length;
    }
    
    for (int i = 0; i < attributedString.length; i++)
    {
        if ([attributedString.string characterAtIndex:i] != '\n' &&
            [attributedString.string characterAtIndex:i] != '\r')
        {
            NSRange range = {i,1};
                
            [layoutManager characterRangeForGlyphRange:range
                                      actualGlyphRange:&glyphRange];
            
            CGRect glyphRect = [layoutManager boundingRectForGlyphRange:glyphRange
                                                        inTextContainer:textContainer];
            
            DPOINT center = {(glyphRect.origin.x + (glyphRect.size.width / 2.0)),
                (glyphRect.origin.y + (glyphRect.size.height / 2.0))};
            
            textPoints[nPoints++] = center;
        }
    }
    
    if (totChar)
        *aveCharWidth = (totWidth / totChar);
    
    if(textLines.count)
        *aveCharHeight = (totHeight / textLines.count);
    
    return nPoints;
}

@end