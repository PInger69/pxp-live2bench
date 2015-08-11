//
//  PxpPlayerViewController.m
//  Live2BenchNative
//
//  Created by Nico Cvitak on 2015-08-07.
//  Copyright © 2015 DEV. All rights reserved.
//

#import "PxpPlayerViewController.h"
#import "PxpPlayerControlBar.h"

@interface PxpPlayerViewController ()

@end

@implementation PxpPlayerViewController
{
    IBOutlet UIView * __nonnull _playerContainer;
    IBOutlet PxpPlayerControlBar * __nonnull _controlBar;
    
    void * _playerObserverContext;
}

- (nonnull instancetype)initWithPlayerViewClass:(nullable Class)playerViewClass {
    self = [super initWithNibName:@"PxpPlayerViewController" bundle:nil];
    if (self) {
        _playerView = [playerViewClass isSubclassOfClass:[PxpPlayerView class]] ? [[playerViewClass alloc] init] : [[PXP_PLAYER_VIEW_DEFAULT_CLASS alloc] init];
        _telestrationViewController = [[PxpTelestrationViewController alloc] init];
        
        _fullscreenGestureRecognizer = [[PxpFullscreenGestureRecognizer alloc] init];
        
        _playerObserverContext = &_playerObserverContext;
        
        [_playerView addObserver:self forKeyPath:@"player" options:0 context:_playerObserverContext];
    }
    return self;
}

- (nonnull instancetype)init {
    return [self initWithPlayerViewClass:nil];
}

- (void)dealloc {
    [_playerView removeObserver:self forKeyPath:@"player" context:_playerObserverContext];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    _playerView.frame = _playerContainer.bounds;
    _telestrationViewController.view.frame = _playerContainer.bounds;
    
    _playerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _telestrationViewController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    [_playerContainer addSubview:_playerView];
    [_playerContainer addSubview:_telestrationViewController.view];
    
    _controlBar.player = _playerView.player;
    
    [_playerView addGestureRecognizer:_fullscreenGestureRecognizer];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)observeValueForKeyPath:(nullable NSString *)keyPath ofObject:(nullable id)object change:(nullable NSDictionary *)change context:(nullable void *)context {
    if (context == _playerObserverContext) {
        _controlBar.player = _playerView.player;
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
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
