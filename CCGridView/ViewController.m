//
//  ViewController.m
//  grid
//
//  Created by ddrccw on 13-9-10.
//  Copyright (c) 2013年 user. All rights reserved.
//

#import "ViewController.h"
#import "CCGridView.h"

@interface ViewController () <CCGridViewDataSource>
@property (nonatomic, retain) CCGridView *grid;
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    _grid = [[CCGridView alloc] initWithLayoutType:CCGridViewLayoutTypeVertical];
    self.grid.frame = self.view.bounds;
    self.grid.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.grid.dataSource = self;;
    self.grid.backgroundColor = [UIColor lightGrayColor];
    self.grid.cellSize = CGSizeMake(200, 300);
    self.grid.centerGrid = YES;
    [self.view addSubview:self.grid];
    [self.grid reloadData];
}

- (NSInteger)numberOfItemsInGridView:(CCGridView *)gridView {
    return 110;
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
        [cell addSubview:lb];
        [lb release];
    }
   
    lb = (UILabel *)[cell viewWithTag:100];
    lb.text = [NSString stringWithFormat:@"cell index=%d", index];
    
    return cell;
 
}
@end
