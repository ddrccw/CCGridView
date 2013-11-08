//
//  ViewController.m
//  grid
//
//  Created by ddrccw on 13-9-10.
//  Copyright (c) 2013年 user. All rights reserved.
//

#import "ViewController.h"
#import "CCGridView.h"

static const int kGridCellCount = 50;

@interface ViewController () <CCGridViewDataSource, CCGridViewDelegate>
{
    BOOL reloaded_;
}
@property (nonatomic, retain) CCGridView *grid;
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)]) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    _grid = [[CCGridView alloc] initWithLayoutType:CCGridViewLayoutTypeHorizontal];
    self.grid.frame = self.view.bounds;
    self.grid.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.grid.dataSource = self;
    self.grid.delegate = self;
    self.grid.backgroundColor = [UIColor lightGrayColor];
    self.grid.cellSize = CGSizeMake(200, 300);
    [self.view addSubview:self.grid];
    [self.grid reloadData];
    
    
    UIBarButtonItem *reloadSectionButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
                                                                                             target:self
                                                                                             action:@selector(reload)];
    UIBarButtonItem *scrollSectionButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction
                                                                                             target:self
                                                                                             action:@selector(randomScroll)];

    [[self navigationItem] setRightBarButtonItems:@[reloadSectionButtonItem, scrollSectionButtonItem]
                                         animated:YES];
    [reloadSectionButtonItem release];
    [scrollSectionButtonItem release];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return YES;
}

- (BOOL)shouldAutorotate {
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskAll;
}


- (void)reload {
    reloaded_ = !reloaded_;
//    [self.grid reloadData];
    
    srand((unsigned)time(NULL));
    int anime = rand() % (CCGridViewCellAnimationNone + 1);
    NSLog(@"reloadCellsAtIndexes anime=%d", anime);

    [self.grid reloadCellsAtIndexes:@[@1, @2, @3, @4] withCellAnimation:anime];
}

- (void)randomScroll {
    srand((unsigned)time(NULL));
    int index = rand() % kGridCellCount;
    int positon = rand() % (CCGridViewScrollPositionAtBottom + 1);
    NSLog(@"scrollToCellIndex=%d, position=%d", index, positon);
    
    [self.grid scrollToItemAtIndex:index animated:YES scrollPosition:positon];

}

- (NSInteger)numberOfItemsInGridView:(CCGridView *)gridView {
    return kGridCellCount;
}

- (CCGridViewCell *)gridView:(CCGridView *)gridView cellForItemAtIndex:(NSInteger)index {
    static NSString *MyCellIdentifier = @"MyCellIdentifier";
    
    CCGridViewCell* cell = [gridView dequeueReusableCellWithIdentifier:MyCellIdentifier];
    UILabel *lb = nil;
    if(cell == nil){
        cell = [[[CCGridViewCell alloc] initWithReuseIdentifier:MyCellIdentifier] autorelease];
        cell.backgroundColor = [UIColor redColor];
        lb = [[UILabel alloc] initWithFrame:cell.bounds];
        lb.textColor = [UIColor blackColor];
        lb.backgroundColor = [UIColor clearColor];
        lb.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        lb.tag = 100;
        [cell.contentView addSubview:lb];
        cell.contentView.backgroundColor = [UIColor yellowColor];
        [lb release];
    }
   
    lb = (UILabel *)[cell viewWithTag:100];
    if (reloaded_) {
        lb.text = [NSString stringWithFormat:@"reloaded cell index=%d", index];
    }
    else {
        lb.text = [NSString stringWithFormat:@"cell index=%d", index];
    }
    
    return cell;
}

- (void)gridView:(CCGridView *)gridView didSelectCellAtIndex:(NSInteger)index {
    NSLog(@"didselectCell=%d", index);
//    NSLog(@"visibleCells=%@, visibleIndexes=%@", self.grid.visibleCells, self.grid.indexesForVisibleCells);
//    NSLog(@"visibleCellsAtIndexes=%@", [gridView visibleCellsAtIndexes:self.grid.indexesForVisibleCells]);
    srand((unsigned)time(NULL));
    int anime = rand() % (CCGridViewCellAnimationNone + 1);
    NSLog(@"reloadCellAtIndex anime=%d", anime);
    [gridView reloadCellAtIndex:index withCellAnimation:anime];
}


@end
