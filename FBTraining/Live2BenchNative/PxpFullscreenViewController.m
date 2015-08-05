//
//  PxpFullscreenViewController.m
//  Live2BenchNative
//
//  Created by Nico Cvitak on 2015-08-04.
//  Copyright © 2015 DEV. All rights reserved.
//

#import "PxpFullscreenViewController.h"
#import "NCTriPinchGestureRecognizer.h"

@interface PxpFullscreenViewController ()

@end

@implementation PxpFullscreenViewController
{
    IBOutlet UIView * __nonnull _contentView;
    IBOutlet UIView * __nonnull _playerContainer;
    IBOutlet UIView * __nonnull _topBar;
    IBOutlet UIView * __nonnull _bottomBar;
    
    IBOutlet SeekButton * __nonnull _backwardSeekButton;
    IBOutlet SeekButton * __nonnull _forwardSeekButton;
    
    IBOutlet Slomo * __nonnull _slomoButton;
    IBOutlet PxpFullscreenButton * __nonnull _fullscreenButton;
    
    void * _playRateObserverContext;
}

@synthesize contentView = _contentView;
@synthesize topBar = _topBar;
@synthesize bottomBar = _bottomBar;

@synthesize backwardSeekButton = _backwardSeekButton;
@synthesize forwardSeekButton = _forwardSeekButton;

@synthesize slomoButton = _slomoButton;
@synthesize fullscreenButton = _fullscreenButton;

- (nonnull instancetype)initWithNibName:(nullable NSString *)nibNameOrNil bundle:(nullable NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _playerViewController = [[PxpPlayerMultiViewController alloc] init];
        
        _playRateObserverContext = &_playRateObserverContext;
        
        [_playerViewController.multiView addObserver:self forKeyPath:@"context.mainPlayer.playRate"options:0 context:_playRateObserverContext];
    }
    return self;
}

- (void)dealloc {
    [_playerViewController.multiView removeObserver:self forKeyPath:@"context.mainPlayer.playRate"];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    _playerViewController.view.frame = _playerContainer.bounds;
    _playerViewController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [_playerContainer addSubview:_playerViewController.view];
    
    NCTriPinchGestureRecognizer *dismissFullscreedGestureRecognizer = [[NCTriPinchGestureRecognizer alloc] initWithTarget:self action:@selector(dismissFullscreenGestureRecognized:)];
    
    [self.view addGestureRecognizer:dismissFullscreedGestureRecognizer];
    
    self.hidden = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)observeValueForKeyPath:(nullable NSString *)keyPath ofObject:(nullable id)object change:(nullable NSDictionary *)change context:(nullable void *)context {
    if (context == _playRateObserverContext) {
        self.slomoButton.slomoOn = _playerViewController.multiView.context.mainPlayer.playRate == 0.5;
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

#pragma mark - Getters / Setters

- (void)setHidden:(BOOL)hidden {
    [self setHidden:hidden animated:NO];
}

- (BOOL)hidden {
    return self.view.hidden;
}

#pragma mark - Actions

- (IBAction)backwardSeekAction:(SeekButton *)sender {
    [_playerViewController.multiView.player seekBy:CMTimeMakeWithSeconds(sender.speed, 600)];
}

- (IBAction)forwardSeekAction:(SeekButton *)sender {
    [_playerViewController.multiView.player seekBy:CMTimeMakeWithSeconds(sender.speed, 600)];
}

- (IBAction)slomoButtonAction:(Slomo *)sender {
    sender.slomoOn = !sender.slomoOn;
    _playerViewController.multiView.context.mainPlayer.playRate = sender.slomoOn ? 0.5 : 1.0;
}

- (IBAction)fullscreenButtonAction:(PxpFullscreenButton *)sender {
    [self setHidden:YES animated:YES frame:_targetFrame];
}

#pragma mark - Gesture Recognizers

- (void)dismissFullscreenGestureRecognized:(NCTriPinchGestureRecognizer *)recognizer {
    
    NSLog(@"s: %f, v: %f", recognizer.scale, recognizer.velocity);
    
    if (recognizer.velocity < -100.0) {
        [self setHidden:YES animated:YES frame:_targetFrame];
    }
}

#pragma mark - Public Methods

- (void)setHidden:(BOOL)hidden animated:(BOOL)animated frame:(CGRect)frame {
    if (self.view.hidden != hidden) {
        
        if (hidden) {
            self.bottomBar.hidden = YES;
            self.topBar.hidden = YES;
            self.forwardSeekButton.hidden = YES;
            self.backwardSeekButton.hidden = YES;
        } else  {
            self.view.frame = frame;
            self.view.hidden = NO;
            [self.view.superview bringSubviewToFront:self.view];
        }
        
        [self.view layoutIfNeeded];
        
        [UIView animateWithDuration:animated ? 0.2 : 0.0 animations:^() {
            if (hidden) {
                self.view.frame = frame;
            } else {
                self.view.frame = self.view.superview.bounds;
            }
            
            [self.view layoutIfNeeded];
        } completion:^(BOOL finished) {
            if (hidden) {
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

- (void)setHidden:(BOOL)hidden animated:(BOOL)animated {
    [self setHidden:hidden animated:animated frame:_targetFrame];
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
