//
//  CCGridView.m
//  Edu901
//
//  Created by ddrccw on 13-9-5.
//  Copyright (c) 2013年 admin. All rights reserved.
//

#import "CCGridView.h"

static const NSInteger kTagOffset = 0x10;
static const float kDefaultAnimationDuration = .25f;

@interface CCGridView ()<UIGestureRecognizerDelegate>
@property (retain, nonatomic) CCGridViewLayout *gridLayout;
@property (retain, nonatomic) NSMutableSet *reusableCellsSet;
@property (retain, nonatomic) NSMutableSet *visibleCellsSet;
@property (nonatomic, retain) UITapGestureRecognizer *tapGestureRecognizer;

@end

@implementation CCGridView

- (void)dealloc {
    [_gridLayout release];
    [_reusableCellsSet release];
    [_visibleCellsSet release];
    [super dealloc];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _visibleCellsSet = [[NSMutableSet alloc] init];
        _reusableCellsSet = [[NSMutableSet alloc] init];
        
        [self setAutoresizesSubviews:NO];
        [self setBackgroundColor:[UIColor whiteColor]];

        _tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                        action:@selector(handleTapGestureRecognition:)];
        [_tapGestureRecognizer setNumberOfTapsRequired:1];
        [_tapGestureRecognizer setNumberOfTouchesRequired:1];
        [_tapGestureRecognizer setDelegate:self];
        [self addGestureRecognizer:_tapGestureRecognizer];

        _layoutType = CCGridViewLayoutTypeVertical;
        _centerGrid = YES;
        _cellSize = kCCGridViewDefaultCellSize;
        _cellSpacing = 10;
        _minEdgeInsets = UIEdgeInsetsMake(5, 5, 5, 5);

    }
    return self;
}

- (id)initWithLayoutType:(CCGridViewLayoutType)layoutType {
    self = [self initWithFrame:CGRectZero];
    if (self) {
        self.layoutType = layoutType;
        if (CCGridViewLayoutTypeVertical == layoutType) {
            self.alwaysBounceVertical = YES;
            self.alwaysBounceHorizontal = NO;
        }
        else if (CCGridViewLayoutTypeHorizontal == layoutType) {
            self.alwaysBounceVertical = NO;
            self.alwaysBounceHorizontal = YES;
        }
    }
    return self;
}

- (void)setCellSize:(CGSize)cellSize {
    if(!CGSizeEqualToSize(_cellSize, cellSize))
    {
        _cellSize = cellSize;
        
        [self reloadContentSize];
        [self setNeedsLayout];
    }
}

- (void)setDelegate:(id<CCGridViewDelegate>)delegate {
    [super setDelegate:delegate];
    _gridViewDelegateRespondsTo.willSelectCell = [delegate respondsToSelector:@selector(gridView:willSelectCellAtIndex:)];
    _gridViewDelegateRespondsTo.didSelectCell = [delegate respondsToSelector:@selector(gridView:didSelectCellAtIndex:)];
}

- (void)setDataSource:(id<CCGridViewDataSource>)dataSource {
    if (_dataSource != dataSource) {
        _dataSource = dataSource;
        _gridViewDataSourceRespondsTo.numberOfItems = [dataSource respondsToSelector:@selector(numberOfItemsInGridView:)];
    }
}

- (void)reloadContentSize {
    [self reloadContentSizeWithFrame:self.frame];
}

- (void)reloadContentSizeWithFrame:(CGRect)frame {
    CGSize contentSize = CGSizeZero;
    if (!self.gridLayout) {
        _gridLayout = [[CCGridViewLayout alloc] init];
    }
    
    [_gridLayout setUpWithLayoutType:self.layoutType
                            cellSize:self.cellSize
                         cellSpacing:self.cellSpacing
                       minEdgeInsets:self.minEdgeInsets
                        centeredGrid:self.centerGrid];
    int itemCount = (_gridViewDataSourceRespondsTo.numberOfItems ?
                     [self.dataSource numberOfItemsInGridView:self] :
                     0);
    [_gridLayout rebaseWithItemCount:itemCount inFrame:frame];
    if(CCGridViewLayoutTypeVertical == self.layoutType) {
        contentSize.width = frame.size.width;
        contentSize.height = _gridLayout.contentSize.height;
    }
    else if(CCGridViewLayoutTypeHorizontal == self.layoutType) {
        contentSize.height = frame.size.height;
        contentSize.width = _gridLayout.contentSize.width;
    }
    [self setContentSize:contentSize];
}


- (void)layoutSubviews {
    [super layoutSubviews];
    
    if(CGRectIsEmpty([self bounds]))
        return;
    
    if (!CGSizeEqualToSize(self.gridLayout.gridBounds.size, self.bounds.size)) {
        [self reloadContentSize];
    }
    
    NSMutableArray *visibleCellsIndexes = [[NSMutableArray alloc] init];
    NSSet *visibleCellsSetCopy = [_visibleCellsSet copy];
    
    for(CCGridViewCell* visibleCell in visibleCellsSetCopy)
    {
        visibleCell.frame = [self.gridLayout rectForCellAtIndex:visibleCell.index - kTagOffset];
        if(CGRectIntersectsRect([visibleCell frame], [self bounds]) == NO) {
            [self throwCellInReusableQueue:visibleCell];
        }
        else {
            [visibleCellsIndexes addObject:@(visibleCell.index)]; // gather the index path of the enumerated cell if it's still visible on screen.
        }
    }
    
    [visibleCellsSetCopy release];
    
    [self layoutCellsWithAlreadyVisibleCellsIndexes:visibleCellsIndexes];
    [visibleCellsIndexes release];

}

- (CCGridViewCell *)dequeueReusableCellWithIdentifier:(NSString *)identifier
{
    CCGridViewCell* dequeuedCell = nil;
    
    if(identifier != nil){
        NSArray *dequeuableCells = [_reusableCellsSet allObjects];
        NSArray *dequeuableIdentifiers = [dequeuableCells valueForKeyPath:@"@unionOfObjects.reuseIdentifier"];
        NSInteger indexOfIdentifier = [dequeuableIdentifiers indexOfObject:identifier];
        
        if(indexOfIdentifier != NSNotFound)
        {
            dequeuedCell = [[dequeuableCells objectAtIndex:indexOfIdentifier] retain];
//            [dequeuedCell prepareForReuse];
            [_reusableCellsSet removeObject:dequeuedCell];
        }
        
        [dequeuedCell setAlpha:1.];
    }
    
    return [dequeuedCell autorelease];
}

- (CCGridViewCell *)visibleCellAtIndex:(NSInteger)index {
    __block CCGridViewCell *cell = nil;
    int itemCountInGridView = (_gridViewDataSourceRespondsTo.numberOfItems ?
                               [self.dataSource numberOfItemsInGridView:self] :
                               0);
    
    if (0 <= index && index < itemCountInGridView) {
        [self.visibleCellsSet enumerateObjectsUsingBlock:^(CCGridViewCell *c, BOOL *stop){
            if (c.index == (index + kTagOffset)) {
                cell = c;
                *stop = YES;
            }
        }];
    }
    
    return [[cell retain] autorelease];
}

- (NSArray *)visibleCellsAtIndexes:(NSArray *)indexes {
    return [self.visibleCells filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^(CCGridViewCell *cell, NSDictionary *bindings){
        return [indexes containsObject:@(cell.index - kTagOffset)];
    }]];
}

- (NSArray *)visibleCells {
    return [self.visibleCellsSet allObjects];
}

- (NSArray *)indexesForVisibleCells {
    NSMutableArray *indexes = [NSMutableArray arrayWithCapacity:[self.visibleCellsSet count]];
    [self.visibleCellsSet enumerateObjectsUsingBlock:^(CCGridViewCell *cell, BOOL *stop){
        [indexes addObject:@(cell.index - kTagOffset)];
    }];
    return [NSArray arrayWithArray:indexes];
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark - scroll
- (void)scrollToItemAtIndex:(NSInteger)index
                   animated:(BOOL)animated
             scrollPosition:(CCGridViewScrollPosition)scrollPosition
{
    CGPoint contentOffsetForItem = CGPointZero;
    CGRect itemRect = [self.gridLayout rectForCellAtIndex:index];
    
    if (CCGridViewLayoutTypeVertical == self.gridLayout.type) {
        contentOffsetForItem.x = self.contentOffset.x;
        
        switch (scrollPosition) {
            case CCGridViewScrollPositionAtTop:
                contentOffsetForItem.y = CGRectGetMinY(itemRect) - self.gridLayout.cellSpacing;
                break;
            case CCGridViewScrollPositionAtMiddle:
                contentOffsetForItem.y = floor(CGRectGetMidY(itemRect) - CGRectGetHeight(self.bounds) / 2.);
                break;
            case CCGridViewScrollPositionAtBottom:
                contentOffsetForItem.y = CGRectGetMinY(itemRect) - (CGRectGetHeight(self.bounds) - CGRectGetHeight(itemRect)) + self.gridLayout.cellSpacing;
                break;
            default:
                break;
        }
        
        float maxOffsetY = self.contentSize.height - CGRectGetHeight(self.bounds);
        if (contentOffsetForItem.y < 0) {
            contentOffsetForItem.y = 0;
        }
        else if (contentOffsetForItem.y > maxOffsetY) {
            contentOffsetForItem.y = maxOffsetY;
        }
    }
    else {
        contentOffsetForItem.y = self.contentOffset.y;
        
        switch (scrollPosition) {
            case CCGridViewScrollPositionAtTop:
                contentOffsetForItem.x = CGRectGetMinX(itemRect) - self.gridLayout.cellSpacing;
                break;
            case CCGridViewScrollPositionAtMiddle:
                contentOffsetForItem.x = floor(CGRectGetMidX(itemRect) - CGRectGetWidth(self.bounds) / 2.);
                break;
            case CCGridViewScrollPositionAtBottom:
                contentOffsetForItem.x = CGRectGetMinX(itemRect) - (CGRectGetWidth(self.bounds) - CGRectGetWidth(itemRect)) + self.gridLayout.cellSpacing;
                break;
            default:
                break;
        }
        
        float maxOffsetX = self.contentSize.width - CGRectGetWidth(self.bounds);
        if (contentOffsetForItem.x < 0) {
            contentOffsetForItem.x = 0;
        }
        else if (contentOffsetForItem.x > maxOffsetX) {
            contentOffsetForItem.x = maxOffsetX;
        }

    }
    
    [self setContentOffset:contentOffsetForItem animated:animated];
}



////////////////////////////////////////////////////////////////////////////////
#pragma mark - reload
- (void)reloadData {
    [self reloadContentSize];
    [self throwCellsInReusableQueue:_visibleCellsSet];
    //    [_selectedCellsIndexPaths release], _selectedCellsIndexPaths = [[NSMutableArray alloc] init];
    [self setNeedsLayout];
}

- (void)reloadCellAtIndex:(NSInteger)index withCellAnimation:(CCGridViewCellAnimation)cellAnimation {
    __block CCGridViewCell *cell = [self visibleCellAtIndex:index];
    if (!cell) return;
    
    CGRect inFrame = cell.frame;
    __block CGRect outFrame = CGRectZero;
    if (CCGridViewCellAnimationNone == cellAnimation) {
        [self throwCellInReusableQueue:cell];
        cell = [self.dataSource gridView:self cellForItemAtIndex:index];
        [self insertCell:cell forIndex:index];
    }
    else {
        [UIView animateWithDuration:kDefaultAnimationDuration
                              delay:0.
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:^
         {
             outFrame = [self finalRectForRect:inFrame usingCellAnimation:cellAnimation];
             cell.frame = outFrame;
             cell.alpha = 0;
         }completion:^(BOOL finished){
             if (finished) {
                 [self throwCellInReusableQueue:cell];
                 cell = [self.dataSource gridView:self cellForItemAtIndex:index];
                 [self insertCell:cell forIndex:index];
                 cell.frame = outFrame;
                 cell.alpha = 0;
                 [UIView animateWithDuration:kDefaultAnimationDuration
                                       delay:0.
                                     options:UIViewAnimationOptionCurveEaseIn
                                  animations:^
                  {
                      cell.frame = inFrame;
                      cell.alpha = 1;
                  }completion:^(BOOL finished){
                      NSLog(@"%@", cell);
                  }];
             }
         }];
    }
}

- (void)reloadCellsAtIndexes:(NSArray *)indexes withCellAnimation:(CCGridViewCellAnimation)cellAnimation {
    for (NSNumber *index in indexes) {
        [self reloadCellAtIndex:[index intValue] withCellAnimation:cellAnimation];
    }
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark - private API -

- (void)throwCellsInReusableQueue:(NSSet*)cellsSet
{
    [cellsSet enumerateObjectsUsingBlock:^(CCGridViewCell *cell, BOOL *stop){
        cell.index = NSIntegerMin;
        [cell removeFromSuperview];
    }];
    
    [_reusableCellsSet unionSet:cellsSet];
    [_visibleCellsSet minusSet:cellsSet];
}


- (void)throwCellInReusableQueue:(CCGridViewCell *)cell
{
    cell.index = NSIntegerMin;
    [cell removeFromSuperview];
    [_reusableCellsSet addObject:cell];
    [_visibleCellsSet removeObject:cell];
}

- (void)layoutCellsWithAlreadyVisibleCellsIndexes:(NSArray*)alreadyVisibleCellsIndexes
{
    CGRect gridContentFrame = [self.gridLayout contentFrame];
    
    int itemCountInGridView = (_gridViewDataSourceRespondsTo.numberOfItems ?
                     [self.dataSource numberOfItemsInGridView:self] :
                     0);
    NSInteger firstVisibleCellIndex = 0;
    NSInteger cellIndexesRange = 0;
    NSInteger numberOfCellsPerLine = [self.gridLayout numberOfCellsPerLine];
    if (CCGridViewLayoutTypeVertical == self.layoutType) {
        NSInteger firstVisibleLineIndex = floor((CGRectGetMinY(self.bounds) - CGRectGetMinY(gridContentFrame) - self.cellSpacing) / ([self cellSize].height + self.cellSpacing));
        if(firstVisibleLineIndex < 0)
            firstVisibleLineIndex = 0;

        NSInteger lastVisibleLineIndex = floor((CGRectGetMaxY(self.bounds) - CGRectGetMinY(gridContentFrame) - self.cellSpacing) / ([self cellSize].height + self.cellSpacing));
        firstVisibleCellIndex = firstVisibleLineIndex * numberOfCellsPerLine;
        cellIndexesRange = (lastVisibleLineIndex + 1) * numberOfCellsPerLine - firstVisibleCellIndex;
        
    }
    else if (CCGridViewLayoutTypeHorizontal == self.layoutType) {
        NSInteger firstVisibleColumnIndex = floor((CGRectGetMinX(self.bounds) - CGRectGetMinX(gridContentFrame) - self.cellSpacing) / ([self cellSize].width + self.cellSpacing));
        if(firstVisibleColumnIndex < 0)
            firstVisibleColumnIndex = 0;

        NSInteger lastVisibleColumnIndex = floor((CGRectGetMaxX(self.bounds) - CGRectGetMinX(gridContentFrame) - self.cellSpacing) / ([self cellSize].width + self.cellSpacing));
        firstVisibleCellIndex = firstVisibleColumnIndex * numberOfCellsPerLine;
        cellIndexesRange = ((lastVisibleColumnIndex + 1) * numberOfCellsPerLine) - firstVisibleCellIndex;
    }
    
    if (firstVisibleCellIndex + cellIndexesRange > itemCountInGridView) {
        cellIndexesRange = itemCountInGridView - firstVisibleCellIndex;
    }
    
    if (cellIndexesRange < 0) {
        cellIndexesRange = 0;
    }
    
    NSMutableIndexSet *visibleContentIndexes = [NSMutableIndexSet indexSetWithIndexesInRange:NSMakeRange(firstVisibleCellIndex, cellIndexesRange)];
    [visibleContentIndexes enumerateIndexesUsingBlock:^(NSUInteger cellIndex, BOOL *stop) {
        if ([alreadyVisibleCellsIndexes containsObject:@(cellIndex + kTagOffset)] == NO) {
            CCGridViewCell *cell = [self.dataSource gridView:self cellForItemAtIndex:cellIndex];
            [self insertCell:cell forIndex:cellIndex];
        }
    }];
}


- (void)insertCell:(CCGridViewCell *)cell forIndex:(NSInteger)index
{
    NSAssert(cell, @"inserted cell should not be nil!");
    cell.index = index + kTagOffset;
    cell.frame = [self.gridLayout rectForCellAtIndex:index];
//    [cell setSelected:[_selectedCellsIndexPaths containsObject:indexPath]];
    [self insertSubview:cell atIndex:index];
    [_visibleCellsSet addObject:cell];
}

- (CGRect)finalRectForRect:(CGRect)initRect usingCellAnimation:(CCGridViewCellAnimation)animation {
    CGRect rect = initRect;
    switch (animation) {
        case CCGridViewCellAnimationTop:
            rect.origin.y -= self.cellSize.height;
            break;
        case CCGridViewCellAnimationBottom:
            rect.origin.y += self.cellSize.height;
            break;
        case CCGridViewCellAnimationLeft:
            rect.origin.x -= self.cellSize.width;
            break;
        case CCGridViewCellAnimationRight:
            rect.origin.x += self.cellSize.width;
            break;
        default:
            break;
    }
    return rect;
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark - gesture
- (void)handleTapGestureRecognition:(UITapGestureRecognizer *)tapGesture {
    CGPoint locationTouch = [tapGesture locationInView:self];
    NSInteger index = [self.gridLayout itemIndexFromLocation:locationTouch];

    if (index != kInvalidItemIndex)
    {
        if (_gridViewDelegateRespondsTo.willSelectCell) {
            [self.delegate gridView:self willSelectCellAtIndex:index];
        }
        
//        [self selectCellAtIndexPath:[aCell __indexPath] animated:YES];
        
        if(_gridViewDelegateRespondsTo.didSelectCell) {
            [self.delegate gridView:self didSelectCellAtIndex:index];
        }
    }
}

@end
