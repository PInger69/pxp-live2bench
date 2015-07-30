//
//  PxpVideoBar.m
//  Live2BenchNative
//
//  Created by Nico Cvitak on 2015-07-29.
//  Copyright © 2015 DEV. All rights reserved.
//

#import "PxpVideoBar.h"

#import "TagView.h"
#import "UIColor+Highlight.h"

@interface PxpVideoBar ()<TagViewDataSource>

@end

static UIImage * __nonnull _tagExtendStartImage;
static UIImage * __nonnull _tagExtendEndImage;

@implementation PxpVideoBar
{
    TagView * __nonnull _tagView;
    NSTimer * __nullable _tagViewTimer;
    UILabel * __nonnull _tagLabel;
    
    CustomButton * __nonnull _tagExtendStartButton;
    CustomButton * __nonnull _tagExtendEndButton;
}

+ (void)initialize {
    _tagExtendStartImage = [UIImage imageNamed:@"extendstartsec"];
    _tagExtendEndImage = [UIImage imageNamed:@"extendendsec"];
}

- (void)initVideoBar {
    _tagView = [[TagView alloc] init];
    _tagView.backgroundColor = [UIColor clearColor];
    _tagLabel = [[UILabel alloc] init];
    _tagLabel.backgroundColor = [UIColor lightGrayColor];
    _tagLabel.layer.borderWidth = 1.0;
    _tagLabel.layer.borderColor = self.tintColor.CGColor;
    _tagLabel.textColor = self.tintColor;
    _tagLabel.adjustsFontSizeToFitWidth = YES;
    _tagLabel.textAlignment = NSTextAlignmentCenter;
    _tagLabel.hidden = YES;
    
    _tagExtendStartButton = [[CustomButton alloc] init];
    _tagExtendEndButton = [[CustomButton alloc] init];
    _tagExtendStartButton.contentMode = UIViewContentModeCenter;
    _tagExtendEndButton.contentMode = UIViewContentModeCenter;
    [_tagExtendStartButton setImage:_tagExtendStartImage forState:UIControlStateNormal];
    [_tagExtendEndButton setImage:_tagExtendEndImage forState:UIControlStateNormal];
    [_tagExtendStartButton addTarget:self action:@selector(extendStartAction:) forControlEvents:UIControlEventTouchUpInside];
    [_tagExtendEndButton addTarget:self action:@selector(extendEndAction:) forControlEvents:UIControlEventTouchUpInside];
    _tagExtendStartButton.hidden = YES;
    _tagExtendEndButton.hidden = YES;
    
    _backwardSeekButton = [[SeekButton alloc] initWithFrame:CGRectZero backward:YES];
    _forwardSeekButton = [[SeekButton alloc] initWithFrame:CGRectZero backward:NO];
    _slomoButton = [[Slomo alloc] init];
    
    [self addSubview:_tagView];
    [self addSubview:_tagLabel];
    [self addSubview:_tagExtendStartButton];
    [self addSubview:_tagExtendEndButton];
    [self addSubview:_backwardSeekButton];
    [self addSubview:_forwardSeekButton];
    [self addSubview:_slomoButton];
    
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
    [_tagViewTimer invalidate];
}

#pragma mark - Overrides

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
        
        [_tagViewTimer invalidate];
        _tagViewTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(tagViewTimerEvent:) userInfo:nil repeats:YES];
    }
}

#pragma mark - Actions

- (void)extendStartAction:(CustomButton *)button {
    if (_selectedTag) {
        _selectedTag.startTime -= fabs(_backwardSeekButton.speed);
        _selectedTag.duration += fabs(_backwardSeekButton.speed);
        [[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_MODIFY_TAG object:_selectedTag];
    }
}

- (void)extendEndAction:(CustomButton *)button {
    if (_selectedTag) {
        _selectedTag.duration += fabs(_forwardSeekButton.speed);
        [[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_MODIFY_TAG object:_selectedTag];
    }
}

#pragma mark - TagViewDataSource

- (NSTimeInterval)durationInTagView:(nonnull TagView *)tagView {
    CMTimeRange range = [_player.currentItem.seekableTimeRanges.firstObject CMTimeRangeValue];
    NSTimeInterval duration = CMTimeGetSeconds(CMTimeAdd(range.start, range.duration));
    return isfinite(duration) ? duration : 0.0;
}

- (nonnull NSArray *)tagsInTagView:(nonnull TagView *)tagView {
    return _event.tags && _player ? _event.tags : @[];
}

- (NSTimeInterval)selectedTimeInTagView:(nonnull TagView *)tagView {
    NSTimeInterval selectedTime = CMTimeGetSeconds(_player.currentTime);
    return isfinite(selectedTime) ? selectedTime : 0.0;
}

- (BOOL)shouldDisplaySelectedTimeInTagView:(nonnull TagView *)tagView {
    return _event.tags.count && _player;
}

#pragma mark - Private Methods

- (void)tagViewTimerEvent:(NSTimer *)timer {
    if (!self.hidden) {
        [_tagView setNeedsDisplay];
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
