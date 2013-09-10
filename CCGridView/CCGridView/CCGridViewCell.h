//
//  CCGridViewCell.h
//  Edu901
//
//  Created by ddrccw on 13-9-5.
//  Copyright (c) 2013年 admin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CCGridViewCell : UIView
@property (nonatomic, assign) NSInteger index;
@property (nonatomic, readonly) NSString *reuseIdentifier;
@property (nonatomic, readonly) UIView *contentView;

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier;

@end
