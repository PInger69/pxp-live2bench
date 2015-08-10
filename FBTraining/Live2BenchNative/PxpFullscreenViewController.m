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
    IBOutlet UIView * __nonnull _contentView;
    IBOutlet UIView * __nonnull _playerContainer;
    IBOutlet UIView * __nonnull _topBar;
    IBOutlet UIView * __nonnull _bottomBar;
    
    IBOutlet SeekButton * __nonnull _backwardSeekButton;
    IBOutlet SeekButton * __nonnull _forwardSeekButton;
    
    IBOutlet Slomo * __nonnull _slomoButton;
    IBOutlet PxpFullscreenButton * __nonnull _fullscreenButton;
    
    IBOutlet LiveButton * __nonnull _liveButton;
    
    IBOutlet PxpRangeModifierButton * __nonnull _rangeStartModifierButton;
    IBOutlet PxpRangeModifierButton * __nonnull _rangeEndModifierButton;
    
    void * _playRateObserverContext;
}

@synthesize contentView = _contentView;
@synthesize topBar = _topBar;
@synthesize bottomBar = _bottomBar;

@synthesize backwardSeekButton = _backwardSeekButton;
@synthesize forwardSeekButton = _forwardSeekButton;

@synthesize slomoButton = _slomoButton;
@synthesize fullscreenButton = _fullscreenButton;

@synthesize liveButton = _liveButton;

@synthesize rangeStartModifierButton = _rangeStartModifierButton;
@synthesize rangeEndModifierButton = _rangeEndModifierButton;

- (nonnull instancetype)init {
    return [self initWithPlayerViewClass:nil];
}

- (nonnull instancetype)initWithPlayerViewClass:(nullable Class)playerViewClass {
    self = [super init];
    if (self) {
        _playerViewController = [[PxpPlayerViewController alloc] initWithPlayerViewClass:playerViewClass];
        
        _playRateObserverContext = &_playRateObserverContext;
        
        [_playerViewController.playerView addObserver:self forKeyPath:@"player.playRate"options:0 context:_playRateObserverContext];
    }
    return self;
}

- (void)dealloc {
    [_playerViewController.playerView removeObserver:self forKeyPath:@"player.playRate"];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    _playerViewController.view.frame = _playerContainer.bounds;
    _playerViewController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [_playerContainer addSubview:_playerViewController.view];
    
    NCTriPinchGestureRecognizer *dismissFullscreedGestureRecognizer = [[NCTriPinchGestureRecognizer alloc] initWithTarget:self action:@selector(dismissFullscreenGestureRecognized:)];
    
    [_playerViewController.playerView addGestureRecognizer:dismissFullscreedGestureRecognizer];
    
    _rangeStartModifierButton.hidden = YES;
    _rangeEndModifierButton.hidden = YES;
    
    self.hidden = YES;
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

- (void)setHidden:(BOOL)hidden {
    [self setHidden:hidden animated:NO];
}

- (BOOL)hidden {
    return self.view.hidden;
}

#pragma mark - Actions

- (IBAction)backwardSeekAction:(SeekButton *)sender {
    [_playerViewController.playerView.player seekBy:CMTimeMakeWithSeconds(sender.speed, 600)];
}

- (IBAction)forwardSeekAction:(SeekButton *)sender {
    [_playerViewController.playerView.player seekBy:CMTimeMakeWithSeconds(sender.speed, 600)];
}

- (IBAction)slomoButtonAction:(Slomo *)sender {
    sender.slomoOn = !sender.slomoOn;
    _playerViewController.playerView.player.playRate = sender.slomoOn ? 0.5 : 1.0;
}

- (IBAction)fullscreenButtonAction:(PxpFullscreenButton *)sender {
    [self setHidden:YES animated:YES frame:_targetFrame];
}

- (IBAction)liveButtonAction:(LiveButton *)sender {
    _playerViewController.playerView.player.live = YES;
}

- (void)extendStartAction:(UIButton *)button {
    if (_tag) {
        
        if ([[LocalMediaManager getInstance]getClipByTag:_tag scrKey:nil]){
            Clip * clipToSeverFromEvent = [[LocalMediaManager getInstance]getClipByTag:_tag scrKey:nil];
            [[LocalMediaManager getInstance] breakTagLink:clipToSeverFromEvent];
        }
        
        
        float newStartTime = 0;
        float endTime = _tag.startTime + _tag.duration;
        
        //extend the duration by decreasing the start time 5 seconds
        newStartTime = _tag.startTime - 5;
        //if the new start time is smaller than 0, set it to 0
        if (newStartTime <0) {
            newStartTime = 0;
        }
        
        //set the new duration to tag end time minus new start time
        int newDuration = endTime - newStartTime;
        
        _tag.startTime = newStartTime;
        
        if (newDuration > _tag.duration) {
            _tag.duration = newDuration;
            [[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_MODIFY_TAG object:_tag];
        }
        
        /*_tag.startTime -= fabs(_backwardSeekButton.speed);
         _tag.duration += fabs(_backwardSeekButton.speed);
         [[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_MODIFY_TAG object:_tag];*/
    }
}

- (void)extendEndAction:(UIButton *)button {
    if (_tag) {
        _tag.duration += fabs(_forwardSeekButton.speed);
        [[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_MODIFY_TAG object:_tag];
    }
    
    
    if ([[LocalMediaManager getInstance]getClipByTag:_tag scrKey:nil]){
        Clip * clipToSeverFromEvent = [[LocalMediaManager getInstance]getClipByTag:_tag scrKey:nil];
        [[LocalMediaManager getInstance] breakTagLink:clipToSeverFromEvent];
    }
    
    
    float startTime = _tag.startTime;
    
    float endTime = startTime + _tag.duration;
    
    //increase end time by 5 seconds
    endTime = endTime + 5;
    //if new end time is greater the duration of video, set it to the video's duration
    if (endTime > [self durationOfVideoPlayer]) {
        endTime = [self durationOfVideoPlayer];
    }
    
    //get the new duration
    int newDuration = newDuration = endTime - startTime;
    if (newDuration > _tag.duration) {
        _tag.duration = newDuration;
        [[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_MODIFY_TAG object:_tag];
    }
    
}

#pragma mark - Gesture Recognizers

- (void)dismissFullscreenGestureRecognized:(NCTriPinchGestureRecognizer *)recognizer {
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

#pragma mark - Private Methods

- (NSTimeInterval)durationOfVideoPlayer{
    CMTimeRange range = [_playerViewController.playerView.player.currentItem.seekableTimeRanges.firstObject CMTimeRangeValue];
    NSTimeInterval duration = CMTimeGetSeconds(CMTimeAdd(range.start, range.duration));
    return isfinite(duration) ? duration : 0.0;
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
