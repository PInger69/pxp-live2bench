//
//  PxpFullscreenViewController.m
//  Live2BenchNative
//
//  Created by Nico Cvitak on 2015-08-04.
//  Copyright © 2015 DEV. All rights reserved.
//

#import "PxpFullscreenViewController.h"
#import "NCTriPinchGestureRecognizer.h"

#import "LocalMediaManager.h"

@interface PxpFullscreenViewController ()

@end

@implementation PxpFullscreenViewController
{
    UIView * __nonnull _playerContainer;
    
    UIView * __nullable _targetView;
    NSUInteger _targetIndex;
    CGRect _targetFrame;
    
    void * _playRateObserverContext;
}

- (nonnull instancetype)initWithPlayerViewController:(nonnull PxpPlayerViewController *)playerViewController {
    self = [super init];
    if (self) {
        _contentView = [[UIView alloc] init];
        _playerContainer = [[UIView alloc] init];
        _topBar = [[UIView alloc] init];
        _bottomBar = [[UIView alloc] init];
        
        _backwardSeekButton = [[SeekButton alloc] initWithBackward:YES];
        _forwardSeekButton = [[SeekButton alloc] initWithBackward:NO];
        
        _slomoButton = [[Slomo alloc] init];
        _fullscreenButton = [[PxpFullscreenButton alloc] init];
        _fullscreenButton.isFullscreen = YES;
        
        _playRateObserverContext = &_playRateObserverContext;
        
        self.playerViewController = playerViewController;
    }
    return self;
}

- (void)dealloc {
    [_playerViewController.playerView removeObserver:self forKeyPath:@"player.playRate"];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self.view addSubview:_contentView];
    [_contentView addSubview:_playerContainer];
    [_contentView addSubview:_topBar];
    [_contentView addSubview:_bottomBar];
    [_contentView addSubview:_backwardSeekButton];
    [_contentView addSubview:_forwardSeekButton];
    
    [_bottomBar addSubview:_slomoButton];
    [_bottomBar addSubview:_fullscreenButton];
    
    [_backwardSeekButton addTarget:self action:@selector(backwardSeekAction:) forControlEvents:UIControlEventTouchUpInside];
    [_forwardSeekButton addTarget:self action:@selector(forwardSeekAction:) forControlEvents:UIControlEventTouchUpInside];
    [_slomoButton addTarget:self action:@selector(slomoButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [_fullscreenButton addTarget:self action:@selector(fullscreenResponseHandler:) forControlEvents:UIControlEventTouchUpInside];
    
    self.view.backgroundColor = [UIColor blackColor];
    _playerContainer.backgroundColor = [UIColor darkGrayColor];
    
    [_playerViewController.fullscreenGestureRecognizer addTarget:self action:@selector(fullscreenResponseHandler:)];
    
    self.fullscreen = NO;
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    // contentView
    
    _contentView.frame = CGRectMake(0.0, 55.0, self.view.bounds.size.width, self.view.bounds.size.height - 55.0);
    
    const CGFloat contentWidth = _contentView.bounds.size.width, contentHeight = _contentView.bounds.size.height;
    
    // player
    const CGFloat playerWidth = contentWidth, playerHeight = playerWidth / (16.0 / 9.0);
    const CGFloat playerX = 0.0, playerY = (contentHeight - playerHeight) / 2.0;
    
    _playerContainer.frame = CGRectMake(playerX, playerY, playerWidth, playerHeight);
    _topBar.frame = CGRectMake(0.0, 0.0, playerWidth, playerY);
    _bottomBar.frame = CGRectMake(0.0, playerY + playerHeight, playerWidth, playerY);
    
    if ([_playerViewController.view isDescendantOfView:_playerContainer]) {
        _playerViewController.view.frame = _playerContainer.bounds;
    }
    
    // button size
    const CGFloat buttonHeight = contentHeight - playerY - playerHeight;
    
    // seek buttons
    const CGFloat seekButtonY = playerY + playerHeight;
    
    _backwardSeekButton.frame = CGRectMake(1.5 * buttonHeight, seekButtonY, buttonHeight, buttonHeight);
    _forwardSeekButton.frame = CGRectMake(contentWidth - buttonHeight - 1.5 * buttonHeight, seekButtonY, buttonHeight, buttonHeight);
    
    // bottom bar buttons
    const CGFloat margin = 8.0;
    
    _slomoButton.frame = CGRectMake(2.5 * buttonHeight + margin, margin, 1.5 * buttonHeight - 2.0 * margin, buttonHeight - 2.0 * margin);
    _fullscreenButton.frame = CGRectMake(contentWidth - buttonHeight - 2.75 * buttonHeight + margin, margin, buttonHeight - 2.0 * margin, buttonHeight - 2.0 * margin);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)observeValueForKeyPath:(nullable NSString *)keyPath ofObject:(nullable id)object change:(nullable NSDictionary *)change context:(nullable void *)context {
    if (context == _playRateObserverContext) {
        self.slomoButton.slomoOn = _playerViewController.playerView.player.playRate == 0.5;
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

#pragma mark - Getters / Setters

- (void)setFullscreen:(BOOL)fullscreen {
    [self setFullscreen:fullscreen animated:NO];
}

- (BOOL)hidden {
    return self.view.hidden;
}

- (void)setPlayerViewController:(nonnull PxpPlayerViewController *)playerViewController {
    [_playerViewController.playerView removeObserver:self forKeyPath:@"player.playRate" context:_playRateObserverContext];
    
    _playerViewController = playerViewController;
    
    [_playerViewController.playerView addObserver:self forKeyPath:@"player.playRate"options:0 context:_playRateObserverContext];
}

#pragma mark - Actions

- (void)backwardSeekAction:(SeekButton *)sender {
    [_playerViewController.playerView.player seekBy:CMTimeMakeWithSeconds(sender.speed, 600)];
}

- (void)forwardSeekAction:(SeekButton *)sender {
    [_playerViewController.playerView.player seekBy:CMTimeMakeWithSeconds(sender.speed, 600)];
}

- (void)slomoButtonAction:(Slomo *)sender {
    sender.slomoOn = !sender.slomoOn;
    _playerViewController.playerView.player.playRate = sender.slomoOn ? 0.5 : 1.0;
}

- (void)fullscreenButtonAction:(PxpFullscreenButton *)sender {
    [self setFullscreen:NO animated:YES];
}

#pragma mark - Public Methods

- (void)setFullscreen:(BOOL)fullscreen animated:(BOOL)animated {
    if (self.view.hidden == fullscreen) {
        
        if (!fullscreen) {
            self.bottomBar.hidden = YES;
            self.topBar.hidden = YES;
            self.forwardSeekButton.hidden = YES;
            self.backwardSeekButton.hidden = YES;
        } else  {
            _targetView = _playerViewController.view.superview;
            _targetIndex = [_targetView.subviews indexOfObject:_playerViewController.view];
            _targetFrame = _playerViewController.view.frame;
            
            [_playerViewController.view removeFromSuperview];
            
            self.view.frame = _targetFrame;
            
            _playerViewController.view.frame = _playerContainer.bounds;
            [_playerContainer addSubview:_playerViewController.view];
            
            self.view.hidden = NO;
        }
        
        [self.view layoutIfNeeded];
        
        [UIView animateWithDuration:animated ? 0.2 : 0.0 animations:^() {
            if (!fullscreen) {
                self.view.frame = _targetFrame;
            } else {
                self.view.frame = self.view.superview.bounds;
            }
            
            [self.view layoutIfNeeded];
        } completion:^(BOOL finished) {
            if (!fullscreen) {
                if ([_playerViewController.view isDescendantOfView:_playerContainer]) {
                    [_playerViewController.view removeFromSuperview];
                    _playerViewController.view.frame = _targetFrame;
                    [_targetView insertSubview:_playerViewController.view atIndex:_targetIndex];
                }
                
                self.view.hidden = YES;
            } else {
                self.bottomBar.hidden = NO;
                self.topBar.hidden = NO;
                self.forwardSeekButton.hidden = NO;
                self.backwardSeekButton.hidden = NO;
            }
        }];
        
    }
}

- (void)fullscreenResponseHandler:(nullable id<PxpFullscreenResponder>)sender {
    if ([sender conformsToProtocol:@protocol(PxpFullscreenResponder)]) {
        if (sender.fullscreenResponse == PxpFullscreenResponseLeave) {
            [self setFullscreen:NO animated:YES];
        } else if (sender.fullscreenResponse == PxpFullscreenResponseEnter) {
            [self setFullscreen:YES animated:YES];
        }
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
