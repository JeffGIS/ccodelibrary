//
//  PointInAreaClass.m
//  CCodeLibrary
//
//  Created by JEFFREY E SMITH on 1/1/15.
//  Copyright (c) 2015 GSSi. All rights reserved.
//

#define COORDINATE_MULTIPLIER 10000000.0

#import "PointInAreaClass.h"

@implementation PointInAreaClass

- (id)init
{
    self = [super init];
    if (self)
    {
        void * bmData;
        self.areaFile = CRAPI.sharedInstance.placeAreaFile;
        self.context = MyCreateBitmapContext (1024,1024,&bmData);
        self.bitmapData = bmData;
    }
    return self;
}

- (void)dealloc
{
    if (self.bitmapData)
        free (self.bitmapData);
    if (self.context)
        CGContextRelease(self.context);
}

CGContextRef MyCreateBitmapContext (int pixelsWide,
                                    int pixelsHigh, void**bmData)
{
    CGContextRef    context = NULL;
    CGColorSpaceRef colorSpace;
    void * bitmapData=NULL;
    
    int             bitmapByteCount;
    int             bitmapBytesPerRow;
    
    bitmapBytesPerRow   = (pixelsWide);// 1
    bitmapByteCount     = (bitmapBytesPerRow * pixelsHigh);
    
    colorSpace = CGColorSpaceCreateDeviceGray();
    bitmapData = malloc( bitmapByteCount );// 3
    if (bitmapData != NULL)
    {
        context = CGBitmapContextCreate (bitmapData,// 4
                                         pixelsWide,
                                         pixelsHigh,
                                         8,      // bits per component
                                         bitmapBytesPerRow,
                                         colorSpace,0);
        if (context== NULL)
        {
            free (bitmapData);// 5
        }
        CGColorSpaceRelease( colorSpace );// 6
    }
    *bmData = bitmapData;
    return context;// 7
}

dbounds getAreaFileBounds (const char * areaFile)
{
    dbounds bounds;
    int nLoops, nPoints, ix, iy;
    int *pnPointsInLoop = 0;
    LPDPOINT pPoints;

    
    InitDBounds(&bounds);
    if (areaFile)
    {
        FILE *fid = fopen(areaFile, "rb");
        if (fid && fread(&nPoints, sizeof(int), 1, fid))
        {
            if (nPoints > 2 && fread(&nLoops, sizeof(int), 1, fid))
            {
                pnPointsInLoop = malloc(nLoops * sizeof(int));
                
                if (nLoops > 1)
                    fread(pnPointsInLoop, sizeof(int), nLoops, fid);
                
                else
                    *pnPointsInLoop = nPoints;
                
                pPoints = (LPDPOINT)malloc(sizeof(DPOINT)*nPoints);
                
                for (int i = 0; i < nPoints ; i++)
                {
                    fread(&ix, sizeof(int), 1, fid);
                    fread(&iy, sizeof(int), 1, fid);
                    pPoints[i].y = (CGFloat)(iy) / COORDINATE_MULTIPLIER;
                    pPoints[i].x = (CGFloat)(ix) / COORDINATE_MULTIPLIER;
                }
                
                int i = 0;
                
                for (int iloop = 0; iloop < nLoops; iloop++)
                {
                    for (int j = 0; j < pnPointsInLoop[iloop]; j++ ,i++)
                    {
                        AddDPointToBounds(&bounds, &pPoints[i]);
                    }
                    if (iloop)
                        i++;
                }
                
                free(pPoints);
            }
        }
        
        fclose(fid);
        
        if (pnPointsInLoop)
            free(pnPointsInLoop);
    }
    return bounds;

}

- (void)setAreaFile:(NSString *)areaFile
{
    self.bounds = getAreaFileBounds (areaFile.UTF8String);
}

- (void)drawAreaInContext:(CGContextRef)context
{
    FILE *fid = fopen(self.areaFile.UTF8String, "rb");
    int nLoops, nPoints, ix, iy;
    int *pnPointsInLoop = 0;
    bounds bnds;
    LPDPOINT pPoints;
    
    bnds.xmn = -180.0;
    bnds.ymn = 0.0;
    bnds.xmx = 0.0;
    bnds.ymx = 80.0;
    
    if (fid && fread (&nPoints, sizeof(int), 1, fid))
    {
        if (nPoints > 2 && fread(&nLoops, sizeof(int), 1, fid))
        {
            pnPointsInLoop = malloc(nLoops * sizeof(int));
            
            if (nLoops > 1)
                fread(pnPointsInLoop, sizeof(int), nLoops, fid);
            
            else
                *pnPointsInLoop = nPoints;
            
            pPoints = (LPDPOINT)malloc(sizeof(DPOINT)*nPoints);
            
            for (int i = 0; i < nPoints; i++)
            {
                fread(&ix, sizeof(int), 1, fid);
                fread(&iy, sizeof(int), 1, fid);
                pPoints[i].y = ((CGFloat)(iy) / COORDINATE_MULTIPLIER);
                pPoints[i].x = ((CGFloat)(ix) / COORDINATE_MULTIPLIER);
            }
            
            CreateMask(&pPoints, &nPoints, &bnds);
            CLLocationCoordinate2D llPoint;
            
            for (int i = 0; i < nPoints; i++)
            {
                llPoint.latitude = pPoints[i].y;
                llPoint.longitude = pPoints[i].x;
                CGPoint pt;// = [self.projection pointForCoordinate:llPoint];
                
                if (i == 0)
                    CGContextMoveToPoint(context, pt.x, pt.y);
                
                else
                    CGContextAddLineToPoint(context, pt.x, pt.y);
            }
            
            free(pnPointsInLoop);
            free(pPoints);
        }
    }
    
    fclose(fid);
    
}

- (bool) DPointInArea:(DPOINT *)dPoint
{
    return true;
}
@end
