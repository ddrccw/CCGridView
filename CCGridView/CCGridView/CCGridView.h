//
//  CCGridView.h
//  Edu901
//
//  Created by ddrccw on 13-9-5.
//  Copyright (c) 2013年 admin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CCGridViewLayout.h"
#import "CCGridViewCell.h"

typedef enum {
    CCGridViewCellAnimationFade,
    CCGridViewCellAnimationRight,
    CCGridViewCellAnimationLeft,
    CCGridViewCellAnimationTop,
    CCGridViewCellAnimationBottom,
    CCGridViewCellAnimationNone
} CCGridViewCellAnimation;

typedef enum{
    CCGridViewScrollPositionAtTop,
    CCGridViewScrollPositionAtMiddle,
    CCGridViewScrollPositionAtBottom
} CCGridViewScrollPosition;


static CGSize const kCCGridViewDefaultCellSize = {50, 70};

@class CCGridView;

@protocol CCGridViewDelegate <UIScrollViewDelegate>
@optional
- (void)gridView:(CCGridView *)gridView willSelectCellAtIndex:(NSInteger)index;
- (void)gridView:(CCGridView *)gridView didSelectCellAtIndex:(NSInteger)index;
@end

@protocol CCGridViewDataSource  <NSObject>

- (NSInteger)numberOfItemsInGridView:(CCGridView *)gridView;
- (CCGridViewCell *)gridView:(CCGridView *)gridView cellForItemAtIndex:(NSInteger)index;

@end


@interface CCGridView : UIScrollView
{
    struct {
        unsigned int willSelectCell:1;
        unsigned int didSelectCell:1;
    } _gridViewDelegateRespondsTo;
    
    struct {
        unsigned int numberOfItems:1;
    } _gridViewDataSourceRespondsTo;
}

@property (nonatomic, assign) CCGridViewLayoutType layoutType;

@property (nonatomic, assign) IBOutlet id<CCGridViewDelegate> delegate;
@property (nonatomic, assign) IBOutlet id<CCGridViewDataSource> dataSource;

/** Determines the size of every cells passed into the gridView. Default value is kCCGridViewDefaultCellSize */
@property (nonatomic, assign) CGSize cellSize;
@property (nonatomic) NSInteger cellSpacing;                          // Default is 10
@property (nonatomic) BOOL centerGrid;                                // Default is YES
@property (nonatomic) UIEdgeInsets minEdgeInsets;                     // Default is (5, 5, 5, 5)

@property (nonatomic, readonly) NSArray *visibleCells;
@property (nonatomic, readonly) NSArray *indexesForVisibleCells;

- (id)initWithLayoutType:(CCGridViewLayoutType)layoutType;

/** Reloading the GridView */
- (void)reloadData;
- (void)reloadCellAtIndex:(NSInteger)index withCellAnimation:(CCGridViewCellAnimation)cellAnimation;
- (void)reloadCellsAtIndexes:(NSArray *)indexes withCellAnimation:(CCGridViewCellAnimation)cellAnimation;

/** Requesting cells */
- (CCGridViewCell *)dequeueReusableCellWithIdentifier:(NSString *)identifier;
- (CCGridViewCell *)visibleCellAtIndex:(NSInteger)index; // returns nil if cell is not visible.
- (NSArray *)visibleCellsAtIndexes:(NSArray *)indexes;

/** scroll */
- (void)scrollToItemAtIndex:(NSInteger)index
                   animated:(BOOL)animated
             scrollPosition:(CCGridViewScrollPosition)scrollPosition;


//@property (nonatomic, assign) BOOL allowsMultipleSelections;
//
///** Returns the indexPath for the selected cell.
// * @discussion If the gridView is allowed to perform multiple selections, the latest selected indexPath is returned.
// */
//- (NSIndexPath *)indexPathForSelectedCell;
//
///** Returns the indexPaths for selected cells. */
//- (NSArray *)indexPathsForSelectedCells;
//
//- (CGRect)rectForItemAtIndexPath:(NSIndexPath *)indexPath;


@end
