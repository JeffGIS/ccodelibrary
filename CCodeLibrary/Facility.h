//  Facility.h
//  CCodeLibrary

#import <Foundation/Foundation.h>

@interface Facility : NSObject

@property int lev21x;
@property int lev21y;
@property int imageX;
@property int imageY;
@property int refno;
@property float trueAz;
@property int adjustedRot;
@property int facID;

@property bool dataUpdated;
@property int intRotation;
@property bool doLater;
@property int timeComplete;
@property (nonatomic, strong) NSString *name1;
@property (nonatomic, strong) NSString *name2;
@property (nonatomic, strong) NSString *name3;
@property int quadDev0, quadDev90, quadDev180, quadDev270;

@end