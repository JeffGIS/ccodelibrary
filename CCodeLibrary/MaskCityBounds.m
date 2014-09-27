//
//  MaskCityBounds.m
//  CCodeLibrary
//
//  Created by JEFFREY E SMITH on 9/26/14.
//  Copyright (c) 2014 GSSi. All rights reserved.
//
#define COORDINATE_MULTIPLIER 10000000.0
#define MAX_AREA_POINTS 15000

#import "MaskCityBounds.h"
#import "MathUtil.h"
#import "UserDefaults.h"

@implementation MaskCityBounds


- (void)drawCityBounds:(NSString *)fromFile inMapView:(GMSMapView *)mapView
{
    FILE *fid = fopen(fromFile.UTF8String,"rb");
    int nLoops, nPoints, ix, iy;
    int *pnPointsInLoop = 0;
    bounds bnds;
    LPDPOINT pPoints;
    UIColor *blue = UserDefaults.defaults.appleBlue;

    InitBounds(&bnds);
    bnds.xmn = -180.0;
    bnds.ymn = 0.0;
    bnds.xmx = 0.0;
    bnds.ymx = 80.0;
    
    if (fid && fread(&nPoints, sizeof(int), 1, fid))
    {
        if (nPoints > 2 && fread (&nLoops, sizeof(int), 1, fid))
        {
            pnPointsInLoop = malloc(nLoops * sizeof(int));
            
            if (nLoops > 1)
                fread(pnPointsInLoop, sizeof(int), nLoops, fid);
            
            else
                *pnPointsInLoop = nPoints;
            
            pPoints = (LPDPOINT)malloc (sizeof(DPOINT)*nPoints);
            
            for (int i = 0; i < nPoints ; i++)
            {
                fread(&ix, sizeof(int), 1, fid);
                fread(&iy, sizeof(int), 1, fid);
                pPoints[i].y = (double)(iy) / COORDINATE_MULTIPLIER;
                pPoints[i].x = (double)(ix) / COORDINATE_MULTIPLIER;
            }
            
            int i=0;
            
            for (int iloop = 0; iloop < nLoops; iloop++)
            {
                GMSMutablePath *path = [[GMSMutablePath alloc] init];
                
                for (int j = 0; j < pnPointsInLoop[iloop]; j++ ,i++)
                {
                    CLLocationCoordinate2D llPoint;
                    llPoint.latitude = pPoints[i].y;
                    llPoint.longitude = pPoints[i].x;
                    [path addCoordinate:llPoint];
                }
                
                if (path.count)
                {
                    GMSPolyline *polyline = [GMSPolyline polylineWithPath:path];
                    polyline.strokeWidth = 3.0;
                    polyline.strokeColor = blue;
                    polyline.map = mapView;
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

- (void)maskCityBounds:(NSString *)fromFile inMapView:(GMSMapView *)mapView
{
    FILE *fid = fopen(fromFile.UTF8String,"rb");
    int nLoops, nPoints, ix, iy;
    int *pnPointsInLoop = 0;
    bounds bnds;
    LPDPOINT pPoints;
    UIColor *blue = UserDefaults.defaults.appleBlue;

    
    InitBounds (&bnds);
    bnds.xmn = -180.0;
    bnds.ymn = 0.0;
    bnds.xmx = 0.0;
    bnds.ymx = 80.0;
    
    GMSMutablePath *path = [[GMSMutablePath alloc]init];
    
    if (fid && fread (&nPoints, sizeof(int), 1, fid))
    {
        if (nPoints > MAX_AREA_POINTS)
        {
            fclose(fid);
            [self drawCityBounds:fromFile inMapView:mapView];
            return;
        }
        
        if (nPoints > 2 && fread (&nLoops, sizeof(int), 1, fid))
        {
            pnPointsInLoop = malloc (nLoops * sizeof(int));
            
            if (nLoops > 1)
                fread(pnPointsInLoop, sizeof(int), nLoops, fid);
            
            else
                *pnPointsInLoop = nPoints;
            
            pPoints = (LPDPOINT)malloc (sizeof(DPOINT)*nPoints);
            
            for (int i = 0; i < nPoints; i++)
            {
                fread(&ix, sizeof(int), 1, fid);
                fread(&iy, sizeof(int), 1, fid);
                pPoints[i].y = (double)(iy) / COORDINATE_MULTIPLIER;
                pPoints[i].x = (double)(ix) / COORDINATE_MULTIPLIER;
            }
            
            CreateMask(&pPoints, &nPoints, &bnds);
            
            for (int i = 0; i < nPoints; i++)
            {
                CLLocationCoordinate2D llPoint;
                llPoint.latitude = pPoints[i].y;
                llPoint.longitude = pPoints[i].x;
                [path addCoordinate:llPoint];
            }
            
            free(pnPointsInLoop);
            free(pPoints);
        }
    }
    
    fclose(fid);
    
    if (path.count)
    {
        GMSPolygon *polygon = [GMSPolygon polygonWithPath:path];
        polygon.strokeWidth = 3.0;
        polygon.fillColor = UserDefaults.defaults.polygonFillColor;
        polygon.strokeColor = blue;
        polygon.map = mapView;
    }
}



@end
