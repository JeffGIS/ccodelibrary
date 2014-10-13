//  ElementOverlayView.h
//  CCodeLibrary

#import <Foundation/Foundation.h>
#import "IntersectionsDatabase.h"

@interface ElementOverlayView : UIView

- (id)initWithParentView:(UIView *)parView;

@property UIView *parentView;
@property LPTRANDATA pTranWToBMP, pTranBMPToW;
@property CGFloat xFactor, yFactor;
@property IntersectionsDatabase *database;

@end