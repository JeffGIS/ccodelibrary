//
//  SlopeClient.h
//  CCodeLibrary
//
//  Created by Jeff Smith on 6/30/19.
//  Copyright © 2019 GSSi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "CRAPI.h"

NS_ASSUME_NONNULL_BEGIN

@class SlopeClient;

@protocol SlopeClientDelegate <NSObject>

- (void)SlopeClient:(SlopeClient *)controller returnedData:(NVSlopeData)slopeData;
- (void)SlopeClientFailed:(SlopeClient *)controller;

@end

@interface SlopeClient : NSObject <CBCentralManagerDelegate,CBPeripheralDelegate>
@property (nonatomic, weak) id <SlopeClientDelegate> delegate;
@property (strong, nonatomic) CBCentralManager      *centralManager;
@property BOOL wantScan;
@property BOOL wantSetNotify;
@property BOOL wantDisconnect;
@property NSMutableData * data;
@property CBCharacteristic *slopeDataCharacteristic;

@end

NS_ASSUME_NONNULL_END
