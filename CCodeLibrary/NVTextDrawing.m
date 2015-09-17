//  NVTextDrawing.m
//  CCodeLibrary

@import CoreText;
#import "NVTextDrawing.h"
#import "CCodeLibrary/MathUtil.h"

@implementation NVTextDrawing

bool LINFIT(LPDPOINT pPoint, long N, double *A, double *B, double *MAXDIF, long *LOFMDF);

+ (void)drawText:(NSString *)text
   inRotatedRect:(CGContextRef)context
        rectMidX:(CGFloat)mpX
        rectMidY:(CGFloat)mpY
           width:(CGFloat)textWidth
          height:(CGFloat)textHeight
        rotation:(CGFloat)rotateRadians
        fontSize:(CGFloat)fontSize
       textColor:(UIColor *)textColor
{
    CGRect rect = CGRectZero;
    NSAttributedString *attString = nil;
    
    rect.size.height = (-textHeight * 1.1);
    rect.size.width  = (textWidth * 1.1);
    rect.origin.x =  (-rect.size.width  / 2.0);
    rect.origin.y =  (textHeight / 2.0);
    
    CGContextSaveGState(context);
    CGContextTranslateCTM(context, mpX, mpY);
    CGContextRotateCTM(context,rotateRadians);
    
    /*if (dbug)
    {
        CGRect rectmp = CGRectMake(fitX[iFit]-8, fitY[iFit],16, 2);
        CGContextSetGrayFillColor(context, 0.5, 0.5);
        CGContextFillRect(context, rect);
        CGContextSetGrayFillColor(context, 0, 0.8);
        CGContextFillRect(context, rectmp);
    }*/
    
    CTFontRef fontRef = CTFontCreateWithName((CFStringRef)NULL,
                                             fontSize, NULL);
    
    NSMutableParagraphStyle *style = NSParagraphStyle.defaultParagraphStyle.mutableCopy;
    style.alignment = NSTextAlignmentCenter;
    
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                (__bridge id)fontRef, kCTFontAttributeName,
                                style, kCTParagraphStyleAttributeName,
                                textColor.CGColor, kCTForegroundColorAttributeName,
                                nil];
    
    NSDictionary *shadowAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                      (__bridge id)fontRef, kCTFontAttributeName,
                                      style, kCTParagraphStyleAttributeName,
                                      UIColor.whiteColor.CGColor, kCTForegroundColorAttributeName,
                                      nil];
    
    CFRelease(fontRef);
    
    /*if (ConfigurationControl.sharedInstance.GMTilesVisible == YES)
    {
        attString = [[NSAttributedString alloc] initWithString:text
                                                    attributes:shadowAttributes];
        
        [self drawTextShadowForRect:rect
                          attString:attString
                            context:context];
    }*/
    
    CGPathRef path = CGPathCreateWithRect(rect, NULL);
    
    attString = [[NSAttributedString alloc] initWithString:text
                                                attributes:attributes];
    
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)attString);
    CTFrameRef frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, attString.length), path, NULL);
    CTFrameDraw(frame, context);
    
    CFRelease(frame);
    CFRelease(framesetter);
    CGPathRelease(path);
    CGContextRestoreGState(context);
}

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

+ (BOOL)getRotation:(CGFloat *)rotation
ofLongestStraightLine:(int)nPoints
             points:(DPOINT *)pPoints
          maxOffset:(CGFloat)offset
          minLength:(CGFloat)minLength
{
    BOOL rtn = NO;
    nPoints--;
    
    LPDPOINT wrappedPoints = (LPDPOINT)malloc(sizeof(DPOINT) * (nPoints * 2));
    
    for (int i = 0; i < nPoints; i++)
    {
        wrappedPoints[i] = pPoints[i];
        wrappedPoints[nPoints + i] = pPoints[i];
    }
    
    double a = 0.0, b = 0.0, maxDiff = 0.0;
    long locOfMaxDiff = 0;
    
    for (int i = 0; i < nPoints; i++)
    {
        long numPoints = 2;
        
        do
        {
            numPoints++;
            LINFIT(&wrappedPoints[i], numPoints, &a, &b, &maxDiff, &locOfMaxDiff);
        }
        
        while ((maxDiff < offset) && (numPoints < nPoints));
        
        NSLog(@"%i[%li]::a:%f, b:%f, maxDiff:%f, locOfMaxDiff:%li", i, numPoints, a, b, maxDiff, locOfMaxDiff);
    }
    
    free(wrappedPoints);
    
    return rtn;
}

@end