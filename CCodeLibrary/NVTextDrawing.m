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

BOOL LINFIT (HPDPOINT pPoint,LONG N,LPDOUBLE A,LPDOUBLE B,LPDOUBLE MAXDIF,LPLONG LOFMDF)
#if ENABLETRACE
{GSSiEnterProg (1200);
#endif
    {
        /*C******* SPECIFICATIONS ************************************************
         C*                                                                     *
         C*       PROGRAM SUMMARY                                               *
         C*       ------- -------                                               *
         C*    LINFIT (LINE FIT) FINDS, THROUGH A LEAST SQUARES TECHNIQUE, THE  *
         C*    PARAMETERS A AND B OF THE EQUATION                               *
         C*                                                                     *
         C*                 RAWELV = A + B * RAWDIS                             *
         C*                                                                     *
         C*    WHICH DESCRIBES THE LINE OF BEST FIT FOR THE N VALUES OF         *
         C*    RAWDIS, RAWELV. THE MAXIMUM VERTICAL DISTANCE FROM ANY RAWELV    *
         C*    TO THE LINE IS ALSO COMPUTED AND RETURNED ALONG THE LOCATION OF  *
         C*    THAT RAWELV IN THE RAWELV ARRAY.                                 *
         C*                                                                     *
         C*       ARGUMENT DESCRIPTION                                          *
         C*       -------- -----------                                          *
         C*    X       R*8 (N)  DISTANCES,OR RAWDIS VALUES, OF DATA TO BE FIT.  *
         C*    Y       R*8 (N)  ELEVATIONS, OR RAWELV VALUES, OF DATA TO BE FIT.*
         C*    N       I*4      NUMBER OF POINTS TO BE FIT                      *
         C*    A       R*8      0 DEGREE COEFFICIENT OF THE LINER EQUATION      *
         C*    B       R*8      1ST DEGREE COEFFICIENT OF THE LINEAR EQUATION   *
         C*    MAXDIF  R*8      THE MAXIMUM DISTANCE DISCUSSED ABOVE            *
         C*    LOFMDF  I*4      THE LOCATION OF THE MAXIMUM DIFFERENCE          *
         C*                                                                     *
         C*       AUTHOR                                                        *
         C*       ------                                                        *
         C*      JEFF SMITH                                                     *
         C*                                                                     *
         C***********************************************************************  */
        double SUMX=0, SUMY=0, XAVE, YAVE, SMXDYD, SMXDSQ, SUMXY=0, SUMXSQ=0, DIFF;
        double	SUMxy=0, SUMx2=0;
        long	I;
        HPDPOINT	pPointIn=pPoint;
        
        for (I=0;I<N;I++,pPoint++)
        {
            SUMX   += pPoint->x;
            SUMY   += pPoint->y;
            SUMXY  += pPoint->x * pPoint->y;
            SUMXSQ += pPoint->x * pPoint->x;
        }
        XAVE   = SUMX / N;
        YAVE   = SUMY / N;
        SMXDSQ = SUMXSQ - (SUMX * SUMX) / N;
        SMXDYD = SUMXY  - (SUMX * SUMY) / N;
        if (!SMXDSQ)
        {
#if ENABLETRACE
            GSSiExitProg (1200);
#endif
            return FALSE;
        }
        *B      = SMXDYD / SMXDSQ;
        *A      = YAVE - *B * XAVE;
        if (MAXDIF)
        {
            *LOFMDF = 0;
            *MAXDIF = 0;
        }
        pPoint = pPointIn;
        for (I=0;I<N;I++,pPoint++)
        {
            SUMxy += (pPoint->x - XAVE) * (pPoint->y - YAVE);
            SUMx2 += pow (pPoint->x - XAVE,2);
        }
        if (!SUMx2)
        {
#if ENABLETRACE
            GSSiExitProg (1200);
#endif
            return FALSE;
        }
        *B = SUMxy / SUMx2;
        pPoint = pPointIn;
        for (I=0;I<N;I++,pPoint++)
        {
            DIFF = fabs (pPoint->y - (*A + *B * pPoint->x));
            if (MAXDIF && DIFF > *MAXDIF)
            {
                *MAXDIF = DIFF;
                *LOFMDF = I;
            }
        }
        {
#if ENABLETRACE
            GSSiExitProg (1200);
#endif
            return TRUE;
        }
#if ENABLETRACE
    }
#endif
}

@end