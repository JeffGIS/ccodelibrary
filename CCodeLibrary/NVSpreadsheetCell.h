//  NVSpreadsheetCell.h
//  CCodeLibrary

@import UIKit;

@interface NVCell : UICollectionViewCell

@property (nonatomic) UILabel *textLabel, *idLabel;
@property (nonatomic) CGFloat idSize;
@property (nonatomic) UIColor *previousColor;

@end

@interface NVGridCell : NVCell

@end

@interface NVTopRowCell : NVCell

@end

@interface NVLeftColumnCell : NVCell

@end
