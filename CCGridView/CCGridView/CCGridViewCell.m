//
//  CCGridViewCell.m
//  Edu901
//
//  Created by ddrccw on 13-9-5.
//  Copyright (c) 2013年 admin. All rights reserved.
//

#import "CCGridViewCell.h"

@interface CCGridViewCell ()
@property (nonatomic, copy) NSString *reuseIdentifier;
@property (nonatomic, retain) UIView *contentView;
@end

@implementation CCGridViewCell

- (void)dealloc {
    [_reuseIdentifier release];
    [_contentView release];
    [super dealloc];
}

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithFrame:CGRectZero];
    if(self)
    {
        NSAssert(reuseIdentifier != nil,
                 @"%@: reusableIdentifier cannot be nil",
                 NSStringFromClass([self class]));
        
        [self commonInit];
        _reuseIdentifier = [reuseIdentifier copy];
    }
    return self;
}


- (void)commonInit
{
    _contentView = [[UIView alloc] initWithFrame:CGRectZero];
    [_contentView setBackgroundColor:[UIColor clearColor]];
    _contentView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin |
                                    UIViewAutoresizingFlexibleRightMargin |
                                    UIViewAutoresizingFlexibleBottomMargin |
                                    UIViewAutoresizingFlexibleLeftMargin |
                                    UIViewAutoresizingFlexibleWidth |
                                    UIViewAutoresizingFlexibleHeight;
    [self addSubview:_contentView];
}

- (void)layoutSubviews {
    _contentView.frame = self.bounds;
}

@end






























