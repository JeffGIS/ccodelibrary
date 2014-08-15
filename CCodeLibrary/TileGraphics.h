#define TGPOLYGON	0
#define TGPOLYLINE	1

typedef struct{short x,y;} SPOINT;
typedef SPOINT *LPSPOINT;
typedef struct{int x,y;} IPOINT;
typedef IPOINT *LPIPOINT;

typedef struct{unsigned char x,y;}	BPOINT;
typedef struct{char x:4,y:4;}CPOINT;
typedef BPOINT				*LPBPOINT;
typedef CPOINT				*LPCPOINT;

BPOINT POINTtoBPOINT (IPOINT p);
IPOINT BPOINTtoPOINT (BPOINT p);

typedef struct  {
				 char key[10];
				 short maxElev;
				 int loc;
				}TINDEX;
typedef TINDEX *LPTINDEX;

#pragma pack(2)
typedef	struct {
				unsigned short
				symbol:10,
				type:2,
				nsegtype:1,
				coordtype:2,
				completeTile:1;
				long refno;} TGRECHEADER;
typedef TGRECHEADER	*LPTGRECHEADER;

typedef struct {
    int i4val;
    short i2val;
    float r4val;
    double r8val;
    char textval[32];

}TESTSTRUCT;
typedef TESTSTRUCT *LPTESTSTRUCT;

#pragma pack()

int DoTestStruct (const char *testFile);
double GroundResolution(double latitude, int levelOfDetail);
void LatLongToPixelXY(double latitudein, double longitudein, int levelOfDetail, int *pixelX, int *pixelY);
void LatLongToPixelXYd(double latitudein, double longitudein, int levelOfDetail, double *pixelX, double *pixelY);
void PixelXYToLatLong(int pixelX, int pixelY, int levelOfDetail, double *latitude, double *longitude);
void PixelXYToLatLongd(double pixelX, double pixelY, int levelOfDetail, double *latitude, double *longitude);
void PixelXYToTileXY(int pixelX, int pixelY, int *tileX, int *tileY);
void TileXYToPixelXY(int tileX, int tileY, int *pixelX, int *pixelY);
void TileXYToQuadKey(int tileX, int tileY, int levelOfDetail,char *quadKey);
int QuadKeyToTileXY(char *quadKey, int *tileX, int *tileY, int *levelOfDetail);
int FindIntersection (const char * indexPath,const char * dataPath,int x, int y, char * intText,char * intAZMS,int * pnumStreets,int * pnRamps,int iWant);
int FindIntersectionFromID (const char * indexPath,const char * dataPath, int intID, char * intText,char * intAZMS,int * pnumStreets,int * pnRamps);
int GetCornerIDFromHeading (int heading,int IntersectionCorrection);
double DeltaAngle (double AZ1, double AZ2);
int Between0And360 (int ival);

