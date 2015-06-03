//
//  NCPlayerView.m
//  iOS Workspace
//
//  Created by Nico Cvitak on 2015-05-26.
//  Copyright (c) 2015 Nicholas Cvitak. All rights reserved.
//

#import "NCPlayerView.h"
#import "OBSlider.h"

#define SLIDER_INSET 100

@interface NCPlayerView ()

@property (copy, nonatomic, nonnull) void(^periodicObserverBlock)(CMTime);
@property (strong, nonatomic, nullable) id periodicObserver;

@property (strong, nonatomic, nonnull) UIBarButtonItem *playButton;
@property (strong, nonatomic, nonnull) UIBarButtonItem *pauseButton;

@property (strong, nonatomic, nonnull) UILabel *timeElapsedLabel;
@property (strong, nonatomic, nonnull) UILabel *timeRemainingLabel;

@property (strong, nonatomic, nonnull) UIBarButtonItem *exitButton;

@property (strong, nonatomic, nonnull) NSMutableArray *toolBarItems;

@property (strong, nonatomic, nonnull) UIView *toolBarContainer;
@property (strong, nonatomic, nonnull) UIToolbar *toolBar;

@property (strong, nonatomic, nonnull) UIView *blurContainer;
@property (strong, nonatomic, nonnull) UIVisualEffectView *blurView;

@property (strong, nonatomic, nonnull) UISlider *durationSlider;

@property (assign, nonatomic) BOOL seeking;
@property (assign, nonatomic) float wasPlayingAtRate;
@property (assign, nonatomic) BOOL finalSeek;

@end

@implementation NCPlayerView
{
    void *_rateObserverContext;
    void *_rangeObserverContext;
}

@dynamic layer; // we know layer will be an AVPlayerLayer at runtime

+ (Class)layerClass {
    return [AVPlayerLayer class];
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _rateObserverContext = &_rateObserverContext;
        _rangeObserverContext = &_rangeObserverContext;
        
        self.tintColor = [UIColor orangeColor];
        
        self.timeElapsedLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, (SLIDER_INSET - 5), 44)];
        self.timeRemainingLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.bounds.size.width - (SLIDER_INSET - 5), 0, (SLIDER_INSET - 5), 44)];
        
        self.timeElapsedLabel.textAlignment = NSTextAlignmentRight;
        self.timeRemainingLabel.textAlignment = NSTextAlignmentLeft;
        
        self.timeElapsedLabel.font = [UIFont systemFontOfSize:12.0];
        self.timeRemainingLabel.font = [UIFont systemFontOfSize:12.0];
        
        self.playButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemPlay target:self action:@selector(play:)];
        self.pauseButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemPause target:self action:@selector(pause:)];
        
        self.exitButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:self action:@selector(exit:)];
        
        
        self.toolBarItems = [NSMutableArray arrayWithArray:@[
                                                             self.playButton,
                                                             [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                                                             [[UIBarButtonItem alloc] init]
                                                             ]];
        
        
        self.toolBarContainer = [[UIView alloc] initWithFrame:CGRectMake(0, self.bounds.size.height - 44, self.bounds.size.width, 44)];
        
        self.blurContainer = [[UIView alloc] initWithFrame:self.toolBarContainer.bounds];
        self.toolBar = [[UIToolbar alloc] initWithFrame:self.toolBarContainer.bounds];
        
        // make transparent
        [self.toolBar setBackgroundImage:[UIImage new] forToolbarPosition:UIToolbarPositionAny barMetrics:UIBarMetricsDefault];
        [self.toolBar setShadowImage:[UIImage new] forToolbarPosition:UIToolbarPositionAny];
        self.toolBar.items = self.toolBarItems;
        
        
        
        // nice iOS8 blur :)
        self.effectStyle = UIBlurEffectStyleDark;
        
        self.showsControlBar = YES;
        
        self.durationSlider = [[OBSlider alloc] init];
        self.durationSlider.minimumValue = 0.0;
        self.durationSlider.maximumValue = 1.0;
        self.durationSlider.value = 0.0;
        self.durationSlider.continuous = YES;
        [self.durationSlider addTarget:self action:@selector(durationSliderAction:) forControlEvents:UIControlEventValueChanged];
        [self.durationSlider addTarget:self action:@selector(seekStart:) forControlEvents:UIControlEventTouchDown];
        [self.durationSlider addTarget:self action:@selector(seekEnd:) forControlEvents:UIControlEventTouchCancel | UIControlEventTouchUpInside | UIControlEventTouchUpOutside];
        
        __block NCPlayerView *_self = self;
        
        self.periodicObserverBlock = ^(CMTime time) {
            CMTimeRange range = CMTIMERANGE_IS_VALID(_self.player.loopRange) ? _self.player.loopRange : CMTimeRangeMake(kCMTimeZero, _self.player.duration);
            
            NSTimeInterval currentTime = CMTimeGetSeconds(_self.player.currentTime);
            NSTimeInterval duration = CMTimeGetSeconds(_self.player.duration);
            
            
            
            if (!_self.seeking) {
                CGFloat percent = CMTimeGetSeconds(CMTimeSubtract(_self.player.currentTime, range.start)) / CMTimeGetSeconds(range.duration);
                
                [_self.durationSlider setValue:isfinite(percent) ? percent : 0.0 animated:YES];
            }
            
            _self.timeElapsedLabel.text = [_self stringForSeconds:currentTime];
            _self.timeRemainingLabel.text = [NSString stringWithFormat:@"-%@", [_self stringForSeconds:duration - currentTime]];
        };
        
        self.durationSlider.frame = CGRectMake(SLIDER_INSET, 0, self.blurView.bounds.size.width - 2 * SLIDER_INSET, self.blurView.bounds.size.height);
        
        [self addSubview:self.toolBarContainer];
        [self.toolBarContainer addSubview:self.blurContainer];
        [self.toolBarContainer addSubview:self.toolBar];
        [self.toolBar addSubview:self.durationSlider];
        [self.toolBar addSubview:self.timeElapsedLabel];
        [self.toolBar addSubview:self.timeRemainingLabel];
        
        self.player = nil;
    }
    return self;
}

#pragma mark - Getters / Setters

- (void)setEffectStyle:(UIBlurEffectStyle)effectStyle {
    _effectStyle = effectStyle;
    
    self.timeElapsedLabel.textColor = effectStyle == UIBlurEffectStyleDark ? [UIColor whiteColor] : [UIColor blackColor];
    self.timeRemainingLabel.textColor = effectStyle == UIBlurEffectStyleDark ? [UIColor whiteColor] : [UIColor blackColor];
    
    UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:effectStyle];
    
    [self.blurView removeFromSuperview];
    
    self.blurView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    self.blurView.frame = self.blurContainer.bounds;
    
    [self.blurContainer addSubview:self.blurView];
    
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    
    self.timeElapsedLabel.frame = CGRectMake(0, 0, (SLIDER_INSET - 5), 44);
    self.timeRemainingLabel.frame = CGRectMake(self.bounds.size.width - (SLIDER_INSET - 5), 0, (SLIDER_INSET - 5), 44);
    
    self.toolBarContainer.frame = CGRectMake(0, self.bounds.size.height - 44, self.bounds.size.width, 44);
    self.blurContainer.frame = self.toolBarContainer.bounds;
    self.blurView.frame = self.blurContainer.bounds;
    self.toolBar.frame = self.toolBarContainer.bounds;
    self.durationSlider.frame = CGRectMake(SLIDER_INSET, 0, self.blurView.bounds.size.width - 2 * SLIDER_INSET, self.blurView.bounds.size.height);
}

- (void)setPlayer:(nullable NCPlayer *)player {
    [self.player removeObserver:self forKeyPath:@"rate" context:_rateObserverContext];
    [self.player removeObserver:self forKeyPath:@"loopRange" context:_rangeObserverContext];
    [self.player removeTimeObserver:self.periodicObserver];
    self.periodicObserver = nil;
    
    self.periodicObserver = [player addPeriodicTimeObserverForInterval:CMTimeMake(1, 1) queue:dispatch_get_main_queue() usingBlock:self.periodicObserverBlock];
    [player addObserver:self forKeyPath:@"rate" options:0 context:_rateObserverContext];
    [player addObserver:self forKeyPath:@"loopRange" options:0 context:_rangeObserverContext];
    
    self.layer.player = player;
}

- (nullable NCPlayer *)player {
    return (NCPlayer *)self.layer.player;
}

- (void)setShowsControlBar:(BOOL)showsControlBar {
    self.toolBarContainer.hidden = !showsControlBar;
}

- (BOOL)showsControlBar {
    return !self.toolBarContainer.hidden;
}

- (void)setEnabled:(BOOL)enabled {
    _enabled = enabled;
    self.durationSlider.enabled = enabled;
    self.pauseButton.enabled = enabled;
    self.playButton.enabled = enabled;
    self.exitButton.enabled = enabled;
}

#pragma mark - Key Value Observing

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (context == _rateObserverContext) {
        
        // update tool bar items
        if (self.player.rate != 0.0 && self.toolBarItems[0] != self.pauseButton) {
            self.toolBarItems[0] = self.pauseButton;
            self.toolBar.items = self.toolBarItems;
        } else if (self.player.rate == 0.0 && self.toolBarItems[0] != self.playButton) {
            self.toolBarItems[0] = self.playButton;
            self.toolBar.items = self.toolBarItems;
        }
    } else if (context == _rangeObserverContext) {
        
        if (CMTIMERANGE_IS_VALID(self.player.loopRange)) {
            self.toolBarItems[2] = self.exitButton;
            self.toolBar.items = self.toolBarItems;
            self.blurContainer.backgroundColor = [UIColor orangeColor];
        } else {
            self.toolBarItems[2] = [[UIBarButtonItem alloc] init];
            self.toolBar.items = self.toolBarItems;
            self.blurContainer.backgroundColor = [UIColor clearColor];
        }
        
    }
}

#pragma mark - Bar Button Actions

- (void)play:(UIBarButtonItem *)item {
    [self prerollAndPlayAtRate:1.0];
}

- (void)pause:(UIBarButtonItem *)item {
    [self.player pause];
}

- (void)exit:(UIBarButtonItem *)item {
    self.player.loopRange = kCMTimeRangeInvalid;
}

#pragma mark - Slider Actions

- (void)durationSliderAction:(UISlider *)slider {
    
    if (!self.finalSeek) {
        CMTimeRange range = CMTIMERANGE_IS_VALID(self.player.loopRange) ? self.player.loopRange : CMTimeRangeMake(kCMTimeZero, self.player.duration);
        
        CMTime time = CMTimeAdd(range.start, CMTimeMultiplyByFloat64(range.duration, self.durationSlider.value));
        
        if (CMTIME_IS_NUMERIC(time)) {
            [self.player seekToTime:time];
        }
    }
    
}

- (void)seekStart:(UISlider *)slider {
    self.seeking = YES;
    self.wasPlayingAtRate = self.player.rate;
    [self.player pause];
}

- (void)seekEnd:(UISlider *)slider {
    self.finalSeek = YES;
    
    CMTimeRange range = CMTIMERANGE_IS_VALID(self.player.loopRange) ? self.player.loopRange : CMTimeRangeMake(kCMTimeZero, self.player.duration);
    
    CMTime time = CMTimeAdd(range.start, CMTimeMultiplyByFloat64(range.duration, self.durationSlider.value));
    
    if (CMTIME_IS_NUMERIC(time)) {
        // begin the final Seek
        
        [self.player seekToTime:time toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero completionHandler:^(BOOL seeked) {
            [self prerollAndPlayAtRate:self.wasPlayingAtRate];
        }];
    }
    
    self.finalSeek = NO;
    self.seeking = NO;
}

#pragma mark - Notification Handlers

- (void)playerItemDidPlayToTimeEnd:(NSNotification *)note {
    [self.player pause];
}

#pragma mark - Helper Methods

- (void)prerollAndPlayAtRate:(float)rate {
    if (rate != 0.0) {
        [self.player prerollAtRate:rate completionHandler:^(BOOL prerolled) {
            //delay just in case ;)
            dispatch_time_t delay = dispatch_time(DISPATCH_TIME_NOW, 0.1 * NSEC_PER_SEC);
            dispatch_after(delay, dispatch_get_main_queue(), ^{
                [self.player setRate:rate];
            });
        }];
    }
}

- (NSString *)stringForSeconds:(NSTimeInterval)seconds {
    NSUInteger second = 00;
    NSUInteger minute = 00;
    NSUInteger hour = 00;
    
    second = (NSUInteger) seconds;
    
    hour = second / 3600;
    minute = second % 3600 / 60;
    second = second % 60;
    
    return [NSString stringWithFormat:@"%02lu:%02lu:%02lu",(unsigned long) hour, (unsigned long) minute, (unsigned long)second];
}

@end
