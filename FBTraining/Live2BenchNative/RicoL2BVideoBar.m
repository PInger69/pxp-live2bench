//
//  PxpVideoBar.m
//  Live2BenchNative
//
//  Created by Nico Cvitak on 2015-07-29.
//  Copyright © 2015 DEV. All rights reserved.
//

#import "RicoL2BVideoBar.h"
#import "LocalMediaManager.h"

#import "PxpTagDisplayBar.h"
#import "UIColor+Highlight.h"
#import "PxpFullscreenButton.h"
#import "PxpRangeModifierButton.h"
#import "RicoPlayerViewController.h"

@interface RicoL2BVideoBar ()<PxpTagDisplayBarDataSource>

@end

@implementation RicoL2BVideoBar
{
    CADisplayLink * __nonnull _displayLink;
    
    PxpTagDisplayBar * __nonnull _tagView;
    UILabel * __nonnull _tagLabel;
    
     UIImage * _orangeFill;
    void *_playRateObserverContext;
    void *_telestrationObserverContext;
}

- (void)initVideoBar {
    _enabled = YES;
    
    _tagView = [[PxpTagDisplayBar alloc] init];
    _tagView.backgroundColor = [UIColor clearColor];
    _tagView.dataSource = self;
    _tagLabel = [[UILabel alloc] init];
    _tagLabel.layer.borderColor      = [UIColor darkGrayColor].CGColor;
    _tagLabel.layer.borderWidth      = .5;
    _tagLabel.layer.cornerRadius     = 5;
    _tagLabel.layer.backgroundColor  = [UIColor colorWithWhite:1.0f alpha:0.9f].CGColor;
    _tagLabel.textColor = [UIColor darkGrayColor];
    _tagLabel.adjustsFontSizeToFitWidth = YES;
    _tagLabel.textAlignment = NSTextAlignmentCenter;
    _tagLabel.hidden = YES;
    
    _tagExtendStartButton = [[PxpRangeModifierButton alloc] initWithFrame:CGRectZero end:NO];
    _tagExtendEndButton = [[PxpRangeModifierButton alloc] initWithFrame:CGRectZero end:YES];
    _tagExtendStartButton.contentMode = UIViewContentModeCenter;
    _tagExtendEndButton.contentMode = UIViewContentModeCenter;
    [_tagExtendStartButton addTarget:self action:@selector(extendStartAction:) forControlEvents:UIControlEventTouchUpInside];
    [_tagExtendEndButton addTarget:self action:@selector(extendEndAction:) forControlEvents:UIControlEventTouchUpInside];
    _tagExtendStartButton.hidden = YES;
    _tagExtendEndButton.hidden = YES;
    
    _backwardSeekButton = [[SeekButton alloc] initWithFrame:CGRectZero backward:YES];
    _forwardSeekButton = [[SeekButton alloc] initWithFrame:CGRectZero backward:NO];
    
    [_backwardSeekButton addTarget:self action:@selector(seekAction:) forControlEvents:UIControlEventTouchUpInside];
    [_forwardSeekButton addTarget:self action:@selector(seekAction:) forControlEvents:UIControlEventTouchUpInside];
    
    _slomoButton = [[Slomo alloc] init];
    [_slomoButton addTarget:self action:@selector(slomoAction:) forControlEvents:UIControlEventTouchUpInside];
    
    _fullscreenButton = [[PxpFullscreenButton alloc] initWithFrame:CGRectMake(0, 0, 52, 52)];
    
    
    // build frame buttons
    _frameBackward = [[UIButton alloc]initWithFrame:CGRectZero];
    _frameBackward.layer.borderWidth = 1;
    _frameBackward.layer.borderColor = PRIMARY_APP_COLOR.CGColor;
    [_frameBackward setTitleColor:PRIMARY_APP_COLOR forState:UIControlStateNormal];
    [_frameBackward setTitle:@"FB" forState:UIControlStateNormal];
    
    _frameForward  = [[UIButton alloc]initWithFrame:CGRectZero];
    _frameForward.layer.borderWidth = 1;
    _frameForward.layer.borderColor = PRIMARY_APP_COLOR.CGColor;
    _frameForward.titleLabel.textColor = PRIMARY_APP_COLOR;
    [_frameForward setTitleColor:PRIMARY_APP_COLOR forState:UIControlStateNormal];
    [_frameForward setTitle:@"FF" forState:UIControlStateNormal];
    _orangeFill = [Utility makeOnePixelUIImageWithColor:PRIMARY_APP_COLOR];
    [_frameBackward setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    [_frameForward setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    [_frameBackward setBackgroundImage:_orangeFill forState:UIControlStateHighlighted];
    [_frameForward setBackgroundImage:_orangeFill forState:UIControlStateHighlighted];
    
    
    
    [self addSubview:_tagView];
    [self addSubview:_tagLabel];
    [self addSubview:_tagExtendStartButton];
    [self addSubview:_tagExtendEndButton];
    [self addSubview:_backwardSeekButton];
    [self addSubview:_forwardSeekButton];
    [self addSubview:_slomoButton];
    [self addSubview:_fullscreenButton];
    [self addSubview:_frameForward];
    [self addSubview:_frameBackward];
    //[self addSubview:_playNextButton];
    //[self addSubview:_playPreButton];
    
    _playRateObserverContext = &_playRateObserverContext;
    _telestrationObserverContext = &_telestrationObserverContext;
    
    _displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(displayLinkAction:)];
    _displayLink.frameInterval = 60;
    [_displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    
    self.backgroundColor = [UIColor colorWithWhite:0.95 alpha:1.0];
}

- (nonnull instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initVideoBar];
    }
    return self;
}

- (nullable instancetype)initWithCoder:(nonnull NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initVideoBar];
    }
    return self;
}

- (void)dealloc {
    [_displayLink invalidate];
//    [_playerViewController.telestrationViewController removeObserver:self forKeyPath:@"telestration" context:_telestrationObserverContext];
}

#pragma mark - Overrides

- (void)observeValueForKeyPath:(nullable NSString *)keyPath ofObject:(nullable id)object change:(nullable NSDictionary *)change context:(nullable void *)context {
    if (context == _playRateObserverContext) {
//        if (_playerViewController.playerView.player) {
//            _slomoButton.slomoOn = _playerViewController.playerView.player.playRate == 0.5;
//        }
    } else if (context == _telestrationObserverContext) {
        [self updateUserInterface];
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

- (void)tintColorDidChange {
    [super tintColorDidChange];
    
//    _tagLabel.layer.borderColor = self.tintColor.CGColor;
//    _tagLabel.textColor = self.tintColor;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    const CGFloat w = self.bounds.size.width, h = self.bounds.size.height;
    const CGFloat lh = (h-10);
    const CGFloat tvm = 20;
    _tagView.frame = CGRectMake((3.5 * h)+tvm, 0.0, (w - 7.0 * h)-(tvm*2), h);
    _tagLabel.frame = CGRectMake((w - 4.0 * lh) / 2.0 , 5.0, 4.0 * lh, lh);
    _tagLabel.font = [UIFont systemFontOfSize:PHI_INV * lh];
    
    _tagExtendStartButton.frame = CGRectMake(0.0, 0.0, h, h);
    _tagExtendEndButton.frame = CGRectMake(w - h, 0.0, h, h);
    
    _backwardSeekButton.frame = CGRectMake(h+20, 0.0, h, h);
    _backwardSeekButton.margin = h / 16.0;
    _forwardSeekButton.frame = CGRectMake((w - 2.0 * h)-20, 0.0, h, h);
    _forwardSeekButton.margin = h / 16.0;
    
    _slomoButton.frame = CGRectMake(2.50 * h, 0.0, 1.5 * h, h);
    _fullscreenButton.frame = CGRectMake((w - 2.0 * h - 1.25 * h)-20, 0.0, h, h);
    
    _frameForward.frame = CGRectMake(self.bounds.size.width-30-10,5,30,30);
    _frameBackward.frame = CGRectMake(10,5,30,30);


    //_playNextButton.frame = CGRectMake(w - 4.5 * h, 0.0, h, h);
    //_playPreButton.frame = CGRectMake(3.5 * h , 0.0, h, h);
}

- (nullable UIView *)hitTest:(CGPoint)point withEvent:(nullable UIEvent *)event {
    for (UIView *view in self.subviews) {
        UIView *hit = [view hitTest:[view convertPoint:point fromView:self] withEvent:event];
        if (hit) {
            return hit;
        }
    }
    return [super hitTest:point withEvent:event];
}

#pragma mark - Getters / Setters

- (void)setPlayerViewController:(RicoPlayerViewController *)playerViewController {
    
//    [_playerViewController removeObserver:self forKeyPath:@"primaryPlayers.avPlayer.rate" context:_playRateObserverContext];
//    [_playerViewController.telestrationViewController removeObserver:self forKeyPath:@"telestration" context:_telestrationObserverContext];
    
    _playerViewController = playerViewController;
    
//    [_playerViewController addObserver:self forKeyPath:@"primaryPlayers.avPlayer.rate" options:0 context:_playRateObserverContext];
//    [_playerViewController.telestrationViewController addObserver:self forKeyPath:@"telestration" options:0 context:_telestrationObserverContext];
}

- (void)setEnabled:(BOOL)enabled {
    _enabled = enabled;
    [self updateUserInterface];
}

- (BOOL)teleIsStill {
    return  NO;//_playerViewController.telestrationViewController.telestration.isStill;
}

- (void)showExtendButton{
    _tagExtendStartButton.hidden = NO;
    _tagExtendEndButton.hidden = NO;
}

- (void)setSelectedTag:(nullable Tag *)selectedTag {
    if (_selectedTag != selectedTag) {
        _selectedTag = selectedTag;
        _tagView.hidden = selectedTag;
        _tagLabel.hidden = !selectedTag;
        _tagExtendStartButton.hidden = !selectedTag;
        _tagExtendEndButton.hidden = !selectedTag;
        _tagLabel.text = selectedTag.name;
    }
}

#pragma mark - Actions

- (void)extendStartAction:(UIButton *)button {
    if (_selectedTag) {
        if ([[LocalMediaManager getInstance]getClipByTag:_selectedTag scrKey:nil]){
            Clip * clipToSeverFromEvent = [[LocalMediaManager getInstance]getClipByTag:_selectedTag scrKey:nil];
            [[LocalMediaManager getInstance] breakTagLink:clipToSeverFromEvent];
        }
        
        
        float newStartTime = 0;
        float endTime = _selectedTag.startTime + _selectedTag.duration;
            
        //extend the duration by decreasing the start time 5 seconds
        newStartTime = _selectedTag.startTime - labs((NSInteger)_backwardSeekButton.speed);
        //if the new start time is smaller than 0, set it to 0
        if (newStartTime <0) {
            newStartTime = 0;
        }
        
        //set the new duration to tag end time minus new start time
        int newDuration = endTime - newStartTime;
        
        _selectedTag.startTime = newStartTime;
        
        if (newDuration > _selectedTag.duration) {
            _selectedTag.duration = newDuration;
            [[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_MODIFY_TAG object:_selectedTag];
        }
    }
}

- (void)extendEndAction:(UIButton *)button {
    if (_selectedTag) {
        if ([[LocalMediaManager getInstance]getClipByTag:_selectedTag scrKey:nil]){
            Clip * clipToSeverFromEvent = [[LocalMediaManager getInstance]getClipByTag:_selectedTag scrKey:nil];
            [[LocalMediaManager getInstance] breakTagLink:clipToSeverFromEvent];
        }
        
        
        float startTime = _selectedTag.startTime;
        
        float endTime = startTime + _selectedTag.duration;
        
        //increase end time by 5 seconds
        endTime = endTime + labs((NSInteger)_forwardSeekButton.speed);
        //if new end time is greater the duration of video, set it to the video's duration
        if (endTime > [self durationOfVideoPlayer]) {
            endTime = [self durationOfVideoPlayer];
        }
        
        //get the new duration
        int newDuration = newDuration = endTime - startTime;
        if (newDuration > _selectedTag.duration) {
            _selectedTag.duration = newDuration;
            [[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_MODIFY_TAG object:_selectedTag];
        }

    }
}

- (void)seekAction:(SeekButton *)seekButton {
//    [_playerViewController.playerView.player seekBy:CMTimeMakeWithSeconds(seekButton.speed, 60)];
}

- (void)slomoAction:(Slomo *)slomoButton {
//    slomoButton.slomoOn = !slomoButton.slomoOn;
//    _playerViewController.playerView.player.playRate = slomoButton.slomoOn ? 0.5 : 1.0;
}

#pragma mark - PxpTagDisplayBarDataSource

- (NSTimeInterval)durationInPxpTagDisplayBar:(nonnull PxpTagDisplayBar *)tagDisplayBar {
    return self.durationOfVideoPlayer;
}

-(CGFloat)getSeekSpeed:(NSString *)direction{
    if ([direction isEqualToString:@"forward"]) {
        return _forwardSeekButton.speed;
    }else if ([direction isEqualToString:@"backward"]){
        return _backwardSeekButton.speed;
    }
    return 0;
}

- (nonnull NSArray *)tagsInPxpTagDisplayBar:(nonnull PxpTagDisplayBar *)tagDisplayBar {
    NSMutableArray *arrayOfTagsToDisplay = [[NSMutableArray alloc]init];
    

    
    for (Tag *tag in _event.tags ) {
        if (tag.type == TagTypeNormal
            || tag.type == TagTypeTele
            || tag.type == TagTypeCloseDuration
            || tag.type == TagTypeCloseDurationOLD
//            || tag.type == TagTypeHockeyStrengthStop
//            || tag.type == TagTypeHockeyStopOLine
//            || tag.type == TagTypeHockeyStopDLine
//            || tag.type == TagTypeSoccerZoneStop
//            || tag.type == TagTypeHockeyStartOLine
//            || tag.type == TagTypeHockeyStartDLine
//            || tag.type == TagTypeHockeyPeriodStart
//            || tag.type == TagTypeHockeyPeriodStop
//            || tag.type == TagTypeHockeyOppOLineStart
//            || tag.type == TagTypeHockeyOppOLineStop
//            || tag.type == TagTypeHockeyOppDLineStart
//            || tag.type == TagTypeHockeyOppDLineStop
//            || tag.type == TagTypeHockeyStrengthStart
            ) {
            [arrayOfTagsToDisplay insertObject:tag atIndex:0];
        }
    }
    
    return arrayOfTagsToDisplay;
    //return _event.tags && _player ? _event.tags : @[];
}

- (NSTimeInterval)selectedTimeInPxpTagDisplayBar:(nonnull PxpTagDisplayBar *)tagDisplayBar {
    NSTimeInterval selectedTime = CMTimeGetSeconds(_playerViewController.primaryPlayer.currentTime);
    return isfinite(selectedTime) ? selectedTime : 0.0;
}

- (BOOL)shouldDisplaySelectedTimeInPxpTagDisplayBar:(nonnull PxpTagDisplayBar *)tagDisplayBar {
    return _event.tags.count && _playerViewController.primaryPlayer;
}

#pragma mark - Private Methods

- (void)displayLinkAction:(CADisplayLink *)displayLink {
    [_tagView setNeedsDisplay];
}

- (NSTimeInterval)durationOfVideoPlayer {
    NSTimeInterval duration = CMTimeGetSeconds(_playerViewController.primaryPlayer.duration);
    return isfinite(duration) ? duration : 0.0;
}

- (void)updateUserInterface {
    BOOL enabled = _enabled && !self.teleIsStill;
    
    _backwardSeekButton.enabled = enabled;
    _forwardSeekButton.enabled = enabled;
}

-(void)clear
{
        _selectedTag = nil;
        _tagView.hidden = YES;
        _tagLabel.hidden = YES;
        _tagExtendStartButton.hidden = YES;
        _tagExtendEndButton.hidden = YES;
        _tagLabel.text = @"";
   
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
