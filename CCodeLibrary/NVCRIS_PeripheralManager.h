//
//  NVCRIS_PeripheralManager.h
//  CCodeLibrary
//
//  Created by Jeff Smith on 6/24/19.
//  Copyright © 2019 GSSi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NVSlopeData.h"

NS_ASSUME_NONNULL_BEGIN
@class NVCRIS_PeripheralManager;

@protocol NVCRIS_PeripheralManagerDelegate<NSObject>

- (void)topDownPhotoDidReturn:(BOOL)success;

@end

@interface NVCRIS_PeripheralManager : NSObject 
@property (nonatomic, weak) id <NVCRIS_PeripheralManagerDelegate> delegate;
- (BOOL) takePhoto:(int)photoNum
           foriPad:(int)ipadNum
      underManager:(int)manager
           inGeoid:(int)geoid;
-(void) updateSlopeData:(NVSlopeData)slopeData;

@end

NS_ASSUME_NONNULL_END
