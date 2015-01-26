//  PointInAreaClass.m
//  CCodeLibrary

#define COORDINATE_MULTIPLIER 10000000.0

#import "PointInAreaClass.h"

@implementation PointInAreaClass

- (id)init
{
    self = [super init];
    
    if (self)
    {
        void * bmData;
        self.colorSpace = CGColorSpaceCreateDeviceGray();
        self.width = self.height = 2048;
        self.context = createBitmapContext (self.width,self.height,self.colorSpace,&bmData);
        self.bitmapData = bmData;
        self.areaFile = CRAPI.sharedInstance.placeAreaFile;

    }
    
    return self;
}

- (void)dealloc
{
    if (_bitmapData)
        free (_bitmapData);
    
    if (_context)
        CGContextRelease(_context);
    CGColorSpaceRelease(_colorSpace);
}

- (void)setAreaFile:(NSString *)areaFile
{
    self.bounds = getAreaFileBounds (areaFile.UTF8String);
    if (self.context)
        [self loadAreaIntoContext:areaFile];
    
}

CGContextRef createBitmapContext(int pixelsWide, int pixelsHigh,CGColorSpaceRef colorSpace, void **bmData)
{
    CGContextRef context = NULL;
    void *bitmapData = NULL;
    int bitmapByteCount, bitmapBytesPerRow;
    
    bitmapBytesPerRow = (pixelsWide); //1
    bitmapByteCount = (bitmapBytesPerRow *pixelsHigh);
    
    bitmapData = malloc(bitmapByteCount); //3
    
    if (bitmapData)
    {
        memset (bitmapData,0,bitmapByteCount);
        context = CGBitmapContextCreate(bitmapData, //4
                                        pixelsWide,
                                        pixelsHigh,
                                        8, //bits per component
                                        bitmapBytesPerRow,
                                        colorSpace,0);
        if (!context)
            free (bitmapData);
        
    }
    
    *bmData = bitmapData;
    return context; //7
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
                CGPoint pt; // = [self.projection pointForCoordinate:llPoint];
                
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

- (CGPoint) projectPointToContext:(CLLocationCoordinate2D*)Point from:(int)from
{
    CGPoint pt;
    
    pt.x = Point->longitude - _bounds.xmn;
    pt.x /= (_bounds.xmx - _bounds.xmn);
    if (from)
        pt.y = Point->latitude - _bounds.ymn;
    else
        pt.y = _bounds.ymx - Point->latitude;
    pt.y /= (_bounds.ymx - _bounds.ymn);
    pt.x *= _width;
    pt.y *= _height;
    return pt;
}

- (bool) loadAreaIntoContext:(NSString *)areaFile
{
    bool rtn = false;
    FILE *fid = fopen(areaFile.UTF8String,"rb");
    int nLoops, nPoints, ix, iy;
    int *pnPointsInLoop = 0;
    LPDPOINT pPoints;
    
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
                pPoints[i].y = (double)(iy) / COORDINATE_MULTIPLIER;
                pPoints[i].x = (double)(ix) / COORDINATE_MULTIPLIER;
            }
            
            CLLocationCoordinate2D llPoint;
            
            for (int i = 0; i < nPoints; i++)
            {
                llPoint.latitude = pPoints[i].y;
                llPoint.longitude = pPoints[i].x;
                CGPoint pt = [self projectPointToContext:&llPoint from:0];
                
                if (i == 0)
                    CGContextMoveToPoint(_context, pt.x, pt.y);
                
                else
                    CGContextAddLineToPoint(_context, pt.x, pt.y);
            }
            
            free(pnPointsInLoop);
            free(pPoints);
        }
    }
    
    fclose(fid);
    
    if (!CGContextIsPathEmpty(_context))
    {
        const CGFloat white[2] = {1, 1};
        
        CGColorRef whiteRef = CGColorCreate(_colorSpace, white);
        CGContextSetFillColorWithColor(_context, whiteRef);
        CGContextDrawPath(_context, kCGPathFill);
        rtn = true;
    }
    
    return rtn;
}

- (BOOL)DPointInArea:(DPOINT *)dPoint
{
    CLLocationCoordinate2D llPoint;
    
    llPoint.latitude = dPoint->y;
    llPoint.longitude = dPoint->x;
    
    CGPoint pt = [self projectPointToContext:&llPoint
                                        from:1];
    
    if (pt.x > -0.5 && pt.x < _width - 0.5 &&
        pt.y > -0.5 && pt.y < _height - 0.5)
    {
        int row = (pt.y + 0.5);
        int col = (pt.x + 0.5);
        BYTE bitmapValue = _bitmapData[row * _width + col];
        
        if (bitmapValue)
            return true;
    }
    
    return NO;
}

@end
