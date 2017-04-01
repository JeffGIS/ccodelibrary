//
//  CompressDecompress.h
//  CCodeLibrary
//
//  Created by JEFFREY E SMITH on 3/6/16.
//  Copyright © 2016 GSSi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "compress.h"
#import "GSSiPopoverView.h"

@interface CompressDecompress : NSObject

@property GSSiPopoverView *popover;
@property NSInteger totLen;

-(bool) DecompressGMZipFile:(char *)TransferFileName
                toDirectory:(char *)toDirectory;

@end
