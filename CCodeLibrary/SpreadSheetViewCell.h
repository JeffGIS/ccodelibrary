//  SpreadSheetViewCell.h
//  GMMobile

#import <UIKit/UIKit.h>

@interface SpreadSheetViewCell : UILabel

@property (nonatomic, copy) NSString *identifier;
@property (nonatomic) BOOL selected;
@property (nonatomic) NSUInteger row, column;

@end