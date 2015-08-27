//
//  PxpPlayerself.m
//  PxpPlayer
//
//  Created by Nico Cvitak on 2015-06-16.
//  Copyright © 2015 Nicholas Cvitak. All rights reserved.
//

#import "PxpPlayerControlBar.h"

#import "PxpPlayer.h"

#import "PxpPlayerControlToolbar.h"
#import "PxpPlayerControlSlider.h"
#import "PxpPlayerLight.h"
#import "PxpPlayPauseButton.h"
#import "PxpCancelButton.h"

#define UI_UPDATE_INTERVAL 0.5

@interface PxpPlayerControlBar () <PxpPlayPauseButtonDelegate>

@property (strong, nonatomic, nullable) NSNumber *seek; // the number is the orginal playback rate

@property (readonly, strong, nonatomic, nonnull) PxpPlayPauseButton *playPauseButton;

@property (strong, nonatomic, nonnull) UIView *container;
@property (strong, nonatomic, nonnull) UIView *blurContainer;

@property (strong, nonatomic, nonnull) UIView *blurView;

@property (strong, nonatomic, nonnull) PxpPlayerControlSlider *slider;
@property (strong, nonatomic, nonnull) UILabel *leftLabel;
@property (strong, nonatomic, nonnull) UILabel *rightLabel;

@property (strong, nonatomic, nonnull) PxpPlayerLight *liveLight;
@property (strong, nonatomic, nonnull) PxpCancelButton *rangeCancelButton;

@property (strong, nonatomic, nonnull) UISwipeGestureRecognizer *hideGestureRecognizer;
@property (strong, nonatomic, nonnull) UISwipeGestureRecognizer *showGestureRecognizer;

@property (strong, nonatomic, nullable) id periodicObserver;

@end

@implementation PxpPlayerControlBar
{
    void *_rateObserverContext;
}

- (void)initControlBar {
    _enabled = YES;
    
    _container = [[UIView alloc] initWithFrame:self.bounds];
    _container.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    _playPauseButton = [[PxpPlayPauseButton alloc] initWithFrame:CGRectMake(0, 0, 22, 22)];
    _playPauseButton.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleHeight;
    _playPauseButton.delegate = self;
    
    _liveLight = [[PxpPlayerLight alloc] initWithFrame:CGRectMake(0, 0, 22, 22)];
    _liveLight.color = [UIColor greenColor];
    _liveLight.hidden = YES;
    
    _rangeCancelButton = [[PxpCancelButton alloc] initWithFrame:CGRectMake(0, 0, 22, 22)];
    _rangeCancelButton.tintColor = [UIColor redColor];
    _rangeCancelButton.hidden = YES;
    
    [_rangeCancelButton addTarget:self action:@selector(cancelRange:) forControlEvents:UIControlEventTouchUpInside];
    
    _blurContainer = [[UIView alloc] initWithFrame:_container.bounds];
    _blurContainer.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    if ([UIDevice currentDevice].systemVersion.floatValue >= 8.0) {
        _blurView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleDark]];
    } else {
        _blurView = [[UIView alloc] init];
        _blurView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
    }
    
    _blurView.frame = _blurContainer.bounds;
    _blurView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    _slider = [[PxpPlayerControlSlider alloc] initWithFrame:CGRectMake(110, 0, _container.bounds.size.width - 2 * 110, _container.bounds.size.height)];
    _slider.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [_slider addTarget:self action:@selector(seekDidBegin:) forControlEvents:UIControlEventTouchDown];
    [_slider addTarget:self action:@selector(seekDidUpdate:) forControlEvents:UIControlEventValueChanged];
    [_slider addTarget:self action:@selector(seekDidEnd:) forControlEvents:UIControlEventTouchCancel | UIControlEventTouchUpInside | UIControlEventTouchUpOutside];
    _slider.minimumValue = 0.0;
    _slider.maximumValue = 1.0;
    
    _leftLabel = [[UILabel alloc] initWithFrame:CGRectMake(49.5, 0, 55, _container.bounds.size.height)];
    _leftLabel.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleHeight;
    _leftLabel.font = [UIFont systemFontOfSize:18.0];
    _leftLabel.adjustsFontSizeToFitWidth = YES;
    _leftLabel.textAlignment = NSTextAlignmentCenter;
    _leftLabel.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
    _leftLabel.text = @"00:00:00";
    _leftLabel.textColor = [UIColor whiteColor];
    _leftLabel.layer.shadowColor = [UIColor whiteColor].CGColor;
    _leftLabel.layer.shadowRadius = 11.0;
    _leftLabel.layer.shadowOpacity = 1.0;
    _leftLabel.layer.shadowOffset = CGSizeZero;
    
    _rightLabel = [[UILabel alloc] initWithFrame:CGRectMake(_container.bounds.size.width - 49.5 - 55, 0, 55, _container.bounds.size.height)];
    _rightLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleHeight;
    _rightLabel.font = [UIFont systemFontOfSize:18.0];
    _rightLabel.adjustsFontSizeToFitWidth = YES;
    _rightLabel.textAlignment = NSTextAlignmentCenter;
    _rightLabel.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
    _rightLabel.text = @"00:00:00";
    _rightLabel.textColor = [UIColor whiteColor];
    _rightLabel.layer.shadowColor = [UIColor whiteColor].CGColor;
    _rightLabel.layer.shadowRadius = 11.0;
    _rightLabel.layer.shadowOpacity = 1.0;
    _rightLabel.layer.shadowOffset = CGSizeZero;
    
    [self addSubview:_container];
    [_container addSubview:_blurContainer];
    [_blurContainer addSubview:_blurView];
    [_container addSubview:_slider];
    [_container addSubview:_playPauseButton];
    [_container addSubview:_liveLight];
    [_container addSubview:_rangeCancelButton];
    [_container addSubview:_leftLabel];
    [_container addSubview:_rightLabel];
    
    _hideGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(controlBarHideGestureRecognized:)];
    _hideGestureRecognizer.direction = UISwipeGestureRecognizerDirectionDown;
    
    _showGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(controlBarHideGestureRecognized:)];
    _showGestureRecognizer.direction = UISwipeGestureRecognizerDirectionUp;
    
    [self addGestureRecognizer:_hideGestureRecognizer];
    [self addGestureRecognizer:_showGestureRecognizer];
    
    self.clipsToBounds = YES;
    
    _rateObserverContext = &_rateObserverContext;
    
    [self addObserver:self forKeyPath:@"player.rate" options:0 context:_rateObserverContext];
    
    self.backgroundColor = [UIColor clearColor];
}

- (nonnull instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initControlBar];
    }
    return self;
}

- (nullable instancetype)initWithCoder:(nonnull NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initControlBar];
    }
    return self;
}

- (void)dealloc {
    [self removeObserver:self forKeyPath:@"player.rate" context:_rateObserverContext];
}

- (void)observeValueForKeyPath:(nullable NSString *)keyPath ofObject:(nullable id)object change:(nullable NSDictionary *)change context:(nullable void *)context {
    
    if (context == _rateObserverContext) {
        self.playPauseButton.paused = self.player.rate == 0.0;
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.slider.frame = CGRectMake(110, 0, self.container.bounds.size.width - 2 * 110, self.container.bounds.size.height);
    
    self.playPauseButton.center = CGPointMake(22.0, 0.5 * self.container.bounds.size.height);
    self.liveLight.center = CGPointMake(self.container.bounds.size.width - 22.0, 0.5 * self.container.bounds.size.height);
    self.rangeCancelButton.center = CGPointMake(self.container.bounds.size.width - 22.0, 0.5 * self.container.bounds.size.height);
}

#pragma mark - Getters / Setters

- (void)setPlayer:(nullable PxpPlayer *)player {
    if (_player != player) {
        [_player removeTimeObserver:self.periodicObserver];
        
        _player = player;
        
        self.periodicObserver = [_player addPeriodicTimeObserverForInterval:CMTimeMake(1, 1) queue:NULL usingBlock:^(CMTime time) {
            [self update:time];
        }];
        
    }
}

- (void)setEnabled:(BOOL)enabled {
    _enabled = enabled;
    self.slider.enabled = enabled;
}

- (void)setVisible:(BOOL)visible animated:(BOOL)animated {
    
    [UIView animateWithDuration:animated ? 0.1 : 0.0
                     animations:^() {
                         if (visible) {
                             self.container.frame = CGRectMake(0.0, 0.0, self.bounds.size.width, self.bounds.size.height);
                         } else {
                             self.container.frame = CGRectMake(0.0, self.bounds.size.height, self.bounds.size.width, self.bounds.size.height);
                         }
                     }];
}

- (void)tintColorDidChange {
    [super tintColorDidChange];
    
    self.container.backgroundColor = CMTIMERANGE_IS_VALID(self.player.range) ? [self.tintColor colorWithAlphaComponent:0.5] : [UIColor clearColor];
}

#pragma mark - Slider Actions

- (void)seekDidBegin:(nonnull UISlider *)slider {
    self.seek = [NSNumber numberWithFloat:self.seek ? self.seek.floatValue : self.player.rate];
    [self.player pause];
}

- (void)seekDidUpdate:(nonnull UISlider *)slider {
    // calculate range
    CMTimeRange range = CMTIMERANGE_IS_VALID(self.player.range) ? self.player.range : CMTimeRangeMake(kCMTimeZero, self.player.duration);
    
    // calculate time to seek to
    CMTime time = CMTimeAdd(range.start, CMTimeMultiplyByFloat64(range.duration, self.slider.value));
    
    // seek if the time is numeric
    if (CMTIME_IS_NUMERIC(time)) {
        [self.player seekToTime:time];
    }
}

- (void)seekDidEnd:(nonnull UISlider *)slider {
    
    // calculate range
    CMTimeRange range = CMTIMERANGE_IS_VALID(self.player.range) ? self.player.range : CMTimeRangeMake(kCMTimeZero, self.player.duration);
    
    // calculate time to seek to
    CMTime time = CMTimeAdd(range.start, CMTimeMultiplyByFloat64(range.duration, self.slider.value));
    
    // seek if the time is numeric
    
    // a new seek may start while we are preparing to play, so we must distinguish them
    NSNumber *seek = self.seek;
    
    if (CMTIME_IS_NUMERIC(time)) {
        [self.player seekToTime:time completionHandler:^(BOOL seekFinished) {
            
            [self.player prerollAtRate:seek.floatValue completionHandler:^(BOOL prerollFinished) {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [self.player setRate:seek.floatValue];
                    if (seek == self.seek) self.seek = nil;
                    
                });
                
            }];
        }];
    } else {
        [self.player setRate:seek.floatValue];
        if (seek == self.seek) self.seek = nil;

    }
    
    
}

#pragma mark - Private Methods

- (void)update:(CMTime)time {
    
    self.container.backgroundColor = CMTIMERANGE_IS_VALID(self.player.range) ? [self.tintColor colorWithAlphaComponent:0.5] : [UIColor clearColor];
    
    if (self.player.live) {
        _liveLight.hidden = NO;
        _rangeCancelButton.hidden = YES;
    } else if (CMTIMERANGE_IS_VALID(self.player.range)) {
        _liveLight.hidden = YES;
        _rangeCancelButton.hidden = NO;
    } else {
        _liveLight.hidden = YES;
        _rangeCancelButton.hidden = YES;
    }
    
    // calculate the range to display on the slider
    CMTimeRange range = CMTIMERANGE_IS_VALID(self.player.range) ? self.player.range : CMTimeRangeMake(kCMTimeZero, self.player.duration);
    
    // update the slider if we are not modifying it
    if (!self.seek) {
        // if the player is live make the user think they are 100% live
        CGFloat percent = self.player.live ? 1.0 : ceil(CMTimeGetSeconds(CMTimeSubtract(time, range.start))) / ceil(CMTimeGetSeconds(range.duration));
        [self.slider setValue:isfinite(percent) ? percent : 0.0 animated:YES];
    }
    
    // calculate time elapsed and remaining
    NSTimeInterval elapsed = MAX(0, CMTimeGetSeconds(self.player.live ? self.player.duration : CMTimeSubtract(time, range.start)));
    NSTimeInterval remaining = MAX(0, CMTimeGetSeconds(CMTimeSubtract(range.duration, CMTimeSubtract(time, range.start))));
    
    // update text labels
    self.leftLabel.text = [self stringForSeconds:isfinite(elapsed) ? elapsed : 0.0];
    self.rightLabel.text = self.player.live ? NSLocalizedString(@"LIVE", nil) : [self stringForSeconds:isfinite(remaining) ? remaining : 0.0];
    
    
}

- (nonnull NSString *)stringForSeconds:(NSTimeInterval)seconds {
    NSUInteger interval = (NSUInteger)seconds;
    NSUInteger s = interval % 60;
    NSUInteger m = (interval / 60) % 60;
    NSUInteger h = interval / 3600;
    
    return [NSString stringWithFormat:@"%02lu:%02lu:%02lu",(unsigned long) h, (unsigned long) m, (unsigned long)s];
}

- (void)cancelRange:(PxpCancelButton *)cancelButton {
    self.player.range = kCMTimeRangeInvalid;
    [self update:self.player.currentTime];
}

#pragma mark - PxpPlayPauseButtonDelegate

- (void)button:(nonnull PxpPlayPauseButton *)button didChangeToPaused:(BOOL)paused {
    if (button == self.playPauseButton) {
        if (paused) {
            [self.player pause];
        } else {
            [self.player play];
        }
    }
}

#pragma mark - Gesture Recognizers

- (void)controlBarHideGestureRecognized:(UISwipeGestureRecognizer *)recognizer {
    if (recognizer.direction == UISwipeGestureRecognizerDirectionDown) {
        [self setVisible:NO animated:YES];
    } else if (recognizer.direction == UISwipeGestureRecognizerDirectionUp) {
        [self setVisible:YES animated:YES];
    }
}


@end

