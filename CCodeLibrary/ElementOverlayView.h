//
//  ElementOverlayView.h
//  CCodeLibrary
//
//  Created by JEFFREY E SMITH on 10/12/14.
//  Copyright (c) 2014 GSSi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IntersectionsDatabase.h"

@interface ElementOverlayView : UIView

- (id)initWithParentView:(UIView *)parView;

@property UIView * parentView;
@property LPTRANDATA pTranWToBMP, pTranBMPToW;
@property CGFloat xFactor, yFactor;
@property IntersectionsDatabase *database;

@end
