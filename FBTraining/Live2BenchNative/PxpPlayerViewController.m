//
//  PxpPlayerViewController.m
//  Live2BenchNative
//
//  Created by Nico Cvitak on 2015-08-07.
//  Copyright © 2015 DEV. All rights reserved.
//

#import "PxpPlayerViewController.h"
#import "PxpPlayerControlBar.h"

@interface PxpPlayerViewController () <PxpPlayerViewDelegate>

@end

@implementation PxpPlayerViewController
{
    IBOutlet UIView * __nonnull _playerContainer;
    IBOutlet PxpPlayerControlBar * __nonnull _controlBar;
    
    void * _playerObserverContext;
    void * _playerRangeObserverContext;
    void * _playerRateObserverContext;
    void * _telestrationObserverContext;
    
    BOOL * _stillFlag;
}

- (nonnull instancetype)initWithPlayerViewClass:(nullable Class)playerViewClass {
    self = [super initWithNibName:@"PxpPlayerViewController" bundle:nil];
    if (self) {
        _enabled = YES;
        
        _playerView = [playerViewClass isSubclassOfClass:[PxpPlayerView class]] ? [[playerViewClass alloc] init] : [[PXP_PLAYER_VIEW_DEFAULT_CLASS alloc] init];
        _playerView.delegate = self;
        
        _telestrationViewController = [[PxpTelestrationViewController alloc] init];
        _telestrationViewController.timeProvider = self;
        
        _fullscreenGestureRecognizer = [[PxpFullscreenGestureRecognizer alloc] init];
        
        _playerObserverContext = &_playerObserverContext;
        _playerRangeObserverContext = &_playerRangeObserverContext;
        _playerRateObserverContext = &_playerRateObserverContext;
        _telestrationObserverContext = &_telestrationObserverContext;
        
        _stillFlag = NO;
        
        [_playerView addObserver:self forKeyPath:@"player" options:0 context:_playerObserverContext];
        [_playerView addObserver:self forKeyPath:@"player.range" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:_playerRangeObserverContext];
        [_playerView addObserver:self forKeyPath:@"player.rate" options:0 context:_playerRateObserverContext];
        [_telestrationViewController addObserver:self forKeyPath:@"telestration" options:0 context:_telestrationObserverContext];
    }
    return self;
}

- (nonnull instancetype)init {
    return [self initWithPlayerViewClass:nil];
}

- (void)dealloc {
    [_playerView removeObserver:self forKeyPath:@"player" context:_playerObserverContext];
    [_playerView removeObserver:self forKeyPath:@"player.range" context:_playerRangeObserverContext];
    [_playerView removeObserver:self forKeyPath:@"player.rate" context:_playerRateObserverContext];
    [_telestrationViewController removeObserver:self forKeyPath:@"telestration" context:_telestrationObserverContext];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    _playerView.frame = _playerContainer.bounds;
    _telestrationViewController.view.frame = _playerContainer.bounds;
    
    [_playerContainer addSubview:_playerView];
    [_playerContainer addSubview:_telestrationViewController.view];
    
    _controlBar.player = _playerView.player;
    
    [_playerView addGestureRecognizer:_fullscreenGestureRecognizer];
    
    [self addChildViewController:_telestrationViewController];
    
    self.view.clipsToBounds = YES;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [_playerView.player reload];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    _playerView.frame = _playerContainer.bounds;
    _telestrationViewController.view.frame = _playerContainer.bounds;
}

- (void)observeValueForKeyPath:(nullable NSString *)keyPath ofObject:(nullable id)object change:(nullable NSDictionary *)change context:(nullable void *)context {
    if (context == _playerObserverContext) {
        _controlBar.player = _playerView.player;
    } else if (context == _playerRangeObserverContext) {
        NSValue *oldValue = change[NSKeyValueChangeOldKey], *newValue = change[NSKeyValueChangeNewKey];
        
        CMTimeRange oldRange = ![oldValue isEqual: [NSNull null]] ? [oldValue CMTimeRangeValue] : kCMTimeRangeInvalid;
        CMTimeRange newRange = ![newValue isEqual: [NSNull null]] ? [newValue CMTimeRangeValue] : kCMTimeRangeInvalid;
        
        if (CMTIMERANGE_IS_INVALID(newRange) && !CMTimeRangeEqual(oldRange, newRange) && !_telestrationViewController.telestrating) {
            _telestrationViewController.telestration = nil;
        }
        
    } else if (context == _playerRateObserverContext) {
        if (_telestrationViewController.telestration.isStill && _playerView.player.rate) {
            _telestrationViewController.telestration = nil;
        }
    } else if (context == _telestrationObserverContext) {
        _playerView.lockFullView = _telestrationViewController.telestration;
        
        if (_telestrationViewController.telestration.isStill && _playerView.player.rate) {
            _stillFlag = YES;
            [_playerView.player pause];
        } else if (_stillFlag) {
            [_playerView.player play];
            _stillFlag = NO;
        }
        
        if (_telestrationViewController.telestrating) {
            _playerView.player.range = kCMTimeRangeInvalid;
        }
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

#pragma mark - Getters / Setters

- (void)setEnabled:(BOOL)enabled {
    _enabled = enabled;
    
    if (!enabled) {
        _telestrationViewController.telestration = nil;
    }
    
    _telestrationViewController.view.hidden = !_playerView.fullView || !_enabled;
    _controlBar.enabled = enabled;
}

#pragma mark - PxpPlayerViewDelegate

- (void)playerView:(nonnull PxpPlayerView *)playerView changedFullViewStatus:(BOOL)fullView {
    _telestrationViewController.view.hidden = !fullView || !_enabled;
}

#pragma mark - PxpTimeProvider

- (NSTimeInterval)currentTimeInSeconds {
    return _playerView.player.currentTimeInSeconds;
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
