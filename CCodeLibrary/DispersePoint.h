//
//  DispersePoint.h
//  CCodeLibrary
//
//  Created by JEFFREY E SMITH on 2/3/16.
//  Copyright © 2016 GSSi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>
#import "MathUtil.h"
#import "SymbolDictionary.h"

@interface DispersePoint : NSObject
@property sqlite3 *database;
@property (nonatomic, copy) NSString *documentsDirectory;
@property (nonatomic, copy) NSString *fileName;
@property (nonatomic, copy) NSString *path;
@property long long fileSize;
@property BOOL isOpen;
@property int width;
@property int height;
@property int nextID;
@property unsigned short * grid;
@property LPTRANDATA pTranLLtoView;
@property LPTRANDATA pTranViewtoLL;

+ (DispersePoint *)initWithWidth:(int)width
                          Height:(int)height
                           tran1:(LPTRANDATA)pTranLLtoView
                           tran2:(LPTRANDATA)pTranViewtoLL;
- (void)commitTransaction;
- (BOOL) addPoint:(DPOINT *)pPoint
       controlNbr:(int)cnbr
             time:(NSInteger)time
          offense:(NSString*)offense
      usingSymbol:(PointSymbols)sym
        withColor:(CGColorRef)color
          andSize:(CGFloat)size;
- (int)pickDispersedPoint:(LLPOINT *)pt
            highlightList:(NSMutableArray*)hlist;

@end
