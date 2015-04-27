//  LegendView.h
//  CCodeLibrary

#import <UIKit/UIKit.h>

@interface LegendView : UIView

@property (nonatomic) UILabel *completed;
@property (nonatomic) UILabel *toBeDone;
@property (nonatomic) UILabel *notAssigned;
@property (nonatomic) UILabel *complex;
@property (nonatomic) UILabel *numRamps;
@property (nonatomic) UILabel *numInts;
@property (nonatomic) UIView *completedMarker;
@property (nonatomic) UIView *toBeDoneMarker;
@property (nonatomic) UIView *notAssignedMarker;
@property (nonatomic) UIView *complexMarker;

- (id)initWithOrigin:(CGPoint)origin
     hasComplexView:(BOOL)hasComplexView;

@end