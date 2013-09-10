//
//  CCGridViewLayout.m
//  Edu901
//
//  Created by ddrccw on 13-9-5.
//  Copyright (c) 2013年 admin. All rights reserved.
//

#import "CCGridViewLayout.h"

@interface CCGridViewLayout()
@property (nonatomic) CCGridViewLayoutType type;
@property (nonatomic) CGSize cellSize;
@property (nonatomic) NSInteger cellSpacing;
@property (nonatomic) UIEdgeInsets minEdgeInsets;
@property (nonatomic) BOOL centeredGrid;

@property (nonatomic) NSInteger itemCount;
@property (nonatomic) UIEdgeInsets edgeInsets;
@property (nonatomic) CGRect gridBounds;
@property (nonatomic) CGSize contentSize;

@end

@implementation CCGridViewLayout

- (void)setUpWithLayoutType:(CCGridViewLayoutType)type
                   cellSize:(CGSize)cellSize
              cellSpacing:(NSInteger)cellSpacing
            minEdgeInsets:(UIEdgeInsets)minEdgeInsets
             centeredGrid:(BOOL)centeredGrid
{
    self.type = type;
    self.cellSize = cellSize;
    self.cellSpacing = cellSpacing;
    self.minEdgeInsets = minEdgeInsets;
    self.centeredGrid = centeredGrid;
}

- (void)rebaseWithItemCount:(NSInteger)itemCount inFrame:(CGRect)frame {
    if (CGRectEqualToRect(self.gridBounds, frame)) return;
    
    CGSize boundsSize = frame.size;
    CGSize actualContentSize = frame.size;
    
    self.itemCount = itemCount;
    CGRect actualBounds = CGRectMake(0,
                                     0,
                                     boundsSize.width  - self.minEdgeInsets.right - self.minEdgeInsets.left,
                                     boundsSize.height - self.minEdgeInsets.top   - self.minEdgeInsets.bottom);
    
    if (CCGridViewLayoutTypeVertical == self.type) {
        int numberOfItemsPerRow = [self numberOfCellsPerLineInContentSize:actualBounds.size];
        NSInteger numberOfRows = ceil(self.itemCount / (1.0 * numberOfItemsPerRow));
        actualContentSize = CGSizeMake(ceil(MIN(self.itemCount, numberOfItemsPerRow) * (self.cellSize.width + self.cellSpacing)) + self.cellSpacing,
                                       ceil(numberOfRows * (self.cellSize.height + self.cellSpacing)) + self.cellSpacing);
        
    }
    else if (CCGridViewLayoutTypeHorizontal == self.type) {
        int numberOfItemsPerColumn = [self numberOfCellsPerLineInContentSize:actualBounds.size];
        NSInteger numberOfColumns = ceil(self.itemCount / (1.0 * numberOfItemsPerColumn));
        actualContentSize = CGSizeMake(ceil(numberOfColumns * (self.cellSize.width + self.cellSpacing)) + self.cellSpacing,
                                       ceil(MIN(self.itemCount, numberOfItemsPerColumn) * (self.cellSize.height + self.cellSpacing)) + self.cellSpacing);
        
    }
    
    if (self.centeredGrid)
    {
        NSInteger widthSpace, heightSpace;
        NSInteger top, left, bottom, right;
        
        widthSpace  = floor((boundsSize.width  - actualContentSize.width)  / 2.0);
        heightSpace = floor((boundsSize.height - actualContentSize.height) / 2.0);
        
        left   = MAX(widthSpace,  self.minEdgeInsets.left);
        right  = MAX(widthSpace,  self.minEdgeInsets.right);
        top    = MAX(heightSpace, self.minEdgeInsets.top);
        bottom = MAX(heightSpace, self.minEdgeInsets.bottom);
        
        _edgeInsets = UIEdgeInsetsMake(top, left, bottom, right);
    }
    else
    {
        _edgeInsets = self.minEdgeInsets;
    }
    
    _contentSize = CGSizeMake(actualContentSize.width  + self.edgeInsets.left + self.edgeInsets.right,
                              actualContentSize.height + self.edgeInsets.top  + self.edgeInsets.bottom);
    self.contentFrame = CGRectMake(self.edgeInsets.left, self.edgeInsets.top,
                                   self.contentSize.width, self.contentSize.height);
    self.gridBounds = frame;
}

- (NSInteger)numberOfCellsPerLine {
    return [self numberOfCellsPerLineInContentSize:self.contentSize];
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark - private -

- (NSInteger)numberOfCellsPerLineInContentSize:(CGSize)contentSize {
    int numberOfCellsPerLine = 0;
    if (CCGridViewLayoutTypeVertical == self.type) {
        numberOfCellsPerLine = floorf((contentSize.width - self.cellSpacing) / (self.cellSize.width + self.cellSpacing));
    }
    else {
        numberOfCellsPerLine = floorf((contentSize.height - self.cellSpacing) / (self.cellSize.height + self.cellSpacing));
    }
    
    return numberOfCellsPerLine;
}
@end
































