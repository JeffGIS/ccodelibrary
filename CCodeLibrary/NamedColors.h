//
//  NamedColors.h
//  CCodeLibrary
//
//  Created by JEFFREY E SMITH on 4/21/15.
//  Copyright (c) 2015 GSSi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface NamedColors : NSObject

-(UIColor*) colorFromIndex:(int)index;
-(NSString*) colorNameFromIndex:(int)index;
-(int) getNearestNamedColorIndex:(UIColor*)color;

@end
