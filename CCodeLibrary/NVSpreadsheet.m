//  NVSpreadsheet.m
//  CCodeLibrary

#import "NVSpreadsheet.h"
#import "NVGridLayout.h"
#import "NSIndexPath+NVSpreadsheet.h"
#import "NVSpreadsheetCell.h"

typedef NS_ENUM(NSUInteger, NVSpreadsheetCollection)
{
    NVSpreadsheetCollectionUpperLeft = 1,
    NVSpreadsheetCollectionUpperRight,
    NVSpreadsheetCollectionLowerLeft,
    NVSpreadsheetCollectionLowerRight,
};

typedef NS_ENUM(NSUInteger, NVSpreadsheetHeaderConfiguration)
{
    NVSpreadsheetHeaderConfigurationNone = 0,
    NVSpreadsheetHeaderConfigurationColumnOnly,
    NVSpreadsheetHeaderConfigurationRowOnly,
    NVSpreadsheetHeaderConfigurationBoth,
};

const static CGFloat NVSpreadsheetGridSpace = 1.0;
const static CGFloat NVSpreadsheetScrollIndicatorWidth = 5.0;
const static CGFloat NVSpreadsheetScrollIndicatorSpace = 3.0;
const static CGFloat NVSpreadsheetScrollIndicatorMinimum = 25.0;
const static CGFloat NVScrollIndicatorDefaultInsetSpace = 2.0;
const static NSUInteger NVScrollIndicatorTag = 12345;

@interface NVSpreadsheet () <UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout,UITextFieldDelegate>

@property (nonatomic) NSUInteger headerRowCount, headerColumnCount;
@property (nonatomic) NVSpreadsheetHeaderConfiguration spreadsheetHeaderConfiguration;
@property (nonatomic) UIScrollView *controllingScrollView;
@property (nonatomic) UIView *upperLeftContainerView, *upperRightContainerView;
@property (nonatomic) UIView *lowerLeftContainerView, *lowerRightContainerView;
@property (nonatomic) UICollectionView *upperLeftCollectionView, *upperRightCollectionView;
@property (nonatomic) UICollectionView *lowerLeftCollectionView, *lowerRightCollectionView;
@property BOOL isUpperRightBouncing, isLowerLeftBouncing, isLowerRightBouncing;
@property (nonatomic) UIView *verticalScrollIndicator, *horizontalScrollIndicator;
@property (nonatomic) UITextField *textField;
@property (nonatomic) UILongPressGestureRecognizer *lp1, *lp2;
@property int currentHeader;
@property (nonatomic) BOOL scrollEnabled;


@end

@implementation NVSpreadsheet

- (id)initWithNumberOfHeaderRows:(NSUInteger)headerRowCount
           numberOfHeaderColumns:(NSUInteger)headerColumnCount
                           frame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self)
    {
        _scrollIndicatorInsets = UIEdgeInsetsZero;
        _showsVerticalScrollIndicator = YES;
        _showsHorizontalScrollIndicator = YES;
        _headerRowCount = headerRowCount;
        _headerColumnCount = headerColumnCount;
        _currentHeader = 0;
        _scrollEnabled = YES;
        
        _textField = UITextField.new;
        _textField.translatesAutoresizingMaskIntoConstraints = NO;
        _textField.delegate = self;
        _textField.layer.borderColor = UIColor.redColor.CGColor;
        _textField.layer.borderWidth = 4.0;
        _textField.textAlignment = NSTextAlignmentCenter;
        _textField.clearButtonMode = UITextFieldViewModeAlways;
        _textField.adjustsFontSizeToFitWidth = YES;
        
        _lp1 = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(headerLongPressed:)];
        _lp2 = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(headerLongPressed:)];
        
        if (headerColumnCount == 0 && headerRowCount == 0)
            _spreadsheetHeaderConfiguration = NVSpreadsheetHeaderConfigurationNone;
        
        else if (headerColumnCount > 0 && headerRowCount == 0)
            _spreadsheetHeaderConfiguration = NVSpreadsheetHeaderConfigurationColumnOnly;
                 
        else if (headerColumnCount == 0 && headerRowCount > 0)
            _spreadsheetHeaderConfiguration = NVSpreadsheetHeaderConfigurationRowOnly;
                 
        else if (headerColumnCount > 0 && headerRowCount > 0)
            _spreadsheetHeaderConfiguration = NVSpreadsheetHeaderConfigurationBoth;
                 
        self.backgroundColor = UIColor.grayColor;
        [self setupSubviews];
    }
    
    return self;
}

- (UICollectionViewCell *)dequeueReusableCellWithReuseIdentifier:identifier
                                                    forIndexPath:(NSIndexPath *)indexPath
{
    NSIndexPath *collectionViewIndexPath = [self collectionViewIndexPathFromDataSourceIndexPath:indexPath];
    UICollectionView *collectionView = [self collectionViewForDataSourceIndexPath:indexPath];
    
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier
                                                                           forIndexPath:collectionViewIndexPath];
    
    return cell;
}

- (void)registerCellClass:(Class)cellClass
forCellWithReuseIdentifier:(NSString *)identifier
{
    [_upperLeftCollectionView registerClass:cellClass forCellWithReuseIdentifier:identifier];
    [_upperRightCollectionView registerClass:cellClass forCellWithReuseIdentifier:identifier];
    [_lowerLeftCollectionView registerClass:cellClass forCellWithReuseIdentifier:identifier];
    [_lowerRightCollectionView registerClass:cellClass forCellWithReuseIdentifier:identifier];
}

- (void)reloadData
{
    [_upperLeftCollectionView reloadData];
    [_upperRightCollectionView reloadData];
    [_lowerLeftCollectionView reloadData];
    [_lowerRightCollectionView reloadData];
}

- (void)setScrollEnabled:(BOOL)scrollEnabled
{
    _scrollEnabled = scrollEnabled;
    _upperLeftCollectionView.scrollEnabled = scrollEnabled;
    _upperRightCollectionView.scrollEnabled = scrollEnabled;
    _lowerLeftCollectionView.scrollEnabled = scrollEnabled;
    _lowerRightCollectionView.scrollEnabled = scrollEnabled;
}

- (void)flashScrollIndicators
{
    [self showScrollIndicators];
    [self performSelector:@selector(hideScrollIndicators) withObject:nil afterDelay:1.0];
}

- (void)setupSubviews
{
    switch (_spreadsheetHeaderConfiguration)
    {
        case NVSpreadsheetHeaderConfigurationNone:
            [self setupLowerRightView];
            break;
        case NVSpreadsheetHeaderConfigurationColumnOnly:
            [self setupLowerLeftView];
            [self setupLowerRightView];
            break;
        case NVSpreadsheetHeaderConfigurationRowOnly:
            [self setupUpperRightView];
            [self setupLowerRightView];
            break;
        case NVSpreadsheetHeaderConfigurationBoth:
            [self setupUpperLeftView];
            [self setupUpperRightView];
            [self setupLowerLeftView];
            [self setupLowerRightView];
            break;
        default:
            break;
    }
    
    _verticalScrollIndicator = [self setupScrollIndicator];
    _horizontalScrollIndicator = [self setupScrollIndicator];
    _controllingScrollView = _lowerRightCollectionView;
}

- (void)setupContainerSubview:(UIView *)container
               collectionView:(UICollectionView *)collectionView
                          tag:(NSInteger)tag
{
    container.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self addSubview:container];
    
    collectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    collectionView.backgroundColor = [UIColor clearColor];
    collectionView.tag = tag;
    collectionView.delegate = self;
    collectionView.dataSource = self;
    collectionView.showsHorizontalScrollIndicator = NO;
    collectionView.showsVerticalScrollIndicator = NO;
    [container addSubview:collectionView];
}

- (UICollectionView *)setupCollectionViewWithGridLayout
{
    NVGridLayout *layout = NVGridLayout.new;
    
    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero
                                                          collectionViewLayout:layout];
    
    return collectionView;
}

- (void)setupUpperLeftView
{
    _upperLeftContainerView = [[UIView alloc] initWithFrame:CGRectZero];
    _upperLeftCollectionView = [self setupCollectionViewWithGridLayout];
    
    [self setupContainerSubview:_upperLeftContainerView
                 collectionView:_upperLeftCollectionView
                            tag:NVSpreadsheetCollectionUpperLeft];
    
    _upperLeftCollectionView.scrollEnabled = NO;
}

- (void)setupUpperRightView
{
    _upperRightContainerView = [[UIView alloc] initWithFrame:CGRectZero];
    _upperRightCollectionView = [self setupCollectionViewWithGridLayout];
    
    [_upperRightCollectionView.panGestureRecognizer addTarget:self
                                                       action:@selector(handleUpperRightPanGesture:)];
    
    [self setupContainerSubview:_upperRightContainerView
                 collectionView:_upperRightCollectionView
                            tag:NVSpreadsheetCollectionUpperRight];
    
    [_upperRightCollectionView addGestureRecognizer:_lp1];
}

- (void)setupLowerLeftView
{
    _lowerLeftContainerView = [[UIView alloc] initWithFrame:CGRectZero];
    _lowerLeftCollectionView = [self setupCollectionViewWithGridLayout];
    
    [_lowerLeftCollectionView.panGestureRecognizer addTarget:self
                                                      action:@selector(handleLowerLeftPanGesture:)];
    
    [self setupContainerSubview:_lowerLeftContainerView
                 collectionView:_lowerLeftCollectionView
                            tag:NVSpreadsheetCollectionLowerLeft];
    
    [_lowerLeftCollectionView addGestureRecognizer:_lp2];
}

- (void)setupLowerRightView
{
    _lowerRightContainerView = [[UIView alloc] initWithFrame:CGRectZero];
    _lowerRightCollectionView = [self setupCollectionViewWithGridLayout];
    
    [_lowerRightCollectionView.panGestureRecognizer addTarget:self
                                                       action:@selector(handleLowerRightPanGesture:)];
    
    [self setupContainerSubview:_lowerRightContainerView
                 collectionView:_lowerRightCollectionView
                            tag:NVSpreadsheetCollectionLowerRight];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    switch (_spreadsheetHeaderConfiguration)
    {
        case NVSpreadsheetHeaderConfigurationNone:
            _lowerRightContainerView.frame = self.bounds;
            break;
            
        case NVSpreadsheetHeaderConfigurationColumnOnly:
        {
            CGSize size = _lowerLeftCollectionView.collectionViewLayout.collectionViewContentSize;
            
            _lowerLeftContainerView.frame = CGRectMake(0.0, 0.0, size.width, self.bounds.size.height);
            
            _lowerRightContainerView.frame = CGRectMake((size.width + NVSpreadsheetGridSpace), 0.0,
                                                        (self.bounds.size.width - size.width - NVSpreadsheetGridSpace),
                                                        self.bounds.size.height);
            break;
        }
            
        case NVSpreadsheetHeaderConfigurationRowOnly:
        {
            CGSize size = _upperRightCollectionView.collectionViewLayout.collectionViewContentSize;
            
            _upperRightContainerView.frame = CGRectMake(0.0 ,0.0, self.bounds.size.width, size.height);
            
            _lowerRightContainerView.frame = CGRectMake(0.0, (size.height + NVSpreadsheetGridSpace), self.bounds.size.width,
                                                            (self.bounds.size.height - size.height - NVSpreadsheetGridSpace));
            break;
        }
            
        case NVSpreadsheetHeaderConfigurationBoth:
        {
            CGSize size = _upperLeftCollectionView.collectionViewLayout.collectionViewContentSize;
            
            _upperLeftContainerView.frame = CGRectMake(0.0, 0.0, size.width, size.height);
            
            _upperRightContainerView.frame = CGRectMake((size.width + NVSpreadsheetGridSpace), 0.0,
                                                        (self.bounds.size.width - size.width - NVSpreadsheetGridSpace), size.height);
            
            _lowerLeftContainerView.frame = CGRectMake(0.0, size.height + NVSpreadsheetGridSpace, size.width,
                                                       (self.bounds.size.height - size.height - NVSpreadsheetGridSpace));
            
            _lowerRightContainerView.frame = CGRectMake(size.width + NVSpreadsheetGridSpace, size.height + NVSpreadsheetGridSpace,
                                                        (self.bounds.size.width - size.width - NVSpreadsheetGridSpace),
                                                        (self.bounds.size.height - size.height - NVSpreadsheetGridSpace));
            break;
        }
            
        default:
            break;
    }
    
    _verticalScrollIndicator.frame = CGRectMake((self.frame.size.width - NVSpreadsheetScrollIndicatorWidth -
                                                _scrollIndicatorInsets.right - NVScrollIndicatorDefaultInsetSpace),
                                                (_scrollIndicatorInsets.top + NVSpreadsheetScrollIndicatorSpace),
                                                NVSpreadsheetScrollIndicatorWidth,
                                                (self.frame.size.height - 4.0 * NVSpreadsheetScrollIndicatorSpace));
    
    [self updateVerticalScrollIndicator];
    
    _horizontalScrollIndicator.frame = CGRectMake((_scrollIndicatorInsets.left + NVSpreadsheetScrollIndicatorSpace),
                                                  (self.frame.size.height - NVSpreadsheetScrollIndicatorWidth -
                                                   _scrollIndicatorInsets.bottom - NVScrollIndicatorDefaultInsetSpace),
                                                  (self.frame.size.width - 4.0 * NVSpreadsheetScrollIndicatorSpace),
                                                  NVSpreadsheetScrollIndicatorWidth);
    
    [self updateHorizontalScrollIndicator];
}

- (void)handleUpperRightPanGesture:(UIPanGestureRecognizer *)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateBegan)
    {
        _lowerLeftContainerView.userInteractionEnabled = NO;
        _lowerRightContainerView.userInteractionEnabled = NO;
    }
    
    else if (recognizer.state == UIGestureRecognizerStateEnded)
    {
        if (_isUpperRightBouncing == NO)
        {
            _lowerLeftContainerView.userInteractionEnabled = YES;
            _lowerRightContainerView.userInteractionEnabled = YES;
        }
    }
}

- (void)handleLowerLeftPanGesture:(UIPanGestureRecognizer *)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateBegan)
    {
        _upperRightContainerView.userInteractionEnabled = NO;
        _lowerRightContainerView.userInteractionEnabled = NO;
    }
    
    else if (recognizer.state == UIGestureRecognizerStateEnded)
    {
        if (_isLowerLeftBouncing == NO)
        {
            _upperRightContainerView.userInteractionEnabled = YES;
            _lowerRightContainerView.userInteractionEnabled = YES;
        }
    }
}

- (void)handleLowerRightPanGesture:(UIPanGestureRecognizer *)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateBegan)
    {
        _upperRightContainerView.userInteractionEnabled = NO;
        _lowerLeftContainerView.userInteractionEnabled = NO;
    }
    
    else if (recognizer.state == UIGestureRecognizerStateEnded)
    {
        if (_isLowerRightBouncing == NO)
        {
            _upperRightContainerView.userInteractionEnabled = YES;
            _lowerLeftContainerView.userInteractionEnabled = YES;
        }
    }
}

- (void)setBounces:(BOOL)bounces
{
    _bounces = bounces;
    _upperLeftCollectionView.bounces = bounces;
    _upperRightCollectionView.bounces = bounces;
    _lowerLeftCollectionView.bounces = bounces;
    _lowerRightCollectionView.bounces = bounces;
}

- (void)setDataSource:(id<NVSpreadsheetDataSource>)dataSource
{
    _dataSource = dataSource;
    
    if (_upperLeftCollectionView)
        [self initializeCollectionViewLayoutItemSize:_upperLeftCollectionView];
    
    if (_upperRightCollectionView)
        [self initializeCollectionViewLayoutItemSize:_upperRightCollectionView];
    
    if (_lowerLeftCollectionView)
        [self initializeCollectionViewLayoutItemSize:_lowerLeftCollectionView];
    
    if (_lowerRightCollectionView)
        [self initializeCollectionViewLayoutItemSize:_lowerRightCollectionView];
}

- (void)initializeCollectionViewLayoutItemSize:(UICollectionView *)collectionView
{
    NSIndexPath *indexPathZero = [NSIndexPath indexPathForItem:0
                                                     inSection:0];
    
    NVGridLayout *layout = (NVGridLayout *)collectionView.collectionViewLayout;
    
    CGSize size = [self collectionView:collectionView
                                layout:layout
                sizeForItemAtIndexPath:indexPathZero];
    
    layout.itemSize = size;
}

- (UIView *)setupScrollIndicator
{
    UIView *scrollIndicator = [[UIView alloc] initWithFrame:CGRectZero];
    scrollIndicator.alpha = 0.0;
    scrollIndicator.layer.cornerRadius = (NVSpreadsheetScrollIndicatorWidth / 2.0);
    scrollIndicator.clipsToBounds = YES;
    [self addSubview:scrollIndicator];
    
    UIView *scrollIndicatorSegment = [[UIView alloc] initWithFrame:CGRectZero];
    
    scrollIndicatorSegment.backgroundColor = [UIColor colorWithWhite:0.44
                                                               alpha:1.0];
    
    scrollIndicatorSegment.layer.cornerRadius = (NVSpreadsheetScrollIndicatorWidth / 2.0);
    scrollIndicatorSegment.tag = NVScrollIndicatorTag;
    [scrollIndicator addSubview:scrollIndicatorSegment];
    
    return scrollIndicator;
}

- (void)showScrollIndicators
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self
                                             selector:_cmd
                                               object:nil];
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self
                                             selector:@selector(hideScrollIndicators)
                                               object:nil];
    
    [UIView animateWithDuration:0.4 animations:^{
        _verticalScrollIndicator.alpha = (_showsVerticalScrollIndicator ? 1.0 : 0.0);
        _horizontalScrollIndicator.alpha = (_showsHorizontalScrollIndicator ? 1.0 : 0.0);
    }];
}

- (void)hideScrollIndicators
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self
                                             selector:_cmd
                                               object:nil];
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self
                                             selector:@selector(showScrollIndicators)
                                               object:nil];
    
    [UIView animateWithDuration:0.5 animations:^{
        _verticalScrollIndicator.alpha = 0.0;
        _horizontalScrollIndicator.alpha = 0.0;
    }];
}

- (void)updateVerticalScrollIndicator
{
    if (_showsVerticalScrollIndicator)
    {
        UIView *scrollIndicator = _verticalScrollIndicator;
        UIView *indicatorView = [scrollIndicator viewWithTag:NVScrollIndicatorTag];
        UICollectionView *collectionView = _lowerRightCollectionView;
        CGSize contentSize = collectionView.collectionViewLayout.collectionViewContentSize;
        CGRect collectionViewFrame = collectionView.frame;
        
        if (collectionViewFrame.size.height > contentSize.height)
            indicatorView.frame = CGRectZero;
        
        else
        {
            CGFloat indicatorHeight = (collectionViewFrame.size.height / contentSize.height * scrollIndicator.frame.size.height);
            
            if (indicatorHeight < NVSpreadsheetScrollIndicatorMinimum)
                indicatorHeight = NVSpreadsheetScrollIndicatorMinimum;
            
            CGFloat indicatorOffsetY = (collectionView.contentOffset.y / (contentSize.height - collectionViewFrame.size.height) *
                                        (scrollIndicator.frame.size.height - indicatorHeight));
            
            indicatorView.frame = CGRectMake(0.0, indicatorOffsetY, NVSpreadsheetScrollIndicatorWidth, indicatorHeight);
        }
    }
}

- (void)updateHorizontalScrollIndicator
{
    if (_showsHorizontalScrollIndicator)
    {
        UIView *scrollIndicator = _horizontalScrollIndicator;
        UIView *indicatorView = [scrollIndicator viewWithTag:NVScrollIndicatorTag];
        UICollectionView *collectionView = _lowerRightCollectionView;
        CGSize contentSize = collectionView.collectionViewLayout.collectionViewContentSize;
        CGRect collectionViewFrame = collectionView.frame;
        
        if (collectionView.frame.size.width > contentSize.width)
            indicatorView.frame = CGRectZero;
        
        else
        {
            CGFloat indicatorWidth = (collectionViewFrame.size.width/contentSize.width * scrollIndicator.frame.size.width);
            
            if (indicatorWidth < NVSpreadsheetScrollIndicatorMinimum)
                indicatorWidth = NVSpreadsheetScrollIndicatorMinimum;
            
            CGFloat indicatorOffsetX = (collectionView.contentOffset.x / (contentSize.width - collectionViewFrame.size.width) *
                                        (scrollIndicator.frame.size.width - indicatorWidth));
            
            indicatorView.frame = CGRectMake(indicatorOffsetX, 0.0, indicatorWidth, NVSpreadsheetScrollIndicatorWidth);
        }
    }
}

- (UICollectionView *)collectionViewForDataSourceIndexPath:(NSIndexPath *)indexPath
{
    UICollectionView *collectionView = nil;
    
    switch (_spreadsheetHeaderConfiguration)
    {
        case NVSpreadsheetHeaderConfigurationNone:
            collectionView = _lowerRightCollectionView;
            break;
            
        case NVSpreadsheetHeaderConfigurationColumnOnly:
            if (indexPath.nvSpreadsheetColumn >= _headerColumnCount)
                collectionView = _lowerRightCollectionView;
            
            else
                collectionView = _lowerLeftCollectionView;
            
            break;
            
        case NVSpreadsheetHeaderConfigurationRowOnly:
            if (indexPath.nvSpreadsheetRow >= _headerRowCount)
                collectionView = _lowerRightCollectionView;
            
            else
                collectionView = _upperRightCollectionView;
            
            break;
            
        case NVSpreadsheetHeaderConfigurationBoth:
            if (indexPath.nvSpreadsheetRow >= _headerRowCount)
            {
                if (indexPath.nvSpreadsheetColumn >= _headerColumnCount)
                    collectionView = _lowerRightCollectionView;
            
                else
                    collectionView = _lowerLeftCollectionView;
            }
            
            else
            {
                if (indexPath.nvSpreadsheetColumn >= _headerColumnCount)
                    collectionView = _upperRightCollectionView;
                
                else
                    collectionView = _upperLeftCollectionView;
            }
            
            break;
            
        default:
            break;
    }
    return collectionView;
}

- (NSIndexPath *)dataSourceIndexPathFromCollectionView:(UICollectionView *)collectionView
                                             indexPath:(NSIndexPath *)indexPath
{
    NSInteger nvSpreadsheetRow = indexPath.nvSpreadsheetRow;
    NSInteger nvSpreadsheetColumn = indexPath.nvSpreadsheetColumn;
    
    if (collectionView)
    {
        switch (collectionView.tag)
        {
            case NVSpreadsheetCollectionUpperLeft:
                break;
                
            case NVSpreadsheetCollectionUpperRight:
                nvSpreadsheetColumn += _headerColumnCount;
                break;
                
            case NVSpreadsheetCollectionLowerLeft:
                nvSpreadsheetRow += _headerRowCount;
                break;
                
            case NVSpreadsheetCollectionLowerRight:
                nvSpreadsheetRow += _headerRowCount;
                nvSpreadsheetColumn += _headerColumnCount;
                break;
                
            default:
                break;
        }
    }
    
    return [NSIndexPath indexPathForItem:nvSpreadsheetColumn
                               inSection:nvSpreadsheetRow];
}

- (NSIndexPath *)collectionViewIndexPathFromDataSourceIndexPath:(NSIndexPath *)indexPath
{
    UICollectionView *collectionView = [self collectionViewForDataSourceIndexPath:indexPath];
    NSInteger nvSpreadsheetRow = indexPath.nvSpreadsheetRow;
    NSInteger nvSpreadsheetColumn = indexPath.nvSpreadsheetColumn;
    
    switch (collectionView.tag)
    {
        case NVSpreadsheetCollectionUpperLeft:
            break;
            
        case NVSpreadsheetCollectionUpperRight:
            nvSpreadsheetColumn -= _headerColumnCount;
            break;
            
        case NVSpreadsheetCollectionLowerLeft:
            nvSpreadsheetRow -= _headerRowCount;
            break;
            
        case NVSpreadsheetCollectionLowerRight:
            nvSpreadsheetRow -= _headerRowCount;
            nvSpreadsheetColumn -= _headerColumnCount;
            break;
            
        default:
            break;
    }
    
    return [NSIndexPath indexPathForItem:nvSpreadsheetColumn
                               inSection:nvSpreadsheetRow];
}

- (void)setScrollEnabledValue:(BOOL)scrollEnabled
                   scrollView:(UIScrollView *)scrollView
{
    switch (scrollView.tag)
    {
        case NVSpreadsheetCollectionUpperLeft:
            break;
            
        case NVSpreadsheetCollectionUpperRight:
            _lowerLeftCollectionView.scrollEnabled = scrollEnabled;
            _lowerRightCollectionView.scrollEnabled = scrollEnabled;
            break;
            
        case NVSpreadsheetCollectionLowerLeft:
            _upperRightCollectionView.scrollEnabled = scrollEnabled;
            _lowerRightCollectionView.scrollEnabled = scrollEnabled;
            break;
            
        case NVSpreadsheetCollectionLowerRight:
            _upperRightCollectionView.scrollEnabled = scrollEnabled;
            _lowerLeftCollectionView.scrollEnabled = scrollEnabled;
            break;
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSIndexPath *dataSourceIndexPath = [self dataSourceIndexPathFromCollectionView:collectionView
                                                                         indexPath:indexPath];
    
    CGSize size = [_dataSource spreadsheetView:self
                        sizeForItemAtIndexPath:dataSourceIndexPath];
    
    return size;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    NSInteger rowCount = [_dataSource numberOfRowsInSpreadsheetView:self];
    NSInteger adjustedRows = 1;
    
    switch (collectionView.tag)
    {
        case NVSpreadsheetCollectionUpperLeft:
            adjustedRows = _headerRowCount;
            break;
            
        case NVSpreadsheetCollectionUpperRight:
            adjustedRows = _headerRowCount;
            break;
            
        case NVSpreadsheetCollectionLowerLeft:
            adjustedRows = (rowCount - _headerRowCount);
            break;
            
        case NVSpreadsheetCollectionLowerRight:
            adjustedRows = (rowCount - _headerRowCount);
            break;
            
        default:
            break;
    }
    
    return adjustedRows;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section
{
    NSInteger items = 0;
    NSInteger columnCount = [_dataSource numberOfColumnsInSpreadsheetView:self];
    
    switch (collectionView.tag)
    {
        case NVSpreadsheetCollectionUpperLeft:
            items = _headerColumnCount;
            break;
            
        case NVSpreadsheetCollectionUpperRight:
            items = (columnCount - _headerColumnCount);
            break;
            
        case NVSpreadsheetCollectionLowerLeft:
            items = _headerColumnCount;
            break;
            
        case NVSpreadsheetCollectionLowerRight:
            items = (columnCount - _headerColumnCount);
            break;
            
        default:
            break;
    }
    
    return items;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSIndexPath *dataSourceIndexPath = [self dataSourceIndexPathFromCollectionView:collectionView
                                                                         indexPath:indexPath];
    
    UICollectionViewCell *cell = [_dataSource spreadsheetView:self
                                       cellForItemAtIndexPath:dataSourceIndexPath];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView
didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (collectionView.tag != NVSpreadsheetCollectionUpperLeft && _scrollEnabled)
    {
        NSIndexPath *dataSourceIndexPath = [self dataSourceIndexPathFromCollectionView:collectionView
                                                                             indexPath:indexPath];
        
        [_delegate spreadsheetView:self didSelectItemAtIndexPath:dataSourceIndexPath];
        [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView == _controllingScrollView)
    {
        switch (scrollView.tag)
        {
            case NVSpreadsheetCollectionLowerLeft:
                [self lowerLeftCollectionViewDidScrollForScrollView:scrollView];
                break;
                
            case NVSpreadsheetCollectionUpperRight:
                [self upperRightCollectionViewDidScrollForScrollView:scrollView];
                break;
                
            case NVSpreadsheetCollectionLowerRight:
                [self lowerRightCollectionViewDidScrollForScrollView:scrollView];
                break;
        }
    }
    
    else
    {
        [scrollView setContentOffset:scrollView.contentOffset
                            animated:NO];
    }
}

- (void)lowerLeftCollectionViewDidScrollForScrollView:(UIScrollView *)scrollView
{
    [_lowerRightCollectionView setContentOffset:CGPointMake(_lowerRightCollectionView.contentOffset.x,
                                                            scrollView.contentOffset.y)
                                       animated:NO];
    
    [self updateVerticalScrollIndicator];
    
    if (scrollView.contentOffset.y <= 0.0)
    {
        CGRect rect = _upperLeftContainerView.frame;
        rect.origin.y = (0.0 - scrollView.contentOffset.y);
        _upperLeftContainerView.frame = rect;
        
        rect = _upperRightContainerView.frame;
        rect.origin.y = (0.0 - scrollView.contentOffset.y);
        _upperRightContainerView.frame = rect;
    }
    
    else
    {
        CGRect rect = _upperLeftContainerView.frame;
        rect.origin.y = 0.0;
        _upperLeftContainerView.frame = rect;
        
        rect = _upperRightContainerView.frame;
        rect.origin.y = 0.0;
        _upperRightContainerView.frame = rect;
    }
}

- (void)upperRightCollectionViewDidScrollForScrollView:(UIScrollView *)scrollView
{
    [_lowerRightCollectionView setContentOffset:CGPointMake(scrollView.contentOffset.x,
                                                            _lowerRightCollectionView.contentOffset.y)
                                       animated:NO];
    [self updateHorizontalScrollIndicator];
    
    if (scrollView.contentOffset.x <= 0.0)
    {
        CGRect rect = _upperLeftContainerView.frame;
        rect.origin.x = (0.0 - scrollView.contentOffset.x);
        _upperLeftContainerView.frame = rect;
        
        rect = _lowerLeftContainerView.frame;
        rect.origin.x = (0.0 - scrollView.contentOffset.x);
        _lowerLeftContainerView.frame = rect;
    }
    
    else
    {
        CGRect rect = _upperLeftContainerView.frame;
        rect.origin.x = 0.0;
        _upperLeftContainerView.frame = rect;
        
        rect = _lowerLeftContainerView.frame;
        rect.origin.x = 0.0;
        _lowerLeftContainerView.frame = rect;
    }
}

- (void)lowerRightCollectionViewDidScrollForScrollView:(UIScrollView *)scrollView
{
    [self updateVerticalScrollIndicator];
    [self updateHorizontalScrollIndicator];
    
    CGPoint offset = CGPointMake(0.0, scrollView.contentOffset.y);
    
    [_lowerLeftCollectionView setContentOffset:offset
                                      animated:NO];
    
    offset = CGPointMake(scrollView.contentOffset.x, 0.0);
    
    [_upperRightCollectionView setContentOffset:offset
                                       animated:NO];
    
    if (scrollView.contentOffset.y <= 0.0)
    {
        CGRect rect = _upperLeftContainerView.frame;
        rect.origin.y = (0.0 - scrollView.contentOffset.y);
        _upperLeftContainerView.frame = rect;
        
        rect = _upperRightContainerView.frame;
        rect.origin.y = (0.0 - scrollView.contentOffset.y);
        _upperRightContainerView.frame = rect;
    }
    
    else
    {
        CGRect rect = _upperLeftContainerView.frame;
        rect.origin.y = 0.0;
        _upperLeftContainerView.frame = rect;
        
        rect = _upperRightContainerView.frame;
        rect.origin.y = 0.0;
        _upperRightContainerView.frame = rect;
    }
    
    if (scrollView.contentOffset.x <= 0.0)
    {
        CGRect rect = _upperLeftContainerView.frame;
        rect.origin.x = (0.0 - scrollView.contentOffset.x);
        
        _upperLeftContainerView.frame = rect;
        rect = _lowerLeftContainerView.frame;
        rect.origin.x = (0.0 - scrollView.contentOffset.x);
        _lowerLeftContainerView.frame = rect;
    }
    
    else
    {
        CGRect rect = _upperLeftContainerView.frame;
        rect.origin.x = 0.0;
        
        _upperLeftContainerView.frame = rect;
        rect = _lowerLeftContainerView.frame;
        rect.origin.x = 0.0;
        _lowerLeftContainerView.frame = rect;
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self setScrollEnabledValue:NO
                     scrollView:scrollView];
    
    if (_controllingScrollView != scrollView)
    {
        
        [_lowerLeftCollectionView setContentOffset:_lowerLeftCollectionView.contentOffset
                                          animated:NO];
        
        [_upperRightCollectionView setContentOffset:_upperRightCollectionView.contentOffset
                                           animated:NO];
        
        [_lowerRightCollectionView setContentOffset:_lowerRightCollectionView.contentOffset
                                           animated:NO];
        
        _controllingScrollView = scrollView;
    }
    
    [self showScrollIndicators];
    
    [self setScrollEnabledValue:YES
                     scrollView:scrollView];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView
                  willDecelerate:(BOOL)decelerate
{
    if (!decelerate)
    {
        [self setNeedsLayout];
        [self hideScrollIndicators];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (!scrollView.isDecelerating && !scrollView.isDragging && !scrollView.isTracking)
    {
        [self setNeedsLayout];
        [self hideScrollIndicators];
    }
}

- (void)goToTop
{
    [_lowerRightCollectionView setContentOffset:CGPointMake(_controllingScrollView.contentOffset.x, 0.0)
                                       animated:YES];
}

- (void)goToBottom
{
    if (_lowerRightCollectionView.contentSize.height > _dataSource.gridContainerSize.height)
    {
        [_lowerRightCollectionView setContentOffset:CGPointMake(_lowerRightCollectionView.contentOffset.x,
                                                             (_lowerRightCollectionView.contentSize.height - _dataSource.gridContainerSize.height))
                                        animated:YES];
    }
}

- (void)goToLeftSide
{
    [_lowerRightCollectionView setContentOffset:CGPointMake(0.0,  _controllingScrollView.contentOffset.y)
                                    animated:YES];
}

- (void)goToRightSide
{
    if (_lowerRightCollectionView.contentSize.width > _dataSource.gridContainerSize.width)
    {
        [_lowerRightCollectionView setContentOffset:CGPointMake((_lowerRightCollectionView.contentSize.width - _dataSource.gridContainerSize.width),
                                                             _lowerRightCollectionView.contentOffset.y)
                                        animated:YES];
    }
}

- (void)goToUpperLeft
{
    [_lowerRightCollectionView setContentOffset:CGPointMake(0.0, 0.0)
                                    animated:YES];
}

- (void)goToUpperRight
{
    if (_lowerRightCollectionView.contentSize.width > _dataSource.gridContainerSize.width)
    {
        [_lowerRightCollectionView setContentOffset:CGPointMake((_lowerRightCollectionView.contentSize.width - _dataSource.gridContainerSize.width), 0.0)
                                        animated:YES];
    }
    
    else
        [self goToTop];
}

- (void)goToLowerLeft
{
    if (_lowerRightCollectionView.contentSize.height > _dataSource.gridContainerSize.height)
    {
        [_lowerRightCollectionView setContentOffset:CGPointMake(0.0, (_lowerRightCollectionView.contentSize.height - _dataSource.gridContainerSize.height))
                                        animated:YES];
    }
    
    else
        [self goToLeftSide];
}

- (void)goToLowerRight
{
    if ((_lowerRightCollectionView.contentSize.height > _dataSource.gridContainerSize.height) &&
        (_lowerRightCollectionView.contentSize.width > _dataSource.gridContainerSize.width))
    {
        [_lowerRightCollectionView setContentOffset:CGPointMake((_lowerRightCollectionView.contentSize.width - _dataSource.gridContainerSize.width),
                                                             (_lowerRightCollectionView.contentSize.height - _dataSource.gridContainerSize.height))
                                        animated:YES];
    }
    
    else
    {
        [self goToBottom];
        [self goToRightSide];
    }
}

- (void)headerLongPressed:(UILongPressGestureRecognizer *)gesture
{
    if (gesture.state == UIGestureRecognizerStateBegan)
    {
        if (gesture.view == _lowerLeftCollectionView)
        {
            CGPoint point = [gesture locationInView:_lowerLeftCollectionView];
            NSIndexPath *indexPath = [_lowerLeftCollectionView indexPathForItemAtPoint:point];
            NSInteger row = indexPath.nvSpreadsheetRow;
            
            if (indexPath)
            {
                if (_dataSource.spreadsheetIsFlipped)
                    _currentHeader = ROW_HEADER;
                
                else
                    _currentHeader = COLUMN_HEADER;
                
                if ([_delegate spreadsheetViewCanEditHeaderOfType:_currentHeader atIndex:row])
                {
                    NVLeftColumnCell *cell = (NVLeftColumnCell *)[_lowerLeftCollectionView cellForItemAtIndexPath:indexPath];
                    _textField.backgroundColor = cell.backgroundColor;
                    _textField.tag = row;
                    _textField.text = cell.textLabel.text;
                    _textField.font = cell.textLabel.font;
                    [cell.contentView addSubview:_textField];
                    [_textField constrainToView:cell.contentView leading:0.0 trailing:0.0 top:0.0 bottom:0.0];
                    [_textField becomeFirstResponder];
                    [_delegate spreadsheetViewInEditingMode:YES];
                    [self setScrollEnabled:NO];
                }
            }
        }
        
        else if (gesture.view == _upperRightCollectionView)
        {
            CGPoint point = [gesture locationInView:_upperRightCollectionView];
            NSIndexPath *indexPath = [_upperRightCollectionView indexPathForItemAtPoint:point];
            NSInteger column = indexPath.nvSpreadsheetColumn;
            
            if (indexPath)
            {
                if (_dataSource.spreadsheetIsFlipped)
                    _currentHeader = COLUMN_HEADER;
                
                else
                    _currentHeader = ROW_HEADER;
                
                if ([_delegate spreadsheetViewCanEditHeaderOfType:_currentHeader atIndex:column])
                {
                    NVTopRowCell *cell = (NVTopRowCell *)[_upperRightCollectionView cellForItemAtIndexPath:indexPath];
                    _textField.backgroundColor = cell.backgroundColor;
                    _textField.tag = column;
                    _textField.text = cell.textLabel.text;
                    _textField.font = cell.textLabel.font;
                    [cell.contentView addSubview:_textField];
                    [_textField constrainToView:cell.contentView leading:0.0 trailing:0.0 top:0.0 bottom:0.0];
                    [_textField becomeFirstResponder];
                    [_delegate spreadsheetViewInEditingMode:YES];
                    [self setScrollEnabled:NO];
                }
            }
        }
    }
}

- (BOOL)textField:(UITextField *)textField
shouldChangeCharactersInRange:(NSRange)range
replacementString:(NSString *)string
{
    NSString *resultString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    NSString *prefixString = [_dataSource spreadsheetViewRowHeaderPrefixAtIndex:textField.tag];
    
    if (!prefixString || !prefixString.length)
        return YES;
    
    else
    {
        NSRange prefixStringRange = [resultString rangeOfString:prefixString options:NSCaseInsensitiveSearch];
        
        if (prefixStringRange.location == 0)
            return YES;
        
        else
            return NO;
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return NO;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [textField removeFromSuperview];
    
    switch (_currentHeader)
    {
        case ROW_HEADER:
            [_delegate spreadsheetViewDidEditRowHeaderText:textField.text atIndex:textField.tag];
            break;
        case COLUMN_HEADER:
            [_delegate spreadsheetViewDidEditColumnHeaderText:textField.text atIndex:textField.tag];
            break;
        default:
            break;
    }
    
    [_upperRightCollectionView reloadData];
    [_lowerLeftCollectionView reloadData];
    [_delegate spreadsheetViewInEditingMode:NO];
    [self setScrollEnabled:YES];
}

@end
