//
//  RicoPlayerControlBar.m
//  Live2BenchNative
//
//  Created by dev on 2015-12-02.
//  Copyright © 2015 DEV. All rights reserved.
//

#import "RicoPlayerControlBar.h"






@interface RicoPlayerControlBar () <PxpPlayPauseButtonDelegate>

@property (strong, nonatomic, nullable) NSNumber *seek; // the number is the orginal playback rate



@property (strong, nonatomic, nonnull) UIView *container;
@property (strong, nonatomic, nonnull) UIView *blurContainer;

@property (strong, nonatomic, nonnull) UIView *blurView;


@property (strong, nonatomic, nonnull) UILabel *leftLabel;
@property (strong, nonatomic, nonnull) UILabel *rightLabel;

@property (strong, nonatomic, nonnull) PxpPlayerLight *liveLight;
@property (strong, nonatomic, nonnull) PxpCancelButton *rangeCancelButton;

@property (strong, nonatomic, nonnull) UISwipeGestureRecognizer *hideGestureRecognizer;
@property (strong, nonatomic, nonnull) UISwipeGestureRecognizer *showGestureRecognizer;

@property (strong, nonatomic, nullable) id periodicObserver;

@end




@implementation RicoPlayerControlBar

#pragma mark - Init

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
    _leftLabel.font = [UIFont systemFontOfSize:12.0];
    _leftLabel.adjustsFontSizeToFitWidth = NO;
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
    _rightLabel.font = [UIFont systemFontOfSize:12.0];
    _rightLabel.adjustsFontSizeToFitWidth = NO;
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

    [_container addSubview:_playPauseButton];
    [_container addSubview:_liveLight];
    [_container addSubview:_rangeCancelButton];
    [_container addSubview:_leftLabel];
    [_container addSubview:_rightLabel];
    [_container addSubview:_slider];


    self.clipsToBounds = YES;
    self.backgroundColor = [UIColor clearColor];
    self.gestureEnabled = YES;
    [self clear];
}


- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.slider.frame               = CGRectMake(110, 0, self.container.bounds.size.width - 2 * 110, self.container.bounds.size.height);
    self.playPauseButton.center     = CGPointMake(22.0, 0.5 * self.container.bounds.size.height);
    self.liveLight.center           = CGPointMake(self.container.bounds.size.width - 22.0, 0.5 * self.container.bounds.size.height);
    self.rangeCancelButton.center   = CGPointMake(self.container.bounds.size.width - 22.0, 0.5 * self.container.bounds.size.height);

}



-(void)clear
{
    _leftLabel.text = @"00:00:00";
    _rightLabel.text = @"00:00:00";
    [self.slider setValue:0.0];
}


- (void)update:(CMTime)time duration:(CMTime)duration
{

        
        

    CMTimeRange timeRange = (self.state == RicoPlayerStateRange)? self.range : CMTimeRangeMake(kCMTimeZero, duration);
  
    NSTimeInterval elapsed = MAX(0, CMTimeGetSeconds((self.state == RicoPlayerStateLive) ? duration : CMTimeSubtract(time, timeRange.start)));
    NSTimeInterval remaining = MAX(0, CMTimeGetSeconds(CMTimeSubtract(timeRange.duration, CMTimeSubtract(time, timeRange.start))));
    dispatch_async(dispatch_get_main_queue(), ^{
        self.leftLabel.text = [self stringForSeconds:isfinite(elapsed) ? elapsed : 0.0];

        if (self.state != RicoPlayerStateLive) {
            self.rightLabel.text = [self stringForSeconds:isfinite(remaining) ? remaining : 0.0];
        }
        
        
        if (!self.seek && self.state != RicoPlayerStateLive) {
            // if the player is live make the user think they are 100% live
            CGFloat percent = ceil(CMTimeGetSeconds(CMTimeSubtract(time, timeRange.start))) / ceil(CMTimeGetSeconds(timeRange.duration));
            [self.slider setValue:isfinite(percent) ? percent : 0.0 animated:YES];
        }
    });
}


- (void)autoUpdate:(CMTime)time duration:(CMTime)duration
{
    if (!self.delegateUpdateEnabled) return;
    
    
    
    CMTimeRange timeRange = (self.state == RicoPlayerStateRange)? self.range : CMTimeRangeMake(kCMTimeZero, duration);
    //     timeRange = CMTIMERANGE_IS_VALID(self.player.range) ? self.player.range : CMTimeRangeMake(kCMTimeZero, self.player.duration);
    
    NSTimeInterval elapsed = MAX(0, CMTimeGetSeconds((self.state == RicoPlayerStateLive) ? duration : CMTimeSubtract(time, timeRange.start)));
    NSTimeInterval remaining = MAX(0, CMTimeGetSeconds(CMTimeSubtract(timeRange.duration, CMTimeSubtract(time, timeRange.start))));
    
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.leftLabel.text = [self stringForSeconds:isfinite(elapsed) ? elapsed : 0.0];
        
        if (self.state != RicoPlayerStateLive) {
            self.rightLabel.text = [self stringForSeconds:isfinite(remaining) ? remaining : 0.0];
        }
        
        
        if (!self.seek) {
            // if the player is live make the user think they are 100% live
            CGFloat percent = ceil(CMTimeGetSeconds(CMTimeSubtract(time, timeRange.start))) / ceil(CMTimeGetSeconds(timeRange.duration));
            [self.slider setValue:isfinite(percent) ? percent : 0.0 animated:YES];
        }
     });
    
}



-(void)setState:(RicoPlayerState)state
{
    float f             =     self.slider.value; // this is to force a refresh
    self.slider.value   = -0.01;
    self.slider.value   = f;
    
    // setNeedsDisplay does not refresh the sliders view on some
    // iPads. It seems to not refresh when you set it to the same value
    

    self.container.backgroundColor = [UIColor clearColor];
    switch (state) {
        case RicoPlayerStateDisabled:
            
            self.playPauseButton.enabled = NO;

            break;
        case RicoPlayerStateNormal:
            _liveLight.hidden           = YES;
            _rangeCancelButton.hidden   = YES;
            self.playPauseButton.enabled = YES;
            self.slider.enabled             = YES;

            break;
        case RicoPlayerStateLive:
            _liveLight.hidden           = NO;
            _rangeCancelButton.hidden   = YES;
            _playPauseButton.paused     = NO;
            self.playPauseButton.enabled = YES;
            self.slider.enabled             = YES;
            self.rightLabel.text = NSLocalizedString(@"LIVE", nil);
            self.slider.value = 1.0f;
            [self.rightLabel setNeedsDisplay];

            break;
        case RicoPlayerStateRange:
            _liveLight.hidden               = YES;
            _rangeCancelButton.hidden       = NO;
            self.slider.enabled             = YES;
            self.playPauseButton.enabled = YES;
            self.container.backgroundColor  = [self.tintColor colorWithAlphaComponent:0.5];
            self.playPauseButton.paused     = NO;            
            break;
            
        case RicoPlayerStateTelestrationStill:
            _liveLight.hidden               = YES;
            _rangeCancelButton.hidden       = NO;
            self.playPauseButton.enabled    = YES;
            self.slider.enabled             = NO;
            self.container.backgroundColor  = [self.tintColor colorWithAlphaComponent:0.5];
            self.playPauseButton.paused     = YES;
            break;
        default:
            break;
    }
    [self.slider setNeedsDisplay];
    _state = state;
}

-(void)setRange:(CMTimeRange)range
{
    
    [self willChangeValueForKey:NSStringFromSelector(@selector(range))];
    _range = range;
    [self didChangeValueForKey:NSStringFromSelector(@selector(range))];
    if (CMTIMERANGE_IS_VALID(_range)){
        self.state = RicoPlayerStateRange;
    } else {
        self.state = RicoPlayerStateNormal;
    }
}


- (void)setEnabled:(BOOL)enabled {
    _enabled = enabled;
    self.slider.enabled = enabled;
    self.playPauseButton.enabled = enabled;
    self.playPauseButton.alpha = (enabled)?1.0:0.5;
    self.state = RicoPlayerStateDisabled;
}

#pragma mark - Gesture Recognizers

- (void)controlBarHideGestureRecognized:(UISwipeGestureRecognizer *)recognizer {
    if (recognizer.direction == UISwipeGestureRecognizerDirectionDown) {
        [self setVisible:NO animated:YES];
    } else if (recognizer.direction == UISwipeGestureRecognizerDirectionUp) {
        [self setVisible:YES animated:YES];
    }
}

-(void)setGestureEnabled:(BOOL)gestureEnabled
{
    if (gestureEnabled && !_hideGestureRecognizer) {
        _hideGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(controlBarHideGestureRecognized:)];
        _hideGestureRecognizer.direction = UISwipeGestureRecognizerDirectionDown;
        
        _showGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(controlBarHideGestureRecognized:)];
        _showGestureRecognizer.direction = UISwipeGestureRecognizerDirectionUp;
        
        [self addGestureRecognizer:_hideGestureRecognizer];
        [self addGestureRecognizer:_showGestureRecognizer];
    } else if (!gestureEnabled && _hideGestureRecognizer) {

        [self removeGestureRecognizer:_hideGestureRecognizer];
        [self removeGestureRecognizer:_showGestureRecognizer];
        _hideGestureRecognizer = nil;
        _showGestureRecognizer = nil;
    }
}

-(BOOL)gestureEnabled
{
    return (_hideGestureRecognizer != nil);
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
    self.container.backgroundColor = self.state == RicoPlayerStateRange ? [self.tintColor colorWithAlphaComponent:0.5] : [UIColor clearColor];
}

#pragma mark - Slider Actions

- (void)seekDidBegin:(nonnull UISlider *)slider {
//    NSLog(@"%s",__FUNCTION__);
    self.scrubbing = YES;
    
    if (self.state == RicoPlayerStateLive) {
        self.state = RicoPlayerStateNormal;
    }

    
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(startScrubbing:)]) {
         [self.delegate startScrubbing:self.slider];
    }
    


    

}

- (void)seekDidUpdate:(nonnull UISlider *)slider {
    // calculate range
    if (!self.scrubbing) {
        return;
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(updateScrubbing:)]) {
           [self.delegate updateScrubbing:self.slider];
    }
}

- (void)seekDidEnd:(nonnull UISlider *)slider {

    self.scrubbing = NO;
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(finishScrubbing:)]) {
        [self.delegate finishScrubbing:self.slider];
    }
 }

#pragma mark - Delegate methods
- (void)cancelRange:(PxpCancelButton *)cancelButton {
//    [self update:self.player.currentTime];
    [[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_PLAYER_BAR_CANCEL object:self];
    self.range = kCMTimeRangeInvalid;
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(cancelPressed:)]) {
        [self.delegate cancelPressed:self];
    }
}

#pragma mark - Utility methods

- (nonnull NSString *)stringForSeconds:(NSTimeInterval)seconds {
    NSUInteger interval = (NSUInteger)seconds;
    NSUInteger s = interval % 60;
    NSUInteger m = (interval / 60) % 60;
    NSUInteger h = interval / 3600;
    
    return [NSString stringWithFormat:@"%02lu:%02lu:%02lu",(unsigned long) h, (unsigned long) m, (unsigned long)s];
}


#pragma mark - PxpPlayPauseButtonDelegate

- (void)button:(nonnull PxpPlayPauseButton *)button didChangeToPaused:(BOOL)paused {
//    if (button == self.playPauseButton) {
//        if (paused) {
//            [self.player pause];
//        } else {
//            [self.player play];
//        }
//    }
    
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(playPausePressed:didChangeToPaused:)]) {
        [self.delegate playPausePressed:self didChangeToPaused:(BOOL)paused];
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
