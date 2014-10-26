//  LegendView.h
//  CCodeLibrary

#import "CCodeLibrary.h"

@interface LegendView : UIView

@property UILabel *completed;
@property UILabel *toBeDone;
@property UILabel *notAssigned;
@property UILabel *complex;
@property UILabel *numRamps;
@property UIView *completedMarker;
@property UIView *toBeDoneMarker;
@property UIView *notAssignedMarker;
@property UIView *complexMarker;

- (id)initWithOrigin:(CGPoint)origin
     hasComplexView:(BOOL)hasComplexView;

@end