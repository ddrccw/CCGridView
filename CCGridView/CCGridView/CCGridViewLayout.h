//
//  CCGridViewLayout.h
//  Edu901
//
//  Created by ddrccw on 13-9-5.
//  Copyright (c) 2013年 admin. All rights reserved.
//

#import <Foundation/Foundation.h>

enum {
    CCGridViewLayoutTypeVertical,
    CCGridViewLayoutTypeHorizontal
};

typedef UInt8 CCGridViewLayoutType;

static const int kInvalidItemIndex = -1;

@interface CCGridViewLayout : NSObject
@property (nonatomic, readonly) CCGridViewLayoutType type;

@property (nonatomic, readonly) CGSize cellSize;
@property (nonatomic, readonly) NSInteger cellSpacing;
@property (nonatomic, readonly) UIEdgeInsets minEdgeInsets;
@property (nonatomic, readonly) BOOL centeredGrid;

@property (nonatomic, readonly) NSInteger itemCount;
@property (nonatomic, readonly) UIEdgeInsets edgeInsets;
@property (nonatomic, readonly) CGRect gridBounds;
@property (nonatomic, readonly) CGSize contentSize;

@property (nonatomic, assign) NSInteger section, numberOfItems;
@property (nonatomic, assign) CGRect contentFrame;

- (void)setUpWithLayoutType:(CCGridViewLayoutType)type
                   cellSize:(CGSize)cellSize
                cellSpacing:(NSInteger)cellSpacing
              minEdgeInsets:(UIEdgeInsets)minEdgeInsets
               centeredGrid:(BOOL)centeredGrid;
- (void)rebaseWithItemCount:(NSInteger)itemCount inFrame:(CGRect)frame;
- (NSInteger)itemIndexFromLocation:(CGPoint)location;
- (NSInteger)numberOfCellsPerLine;
- (CGRect)rectForCellAtIndex:(NSInteger)index;

@end
