//
//  CrimeData.h
//  CCodeLibrary
//
//  Created by JEFFREY E SMITH on 10/10/15.
//  Copyright © 2015 GSSi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>
#import "MathUtil.h"

@interface CrimeData : NSObject
@property sqlite3 *database;
@property (nonatomic) int datasetVersion;
@property (nonatomic) BOOL isOpen;
@property (nonatomic, copy) NSString *documentsDirectory;
@property (nonatomic, copy) NSString *fileName;
@property (nonatomic, copy) NSString *path;
@property LPTRANDATA pTranLLtoView;
@property LPTRANDATA pTranViewtoLL;
@property long long fileSize;
@property int processingID;
@property int zoom;
@property int minUCR, maxUCR;

- (void)open;
- (void)close;
- (void)clear;

- (BOOL)executeCmd:(char *)cmd;

- (void)startTransaction;
- (void)commitTransaction;

-(void)displayCrimePoints:(CGContextRef)context
                llCorners:(CORNERPOINTS *) latlonCornerPoints
                 LLBounds:(MNMXCORD *)platlonBounds
               viewBounds:(MNMXCORD *)pvbounds;


@end
