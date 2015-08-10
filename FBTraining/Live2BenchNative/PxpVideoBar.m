//
//  PxpVideoBar.m
//  Live2BenchNative
//
//  Created by Nico Cvitak on 2015-07-29.
//  Copyright © 2015 DEV. All rights reserved.
//

#import "PxpVideoBar.h"
#import "LocalMediaManager.h"

#import "TagView.h"
#import "UIColor+Highlight.h"
#import "PxpFullscreenButton.h"
#import "PxpRangeModifierButton.h"

@interface PxpVideoBar ()<TagViewDataSource>

@end

@implementation PxpVideoBar
{
    CADisplayLink * __nonnull _displayLink;
    
    TagView * __nonnull _tagView;
    UILabel * __nonnull _tagLabel;
    
    PxpRangeModifierButton * __nonnull _tagExtendStartButton;
    PxpRangeModifierButton * __nonnull _tagExtendEndButton;
    
    void *_playRateObserverContext;
}

- (void)initVideoBar {
    _tagView = [[TagView alloc] init];
    _tagView.backgroundColor = [UIColor clearColor];
    _tagView.dataSource = self;
    _tagLabel = [[UILabel alloc] init];
    _tagLabel.layer.borderWidth = 1.0;
    _tagLabel.layer.borderColor = self.tintColor.CGColor;
    _tagLabel.textColor = self.tintColor;
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
    
    _fullscreenButton = [[PxpFullscreenButton alloc] init];
    
    [self addSubview:_tagView];
    [self addSubview:_tagLabel];
    [self addSubview:_tagExtendStartButton];
    [self addSubview:_tagExtendEndButton];
    [self addSubview:_backwardSeekButton];
    [self addSubview:_forwardSeekButton];
    [self addSubview:_slomoButton];
    [self addSubview:_fullscreenButton];
    
    _playRateObserverContext = &_playRateObserverContext;
    [self addObserver:self forKeyPath:@"player.playRate" options:0 context:_playRateObserverContext];
    
    _displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(displayLinkAction:)];
    _displayLink.frameInterval = 4;
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

- (nonnull instancetype)initWithCoder:(nonnull NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initVideoBar];
    }
    return self;
}

- (void)dealloc {
    [_displayLink invalidate];
    [self removeObserver:self forKeyPath:@"player.playRate" context:_playRateObserverContext];
}

#pragma mark - Overrides

- (void)observeValueForKeyPath:(nullable NSString *)keyPath ofObject:(nullable id)object change:(nullable NSDictionary *)change context:(nullable void *)context {
    if (context == _playRateObserverContext) {
        if (_player) {
            _slomoButton.slomoOn = _player.playRate < 1.0;
        }
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

- (void)tintColorDidChange {
    [super tintColorDidChange];
    
    _tagLabel.layer.borderColor = self.tintColor.CGColor;
    _tagLabel.textColor = self.tintColor;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    const CGFloat w = self.bounds.size.width, h = self.bounds.size.height;
    
    _tagView.frame = CGRectMake(3.5 * h, 0.0, w - 7.0 * h, h);
    _tagLabel.frame = CGRectMake((w - 5.0 * h) / 2.0, 0.0, 5.0 * h, h);
    _tagLabel.font = [UIFont systemFontOfSize:PHI_INV * h];
    
    _tagExtendStartButton.frame = CGRectMake(0.0, 0.0, h, h);
    _tagExtendEndButton.frame = CGRectMake(w - h, 0.0, h, h);
    
    _backwardSeekButton.frame = CGRectMake(h, 0.0, h, h);
    _backwardSeekButton.margin = h / 16.0;
    _forwardSeekButton.frame = CGRectMake(w - 2.0 * h, 0.0, h, h);
    _forwardSeekButton.margin = h / 16.0;
    
    _slomoButton.frame = CGRectMake(2.0 * h, 0.0, 1.5 * h, h);
    _fullscreenButton.frame = CGRectMake(w - 2.0 * h - 1.25 * h, 0.0, h, h);
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
        newStartTime = _selectedTag.startTime - 5;
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
        endTime = endTime + 5;
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
    CMTime currentTime = _player.currentTime;
    [_player seekToTime:CMTimeAdd(currentTime, CMTimeMakeWithSeconds(seekButton.speed, currentTime.timescale))];
}

- (void)slomoAction:(Slomo *)slomoButton {
    slomoButton.slomoOn = !slomoButton.slomoOn;
    _player.playRate = slomoButton.slomoOn ? 0.5 : 1.0;
}

#pragma mark - TagViewDataSource

- (NSTimeInterval)durationInTagView:(nonnull TagView *)tagView {
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

- (nonnull NSArray *)tagsInTagView:(nonnull TagView *)tagView {
    NSMutableArray *arrayOfTagsToDisplay = [[NSMutableArray alloc]init];
    for (Tag *tag in _event.tags ) {
        if (tag.type == TagTypeNormal || tag.type == TagTypeTele || tag.type == TagTypeCloseDuration || tag.type == TagTypeHockeyStrengthStop || tag.type == TagTypeHockeyStopOLine || tag.type == TagTypeHockeyStopDLine || tag.type == TagTypeSoccerZoneStop) {
            [arrayOfTagsToDisplay insertObject:tag atIndex:0];
        }
    }
    
    return arrayOfTagsToDisplay;
    //return _event.tags && _player ? _event.tags : @[];
}

- (NSTimeInterval)selectedTimeInTagView:(nonnull TagView *)tagView {
    NSTimeInterval selectedTime = CMTimeGetSeconds(_player.currentTime);
    return isfinite(selectedTime) ? selectedTime : 0.0;
}

- (BOOL)shouldDisplaySelectedTimeInTagView:(nonnull TagView *)tagView {
    return _event.tags.count && _player;
}

#pragma mark - Private Methods

- (void)displayLinkAction:(CADisplayLink *)displayLink {
    if (!self.hidden) {
        [_tagView setNeedsDisplay];
    }
}

- (NSTimeInterval)durationOfVideoPlayer{
    CMTimeRange range = [_player.currentItem.seekableTimeRanges.firstObject CMTimeRangeValue];
    NSTimeInterval duration = CMTimeGetSeconds(CMTimeAdd(range.start, range.duration));
    return isfinite(duration) ? duration : 0.0;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
