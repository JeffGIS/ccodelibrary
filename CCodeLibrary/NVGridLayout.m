//  NVGridLayout.m
//  CCodeLibrary

#import "NVGridLayout.h"
#import "NVSpreadsheet.h"

@interface NVGridLayout ()

@property (nonatomic) NSInteger gridRowCount, gridColumnCount;
@property BOOL isInitialized;

@end

@implementation NVGridLayout

- (id)init
{
    self = [super init];
    
    if (self)
    {
        _cellSpacing = 1.0;
        _itemSize = CGSizeMake(120.0, 120.0);
    }
    
    return self;
}

- (void)setItemSize:(CGSize)itemSize
{
    _itemSize = CGSizeMake((itemSize.width + _cellSpacing), (itemSize.height + _cellSpacing));
    [self invalidateLayout];
}

- (void)setCellSpacing:(CGFloat)cellSpacing
{
    _cellSpacing = cellSpacing;
    [self invalidateLayout];
}

- (void)prepareLayout
{
    [super prepareLayout];
    
    _gridRowCount = [self.collectionView numberOfSections];
    _gridColumnCount = [self.collectionView numberOfItemsInSection:0];
    
    if (!_isInitialized) {
        id<UICollectionViewDelegateFlowLayout> delegate = (id)self.collectionView.delegate;
        
        CGSize size = [delegate collectionView:self.collectionView
                                        layout:self
                       sizeForItemAtIndexPath:[NSIndexPath indexPathForItem:0
                                                                  inSection:0]];
        
        _itemSize = size;
        _isInitialized = YES;
    }
}

- (CGSize)collectionViewContentSize
{
    if (!_isInitialized)
        [self prepareLayout];
    
    CGSize size = CGSizeMake((_gridColumnCount * _itemSize.width), (_gridRowCount * _itemSize.height));
    
    return size;
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect
{
    NSMutableArray *attributes = NSMutableArray.array;
    NSUInteger startRow = floorf(rect.origin.y / _itemSize.height);
    NSUInteger startCol = floorf(rect.origin.x / _itemSize.width);
    NSUInteger endRow = MIN((_gridRowCount - 1), ceilf(CGRectGetMaxY(rect) / _itemSize.height));
    NSUInteger endCol = MIN((_gridColumnCount - 1), ceilf(CGRectGetMaxX(rect) / _itemSize.width));
    
    for (NSUInteger row = startRow; row <= endRow; row++)
    {
        for (NSUInteger col = startCol; col <=  endCol; col++)
        {
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:col
                                                         inSection:row];
            
            UICollectionViewLayoutAttributes *layoutAttributes = [self layoutAttributesForItemAtIndexPath:indexPath];
            [attributes addObject:layoutAttributes];
        }
    }
    
    return attributes;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewLayoutAttributes *attributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
    
    attributes.frame = CGRectMake((indexPath.item * _itemSize.width), (indexPath.section * _itemSize.height),
                                  (_itemSize.width - _cellSpacing), (_itemSize.height - _cellSpacing));
    
    return attributes;
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds
{
    return NO;
}

@end
