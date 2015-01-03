//  MathUtil.c
//  CCodeLibrary

#include "MathUtil.h"
#include "Rotate256.h"
#include <stdlib.h>
#include <math.h>
#include <float.h>
#include <string.h>
#include <stdio.h>
#include <limits.h>

double ArcDistance(DPOINT p1, DPOINT p2)
// returns distance in meters between two lat-longs
{
    double GreatCircle, cos_c, ArcCos, sina,sinb, cosa, cosb, cosl;
    
    sina =  sin(p1.y/DEGRAD);
    sinb =  sin(p2.y/DEGRAD);
    cosa =  cos(p1.y/DEGRAD);
    cosb =  cos(p2.y/DEGRAD);
    cosl =  cos((p2.x-p1.x)/DEGRAD);
    
    cos_c = sina*sinb+cosa*cosb*cosl;
    ArcCos = acos(cos_c);
    GreatCircle = fabs(6371100 * ArcCos);
    {
        return GreatCircle;
    }
}

DPOINT NewLatLong(double Lat,double Long,double Dist,double Direction)
{
    DPOINT LatLong;
    //given:          Fixed 7 Oct 96 lda
    //  Point N is at the North Pole
    //  Point A is at the Given Lat,Long
    //  Length of two sides of a triangle and the angle it forms
    
    double  cosc,cosb,cosa,sinb,sinc,sina,cosC,cosA;
    
    cosc = cos(Dist/6371100);
    sinc = sin(Dist/6371100);
    cosb = cos((90e0-Lat)/DEGRAD);
    sinb = sin((90e0-Lat)/DEGRAD);
    cosa = cos(Direction)*sinb*sinc+cosb*cosc;
    cosA = acos(cosa);
    cosA *= DEGRAD;
    LatLong.y = 90e0 - cosA;
    sina = acos(cosa);
    sina = sin(sina);
    cosC = (cosc-(cosb*cosa)) / (sinb*sina);
    cosC = max (-1.0,min (cosC,1.0));
    cosC = acos(cosC);
    cosC *= DEGRAD;
    if(Direction > PY)
        LatLong.x = Long - cosC;
    else
        LatLong.x = Long + cosC;
    
    {
        return LatLong;
    }
}
bool pointInDBounds (DPOINT *pt,dbounds *pBounds)
{
    bool rtn = true;
    
    if (pt->x < pBounds->xmn || pt->x > pBounds->xmx ||
        pt->y < pBounds->ymn || pt->y > pBounds->ymx)
        rtn = false;
    
    return rtn;
}

float MaxF(float l, float r)
{
	return l > r ? l : r;
}

int Max(int l, int r)
{
	return l > r ? l : r;
}

int	Clamp(int n, int clampMin, int clampMax)
{
	if(n < clampMin)
		n = clampMin;
    
	else if(n > clampMax)
		n = clampMax;
	
	return n;
}

float ClampF(float n, float clampMin, float clampMax)
{
	if(n < clampMin)
		n = clampMin;
    
	else if(n > clampMax)
		n = clampMax;
	
	return n;
}

float DegreesToRadians(float degrees)
{
	return degrees * 0.0174532925f;
}

float DotVec2(vec2* vec0, vec2* vec1)
{
	return vec0->x * vec1->x + vec0->y * vec1->y;
}

float DotVec3(const vec3 *vec0, const vec3 *vec1)
{
	return vec0->x * vec1->x + vec0->y * vec1->y + vec0->z * vec1->z;
}

float Lerp(float f0, float f1, float t)
{
	return f0 + t * (f1 - f0);
}

void LerpVec2(vec2 *out_lerpedPos, vec2 *p0, vec2 *p1, float t)
{
	const float outX = p0->x + t *(p1->x - p0->x);
	const float outY = p0->y + t * (p1->y - p0->y);
	
	if(out_lerpedPos)
	{
		out_lerpedPos->x = outX;
		out_lerpedPos->y = outY;
	}
}

void  LerpVec3(vec3 *out_lerpedPos, const vec3 *p0, const vec3 *p1, float t)
{
	const float outX = p0->x + t * (p1->x - p0->x);
	const float outY = p0->y + t * (p1->y - p0->y);
	const float outZ = p0->z + t * (p1->z - p0->z);
	
	if(out_lerpedPos)
	{
		out_lerpedPos->x = outX;
		out_lerpedPos->y = outY;
		out_lerpedPos->z = outZ;
	}
}

float MagnitudeVec2(vec2 *vec)
{
	return sqrtf(DotVec2(vec,vec));
}

float DistVec3_2D(const vec3 *vec0, const vec3 *vec1)
{
	vec3 vec2D;
	SubVec3(&vec2D, vec0, vec1);
	vec2D.y = 0.0f;
	return MagnitudeSqVec3(&vec2D);
}

float DistVec3(const vec3 *vec0, const vec3 *vec1)
{
	return sqrtf(DistSqVec3(vec0,vec1));
}

float DistSqVec3(const vec3 *vec0, const vec3 *vec1)
{
	vec3 distVec;
	SubVec3(&distVec, vec0, vec1);
	return MagnitudeSqVec3(&distVec);
}

bool PosIsBehind(const vec3 *frontPos, const vec3 *frontAt, const vec3 *behindPos)
{
	vec3 dirVec;
	SubVec3(&dirVec, behindPos, frontPos);
	
	return DotVec3(frontAt, &dirVec) <= 0.0f;
}

float MagnitudeSqVec3(const vec3 *vec)
{
	return DotVec3(vec,vec);
}

float MagnitudeVec3(const vec3 *vec)
{
	return sqrtf(MagnitudeSqVec3(vec));
}

void NormalizeVec2(vec2 *vec)
{
	const float length = MagnitudeVec2(vec);
	vec->x/=length;
	vec->y/=length;
}

void NormalizeVec3(vec3 *vec)
{
	const float length = MagnitudeVec3(vec);
	vec->x/=length;
	vec->y/=length;
	vec->z/=length;
}

void SubVec2(vec2 *out_resultVec, vec2 *p0, vec2 *p1)
{
	out_resultVec->x = p0->x-p1->x;
	out_resultVec->y = p0->y-p1->y;
}

void SubVec2_Self(vec2 *out_resultVec, vec2 *p)
{
	out_resultVec->x -= p->x;
	out_resultVec->y -= p->y;
}

void SubVec3(vec3 *out_resultVec, const vec3 *p0, const vec3 *p1)
{
	out_resultVec->x = p0->x-p1->x;
	out_resultVec->y = p0->y-p1->y;
	out_resultVec->z = p0->z-p1->z;
}

void ScaleVec2_Self(vec2 *vec, float scale)
{
	vec->x *= scale;
	vec->y *= scale;
}

void ScaleVec2(vec2 *out_resultVec, vec2 *vec, float scale)
{
	out_resultVec->x = vec->x*scale;
	out_resultVec->y = vec->y*scale;
}

void ScaleVec3_Self(vec3 *vec, float scale)
{
	vec->x *= scale;
	vec->y *= scale;
	vec->z *= scale;
}

void ScaleVec3(vec3 *out_resultVec, const vec3 *vec, float scale)
{
	out_resultVec->x = vec->x*scale;
	out_resultVec->y = vec->y*scale;
	out_resultVec->z = vec->z*scale;
}

void AddScaledVec2_Self(vec2 *out_resultVec, vec2 *vec, float scale)
{
	out_resultVec->x += vec->x*scale;
	out_resultVec->y += vec->y*scale;
}

void AddScaledVec2(vec2 *out_resultVec, vec2 *vec0, vec2 *vec1, float scale)
{
	out_resultVec->x = vec0->x + vec1->x*scale;
	out_resultVec->y = vec0->y + vec1->y*scale;
}

void SubScaledVec2_Self(vec2 *out_resultVec, vec2 *vec, float scale)
{
	out_resultVec->x -= vec->x*scale;
	out_resultVec->y -= vec->y*scale;
}

void SubScaledVec2(vec2 *out_resultVec, vec2 *vec0, vec2 *vec1, float scale)
{
	out_resultVec->x = vec0->x - vec1->x*scale;
	out_resultVec->y = vec0->y - vec1->y*scale;
}

void AddVec2_Self(vec2 *out_resultVec, vec2 *vec)
{
	out_resultVec->x += vec->x;
	out_resultVec->y += vec->y;
}

void AddVec2(vec2 *out_resultVec, vec2 *vec0, vec2 *vec1)
{
	out_resultVec->x = vec0->x + vec1->x;
	out_resultVec->y = vec0->y + vec1->y;
}

void CopyVec2(vec2 *out_result, vec2 *point)
{
	out_result->x = point->x;
	out_result->y = point->y;
}

void CopyVec3(vec3 *out_result, const vec3 *point)
{
	out_result->x = point->x;
	out_result->y = point->y;
	out_result->z = point->z;
}

void CreatePlaneFromPointsVec2(struct PlaneVec2 *out_resultPlane, vec2 *p0, vec2 *p1)
{
	float tempX;
	//Copy point
	CopyVec2(&out_resultPlane->point, p0);
	
	//Create normal
	SubVec2(&out_resultPlane->normal, p1, p0);
	NormalizeVec2(&out_resultPlane->normal);
	
	tempX = out_resultPlane->normal.x;
	
	//Rotate 90 degrees (normal faces to the right of the direction)
	out_resultPlane->normal.x = out_resultPlane->normal.y;
	out_resultPlane->normal.y = -tempX;
}

bool PointInsidePlaneVec2(vec2 *point, struct PlaneVec2 *plane)
{
	vec2 dirVec;
	SubVec2(&dirVec,point, &plane->point);
	return DotVec2(&dirVec, &plane->normal) < 0.0f;
}

float AngleBetweenVec2(vec2 *vec0, vec2 *vec1)
{
	return (float)(atan2(vec1->y,vec1->x) - atan2(vec0->y,vec0->x));
}

float AngleBetweenVec3(vec3 *vec0, vec3 *vec1)
{
	//TODO: get the angle
	return 0;
}

void CrossVec3(vec3 *out_resultVec, const vec3 *vec0, const vec3 *vec1)
{
	const float x = vec0->y * vec1->z - vec1->y * vec0->z;
	const float y = vec0->z * vec1->x - vec1->z * vec0->x;
	const float z = vec0->x * vec1->y - vec1->x * vec0->y;
	
	out_resultVec->x = x;
	out_resultVec->y = y;
	out_resultVec->z = z;
}

void SetVec3(vec3 *out_resultVec,float x, float y, float z)
{
	out_resultVec->x = x;
	out_resultVec->y = y;
	out_resultVec->z = z;
}

void AddVec3_Self(vec3 *out_resultVec, vec3 *vec)
{
	out_resultVec->x += vec->x;
	out_resultVec->y += vec->y;
	out_resultVec->z += vec->z;
}

void AddVec3(vec3 *out_resultVec, vec3 *vec0, vec3 *vec1)
{
	out_resultVec->x = vec0->x+vec1->x;
	out_resultVec->y = vec0->y+vec1->y;
	out_resultVec->z = vec0->z+vec1->z;
}

void AddScaledVec3_Self(vec3 *out_resultVec, const vec3 *vec, float scale)
{
	out_resultVec->x += vec->x*scale;
	out_resultVec->y += vec->y*scale;
	out_resultVec->z += vec->z*scale;
}

void AddScaledVec3(vec3 *out_resultVec, const vec3 *vec0, const vec3 *vec1, float scale)
{
	out_resultVec->x = vec0->x+vec1->x*scale;
	out_resultVec->y = vec0->y+vec1->y*scale;
	out_resultVec->z = vec0->z+vec1->z*scale;
}

void SubScaledVec3_Self(vec3 *out_resultVec, vec3 *vec, float scale)
{
	out_resultVec->x -= vec->x*scale;
	out_resultVec->y -= vec->y*scale;
	out_resultVec->z -= vec->z*scale;
}

void SubScaledVec3(vec3 *out_resultVec, vec3 *vec0, vec3 *vec1, float scale)
{
	out_resultVec->x = vec0->x-vec1->x*scale;
	out_resultVec->y = vec0->y-vec1->y*scale;
	out_resultVec->z = vec0->z-vec1->z*scale;
}

float ClockwiseDegFromNorth(float deg)
{
    float rtn = 90 - deg;
    
    if (rtn < 0)
        rtn = 360 + rtn;
    
    return rtn;
}

int ININT(double X)
{
    if (X < 0)
        return ((int)(X - 0.5));
    
    return ((int)(X + 0.5));
}

int iSign(double *val)
{
	if (*val < 0)
		return -1;
    
	else
		return 1;
}

float BTWNTWOPI(float AZ1)
{
    if (AZ1 < 0)
      	return (float)(TWOPI + fmod(AZ1, (float)TWOPI));
    
    if (AZ1 == 0)
      	return (AZ1);
    
    return (float)(fmod(AZ1,(float)TWOPI));
}

double DTWOPI(double az)
{
    if (az < 0)
      	return (float)(TWOPI + fmod(az,(double)TWOPI));
    
    if (az == 0)
      	return (az);
    
    return fmod(az, TWOPI);
}

int diffInDegrees(int angle1,int angle2)
{
    int rtn = angle2 - angle1;
    int mindiff = abs(rtn);
    int diff = (angle2 + 360) - angle1;
    
    if (abs(diff) < mindiff)
    {
        mindiff = abs(diff);
        rtn = diff;
    }

    diff = (angle2-360)-angle1;
    
    if (abs(diff) < mindiff)
        rtn = diff;
    
    return rtn;
}


float distpd(vec2 *Point1, vec2 *Point2)
{
    return (float)sqrt((Point1->x - Point2->x) * (Point1->x - Point2->x) +
                       (Point1->y - Point2->y) * (Point1->y - Point2->y));
}

double LDIST(double X1, double Y1, double X2, double Y2)
{
	double xdf = (X1 - X2);
	double ydf = (Y1 - Y2);
  	
  	return sqrt(xdf * xdf + ydf * ydf);
}

double LGETAZ(double X1, double Y1, double X2, double Y2)
{
	double rtn = DTWOPI(atan2(Y2 - Y1, X2 - X1));
	return rtn;
}

double HeadingToAzimuth (double heading)
{
	double rtn = fmod((360 - heading) * DEGtoRAD + HALFPI,TWOPI);
	return rtn;
}

vec2 newpt(vec2 *OldPoint, float AZM, float DIS)
{
    vec2 NewPoint;
    
    NewPoint.x = (float)(OldPoint->x + DIS * cos(AZM));
    NewPoint.y = (float)(OldPoint->y + DIS * sin(AZM));
    return NewPoint;
}

dvec2 dnewpt(dvec2 *OldPoint, double AZM, double DIS)
{
    dvec2 NewPoint;
    
    NewPoint.x = OldPoint->x + DIS * cos(AZM);
    NewPoint.y = OldPoint->y + DIS * sin(AZM);
    return NewPoint;
}

float getazmd(vec2 *Point1, vec2 *Point2)
{
	float rtn = BTWNTWOPI((float)atan2((Point2->y - Point1->y), (Point2->x - Point1->x)));
	return rtn;
}

double getazd(LPDPOINT Point1, LPDPOINT Point2)
{
	double rtn = DTWOPI(atan2((Point2->y - Point1->y), (Point2->x - Point1->x)));
	return rtn;
}

float DeltaAZ(float *AZ1, float *AZ2)
{
	float daz;
	daz = *AZ2 - *AZ1;
    
	if (daz < -PY)
		daz += (float)TWOPI;
    
	else if (daz > PY)
		daz -= (float)TWOPI;
    
	return daz;
}

void InitBounds(bounds *bnds)
{
	bnds->xmn = FLT_MAX;
	bnds->ymn = FLT_MAX;
	bnds->xmx = -FLT_MAX;
	bnds->ymx = -FLT_MAX;
	return;
}

void AddPointToBounds(bounds *pBounds,vec2 *pt)
{
    pBounds->xmn = min (pBounds->xmn,pt->x);
    pBounds->ymn = min (pBounds->ymn,pt->y);
    pBounds->xmx = max (pBounds->xmx,pt->x);
    pBounds->ymx = max (pBounds->ymx,pt->y);
	return;
}

void InitDBounds(dbounds *bnds)
{
    bnds->xmn = DBL_MAX;
    bnds->ymn = DBL_MAX;
    bnds->xmx = -DBL_MAX;
    bnds->ymx = -DBL_MAX;
    return;
}

void InitIBounds(IBOUNDS *bnds)
{
    bnds->xmn = INT_MAX;
    bnds->ymn = INT_MAX;
    bnds->xmx = INT_MIN;
    bnds->ymx = INT_MIN;
    return;
}

IBOUNDS IBoundsFromPointAndDist(IPOINT pt, int dist)
{
    IBOUNDS bnds;
    
    bnds.xmn = pt.x - dist;
    bnds.xmx = pt.x + dist;
    bnds.ymn = pt.y - dist;
    bnds.ymx = pt.y + dist;
    return bnds;
}

IPOINT IBoundsMid(IBOUNDS *bnds)
{
    IPOINT pt;
    
    pt.x = (int)(bnds->xmn + (bnds->xmx - bnds->xmn) / 2);
    pt.y = (int)(bnds->ymn + (bnds->ymx - bnds->ymn) / 2);
    return pt;
}

void AddPointToDBounds(dbounds *pBounds, dvec2 *pt)
{
    pBounds->xmn = min(pBounds->xmn, pt->x);
    pBounds->ymn = min(pBounds->ymn, pt->y);
    pBounds->xmx = max(pBounds->xmx, pt->x);
    pBounds->ymx = max(pBounds->ymx, pt->y);
    return;
}

void AddDPointToBounds(dbounds *pBounds, DPOINT *pt)
{
    pBounds->xmn = min(pBounds->xmn, pt->x);
    pBounds->ymn = min(pBounds->ymn, pt->y);
    pBounds->xmx = max(pBounds->xmx, pt->x);
    pBounds->ymx = max(pBounds->ymx, pt->y);
    return;
}

void AddPointToIBounds(IBOUNDS *pBounds, IPOINT *pt)
{
    pBounds->xmn = min(pBounds->xmn, pt->x);
    pBounds->ymn = min(pBounds->ymn, pt->y);
    pBounds->xmx = max(pBounds->xmx, pt->x);
    pBounds->ymx = max(pBounds->ymx, pt->y);
    return;
}

/*
 Determine which side of a plane the point p lies.
 The plane is defined by a normal n and point on the plane vp.
 Return 1 if the point is on the same side as the normal,
 otherwise -1.
 */
int WhichSide(vec3 p, vec3 n, vec3 vp)
{
    double D,s;
    
    D = -(n.x * vp.x + n.y * vp.y + n.z * vp.z);
    s = n.x * p.x + n.y * p.y + n.z * p.z + D;
    
    return(s <= 0 ? -1 : 1);
}

vec3 VectorFromPoints(vec3 *p1, vec3 *p2)
{
	vec3 outVector;
    
	outVector.x = p2->x - p1->x;
	outVector.y = p2->y - p1->y;
	outVector.z = p2->z - p1->z;
	return outVector;
}

vec3 sVectorFromPoints(svec3 *p1, svec3 *p2)
{
	vec3 outVector;
    
	outVector.x = p2->x - p1->x;
	outVector.y = p2->y - p1->y;
	outVector.z = p2->z - p1->z;
	return outVector;
}

vec3 GetTriangleNormal(vec3 *vertex1, vec3 *vertex2, vec3 *vertex3)
{
	vec3 vNormal, v1, v2;
	v1 = VectorFromPoints(vertex2, vertex1);
	v2 = VectorFromPoints(vertex3, vertex1);
	
	CrossVec3(&vNormal, &v1, &v2);
	NormalizeVec3(&vNormal);
    return vNormal;
}

double ComputeMaxSlope(double frontSlope, double sideSlope)
{
    double rtn = 0;
    vec3 vertex1, vertex2, vertex3;
    vec3 normal;
    double xyDist;
    
    vertex1.x = vertex1.y = vertex1.z = 0.0f;
    vertex2.x = 1.0f;
    vertex2.y = 0.0f;
    vertex2.z = sideSlope / 100.0;
    vertex3.x = 0.0f;
    vertex3.y = 1.0f;
    vertex3.z = frontSlope / 100.0;
    normal = GetTriangleNormal(&vertex1, &vertex2, &vertex3);
    xyDist = LDIST(0.0, 0.0, normal.x, normal.y);
    
    if (fabs(normal.z) > 0.0000001)
        rtn = (100.0 * fabs(xyDist / normal.z));
    
    else
        rtn = -9999.0;
    
    return rtn;
}

vec3 sGetTriangleNormal(svec3 *vertex1, svec3 *vertex2, svec3 *vertex3, double metersperpixel)
{
	vec3 vNormal, v1, v2;
	vec3 vertex1f, vertex2f, vertex3f;
	float f = metersperpixel;
	
	vertex1f.x = vertex1->x * f;
	vertex1f.y = vertex1->y * f;
	vertex1f.z = FTM * vertex1->z / 8.0f;
    
	vertex2f.x = vertex2->x * f;
	vertex2f.y = vertex2->y * f;
	vertex2f.z = FTM * vertex2->z / 8.0f;
    
	vertex3f.x = vertex3->x * f;
	vertex3f.y = vertex3->y * f;
	vertex3f.z = FTM * vertex3->z / 8.0f;
    
	v1 = VectorFromPoints(&vertex2f, &vertex1f);
	v2 = VectorFromPoints(&vertex3f, &vertex1f);
	
	CrossVec3(&vNormal, &v1, &v2);
	NormalizeVec3(&vNormal);
    return vNormal;
}

void GetFrustum ()
{
	return;
}

void GetFrustum2(float LIGHTLOOKAT[3],float lightPos[3])
{

}

float getazm (vec2 *Point1, vec2 *Point2)
{
	float rtn = BTWNTWOPI((float)atan2((Point2->y - Point1->y), (Point2->x - Point1->x)));
	return rtn;
}

void Rotate256 (int irot,vec2 *pt)
{
    float XOUT, YOUT;
    
    if (irot < 1 || irot > 255)
        return;
    
    XOUT = B1[irot] * pt->x + C1[irot] * pt->y;
    YOUT = B2[irot] * pt->y + C2[irot] * pt->x;
    
    pt->x = XOUT;
    pt->y = YOUT;
    return;
}

/*
    Determine which side of a plane the point p lies.
    The plane is defined by a normal n and point on the plane vp.
    Return 1 if the point is on the same side as the normal,
    otherwise -1.
*/
vec3 MultiplyVec3ByMat3(vec3 *v, mat3 mat)
{
	vec3 vout;
    
	vout.x = v->x * mat[0][0] + v->y * mat[0][1] + v->z * mat[0][2];
	vout.y = v->x * mat[1][0] + v->y * mat[1][1] + v->z * mat[1][2];
	vout.z = v->x * mat[2][0] + v->y * mat[2][1] + v->z * mat[2][2];
    
	return vout;
}

double AMEAN (double X[],int N)
{
    double SUM;
    int I;
    SUM = 0;
    
    for (I = 0; I < N; I++)
        SUM += X[I];
    
    return (SUM / N);
}

float MULREG(double Y[], double X1[], double X2[], int N, double *A, double *B, double *C)
{
    double D, DY, SMD1SQ, SMD2SQ, SMYSQ, SMD1D2, SMD1Y, SMD2Y, YHAT, X1HAT, X2HAT, D1, D2;
    short I;
    float RSQ;
    
    SMD1SQ = 0e0;
    SMD2SQ = 0e0;
    SMYSQ  = 0e0;
    SMD1D2 = 0e0;
    SMD1Y  = 0e0;
    SMD2Y  = 0e0;
    YHAT   = AMEAN(Y,N);
    X1HAT  = AMEAN(X1,N);
    X2HAT  = AMEAN(X2,N);
    
    for (I = 0; I < N; I++)
    {
        D1 = X1[I] - X1HAT;
        D2 = X2[I] - X2HAT;
        DY = Y[I]  - YHAT;
        SMD1SQ = SMD1SQ + pow(D1,2);
        SMD2SQ = SMD2SQ + pow(D2,2);
        SMD1D2 = SMD1D2 + D1 * D2;
        SMYSQ = SMYSQ + pow(DY,2);
        SMD1Y = SMD1Y + D1 * DY;
        SMD2Y = SMD2Y + D2 * DY;
    }
    
    D = SMD1SQ * SMD2SQ - pow(SMD1D2,2);
    
    if (D == 0E0)
      	return (float)(0.0);
    
    *B = (SMD2SQ * SMD1Y - SMD1D2 * SMD2Y) / D;
    *C = (SMD1SQ * SMD2Y - SMD1D2 * SMD1Y) / D;
    *A = YHAT - *B * X1HAT - *C * X2HAT;
    
    if (!SMYSQ)
      	RSQ = 1.0;
    
    else
      	RSQ = (float)((*B * SMD1Y + *C * SMD2Y) / SMYSQ);
    
    return(RSQ);
}

bool LINFIT(LPDPOINT pPoint, long N, double *A, double *B, double *MAXDIF, long *LOFMDF)
{
	double SUMX = 0, SUMY = 0, XAVE, YAVE, SMXDYD, SMXDSQ, SUMXY = 0, SUMXSQ = 0, DIFF;
	double	SUMxy = 0, SUMx2 = 0;
	long I;
	LPDPOINT pPointIn = pPoint;
    
	for (I = 0; I < N; I++, pPoint++)
	{
        SUMX += pPoint->x;
        SUMY += pPoint->y;
        SUMXY += pPoint->x * pPoint->y;
    	SUMXSQ += pPoint->x * pPoint->x;
    }
    
    XAVE   = SUMX / N;
    YAVE   = SUMY / N;
    SMXDSQ = SUMXSQ - (SUMX * SUMX) / N;
    SMXDYD = SUMXY  - (SUMX * SUMY) / N;
    
    if (!SMXDSQ)
    	return false;
    
    *B = SMXDYD / SMXDSQ;
    *A = YAVE - *B * XAVE;
    
	if (MAXDIF)
	{
		*LOFMDF = 0;
		*MAXDIF = 0;
	}
    
    pPoint = pPointIn;
    
	for (I = 0; I < N; I++, pPoint++)
	{
		SUMxy += (pPoint->x - XAVE) * (pPoint->y - YAVE);
		SUMx2 += pow(pPoint->x - XAVE,2);
	}
    
	if (!SUMx2)
		return false;
    
	*B = SUMxy / SUMx2;
    pPoint = pPointIn;
    
	for (I = 0; I < N; I++, pPoint++)
	{
    	DIFF = fabs(pPoint->y - (*A + *B * pPoint->x));
        
        if (MAXDIF && DIFF > *MAXDIF)
        {
         	*MAXDIF = DIFF;
         	*LOFMDF = I;
        }
    }
    return true;
}

LPTRANDATA STRAN2(int ID, double X1[], double Y1[], double X2[], double Y2[], int N, float *RSQMIN)
{
	double ANGLE1, ANGLE2, ANGLE, DEN, SINANG, COSANG, DX1, DX2, DY1, DY2, SCLRAT,
    ANGLED, BASX1, BASX2, BASY1, BASY2, D,TOTD, *XT1, *YT1, *XT2, *YT2;
    float RSQ1, RSQ2;
    short NUM, I,J,i;
    LPTRANDATA TranPtr = 0;
    LPDPOINT pPoints;
    double A, B, xmin, xmax;
    
    if (!N || N > MAXTRANPOINTS)
    	goto Exit;
    
    for (i = 0;i < N; i++)
    {
    	if (X1[i] != X2[i] || Y1[i] != Y2[i])
    		goto Start;
    }
    
Start:
    XT1 = (double *)malloc(4 * MAXTRANPOINTS * sizeof(double));
    XT2 = XT1 + MAXTRANPOINTS;
    YT1 = XT2 + MAXTRANPOINTS;
    YT2 = YT1 + MAXTRANPOINTS;
    TranPtr = (LPTRANDATA) calloc(1, sizeof(TRANDATA));
    
    if (N == 2) goto S10;
    
    BASX1 = DBL_MAX;
    BASX2 = DBL_MAX;
    BASY1 = DBL_MAX;
    BASY2 = DBL_MAX;
    
    for (I = 0; I < N; I++)
    {
        BASX1  = min (BASX1, X1[I]);
        BASX2  = min (BASX2, X2[I]);
        BASY1  = min (BASY1, Y1[I]);
        BASY2  = min (BASY2, Y2[I]);
    }
    
    for (I = 0; I < N; I++)
    {
        XT1[I] = X1[I] - BASX1;
        XT2[I] = X2[I] - BASX2;
        YT1[I] = Y1[I] - BASY1;
        YT2[I] = Y2[I] - BASY2;
    }
    
    RSQ1 = MULREG(XT2, XT1, YT1, N, &TranPtr->A1, &TranPtr->B1, &TranPtr->C1);
    RSQ2 = MULREG(YT2, YT1, XT1, N, &TranPtr->A2, &TranPtr->B2, &TranPtr->C2);
    TranPtr->A1 = TranPtr->A1 + BASX2;
    TranPtr->A2 = TranPtr->A2 + BASY2;
    TranPtr->BASX = BASX1;
    TranPtr->BASY = BASY1;
    *RSQMIN = min(RSQ1,RSQ2);
    TranPtr->NSETPT = N;
    free(XT1);
    goto Exit;
    
//SET-UP WITH N EQ 2.
S10: NUM = 0;
    ANGLE = 0;
    SCLRAT = 0;
    TOTD = 0;
    
    for (I = 0; I < N - 1; I++)
    {
        for (J = I + 1; J < N; J++)
        {
            DX1 = X1[J] - X1[I];
            DX2 = X2[J] - X2[I];
            DY1 = Y1[J] - Y1[I];
            DY2 = Y2[J] - Y2[I];
            DEN = pow(DX1,2) + pow(DY1,2);
            
            if (!DEN)
	          	continue;
            
            D = sqrt(DEN);
            TOTD += D;
            SCLRAT = SCLRAT + (sqrt((pow(DX2, 2) + pow(DY2, 2)) / DEN)) * D;
            ANGLE1 = atan2(DY2, DX2);
            ANGLE2 = atan2(DY1, DX1);
            ANGLED  = DTWOPI(ANGLE2 - ANGLE1);
            
            if (ANGLED > PY)
	          	ANGLED =  ANGLED - TWOPI;
            
            ANGLE  = ANGLE + ANGLED * D;
            NUM = NUM + 1;
        }
    }
    
    if (!NUM)
      	goto S1000;
    
    ANGLE  = ANGLE / TOTD;
    SCLRAT = SCLRAT / TOTD;
    COSANG = cos(ANGLE);
    SINANG = sin(ANGLE);
    TranPtr->B1 = COSANG * SCLRAT;
    TranPtr->C1 = SINANG * SCLRAT;
    TranPtr->B2 = COSANG * SCLRAT;
    TranPtr->C2 =-SINANG * SCLRAT;
    TranPtr->A1 = 0;
    TranPtr->A2 = 0;
    pPoints = (LPDPOINT)malloc(sizeof(DPOINT) * N);
    xmin = DBL_MAX;
    xmax = -DBL_MAX;
    
    for (I = 0; I < N; I++)
    {
        TranPtr->A1 = TranPtr->A1 + X2[I] - (COSANG * X1[I] +SINANG * Y1[I]) * SCLRAT;
        TranPtr->A2 = TranPtr->A2 + Y2[I] - (COSANG * Y1[I] -SINANG * X1[I]) * SCLRAT;
        pPoints[I].x = X1[I];
        pPoints[I].y = Y1[I];
        xmin = min(xmin, X2[I]);
        xmax = max(xmax, X2[I]);
    }
    
    if (LINFIT(pPoints, N, &A, &B, 0, 0))
    {
        pPoints[0].x = xmin;
        pPoints[0].y = A + pPoints[0].x * B;
        pPoints[1].x = xmax;
        pPoints[1].y = A + pPoints[1].x * B;
        TranPtr->FitPointAZFrom = getazd(&pPoints[0], &pPoints[1]);
    }
    
    xmin = DBL_MAX;
    xmax = -DBL_MAX;
    
    for (I = 0; I < N; I++)
    {
        pPoints[I].x = X2[I];
        pPoints[I].y = Y2[I];
        xmin = min(xmin, X2[I]);
        xmax = max(xmax, X2[I]);
    }
    
    if (LINFIT(pPoints, N, &A, &B, 0, 0))
    {
        pPoints[0].x = xmin;
        pPoints[0].y = A + pPoints[0].x * B;
        pPoints[1].x = xmax;
        pPoints[1].y = A + pPoints[1].x * B;
        TranPtr->FitPointAZTo = getazd(&pPoints[0], &pPoints[1]);
    }
    
    free(pPoints);
    TranPtr->A1 = TranPtr->A1 / N;
    TranPtr->A2 = TranPtr->A2 / N;
    *RSQMIN = (float)1.;
    TranPtr->BASX = 0;
    TranPtr->BASY = 0;
    TranPtr->NSETPT = N;
    free(XT1);
    goto Exit;
S1000:
    free(XT1);
    free(TranPtr);
    TranPtr = 0;
Exit:
    return TranPtr;
}

void TRANS2(double XIN, double YIN, double *XOUT,double *YOUT, LPTRANDATA TranPtr)
{
	double XI, YI;
	DPOINT Point;
    
    if (!TranPtr)
    {
      	*XOUT = XIN;
      	*YOUT = YIN;
      	goto Exit2;
    }
    
    Point.x = XIN;
    Point.y = YIN;
    XI = XIN - TranPtr->BASX;
    YI = YIN - TranPtr->BASY;
    *XOUT = TranPtr->A1 + TranPtr->B1 * XI + TranPtr->C1 * YI;
    *YOUT = TranPtr->A2 + TranPtr->B2 * YI + TranPtr->C2 * XI;
Exit2:
    return;
}

double Acos(double v)
{
	v = max(-1.0e0, v);
	v = min(1.0e0, v);
	v = acos(v);
	return v;
}

dvec2 PointOnEllipseAtAngle(double a, double b, double az)
{
	double x0 = cos(az), y0 = sin(az);
	double x = x0 * (a * b) / sqrt(a * a * y0 * y0 + b * b * x0 * x0);
	double y = y0 * (a * b) / sqrt(a * a * y0 * y0 + b * b * x0 * x0);
    
	dvec2 rtn;
	rtn.x = x;
	rtn.y = y;
	return rtn;
}

void MNMXCORLtoMNMXCORD(MNMXCORL *in, MNMXCORD *out)
{
	out->xmn = in->xmn;
	out->xmx = in->xmx;
	out->ymn = in->ymn;
	out->ymx = in->ymx;
	return;
}

void MNMXCORDtoMNMXCORL(MNMXCORD *in, MNMXCORL *out)
{
	out->xmn = ININT(in->xmn);
	out->xmx = ININT(in->xmx);
	out->ymn = ININT(in->ymn);
	out->ymx = ININT(in->ymx);
	return;
}

void InflateMNMXCORL(LPMNMXCORL pBounds, int Value)
{
	pBounds->xmn -= Value;
	pBounds->xmx += Value;
	pBounds->ymn -= Value;
	pBounds->ymx += Value;
	return;
}

void TranMNMXCORD(MNMXCORD *in, MNMXCORD *out, LPTRANDATA TranPtr)
{
	dvec2 outpt;
	dbounds outb;
	InitDBounds(&outb);
    
	TRANS2(in->xmn, in->ymn, &outpt.x, &outpt.y, TranPtr);
	AddPointToDBounds(&outb, &outpt);
	TRANS2(in->xmn, in->ymx, &outpt.x, &outpt.y, TranPtr);
	AddPointToDBounds(&outb, &outpt);
	TRANS2(in->xmx, in->ymn, &outpt.x, &outpt.y, TranPtr);
	AddPointToDBounds(&outb, &outpt);
	TRANS2(in->xmx, in->ymx, &outpt.x, &outpt.y, TranPtr);
	AddPointToDBounds(&outb, &outpt);
	memcpy(out, &outb, sizeof(MNMXCORD));
	return;
}

void TranMNMXCORL(MNMXCORL *in, MNMXCORL *out, LPTRANDATA TranPtr)
{
	MNMXCORD ind, outd;
	MNMXCORLtoMNMXCORD(in, &ind);
	TranMNMXCORD(&ind, &outd, TranPtr);
	MNMXCORDtoMNMXCORL(&outd, out);
	return;
}

int fgetstring(char *str, int maxlen, FILE *fid)
{
    int ln;
    char * pEnd;
    
    if (!fgets(str,maxlen,fid))
        return 0;
    
    pEnd = strchr(str,'\r');
    
    if (pEnd)
        *pEnd = 0;
    
    pEnd = strchr(str,'\n');
    
    if (pEnd)
        *pEnd = 0;
    
    ln = (int)strlen(str);
    return ln;
}

//dir = 1 bitmap to world, 2 = world to bmp
LPTRANDATA  LoadTranFromBPW(char *Name, int dir)
{
	FILE *Fid = fopen(Name,"rb");
    LPTRANDATA TranPtr = 0;
	double XFROM[4], YFROM[4], XTO[4], YTO[4];
	double xres, yres, bpx, bpy, wx, wy;
	char str[66];
	float RSQMIN = 0;
    
    if (Fid)
    {
		fgetstring(str, 64, Fid);
		xres = atof(str);
		fgetstring(str, 64, Fid);
		bpx = atof(str);
		fgetstring(str, 64, Fid);
		bpy = atof(str);
		fgetstring(str, 64, Fid);
		yres = atof(str);
		fgetstring(str, 64, Fid);
		wx = atof(str);
		fgetstring(str, 64, Fid);
		wy = atof(str);
		XFROM[0] = bpx;
		YFROM[0] = bpy;
		XFROM[1] = bpx + 100;
		YFROM[1] = bpy;
		XFROM[2] = bpx + 100;
		YFROM[2] = bpy + 100;
		XFROM[3] = bpx;
		YFROM[3] = bpy + 100;
		XTO[0] = wx;
		YTO[0] = wy;
		XTO[1] = wx + 100 * xres;
		YTO[1] = wy;
		XTO[2] = wx + 100 * xres;
		YTO[2] = wy + 100 * yres;
		XTO[3] = wx;
		YTO[3] = wy + 100 * yres;
        
        if (dir == 2)
            TranPtr = STRAN2(1660, XTO, YTO, XFROM, YFROM, 4, &RSQMIN);
        
        else
            TranPtr = STRAN2(1660, XFROM, YFROM, XTO, YTO, 4, &RSQMIN);
        
		fclose(Fid);
	}
    
	return TranPtr;
}

//dir = 1 bitmap to world, 2 = world to bmp
LPTRANDATA  LoadTranFromCPT(const char *Name, int dir)
{
	FILE *Fid = fopen(Name,"rb");
    LPTRANDATA TranPtr = 0;
	double XFROM[4], YFROM[4], XTO[4], YTO[4];
	char str[130];
	float RSQMIN=0;
    
    if (Fid != NULL)
    {
        for (int i = 0; i < 4; i++)
        {
            fgetstring (str, 128, Fid);
            sscanf(str, "%lf %lf %lf %lf", &XFROM[i], &YFROM[i], &XTO[i], &YTO[i]);
        }
        
        if (dir == 2)
            TranPtr = STRAN2 (1660 ,XTO, YTO, XFROM, YFROM, 4, &RSQMIN);
        
        else
            TranPtr = STRAN2 (1660, XFROM, YFROM, XTO, YTO, 4, &RSQMIN);
        
		fclose(Fid);
	}
	return TranPtr;
}

bool CreateMask(LPDPOINT *pPointsIN, int *pnPoints, bounds *pbnds)
{
    LPDPOINT pPoints = *pPointsIN;
    int nNewPoints = 5;
    
    if (!pnPoints || !pPoints || *pnPoints < 3)
        return false;
    
    LPDPOINT pNewPoints = (LPDPOINT)malloc(sizeof(DPOINT) * (*pnPoints + 5));
    
    pNewPoints[0].x = pbnds->xmn;
    pNewPoints[0].y = pbnds->ymn;
    pNewPoints[1].x = pbnds->xmn;
    pNewPoints[1].y = pbnds->ymx;
    pNewPoints[2].x = pbnds->xmx;
    pNewPoints[2].y = pbnds->ymx;
    pNewPoints[3].x = pbnds->xmx;
    pNewPoints[3].y = pbnds->ymn;
    pNewPoints[4].x = pbnds->xmn;
    pNewPoints[4].y = pbnds->ymn;
    
    for (int i = *pnPoints -1; i >= 0; i--)
    {
        pNewPoints[nNewPoints].x = pPoints[i].x;
        pNewPoints[nNewPoints++].y = pPoints[i].y;
    }
    
    *pnPoints = nNewPoints;
    free(pPoints);
    *pPointsIN = pNewPoints;
    return true;
}