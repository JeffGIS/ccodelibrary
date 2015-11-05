//
//  DisplayCharacteristics.h
//  CCodeLibrary
//
//  Created by JEFFREY E SMITH on 11/3/15.
//  Copyright © 2015 GSSi. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef NS_ENUM(NSInteger, PointSymbols)
{
    CrossSym,
    PlusSym,
    DiamondSym,
    TriangleSym,
    SquareSym,
    Star1Sym,
    Star2Sym,
    CircleSym,
    ArsonSym,
};


typedef NS_ENUM(NSInteger, ItemProcessingPassTypes) {
    AerialPass=1,
    PickPass=2,
    DataPass=3,
    DisplayPass=4,
    DonePass=5,
};

@interface DisplayCharacteristics : NSObject

@property int itemBeginTime, itemEndTime;
@property PointSymbols pointSymbol;


@end
