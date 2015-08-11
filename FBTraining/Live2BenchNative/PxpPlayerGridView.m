//
//  PxpPlayerGridView.m
//  PxpPlayer
//
//  Created by Nico Cvitak on 2015-06-26.
//  Copyright © 2015 Nicholas Cvitak. All rights reserved.
//

#import "PxpPlayerGridView.h"

@interface PxpPlayerGridView () <PxpPlayerGridViewDataSource>

@property (strong, nonatomic, nonnull) NSMutableArray *playerViews;
@property (strong, nonatomic, nonnull) UIView *containerView;

@end

@implementation PxpPlayerGridView

@dynamic delegate;

- (void)initGridView {
    
    _playerViews = [NSMutableArray array];
    _containerView = [[UIView alloc] init];
    _containerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    _dataSource = self;
    
    [self addSubview:_containerView];
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initGridView];
    }
    return self;
}

- (instancetype)initWithCoder:(nonnull NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initGridView];
    }
    return self;
}

#pragma mark - Overrides

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.containerView.frame = self.bounds;
    
    [self reloadData];
}

#pragma mark - Getters / Setters

- (void)setPlayer:(nullable PxpPlayer *)player {
    [super setPlayer:player];
    
    [self reloadData];
}

- (BOOL)fullView {
    return NO;
}

#pragma mark - Public Methods

- (void)reloadData {
    
    NSUInteger rows = self.dataSource ? [self.dataSource numberOfRowsInGridView:self] : 0;
    NSUInteger columns = self.dataSource ? [self.dataSource numberOfColumnsInGridView:self] : 0;
    
    // remove unnecessary views
    while (self.playerViews.count > rows * columns) {
        PxpPlayerSingleView *playerView = self.playerViews.lastObject;
        [playerView removeFromSuperview];
        [self.playerViews removeLastObject];
        
        [self.delegate playerView:playerView didUnloadInGridView:self];
    }
    
    // add necessary views
    while (self.playerViews.count < rows * columns) {
        PxpPlayerSingleView *playerView = [[PxpPlayerSingleView alloc] init];
        [self.playerViews addObject:playerView];
        [self.containerView addSubview:playerView];

        [self.delegate playerView:playerView didLoadInGridView:self];
    }
    
    // update views
    CGFloat width = self.containerView.bounds.size.width / columns;
    CGFloat height = self.containerView.bounds.size.height / rows;
    
    for (NSUInteger r = 0; r < rows; r++) {
        for (NSUInteger c = 0; c < columns; c++) {
            
            NSUInteger i = (c * rows + r) % (rows * columns);
            
            PxpPlayerSingleView *playerView = self.playerViews[i];
            playerView.frame = CGRectMake(c * width, r * height, width, height);
            playerView.player = self.dataSource ? self.context.players[[self.dataSource contextIndexForPlayerGridView:self forRow:r column:c]] : self.context.players.firstObject;
        }
    }
}

#pragma mark - PxpPlayerGridViewDataSource

- (NSUInteger)numberOfColumnsInGridView:(nonnull PxpPlayerGridView *)gridView {
    return MAX(ceil(sqrt(self.context.players.count)), 2);
}

- (NSUInteger)numberOfRowsInGridView:(nonnull PxpPlayerGridView *)gridView {
    return ceil((CGFloat) self.context.players.count / [self numberOfColumnsInGridView:self]);
}

- (NSUInteger)contextIndexForPlayerGridView:(nonnull PxpPlayerGridView *)gridView forRow:(NSUInteger)row column:(NSUInteger)column {
    return self.context.players.count > 0 ? (column + row * [self numberOfColumnsInGridView:gridView]) % self.context.players.count : 0;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
