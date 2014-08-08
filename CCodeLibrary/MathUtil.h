
/*#ifndef __MATHUTIL_H
#define __MATHUTIL_H

#include "MathTypes.h"
#include <stdbool.h>

#define PI 3.141592653589f
#define PY		  3.141592653589793e0
#define TWOPI     6.283185307179586e0
#define	HALFPI    1.570796326794896e0 
#define RADtoDEG 57.295779513082322
#define DEGtoRAD 0.017453292519943296
#define MFT  3.280833333333333e0
#define FTM 3.04800609601219e-1

#ifndef max
#define max(a,b)            (((a) > (b)) ? (a) : (b))
#endif

#ifndef min
#define min(a,b)            (((a) < (b)) ? (a) : (b))
#endif

#define IDNINT(r)     (int)(r < 0 ? r - 0.5f : r + 0.5f)

//1D
float DegreesToRadians(float degrees);
float Lerp(float f0, float f1, float t);
int	  Clamp(int n, int clampMin, int clampMax);
float ClampF(float n, float clampMin, float clampMax);
float MaxF(float l, float r);
int Max(int l, int r);

//2D
float DotVec2(vec2* vec0, vec2* vec1);
void  LerpVec2(vec2* out_lerpedPos, vec2* p0, vec2* p1, float t);
void  NormalizeVec2(vec2* vec);
float MagnitudeVec2(vec2* vec);
void  SubVec2(vec2* out_resultVec, vec2* p0, vec2* p1);
void  SubVec2_Self(vec2* out_resultVec, vec2* p);
void  ScaleVec2_Self(vec2* vec, float scale);
void  ScaleVec2(vec2* out_resultVec, vec2* vec, float scale);
void  AddVec2_Self(vec2* out_resultVec, vec2* vec);
void  AddVec2(vec2* out_resultVec, vec2* vec0, vec2* vec1);
void  AddScaledVec2_Self(vec2* out_resultVec, vec2* vec, float scale);
void  AddScaledVec2(vec2* out_resultVec, vec2* vec0, vec2* vec1, float scale);
void  SubScaledVec2_Self(vec2* out_resultVec, vec2* vec, float scale);
void  SubScaledVec2(vec2* out_resultVec, vec2* vec0, vec2* vec1, float scale);
void  CopyVec2(vec2* out_result, vec2* point);
void  CreatePlaneFromPointsVec2(struct PlaneVec2* out_resultPlane, vec2* p0, vec2* p1);
bool  PointInsidePlaneVec2(vec2* point,struct PlaneVec2* plane);
bool  PointInsidePlaneVec2(vec2* point, struct PlaneVec2* plane);
float AngleBetweenVec2(vec2* vec0, vec2* vec1);

//3D
void  SetVec3(vec3* out_resultVec,float x, float y, float z);
void  CrossVec3(vec3* out_resultVec, const vec3* vec0, const vec3* vec1);
float DotVec3(const vec3* vec0, const vec3* vec1);
void  LerpVec3(vec3* out_lerpedPos, const vec3* p0, const vec3* p1, float t);
void  NormalizeVec3(vec3* vec);
float MagnitudeVec3(const vec3* vec);
bool  PosIsBehind(const vec3* frontPos, const vec3* frontAt, const vec3* behindPos);
float DistSqVec3(const vec3* vec0, const vec3* vec1);
float DistVec3_2D(const vec3* vec0, const vec3* vec1);
float DistVec3(const vec3* vec0, const vec3* vec1);
float MagnitudeSqVec3(const vec3* vec);
void  AddVec3_Self(vec3* out_resultVec, vec3* vec);
void  AddVec3(vec3* out_resultVec, vec3* vec0, vec3* vec1);
void  AddScaledVec3_Self(vec3* out_resultVec, const vec3* vec, float scale);
void  AddScaledVec3(vec3* out_resultVec, const vec3* vec0, const vec3* vec1, float scale);
void  SubScaledVec3_Self(vec3* out_resultVec, vec3* vec, float scale);
void  SubScaledVec3(vec3* out_resultVec, vec3* vec0, vec3* vec1, float scale);
void  SubVec3(vec3* out_resultVec, const vec3* p0, const vec3* p1);
void  ScaleVec3_Self(vec3* vec, float scale);
void  ScaleVec3(vec3* out_resultVec, const vec3* vec, float scale);
void  CopyVec3(vec3* out_result, const vec3* point);
float AngleBetweenVec3(vec3* vec0, vec3* vec1);

float distpd(vec2 *Point1, vec2 *Point2);
float getazmd (vec2 *Point1, vec2 *Point2);
vec2  newpt (vec2 *OldPoint, float AZM, float DIS);
dvec2 dnewpt (dvec2 *OldPoint, double AZM, double DIS);
float DeltaAZ (float *AZ1, float *AZ2);
float BTWNTWOPI (float AZ1);
void InitBounds (bounds* bnds);
void AddPointToBounds (bounds* bnds,vec2 *pt);
void InitDBounds (dbounds* bnds);
void AddPointToDBounds (dbounds* bnds,dvec2 *pt);
void Rotate256 (int irot,vec2* pt);
double LDIST(double X1,double Y1,double X2,double Y2);
double LGETAZ(double X1, double Y1, double X2, double Y2);
double DTWOPI (double az);
vec3 GetTriangleNormal (vec3 * vertex1,vec3 * vertex2,vec3 * vertex3);
double ComputeMaxSlope (double frontSlope,double sideSlope);


#endif*/

#ifndef __MATHUTIL_H
#define __MATHUTIL_H

#include "MathTypes.h"
#include <stdbool.h>

#define PI 3.141592653589f
#define PY		  3.141592653589793e0
#define TWOPI     6.283185307179586e0
#define	HALFPI    1.570796326794896e0
#define RADtoDEG 57.295779513082322
#define DEGtoRAD 0.017453292519943296
#define MFT  3.280833333333333e0
#define FTM 3.04800609601219e-1

#ifndef max
#define max(a,b)            (((a) > (b)) ? (a) : (b))
#endif

#ifndef min
#define min(a,b)            (((a) < (b)) ? (a) : (b))
#endif

#define IDNINT(r)     (int)(r < 0 ? r - 0.5f : r + 0.5f)
typedef struct
{
    int NSETPT;
    double  A1, A2, B1, B2, C1, C2, BASX, BASY;
    double	FitPointAZFrom, FitPointAZTo;
} TRANDATA;
typedef TRANDATA    *LPTRANDATA;
#define MAXTRANPOINTS	32

typedef struct
{	long	xmn;
    long	ymn;
    long	xmx;
    long	ymx;
} MNMXCORL;
typedef MNMXCORL *LPMNMXCORL;
typedef struct
{	double	xmn;
    double	ymn;
    double	xmx;
    double	ymx;
} MNMXCORD;
typedef MNMXCORD *LPMNMXCORD;

//1D
float ClockwiseDegFromNorth (float deg);
float DegreesToRadians(float degrees);
float Lerp(float f0, float f1, float t);
int	  Clamp(int n, int clampMin, int clampMax);
float ClampF(float n, float clampMin, float clampMax);
float MaxF(float l, float r);
int Max(int l, int r);

//2D
float DotVec2(vec2* vec0, vec2* vec1);
void  LerpVec2(vec2* out_lerpedPos, vec2* p0, vec2* p1, float t);
void  NormalizeVec2(vec2* vec);
float MagnitudeVec2(vec2* vec);
void  SubVec2(vec2* out_resultVec, vec2* p0, vec2* p1);
void  SubVec2_Self(vec2* out_resultVec, vec2* p);
void  ScaleVec2_Self(vec2* vec, float scale);
void  ScaleVec2(vec2* out_resultVec, vec2* vec, float scale);
void  AddVec2_Self(vec2* out_resultVec, vec2* vec);
void  AddVec2(vec2* out_resultVec, vec2* vec0, vec2* vec1);
void  AddScaledVec2_Self(vec2* out_resultVec, vec2* vec, float scale);
void  AddScaledVec2(vec2* out_resultVec, vec2* vec0, vec2* vec1, float scale);
void  SubScaledVec2_Self(vec2* out_resultVec, vec2* vec, float scale);
void  SubScaledVec2(vec2* out_resultVec, vec2* vec0, vec2* vec1, float scale);
void  CopyVec2(vec2* out_result, vec2* point);
void  CreatePlaneFromPointsVec2(struct PlaneVec2* out_resultPlane, vec2* p0, vec2* p1);
bool  PointInsidePlaneVec2(vec2* point,struct PlaneVec2* plane);
bool  PointInsidePlaneVec2(vec2* point, struct PlaneVec2* plane);
float AngleBetweenVec2(vec2* vec0, vec2* vec1);

//3D
void  SetVec3(vec3* out_resultVec,float x, float y, float z);
void  CrossVec3(vec3* out_resultVec, const vec3* vec0, const vec3* vec1);
float DotVec3(const vec3* vec0, const vec3* vec1);
void  LerpVec3(vec3* out_lerpedPos, const vec3* p0, const vec3* p1, float t);
void  NormalizeVec3(vec3* vec);
float MagnitudeVec3(const vec3* vec);
bool  PosIsBehind(const vec3* frontPos, const vec3* frontAt, const vec3* behindPos);
float DistSqVec3(const vec3* vec0, const vec3* vec1);
float DistVec3_2D(const vec3* vec0, const vec3* vec1);
float DistVec3(const vec3* vec0, const vec3* vec1);
float MagnitudeSqVec3(const vec3* vec);
void  AddVec3_Self(vec3* out_resultVec, vec3* vec);
void  AddVec3(vec3* out_resultVec, vec3* vec0, vec3* vec1);
void  AddScaledVec3_Self(vec3* out_resultVec, const vec3* vec, float scale);
void  AddScaledVec3(vec3* out_resultVec, const vec3* vec0, const vec3* vec1, float scale);
void  SubScaledVec3_Self(vec3* out_resultVec, vec3* vec, float scale);
void  SubScaledVec3(vec3* out_resultVec, vec3* vec0, vec3* vec1, float scale);
void  SubVec3(vec3* out_resultVec, const vec3* p0, const vec3* p1);
void  ScaleVec3_Self(vec3* vec, float scale);
void  ScaleVec3(vec3* out_resultVec, const vec3* vec, float scale);
void  CopyVec3(vec3* out_result, const vec3* point);
float AngleBetweenVec3(vec3* vec0, vec3* vec1);

float distpd(vec2 *Point1, vec2 *Point2);
float getazmd (vec2 *Point1, vec2 *Point2);
double getazd (LPDPOINT Point1, LPDPOINT Point2);
vec2  newpt (vec2 *OldPoint, float AZM, float DIS);
dvec2 dnewpt (dvec2 *OldPoint, double AZM, double DIS);
float DeltaAZ (float *AZ1, float *AZ2);
float BTWNTWOPI (float AZ1);
void InitBounds (bounds* bnds);
void AddPointToBounds (bounds* bnds,vec2 *pt);
void InitDBounds (dbounds* bnds);
void AddPointToDBounds (dbounds* bnds,dvec2 *pt);
void Rotate256 (int irot,vec2* pt);
double LDIST(double X1,double Y1,double X2,double Y2);
double LGETAZ(double X1, double Y1, double X2, double Y2);
double DTWOPI (double az);
vec3 GetTriangleNormal (vec3 * vertex1,vec3 * vertex2,vec3 * vertex3);
double ComputeMaxSlope (double frontSlope,double sideSlope);

LPTRANDATA STRAN2 (int ID,double X1[], double Y1[],double X2[],double Y2[],int N, LPFLOAT RSQMIN);
void TRANS2 (double XIN,double YIN, LPDOUBLE XOUT,LPDOUBLE YOUT, LPTRANDATA TranPtr);
void TranMNMXCORL (MNMXCORL * in,MNMXCORL * out,LPTRANDATA TranPtr);
void TranMNMXCORD (MNMXCORD * in,MNMXCORD * out,LPTRANDATA TranPtr);
LPTRANDATA  LoadTranFromBPW (char * Name, int dir);
LPTRANDATA  LoadTranFromCPT (const char * Name, int dir);
void MNMXCORLtoMNMXCORD (MNMXCORL *in,MNMXCORD *out);
void MNMXCORDtoMNMXCORL (MNMXCORD *in,MNMXCORL *out);
void InflateMNMXCORL (LPMNMXCORL pBounds, int Value);
double ArcDistance(DPOINT p1, DPOINT p2);
DPOINT NewLatLong(double Lat,double Long,double Dist,double Direction);
int diffInDegrees (int angle1,int angle2);

#endif