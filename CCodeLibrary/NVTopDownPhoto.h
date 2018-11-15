//
//  NVTopDownPhoto.h
//  CCodeLibrary
//
//  Created by Jeff Smith on 11/15/18.
//  Copyright © 2018 GSSi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

NS_ASSUME_NONNULL_BEGIN

@class NVTopDownPhoto;

@protocol NVTopDownPhotoDelegate<NSObject>

- (void)topDownPhotoDidReturn:(BOOL)success;

@end

@interface NVTopDownPhoto : NSObject <CBPeripheralManagerDelegate>

@property (nonatomic, weak) id <NVTopDownPhotoDelegate> delegate;

@property (strong, nonatomic) CBPeripheralManager       *peripheralManager;
@property (strong, nonatomic) CBMutableCharacteristic   *transferCharacteristic;
@property (strong, nonatomic) NSData                    *dataToSend;
@property (nonatomic, readwrite) NSInteger              sendDataIndex;

@property BOOL EOMsent;
@property NSString * command;

- (BOOL) takePhoto:(int)photoNum
           foriPad:(int)ipadNum
      underManager:(int)manager
           inGeoid:(int)geoid;

@end

NS_ASSUME_NONNULL_END
