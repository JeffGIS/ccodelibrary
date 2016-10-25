//  NVSpreadsheetCell.h
//  CCodeLibrary

@import UIKit;

@interface NVGridCell : UICollectionViewCell

@property (nonatomic) UILabel *textLabel;
@property NSUInteger row, column;

@end

@interface NVTopRowCell : UICollectionViewCell

@property (nonatomic) UILabel *textLabel;

@end

@interface NVLeftColumnCell : UICollectionViewCell

@property (nonatomic) UILabel *textLabel;
@property NSUInteger row, column;

@end
