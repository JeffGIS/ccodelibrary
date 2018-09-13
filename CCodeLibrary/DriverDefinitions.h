//  DriverDefinitions.h
//  CCodeLibrary

@import Foundation;
#import "SQLiteLib.h"
#import "UserDefaults.h"

typedef struct {
    char SECTIONID[32];
    char NAME[255];
    char TYPE[16];
    int  PAGE;;
    float ULX,ULY,LRX,LRY;}PDFPARM;
typedef PDFPARM *LPPDFPARM;


@interface DriverDefinitions : NSObject

@property sqlite3nv *database;
@property (atomic) BOOL isOpen;
@property (atomic) BOOL allowUpdates;
- (BOOL)open;
- (void)close:(BOOL)opened;
- (NSString *)databasePath;

- (int)getPDFParamters:(NSString*)ID
                   parm:(LPPDFPARM) parm
            defaultType:(NSString *)defType
              maxParms:(int)nMax;

- (BOOL)addDefinition:(NSString *)ID
                 name:(NSString *)name
                 page:(int)page
                  ulx:(float)ulx
                  uly:(float)uly
                  lrx:(float)lrx
                  lry:(float)lry;

- (NSArray<NSString *> *)getReferencesForFigure:(NSString *)figure;

@end
