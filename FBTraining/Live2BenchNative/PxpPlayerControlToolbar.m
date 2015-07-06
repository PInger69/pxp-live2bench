//
//  PxpPlayerControlToolbar.m
//  PxpPlayer
//
//  Created by Nico Cvitak on 2015-06-09.
//  Copyright © 2015 Nicholas Cvitak. All rights reserved.
//

#import "PxpPlayerControlToolbar.h"

@interface PxpPlayerControlToolbar ()

@property (strong, nonatomic, nullable) NSMutableArray *toolbarItems;

@end

@implementation PxpPlayerControlToolbar

- (void)initCommon {
    _toolbarItems = [NSMutableArray arrayWithArray:@[[[UIBarButtonItem alloc] init],
                                                     [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                                                     [[UIBarButtonItem alloc] init]
                                                     ]];
    
    self.items = _toolbarItems;
}

- (nonnull instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initCommon];
    }
    return self;
}

- (instancetype)initWithCoder:(nonnull NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initCommon];
    }
    return self;
}

- (void)setLeftBarButtonItem:(nonnull UIBarButtonItem *)leftBarButtonItem {
    self.toolbarItems[0] = leftBarButtonItem;
    [self setItems:self.toolbarItems animated:YES];
}

- (nonnull UIBarButtonItem *)leftBarButtonItem {
    return self.toolbarItems[0];
}

- (void)setRightBarButtonItem:(nonnull UIBarButtonItem *)rightBarButtonItem {
    self.toolbarItems[self.items.count - 1] = rightBarButtonItem;
    [self setItems:self.toolbarItems animated:YES];
}

- (nonnull UIBarButtonItem *)rightBarButtonItem {
    return self.toolbarItems[self.items.count - 1];
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    
    // Do Nothing, Transparent
}
 


@end
