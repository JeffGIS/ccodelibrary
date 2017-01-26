//  NVSpreadsheetCell.h
//  CCodeLibrary

@import UIKit;

@interface NVGridCell : UICollectionViewCell

@property (nonatomic) UILabel *textLabel;
@property NSUInteger row, column;
@property CGFloat idSize;

@end

@interface NVTopRowCell : UICollectionViewCell

@property (nonatomic) UILabel *textLabel, *idLabel;
@property CGFloat idSize;

@end

@interface NVLeftColumnCell : UICollectionViewCell

@property (nonatomic) UILabel *textLabel, *idLabel;
@property NSUInteger row, column;
@property CGFloat idSize;

@end
