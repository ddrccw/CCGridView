//
//  CCGridView.m
//  Edu901
//
//  Created by ddrccw on 13-9-5.
//  Copyright (c) 2013年 admin. All rights reserved.
//

#import "CCGridView.h"

static const NSInteger kTagOffset = 0x10;

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
    [_visibleCells release];
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
        [self setAlwaysBounceVertical:YES];
        
        _tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                        action:@selector(handleTapGestureRecognition:)];
        [_tapGestureRecognizer setNumberOfTapsRequired:1];
        [_tapGestureRecognizer setNumberOfTouchesRequired:1];
        [_tapGestureRecognizer setDelegate:self];
        [self addGestureRecognizer:_tapGestureRecognizer];

        self.layoutType = CCGridViewLayoutTypeVertical;
        self.cellSize = kCCGridViewDefaultCellSize;
        self.cellSpacing = 10;
        self.minEdgeInsets = UIEdgeInsetsMake(5, 5, 5, 5);

    }
    return self;
}

- (id)initWithLayoutType:(CCGridViewLayoutType)layoutType {
    self = [self initWithFrame:CGRectZero];
    if (self) {
        self.layoutType = layoutType;
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

- (void)reloadData {
    [self reloadContentSize];
    [self throwCellsInReusableQueue:_visibleCellsSet];
//    [_selectedCellsIndexPaths release], _selectedCellsIndexPaths = [[NSMutableArray alloc] init];
    [self setNeedsLayout];
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
        
        NSLog(@"dequeuCellIdx=%d", dequeuedCell.index);
    }
    
    return [dequeuedCell autorelease];
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
    NSLog(@"reuseCell index=%d", cell.index - kTagOffset);
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
        NSInteger firstVisibleColumnIndex = floor((CGRectGetMinX(self.bounds) - CGRectGetMinX(gridContentFrame) - self.cellSpacing) / ([self cellSize].width) + self.cellSpacing);
        if(firstVisibleColumnIndex<0)
            firstVisibleColumnIndex = 0;

        NSInteger lastVisibleColumnIndex = floor((CGRectGetMaxX(self.bounds) - CGRectGetMinX(gridContentFrame)) / ([self cellSize].width + self.cellSpacing));

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
    cell.index = index + kTagOffset;
    cell.frame = [self.gridLayout rectForCellAtIndex:index];
//    [cell setSelected:[_selectedCellsIndexPaths containsObject:indexPath]];
    [self insertSubview:cell atIndex:0];
    [_visibleCellsSet addObject:cell];
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
