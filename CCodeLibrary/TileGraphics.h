//  TileGraphics.h
//  CCodeLibrary

#define TGPOLYGON 0
#define TGPOLYLINE 1
#import "CCodeTypes.h"


BPOINT POINTtoBPOINT (IPOINT p);
IPOINT BPOINTtoPOINT (BPOINT p);

typedef struct
{
    char key[10];
	short maxElev;
	int loc;
}TINDEX;

typedef TINDEX *LPTINDEX;

#pragma pack(2)
typedef	struct
{
    unsigned short
	symbol:10,
	type:2,
	nsegtype:1,
	coordtype:2,
	completeTile:1;
	long refno;
}TGRECHEADER;

typedef TGRECHEADER	*LPTGRECHEADER;

typedef struct
{
    int i4val;
    short i2val;
    float r4val;
    double r8val;
    char textval[32];
}TESTSTRUCT;

typedef TESTSTRUCT *LPTESTSTRUCT;

#pragma pack()

int DoTestStruct (const char *testFile);
unsigned int MapSize(int levelOfDetail);

double GroundResolution(double latitude, int levelOfDetail);
void LatLongToPixelXY(double latitudein, double longitudein, int levelOfDetail, int *pixelX, int *pixelY);
void LatLongToPixelXY_old(double latitudein, double longitudein, int levelOfDetail, int *pixelX, int *pixelY);
void LatLongToPixelXYd(double latitudein, double longitudein, int levelOfDetail, double *pixelX, double *pixelY);
DPOINT LatLongPointToPixelPoint(DPOINT llPoint, int levelOfDetail);
void PixelXYToLatLong(int pixelX, int pixelY, int levelOfDetail, double *latitude, double *longitude);
void PixelXYToLatLong_old(int pixelX, int pixelY, int levelOfDetail, double *latitude, double *longitude);
void PixelXYToLatLongd(double pixelX, double pixelY, int levelOfDetail, double *latitude, double *longitude);
void PixelXYToTileXY(int pixelX, int pixelY, int *tileX, int *tileY);
void TileXYToPixelXY(int tileX, int tileY, int *pixelX, int *pixelY);
void TileXYToQuadKey(int tileX, int tileY, int levelOfDetail,char *quadKey);
int QuadKeyToTileXY(char *quadKey, int *tileX, int *tileY, int *levelOfDetail);
int FindIntersection (const char *indexPath, const char *dataPath, int x, int y, char *intText, char *intAZMS, int *pnumStreets, int *pnRamps, int iWant, int *plev21x, int *plev21y);
int FindIntersectionFromID (const char *indexPath,const char *dataPath, int intID, char *intText,char *intAZMS,int *pnumStreets,int *pnRamps,int *plev21x, int *plev21y);
int GetCornerIDFromHeading (int heading,int IntersectionCorrection);
