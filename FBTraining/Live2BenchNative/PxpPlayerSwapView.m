//
//  PxpPlayerPipView.m
//  PxpPlayer
//
//  Created by Nico Cvitak on 2015-06-26.
//  Copyright © 2015 Nicholas Cvitak. All rights reserved.
//

#import "PxpPlayerSwapView.h"

#define ROW_HEIGHT 44.0
#define ROW_WIDTH ROW_HEIGHT * (16.0 / 9.0) * 2.0

@interface PxpPlayerSwapView () <UITableViewDataSource, UITableViewDelegate>

@property (assign, nonatomic) NSUInteger playerContextIndex;

@property (strong, nonatomic, nonnull) UITableViewController *tableViewController;
@property (strong, nonatomic, nonnull) UIPopoverController *popoverController;

@end

@implementation PxpPlayerSwapView

- (void)initSwapView {
    
    _tapToAdvanceEnabled = YES;
    _playerContextIndex = NSNotFound;
    
    _tableViewController = [[UITableViewController alloc] init];
    _tableViewController.tableView.dataSource = self;
    _tableViewController.tableView.delegate = self;
    
    //_tableViewController.tableView.backgroundView = view;
    
    [_tableViewController.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"UITableViewCell"];
    
    _popoverController = [[UIPopoverController alloc] initWithContentViewController:_tableViewController];
    
    CALayer *layer = _popoverController.contentViewController.view.superview.superview.layer;
    
    layer.shadowColor = [UIColor greenColor].CGColor;
    layer.shadowOffset = CGSizeZero;
    layer.shadowOpacity = 1.0;
    layer.shadowRadius = 11.0;
    layer.masksToBounds = NO;
    
    UITapGestureRecognizer *advanceGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(advanceGestureRecognized:)];
    advanceGestureRecognizer.numberOfTouchesRequired = 1;
    
    UILongPressGestureRecognizer *listGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(listGestureRecognized:)];
    listGestureRecognizer.numberOfTouchesRequired = 1;
    
    [self addGestureRecognizer:advanceGestureRecognizer];
    [self addGestureRecognizer:listGestureRecognizer];
}

- (instancetype)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        [self initSwapView];
    }
    return self;
}

- (instancetype)initWithCoder:(nonnull NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initSwapView];
    }
    return self;
}

#pragma mark - Overrides

- (void)setPlayer:(nullable PxpPlayer *)player {
    [super setPlayer:player];
    
    self.playerContextIndex = self.player.context ? [self.player.context.players indexOfObject:self.player] : NSNotFound;
}

#pragma mark - Gesture Recognizers

- (void)advanceGestureRecognized:(UIGestureRecognizer *)recognizer {
    if (self.tapToAdvanceEnabled && recognizer.view == self) {
        [self nextPlayer];
    }
}

- (void)listGestureRecognized:(UIGestureRecognizer *)recognizer {
    self.popoverController.popoverContentSize = CGSizeMake(ROW_WIDTH, MIN(self.player.context.players.count * ROW_HEIGHT, 4 * ROW_HEIGHT));
    
    CGPoint loc = [recognizer locationInView:self];
    
    [self.popoverController presentPopoverFromRect:CGRectMake(loc.x, loc.y, 0.0, 0.0) inView:self permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
}

#pragma mark - Public Methods

- (void)nextPlayer {
    if (self.playerContextIndex != NSNotFound) {
        self.player = self.context.players[(self.playerContextIndex + 1) % self.context.players.count];
        [self.player sync];
    }
}

- (void)previousPlayer {
    if (self.playerContextIndex != NSNotFound) {
        self.player = self.context.players[(self.playerContextIndex + 1) % self.context.players.count];
        [self.player sync];
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(nonnull UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.player.context.players.count;
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell" forIndexPath:indexPath];
    PxpPlayer *player = indexPath.row < self.context.players.count ? self.context.players[indexPath.row] : nil;
    
    cell.textLabel.text = player.name;
    cell.textLabel.textAlignment = NSTextAlignmentLeft;
    cell.textLabel.adjustsFontSizeToFitWidth = YES;
    
    return cell;
}

- (void)tableView:(nonnull UITableView *)tableView didSelectRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    if (indexPath.row < self.context.players.count) {
        self.player = self.context.players[indexPath.row];
        [self.player sync];
        [self.popoverController dismissPopoverAnimated:YES];
    }
}

- (CGFloat)tableView:(nonnull UITableView *)tableView heightForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    return ROW_HEIGHT;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
