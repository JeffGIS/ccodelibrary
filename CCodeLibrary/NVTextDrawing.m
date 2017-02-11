//  NVTextDrawing.m
//  CCodeLibrary

@import CoreText;
#import "NVTextDrawing.h"

@interface TextAttempt: NSObject
@property NSString * text;
@property CGFloat mpX;
@property CGFloat mpY;
@property CGFloat textWidth;
@property CGFloat textHeight;
@property CGFloat rotation;
@property CGFloat fontSize;
@end
@implementation TextAttempt
-(id) copyWithZone: (NSZone *) zone
{
    TextAttempt *another = [[TextAttempt allocWithZone: zone] init];
    
    another.text = [NSString stringWithString:self.text];
    another.mpX = _mpX;
    another.mpY = _mpY;
    another.textWidth = _textWidth;
    another.textHeight = _textHeight;
    another.rotation = _rotation;
    another.fontSize= _fontSize;
    return another;
}
@end

@implementation NVTextDrawing

+ (BOOL)continue:(NSInteger) processingID
{
    if (!processingID)
        return YES;
    if (processingID == CRAPI.sharedInstance.keepProcessing)
        return YES;
    return NO;
}


+ (int) numLinesInText:(const char *)txt
{
    int numLines = 1;
    
    while (*txt)
    {
        if (*txt++ == '\n')
            numLines++;
    }
    return numLines;
}

+ (BOOL)drawText:(NSString *)textIN
       inContext:(CGContextRef)context
   withinPolygon:(LPDPOINT)pPoints
   withNumPoints:(NSInteger)numPoints
     andNumLoops:(NSInteger)numLoops
         loopLen:(int*)polyPartLen
    withinBounds:(LPMNMXCORD)pBounds
        fontSize:(CGFloat)desiredFontSize
     minFontSize:(CGFloat)minFontSize
       textColor:(UIColor *)textColor
    processingID:(NSInteger)processingID
{
    if (!textIN.length)
        return FALSE;
    CGFloat rotation = 0;
    TextAttempt* ta[4];
    int nAttempts = 0;
    int npass = 0;
    NSString *text;
    
Top:
    text = textIN;
    //try it level
    ta[nAttempts++] = [NVTextDrawing computeText:text
                                       inContext:context
                                   withinPolygon:pPoints
                                   withNumPoints:numPoints
                                     andNumLoops:numLoops
                                         loopLen:polyPartLen
                                    withinBounds:pBounds
                                        fontSize:desiredFontSize
                                     minFontSize:minFontSize
                                        rotation:rotation
                                       textColor:textColor
                                    processingID:processingID];
    CGFloat minTextWidth = ta[nAttempts-1].textWidth;
    /*
     int ii;
     if (![text isEqualToString:@"New Hope"])
     return;
     for (int i = 0;i<polyPartLen[0]-1;i++)
     {
     [NVTextDrawing drawText:[NSString stringWithFormat:@"%i",i]
     inRotatedRect:context
     rectMidX:pPoints[i].x
     rectMidY:pPoints[i].y
     width:40
     height:40
     rotation:0
     fontSize:18
     textColor:textColor];
     
     }*/
    if (!context)
        return TRUE;
    if (ta[nAttempts-1].fontSize >= desiredFontSize)
    {
        BOOL st = [NVTextDrawing drawText:ta[nAttempts-1].text
                  inRotatedRect:context
                       rectMidX:ta[nAttempts-1].mpX
                       rectMidY:ta[nAttempts-1].mpY
                          width:ta[nAttempts-1].textWidth
                         height:ta[nAttempts-1].textHeight
                       rotation:ta[nAttempts-1].rotation
                       fontSize:ta[nAttempts-1].fontSize
                      textColor:textColor];
        return st;
    }
    NSString * splitText = splitLongestLine (textIN);
    if (splitText)
    {
        text = splitText;
        
        ta[nAttempts++] = [NVTextDrawing computeText:text
                                           inContext:context
                                       withinPolygon:pPoints
                                       withNumPoints:numPoints
                                         andNumLoops:numLoops
                                             loopLen:polyPartLen
                                        withinBounds:pBounds
                                            fontSize:desiredFontSize
                                         minFontSize:minFontSize
                                            rotation:rotation
                                           textColor:textColor
                                        processingID:processingID];
        if (ta[nAttempts-1].fontSize >= desiredFontSize)
        {
            BOOL st = [NVTextDrawing drawText:ta[nAttempts-1].text
                      inRotatedRect:context
                           rectMidX:ta[nAttempts-1].mpX
                           rectMidY:ta[nAttempts-1].mpY
                              width:ta[nAttempts-1].textWidth
                             height:ta[nAttempts-1].textHeight
                           rotation:ta[nAttempts-1].rotation
                           fontSize:ta[nAttempts-1].fontSize
                          textColor:textColor];
            return st;
        }
    }
    if (npass++ < 1)
    {
        //try it rotated
        if ([NVTextDrawing getRotation:&rotation
                 ofLongestStraightLine:(int)numPoints
                                points:pPoints
                              numLoops:(int)numLoops
                               loopLen:polyPartLen
                             maxOffset:1.0
                             minLength:minTextWidth])
            goto Top;
        
    }
    int maxi = 0;
    for (int i = 1;i < nAttempts; i++)
    {
        if (ta[i].fontSize > ta[maxi].fontSize)
            maxi = i;
    }
    if (ta[maxi].fontSize >= minFontSize)
    {
        BOOL st = [NVTextDrawing drawText:ta[maxi].text
                  inRotatedRect:context
                       rectMidX:ta[maxi].mpX
                       rectMidY:ta[maxi].mpY
                          width:ta[maxi].textWidth
                         height:ta[maxi].textHeight
                       rotation:ta[maxi].rotation
                       fontSize:ta[maxi].fontSize
                      textColor:textColor];
        return st;
    }
    return FALSE;
}

+ (TextAttempt*)computeText:(NSString *)text
                  inContext:(CGContextRef)context
              withinPolygon:(LPDPOINT)pPoints
              withNumPoints:(NSInteger)numPoints
                andNumLoops:(NSInteger)numLoops
                    loopLen:(int*)polyPartLen
               withinBounds:(LPMNMXCORD)pBounds
                   fontSize:(CGFloat)fontSize
                minFontSize:(CGFloat)minFontSize
                   rotation:(CGFloat)rotation
                  textColor:(UIColor *)textColor
               processingID:(NSInteger)processingID

{
    TextAttempt * ta = [[TextAttempt alloc]init];
    NSInteger nLines = 0;
    CGFloat textArea = 0.0;
    CGFloat aveCharWidth = 0.0, aveCharHeight = 0.0;
    BOOL isRotated = FALSE;
    DPOINT midPt;
    
    if (rotation != 0)
    {
        isRotated = TRUE;
        LPDPOINT pPointsRotated = malloc (numPoints * sizeof(DPOINT)+4);
        MNMXCORD areaBounds = PolyBounds(pPoints, (int)numPoints);
        midPt = DBoundsMid(&areaBounds);
        for (int i = 0;i<numPoints;i++)
        {
            double az = getazd(&midPt, &pPoints[i]);
            double d = ldistpp(&midPt,&pPoints[i]);
            pPointsRotated[i] = dnewpt(&midPt, az-rotation, d);
        }
        pPoints = pPointsRotated;
    }
    PointInArea *pia = [[PointInArea alloc] init];
    pia.maxDimension = 256;
    
    CGFloat areaSize = fabs(ComputeAreaAreaD(pPoints, numPoints, 0));
    if (areaSize != 0)
    {
        MNMXCORD areaBounds = PolyBounds(pPoints, (int)numPoints);
        if (pBounds)
        {
            areaBounds.xmn = max (areaBounds.xmn,pBounds->xmn);
            areaBounds.ymn = max (areaBounds.ymn,pBounds->ymn);
            areaBounds.xmx = min (areaBounds.xmx,pBounds->xmx);
            areaBounds.ymx = min (areaBounds.ymx,pBounds->ymx);
        }
        DPOINT areaMid = DBoundsMid(&areaBounds);
        CGFloat areaWidth = MNMXCORDWidth(&areaBounds);
        CGFloat areaHeight = MNMXCORDHeight(&areaBounds);
        
        [pia loadArea:(int)numPoints
             numLoops:(int)numLoops
          polyPartLen:polyPartLen
               points:pPoints
        boundaryWidth:0];
        
        //int numTextLines = [NVTextDrawing numLinesInText:text.UTF8String];
        
        CTFontRef textPointFontRef = CTFontCreateWithName((CFStringRef)NULL,
                                                          fontSize, NULL);
        
        NSMutableParagraphStyle *style = NSParagraphStyle.defaultParagraphStyle.mutableCopy;
        style.alignment = NSTextAlignmentCenter;
        
        NSDictionary *textPointAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                             (__bridge id)textPointFontRef, kCTFontAttributeName,
                                             style, kCTParagraphStyleAttributeName,
                                             nil];
        
        CFRelease(textPointFontRef);
        
        NSAttributedString *textPointString = [[NSAttributedString alloc] initWithString:text
                                                                              attributes:textPointAttributes];
        
        // LPDPOINT textPoints = (LPDPOINT)malloc((sizeof(DPOINT) * (textPointString.length + 32)) + 4);//enough memory for 16 lines
        DPOINT textPoints[256] = {0};
        
        int nTextPoints = (int)[NVTextDrawing getTextContainerPoints:textPoints
                                                            numLines:&nLines
                                                             totArea:&textArea
                                               averageCharacterWidth:&aveCharWidth
                                              averageCharacterHeight:&aveCharHeight
                                                    attributedString:textPointString];
        
        MNMXCORD textBounds = PolyBounds(textPoints, nTextPoints);
        CGFloat textWidth = MNMXCORDWidth(&textBounds);
        CGFloat textHeight = MNMXCORDHeight(&textBounds);
        DPOINT textMid = DBoundsMid(&textBounds);
        
        for (int i = 0; i < nTextPoints; i++)
        {
            textPoints[i].x -= textMid.x;
            textPoints[i].y -= textMid.y;
        }
        
        //LPDPOINT testPoints = (LPDPOINT)malloc(nTextPoints * sizeof(DPOINT) + 4);
        DPOINT testPoints[256];
        
        /*if (ii){ //debug stuff
         int ir=0, ic;
         CGFloat xoffset = 0.0, yoffset = 0.0;
         CGFloat xinc = 1;
         CGFloat yinc = 1;
         CGRect areaRect = CGRectMake(areaBounds.xmn, areaBounds.ymn, areaWidth, areaHeight);
         while (yoffset < curbounds.ymx)
         {
         xoffset = curbounds.xmn;
         ic = 0;
         while (xoffset < curbounds.xmx)
         {
         DPOINT pt = {xoffset,yoffset};
         if ([pia DPointInArea:&pt])
         {
         CGRect rect = CGRectMake(xoffset, yoffset, 2, 2);
         CGContextSetGrayFillColor(context, 0.5, 0.5);
         
         CGContextFillRect(context, rect);
         }
         xoffset += xinc;
         }
         ir++;
         yoffset += yinc;
         }
         CGContextSetGrayFillColor(context, 1, 1);
         CGContextFillRect(context, areaRect);
         }*/
        if (areaSize && textArea)
        {
            CGFloat desiredTextFactor = 1.0;
            CGFloat textFactor = (areaSize / textArea);
            CGFloat textFactor2 = 1;
            CGFloat minTextFactor = (desiredTextFactor * ((CGFloat)minFontSize / (CGFloat)fontSize) * ((CGFloat)minFontSize / (CGFloat)fontSize));
            CGFloat shrink = 0.90;
            NSInteger numFit = 0;
#define MAXFIT 256
            CGFloat fitX[MAXFIT] = {0}, fitY[MAXFIT] = {0};
            CGFloat xoffset = 0.0, yoffset = 0.0;
            BOOL firstFit = YES;
        Top:
            while (!numFit && (textFactor > minTextFactor && [self continue:processingID]))
            {
                CGFloat xinc = max (aveCharWidth/2,(aveCharWidth * textFactor)/2);
                CGFloat yinc = max (aveCharHeight/2,(aveCharHeight * textFactor)/2);
                yoffset = areaMid.y - areaHeight + textHeight * textFactor/2;
                
                while (yoffset < areaBounds.ymx)
                {
                    xoffset = areaMid.x - areaWidth/2 + textWidth * textFactor/2;
                    
                    while (xoffset < areaBounds.xmx)
                    {
                        for (int i = 0; i < nTextPoints; i++)
                        {
                            testPoints[i].x = textPoints[i].x * textFactor * textFactor2 + xoffset;
                            testPoints[i].y = yoffset - textPoints[i].y * textFactor * textFactor2;
                            if (!DPointInBounds (&testPoints[i],pBounds))
                                goto NextX;
                            if (![pia DPointInArea:&testPoints[i]])
                                goto NextX;
                        }
                        /*if (ii)
                         {
                         for (int i = 0; i < nTextPoints; i++)
                         {
                         static CGFloat pctBlack = 0;
                         CGRect rect = CGRectMake(testPoints[i].x, testPoints[i].y, 16, 16);
                         CGContextSetGrayFillColor(context, pctBlack, 1);
                         CGContextFillRect(context, rect);
                         }
                         }*/
                        if (numFit < MAXFIT)
                        {
                            if (firstFit)
                            {
                                firstFit = NO;
                                textFactor2 = 0.95;
                                goto Top;
                            }
                            fitX[numFit] = xoffset;
                            fitY[numFit++] = yoffset;
                        }
                        
                    NextX:
                        xoffset += xinc;
                    }
                    
                    yoffset += yinc;
                }
                
                textFactor *= shrink;
            }
            
            if (numFit && [self continue:processingID])
            {
                CGFloat fontFactor = min(textFactor*textFactor2, desiredTextFactor);
                fontSize *= fontFactor;
                fontSize *= 0.9;
                
                if (fontSize >= minFontSize)
                {
                    NSInteger iFit = numFit / 2;
                    if (!(numFit%2))
                    {
                        fitX[iFit] += fitX[iFit-1];
                        fitX[iFit] /= 2;
                        fitY[iFit] += fitY[iFit-1];
                        fitY[iFit] /= 2;
                    }
                    
                    DPOINT pt = {fitX[iFit],fitY[iFit]};
                    if (isRotated)
                    {
                        double az = getazd(&midPt, &pt);
                        double d = ldistpp(&midPt,&pt);
                        pt = dnewpt(&midPt, az+rotation, d);
                        
                    }
                    ta.text = text.copy;
                    ta.mpX = pt.x;
                    ta.mpY = pt.y;
                    ta.textWidth = (textWidth * fontFactor);
                    ta.textHeight = (textHeight * fontFactor);
                    ta.rotation = rotation;
                    ta.fontSize = fontSize;
                }
            }
        }
    }
    if (isRotated)
        free (pPoints);
    return ta;
}

+ (BOOL)drawText:(NSString *)text
   inRotatedRect:(CGContextRef)context
        rectMidX:(CGFloat)mpX
        rectMidY:(CGFloat)mpY
           width:(CGFloat)textWidth
          height:(CGFloat)textHeight
        rotation:(CGFloat)rotateRadians
        fontSize:(CGFloat)fontSize
       textColor:(UIColor *)textColor
{
    BOOL rtn = TRUE;
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
    
    /*   if (ConfigurationControl.sharedInstance.GMTilesVisible)
     {
     CGRect shadowRect = rect;
     shadowRect.origin.x += 1;
     shadowRect.origin.y += 1;
     CGPathRef path = CGPathCreateWithRect(shadowRect, NULL);
     attString = [[NSAttributedString alloc] initWithString:text
     attributes:shadowAttributes];
     
     CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)attString);
     CTFrameRef frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, attString.length), path, NULL);
     CTFrameDraw(frame, context);
     }*/
    
    attString = [[NSAttributedString alloc] initWithString:text
                                                attributes:shadowAttributes];
    [self drawTextShadowForRect:rect
                      attString:attString
                        context:context];
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
    return rtn;
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
        numLoops:(int)numLoops
            loopLen:(int*)polyPartLen
          maxOffset:(CGFloat)offset
          minLength:(CGFloat)minLength
{
    int ii;
    BOOL rtn = NO;
    CGFloat longestLine = 0.0, currentRot = 0.0;
 
/*    {
        DPOINT p[4];
        double a,b, maxDiff;
        int loc;
        p[0].x =1;p[0].y=0;
        p[1].x =1; p[1].y = 1;
        p[2].x =1;p[2].y=2.1;
        p[3].x =1;p[3].y=3;
        
        LINFIT(p, 4, &a, &b, &maxDiff, &loc);
        ii=1;
    }*/
    
    if (numLoops > 1)
        nPoints = polyPartLen[0];
    nPoints--;
  
    
    
    for (int i = 0; i < nPoints; i++)
    {
        CGFloat lineLength = GetPolyLengthD(&pPoints[i], 2);
        
        if (lineLength > longestLine)
        {
            currentRot = getazd(&pPoints[i], &pPoints[i + 1]);
            longestLine = lineLength;
        }
    }
    
    if (nPoints > 4)
    {
        LPDPOINT wrappedPoints = (LPDPOINT)malloc(sizeof(DPOINT) * (nPoints * 2));
        
        for (int i = 0; i < nPoints; i++)
        {
            wrappedPoints[i] = pPoints[i];
            wrappedPoints[nPoints + i] = pPoints[i];
        }
        
        double a = 0.0, b = 0.0, maxDiff = offset * 2;
        long locOfMaxDiff = 0;
        double lastDiff, lastRot;
        
        for (int i = 0; i < nPoints*2; i++)
        {
            long numPoints = 2;
            
            if (i > nPoints)
                break;
            do
            {
                numPoints++;
                lastDiff = maxDiff;
                lastRot = b;
                maxDiff = -offset;
                LINFIT(&wrappedPoints[i], numPoints, &a, &b, &maxDiff, &locOfMaxDiff);
            }
            
            while ((maxDiff < offset) && (i+numPoints < nPoints*2));
            
            if (lastDiff < offset)
            {
                numPoints--;
                if (numPoints > 2)
                {
                    CGFloat lineLength = GetPolyLengthD(&wrappedPoints[i], numPoints);
                    lastRot = getazd(&wrappedPoints[i], &wrappedPoints[i+numPoints-1]);
                    if ((lineLength > longestLine) && (lastDiff < offset))
                    {
                        currentRot = lastRot;
                        longestLine = lineLength;
                    }
                }
            }
        }
        
        free(wrappedPoints);
    }
    
    currentRot = LTWOPI(currentRot);
    if ((currentRot > HALFPI) && (currentRot < (3.0 * HALFPI)))
        currentRot = LTWOPI(currentRot + M_PI);
    
    if (longestLine > minLength)
    {
        *rotation = currentRot;
        rtn = YES;
    }
    
    return rtn;
}
+ (void)drawTextShadowForRect:(CGRect)rect
                    attString:(NSAttributedString *)attString
                      context:(CGContextRef)context
{
    CGFloat shadowOffset = 2.0;
    
    CGRect shadowRect = CGRectMake((rect.origin.x + shadowOffset), (rect.origin.y + shadowOffset),
                                   rect.size.width, rect.size.height);
    
    CGPathRef shadowPath = CGPathCreateWithRect(shadowRect, NULL);
    
    CTFramesetterRef shadowFramesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)attString);
    CTFrameRef shadowFrame = CTFramesetterCreateFrame(shadowFramesetter, CFRangeMake(0, 0), shadowPath, NULL);
    CTFrameDraw(shadowFrame, context);
    
    CFRelease(shadowFrame);
    CFRelease(shadowPath);
    CFRelease(shadowFramesetter);
    
    CGRect shadowRect2 = CGRectMake((rect.origin.x - shadowOffset), (rect.origin.y - shadowOffset),
                                    rect.size.width, rect.size.height);
    
    CGPathRef shadowPath2 = CGPathCreateWithRect(shadowRect2, NULL);
    
    CTFramesetterRef shadowFramesetter2 = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)attString);
    CTFrameRef shadowFrame2 = CTFramesetterCreateFrame(shadowFramesetter2, CFRangeMake(0, 0), shadowPath2, NULL);
    CTFrameDraw(shadowFrame2, context);
    
    CFRelease(shadowFrame2);
    CFRelease(shadowPath2);
    CFRelease(shadowFramesetter2);
    
    CGRect shadowRect3 = CGRectMake((rect.origin.x + shadowOffset), (rect.origin.y - shadowOffset),
                                    rect.size.width, rect.size.height);
    
    CGPathRef shadowPath3 = CGPathCreateWithRect(shadowRect3, NULL);
    
    CTFramesetterRef shadowFramesetter3 = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)attString);
    CTFrameRef shadowFrame3 = CTFramesetterCreateFrame(shadowFramesetter3, CFRangeMake(0, 0), shadowPath3, NULL);
    CTFrameDraw(shadowFrame3, context);
    
    CFRelease(shadowFrame3);
    CFRelease(shadowPath3);
    CFRelease(shadowFramesetter3);
    
    CGRect shadowRect4 = CGRectMake((rect.origin.x - shadowOffset), (rect.origin.y + shadowOffset),
                                    rect.size.width, rect.size.height);
    
    CGPathRef shadowPath4 = CGPathCreateWithRect(shadowRect4, NULL);
    
    CTFramesetterRef shadowFramesetter4 = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)attString);
    CTFrameRef shadowFrame4 = CTFramesetterCreateFrame(shadowFramesetter4, CFRangeMake(0, 0), shadowPath4, NULL);
    CTFrameDraw(shadowFrame4, context);
    
    CFRelease(shadowFrame4);
    CFRelease(shadowPath4);
    CFRelease(shadowFramesetter4);
}


@end
