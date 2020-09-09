//
//  NVCRIS_PeripheralManager.m
//  CCodeLibrary
//
//  Created by Jeff Smith on 6/24/19.
//  Copyright © 2019 GSSi. All rights reserved.
//

#import "CRAPI.h"



@interface NVCRIS_PeripheralManager () <CBPeripheralManagerDelegate>
@property CBPeripheralManager * manager;
@property (strong, nonatomic) CBMutableCharacteristic   *slopeDataCharacteristic;
@property (strong, nonatomic) CBMutableCharacteristic   *takePhotoCharacteristic;
@property (strong, nonatomic) CBMutableCharacteristic   *photoTakenCharacteristic;
@property (strong, nonatomic) NSData                    *photoDataToSend;
@property (nonatomic, readwrite) NSInteger              sendPhotoDataIndex;
@property (strong, nonatomic) NSData                    *slopeDataToSend;
@property (nonatomic, readwrite) NSInteger              slopeDataIndex;
@property NSString * slopeCommand;
@property NSString * photoCommand;

@property BOOL photoEOMsent;
@property BOOL slopeEOMsent;
@property NVSlopeData currentSlopeData;

@end
@implementation NVCRIS_PeripheralManager

- (id)init
{
    self = [super init];
    
    if (self)
    {
        self.manager = [CRAPI.sharedInstance getPeripheralManager:(id)self];
    }
    return self;
}
- (void)dealloc
{
    NSLog(@"NVCRIS_PeripheralManager dealloc");
}
/** Required protocol method.  A full app should take care of all the possible states,
 *  but we're just waiting for  to know when the CBPeripheralManager is ready
 */
- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheralManager
{
    // Opt out from any other state
    if (peripheralManager.state != CBPeripheralManagerStatePoweredOn) {
        showAlert(@"Bluetooth not on");
        return;
    }
    
    // We're in CBPeripheralManagerStatePoweredOn state...
    NSLog(@"self.peripheralManager powered on.");
    
    // ... so build our service.
    
    // Start with the slope data char
    _slopeDataCharacteristic = [[CBMutableCharacteristic alloc] initWithType:[CBUUID UUIDWithString:CRAPI.sharedInstance.group_NVCRIS_SLOPEDATA_CHARACTERISTIC_UUID]
                                                                      properties:CBCharacteristicPropertyNotify|CBCharacteristicPropertyRead
                                                                           value:nil
                                                                     permissions:CBAttributePermissionsReadable];
    // then the take photo char
    _takePhotoCharacteristic = [[CBMutableCharacteristic alloc] initWithType:[CBUUID UUIDWithString:CRAPI.sharedInstance.group_NVCRIS_TAKEPHOTO_CHARACTERISTIC_UUID]
                                                                      properties:CBCharacteristicPropertyNotify|CBCharacteristicPropertyRead
                                                                           value:nil
                                                                     permissions:CBAttributePermissionsReadable];
    
    // then the photo taken response char
    _photoTakenCharacteristic = [[CBMutableCharacteristic alloc] initWithType:[CBUUID UUIDWithString:CRAPI.sharedInstance.group_NVCRIS_PHOTOTAKEN_CHARACTERISTIC_UUID]
                                                                      properties:CBCharacteristicPropertyWrite
                                                                           value:nil
                                                                     permissions:CBAttributePermissionsWriteable];
    
    // Then the service
     CBMutableService *NVCRISService = [[CBMutableService alloc] initWithType:[CBUUID UUIDWithString:CRAPI.sharedInstance.group_NVCRIS_SERVICE_UUID]
                                                                       primary:YES];
    // Add the characteristics to the service
    NVCRISService.characteristics = @[_takePhotoCharacteristic,_photoTakenCharacteristic,_slopeDataCharacteristic];
    
    // And add it to the peripheral manager
    [_manager removeAllServices];
    [_manager addService:NVCRISService];
    // Start sending
    [_manager startAdvertising:@{ CBAdvertisementDataServiceUUIDsKey : @[[CBUUID UUIDWithString:CRAPI.sharedInstance.group_NVCRIS_SERVICE_UUID]] }];
}
 - (void)peripheralManager:(CBPeripheralManager *)peripheral didAddService:(CBService *)service error:(NSError *)error
{
    if (error) {
        NSLog(@"Error adding service: %@", [error localizedDescription]);
        return;
    }
    NSLog (@"Service added successfully:%@",service);
}

/** Catch when someone subscribes to our characteristic, then start sending them data
 */
- (void)peripheralManager:(CBPeripheralManager *)peripheral central:(CBCentral *)central didSubscribeToCharacteristic:(CBCharacteristic *)characteristic
{
    NSLog(@"Central subscribed to characteristic %@",characteristic);
    
    if (characteristic == _slopeDataCharacteristic)
    {
        _slopeEOMsent = YES;
        // Get the data
        _slopeCommand = [self packageCurrentSlopeData];
        _slopeDataToSend = [_slopeCommand dataUsingEncoding:NSUTF8StringEncoding];
        
        // Reset the index
        _slopeDataIndex = 0;
        
        // Start sending
        [self sendSlopeData];
    }
    if (characteristic == _takePhotoCharacteristic)
    {
        _photoEOMsent = YES;
    }
    return;
}

/** Recognise when the central unsubscribes
 */
- (void)peripheralManager:(CBPeripheralManager *)peripheral central:(CBCentral *)central didUnsubscribeFromCharacteristic:(CBCharacteristic *)characteristic
{
    NSLog(@"Central unsubscribed from characteristic %@",characteristic);
}


/** Sends the next amount of data to the connected central
 */
- (void)sendPhotoData
{
    // First up, check if we're meant to be sending an EOM
    static BOOL sendingEOM = NO;
    
    if (sendingEOM) {
        
        // send it
        BOOL didSend = [_manager updateValue:[@"EOM" dataUsingEncoding:NSUTF8StringEncoding] forCharacteristic:_takePhotoCharacteristic onSubscribedCentrals:nil];
        
        // Did it send?
        if (didSend) {
            
            // It did, so mark it as sent
            sendingEOM = NO;
            
            NSLog(@"Sent: EOM");
            _photoEOMsent = YES;
            [self photoTaken];
        }
        
        // It didn't send, so we'll exit and wait for peripheralManagerIsReadyToUpdateSubscribers to call sendData again
        return;
    }
    
    // We're not sending an EOM, so we're sending data
    
    // Is there any left to send?
    
    if (_sendPhotoDataIndex >= _photoDataToSend.length) {
        
        // No data left.  Do nothing
        return;
    }
    
    // There's data left, so send until the callback fails, or we're done.
    
    BOOL didSend = YES;
    
    while (didSend) {
        
        // Make the next chunk
        
        // Work out how big it should be
        NSInteger amountToSend = _photoDataToSend.length - _sendPhotoDataIndex;
        
        // Can't be longer than 20 bytes
        if (amountToSend > NOTIFY_MTU) amountToSend = NOTIFY_MTU;
        
        // Copy out the data we want
        NSData *chunk = [NSData dataWithBytes:_photoDataToSend.bytes+_sendPhotoDataIndex length:amountToSend];
        
        // Send it
        didSend = [_manager updateValue:chunk forCharacteristic:_takePhotoCharacteristic onSubscribedCentrals:nil];
        
        // If it didn't work, drop out and wait for the callback
        if (!didSend) {
            return;
        }
        
        NSString *stringFromData = [[NSString alloc] initWithData:chunk encoding:NSUTF8StringEncoding];
        NSLog(@"Sent: %@", stringFromData);
        
        // It did send, so update our index
        _sendPhotoDataIndex += amountToSend;
        
        // Was it the last one?
        if (_sendPhotoDataIndex >= _photoDataToSend.length) {
            
            // It was - send an EOM
            
            // Set this so if the send fails, we'll send it next time
            sendingEOM = YES;
            
            // Send it
            BOOL eomSent = [_manager updateValue:[@"EOM" dataUsingEncoding:NSUTF8StringEncoding] forCharacteristic:_takePhotoCharacteristic onSubscribedCentrals:nil];
            
            if (eomSent) {
                // It sent, we're all done
                sendingEOM = NO;
                
                NSLog(@"Sent: EOM");
            }
            
            return;
        }
    }
}

- (void)sendSlopeData
{
    // First up, check if we're meant to be sending an EOM
    static BOOL sendingEOM = NO;
    
    if (sendingEOM) {
        
        // send it
        BOOL didSend = [_manager updateValue:[@"EOM" dataUsingEncoding:NSUTF8StringEncoding] forCharacteristic:_slopeDataCharacteristic onSubscribedCentrals:nil];
        
        // Did it send?
        if (didSend) {
            
            // It did, so mark it as sent
            sendingEOM = NO;
            
            NSLog(@"Sent: EOM");
            _slopeEOMsent = YES;
 
        }
        
        // It didn't send, so we'll exit and wait for peripheralManagerIsReadyToUpdateSubscribers to call sendData again
        return;
    }
    
    // We're not sending an EOM, so we're sending data
    
    // Is there any left to send?
    
    if (_slopeDataIndex >= _slopeDataToSend.length) {
        
        // No data left.  Do nothing
        return;
    }
    
    // There's data left, so send until the callback fails, or we're done.
    
    BOOL didSend = YES;
    
    while (didSend) {
        
        // Make the next chunk
        
        // Work out how big it should be
        NSInteger amountToSend = _slopeDataToSend.length - _slopeDataIndex;
        
        // Can't be longer than 20 bytes
        if (amountToSend > NOTIFY_MTU) amountToSend = NOTIFY_MTU;
        
        // Copy out the data we want
        NSData *chunk = [NSData dataWithBytes:_slopeDataToSend.bytes+_slopeDataIndex length:amountToSend];
        
        // Send it
        didSend = [_manager updateValue:chunk forCharacteristic:_slopeDataCharacteristic onSubscribedCentrals:nil];
        
        // If it didn't work, drop out and wait for the callback
        if (!didSend) {
            return;
        }
        
        NSString *stringFromData = [[NSString alloc] initWithData:chunk encoding:NSUTF8StringEncoding];
        NSLog(@"Sent: %@", stringFromData);
        
        // It did send, so update our index
        _slopeDataIndex += amountToSend;
        
        // Was it the last one?
        if (_slopeDataIndex >= _slopeDataToSend.length) {
            
            // It was - send an EOM
            
            // Set this so if the send fails, we'll send it next time
            sendingEOM = YES;
            
            // Send it
            BOOL eomSent = [_manager updateValue:[@"EOM" dataUsingEncoding:NSUTF8StringEncoding] forCharacteristic:_slopeDataCharacteristic onSubscribedCentrals:nil];
            
            if (eomSent) {
                // It sent, we're all done
                sendingEOM = NO;
                
                NSLog(@"Sent: EOM");
            }
            
            return;
        }
    }
}

/** This callback comes in when the PeripheralManager is ready to send the next chunk of data.
 *  This is to ensure that packets will arrive in the order they are sent
 */
- (void)peripheralManagerIsReadyToUpdateSubscribers:(CBPeripheralManager *)peripheral
{
    // Start sending again
    [self sendSlopeData];
    [self sendPhotoData];
}

- (BOOL) takePhoto:(int)photoNum
           foriPad:(int)ipadNum
      underManager:(int)manager
           inGeoid:(int)geoid
{
    if (!_photoEOMsent)
        return FALSE;
    if (!_manager)
        return FALSE;
    _photoCommand = [NSString stringWithFormat:@"TakePhoto:%i_%i.jpg|%i|%i|%i",ipadNum,photoNum,manager,geoid,(int)CRAPI.sharedInstance.currentSidewalkPointID];
    _photoEOMsent = NO;
    // Reset the index
    _sendPhotoDataIndex = 0;
    _photoDataToSend = [_photoCommand dataUsingEncoding:NSUTF8StringEncoding];
    [self sendPhotoData];
    return TRUE;
}
- (void) photoTaken
{
    [_delegate topDownPhotoDidReturn:YES];
}

- (NSString *)packageCurrentSlopeData
{
    NSString * data = [NSString stringWithFormat:@"%.1f;%.1f;%.1f;%.1f",_currentSlopeData.frontSlopePct,_currentSlopeData.sideSlopePct,_currentSlopeData.maxSlopePct,_currentSlopeData.heading];
    
    return data;
}

-(void) updateSlopeData:(NVSlopeData)slopeData
{
    if (_slopeDataCharacteristic)
    {
        _currentSlopeData = slopeData;
        _slopeCommand = [self packageCurrentSlopeData];
        _slopeDataToSend = [_slopeCommand dataUsingEncoding:NSUTF8StringEncoding];
        
        // Reset the index
        _slopeDataIndex = 0;
        
        [self sendSlopeData];
    }
}

@end
