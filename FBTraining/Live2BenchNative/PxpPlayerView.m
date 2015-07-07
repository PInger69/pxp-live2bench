//
//  PxpPlayerView.m
//  PxpPlayer
//
//  Created by Nico Cvitak on 2015-06-10.
//  Copyright © 2015 Nicholas Cvitak. All rights reserved.
//

#import "PxpPlayerView.h"

#define MAX_ZOOM_SCALE 16.0

@interface PxpAVPlayerView : UIView

@property (readonly, strong, nonatomic, nonnull) AVPlayerLayer *layer;

@end

@implementation PxpAVPlayerView

@dynamic layer;

+ (Class)layerClass
{
    return [AVPlayerLayer class];
}

@end

@interface PxpPlayerView () <UIScrollViewDelegate>

@property (strong, nonatomic, nonnull) UIScrollView *scrollView;
@property (strong, nonatomic, nonnull) PxpAVPlayerView *avPlayerView;

@property (strong, nonatomic, nonnull) UILabel *nameLabel;
@property (strong, nonatomic, nonnull) UILabel *zoomLabel;

@property (strong, nonatomic, nonnull) UIActivityIndicatorView *activityIndicator;

@property (strong, nonatomic, nonnull) UIVisualEffectView *blurView;
@property (strong, nonatomic, nonnull) UIVisualEffectView *vibrancyView;
@property (strong, nonatomic, nonnull) UILabel *failedLabel;

@property (strong, nonatomic, nonnull) NSTimer *timer;

@end

@implementation PxpPlayerView
{
    void *_statusContext;
    void *_nameContext;
    
    void *_failedObserverContext;
    void *_motionObserverContext;
}

- (void)initPlayerView {
    _scrollView = [[UIScrollView alloc] init];
    _avPlayerView = [[PxpAVPlayerView alloc] init];
    
    _nameLabel = [[UILabel alloc] init];
    _nameLabel.font = [UIFont systemFontOfSize:18.0];
    _nameLabel.textColor = [UIColor whiteColor];
    _nameLabel.layer.shadowColor = [UIColor blackColor].CGColor;
    _nameLabel.layer.shadowOpacity = 1.0;
    _nameLabel.layer.shadowRadius = 1.0;
    _nameLabel.layer.shadowOffset = CGSizeZero;
    _nameLabel.textAlignment = NSTextAlignmentLeft;
    
    _zoomLabel = [[UILabel alloc] init];
    _zoomLabel.font = [UIFont systemFontOfSize:18.0];
    _zoomLabel.textColor = self.tintColor;
    _zoomLabel.layer.shadowColor = [UIColor blackColor].CGColor;
    _zoomLabel.layer.shadowOpacity = 1.0;
    _zoomLabel.layer.shadowRadius = 1.0;
    _zoomLabel.layer.shadowOffset = CGSizeZero;
    _zoomLabel.textAlignment = NSTextAlignmentRight;
    
    _activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    _activityIndicator.color = self.tintColor;
    _activityIndicator.hidesWhenStopped = YES;
    
    UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    UIVibrancyEffect *vibrancyEffect = [UIVibrancyEffect effectForBlurEffect:blurEffect];
    
    _blurView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    _blurView.hidden = YES;
    _vibrancyView = [[UIVisualEffectView alloc] initWithEffect:vibrancyEffect];
    
    _failedLabel = [[UILabel alloc] init];
    _failedLabel.font = [UIFont systemFontOfSize:72.0];
    _failedLabel.textColor = [UIColor redColor];
    _failedLabel.layer.shadowColor = [UIColor redColor].CGColor;
    _failedLabel.layer.shadowOpacity = 1.0;
    _failedLabel.layer.shadowRadius = 1.0;
    _failedLabel.layer.shadowOffset = CGSizeZero;
    _failedLabel.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
    _failedLabel.textAlignment = NSTextAlignmentCenter;
    _failedLabel.adjustsFontSizeToFitWidth = YES;
    _failedLabel.text = @"☠";
    
    _zoomEnabled = YES;
    
    _scrollView.minimumZoomScale = 1.0;
    _scrollView.maximumZoomScale = MAX_ZOOM_SCALE;
    _scrollView.bounces = NO;
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.showsVerticalScrollIndicator = NO;
    _scrollView.bouncesZoom = NO;
    
    _scrollView.delegate = self;
    
    [self addSubview:_scrollView];
    [_scrollView addSubview:_avPlayerView];
    [self addSubview:_blurView];
    [_blurView.contentView addSubview:_vibrancyView];
    [_vibrancyView.contentView addSubview:_failedLabel];
    
    [self addSubview:_nameLabel];
    [self addSubview:_zoomLabel];
    [self addSubview:_activityIndicator];
    
    _timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(timerTick:) userInfo:nil repeats:YES];
    
    _statusContext = &_statusContext;
    _nameContext = &_nameContext;
    
    _failedObserverContext = &_failedObserverContext;
    _motionObserverContext = &_motionObserverContext;
    
    [self addObserver:self forKeyPath:@"player.currentItem.status" options:0 context:_statusContext];
    [self addObserver:self forKeyPath:@"player.name" options:0 context:_nameContext];
    
    [self addObserver:self forKeyPath:@"player.failed" options:0 context:_failedObserverContext];
    //[self addObserver:self forKeyPath:@"player.motion" options:0 context:_motionObserverContext];
    
    self.backgroundColor = [UIColor blackColor];
    
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initPlayerView];
    }
    return self;
}

- (instancetype)initWithCoder:(nonnull NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initPlayerView];
    }
    return self;
}

- (instancetype)init {
    return [self initWithFrame:CGRectZero];
}

- (void)dealloc {
    [self removeObserver:self forKeyPath:@"player.currentItem.status" context:_statusContext];
    [self removeObserver:self forKeyPath:@"player.name" context:_nameContext];
    
    [self removeObserver:self forKeyPath:@"player.failed" context:_failedObserverContext];
    //[self removeObserver:self forKeyPath:@"player.motion" context:_motionObserverContext];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    
    if (context == _statusContext) {
        if (self.player.currentItem.status == AVPlayerItemStatusUnknown) {
            [self.activityIndicator startAnimating];
        } else {
            [self.activityIndicator stopAnimating];
        }
    } else if (context == _nameContext) {
        self.nameLabel.text = self.player.name;
    } else if (context == _motionObserverContext) {
        self.nameLabel.textColor = self.player.motion ? self.tintColor : [UIColor whiteColor];
    } else if (context == _failedObserverContext) {
        self.blurView.hidden = self.player.currentItem.status == AVPlayerItemStatusUnknown || self.player.currentItem.seekableTimeRanges.firstObject;
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

- (void)timerTick:(NSTimer *)timer {
    
}

#pragma mark - Getters / Setters

- (void)setPlayer:(nullable PxpPlayer *)player {
    [self willChangeValueForKey:@"player"];
    self.avPlayerView.layer.player = player;
    [self didChangeValueForKey:@"player"];
}

- (nullable PxpPlayer *)player {
    return [self.avPlayerView.layer.player isKindOfClass:[PxpPlayer class]] ? (PxpPlayer *)self.avPlayerView.layer.player : nil;
}

- (CGRect)videoRect {
    
    CGRect rect = self.avPlayerView.layer.videoRect;
    
    return CGRectMake(rect.origin.x / self.scrollView.zoomScale, rect.origin.y / self.scrollView.zoomScale, rect.size.width / self.scrollView.zoomScale, rect.size.height / self.scrollView.zoomScale);
    
    
    return rect;
}

- (void)setVideoGravity:(nonnull NSString *)videoGravity {
    [self willChangeValueForKey:@"videoGravity"];
    self.avPlayerView.layer.videoGravity = videoGravity;
    [self didChangeValueForKey:@"videoGravity"];
}

- (nonnull NSString *)videoGravity {
    return self.avPlayerView.layer.videoGravity;
}

- (void)setShowsName:(BOOL)showsName {
    [self willChangeValueForKey:@"showsName"];
    self.nameLabel.hidden = !showsName;
    [self didChangeValueForKey:@"showsName"];
}

- (BOOL)showsName {
    return !self.nameLabel.hidden;
}

- (void)setShowsZoomLevel:(BOOL)showsZoomLevel {
    [self willChangeValueForKey:@"showsZoomLevel"];
    self.zoomLabel.hidden = !showsZoomLevel;
    [self didChangeValueForKey:@"showsZoomLevel"];
}

- (BOOL)showsZoomLevel {
    return !self.zoomLabel.hidden;
}

- (void)setZoomEnabled:(BOOL)zoomEnabled {
    [self willChangeValueForKey:@"zoomEnabled"];
    
    if (!zoomEnabled) {
        self.scrollView.zoomScale = 1.0;
        self.scrollView.contentSize = self.scrollView.bounds.size;
        
        self.avPlayerView.frame = self.scrollView.bounds;
    }
    
    self.scrollView.maximumZoomScale = zoomEnabled ? MAX_ZOOM_SCALE : 1.0;
    
    _zoomEnabled = zoomEnabled;
    
    [self didChangeValueForKey:@"zoomEnabled"];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    if (!self.scrollView.zooming) {
        self.scrollView.frame = self.bounds;
        
        self.scrollView.zoomScale = 1.0;
        self.scrollView.contentSize = self.scrollView.bounds.size;
        
        self.avPlayerView.frame = self.scrollView.bounds;
        
    }
    
    self.nameLabel.frame = CGRectMake(0, 0, self.bounds.size.width, 22);
    self.zoomLabel.frame = CGRectMake(0, 0, self.bounds.size.width, 22);
    
    self.activityIndicator.frame = self.bounds;
    
    self.blurView.frame = self.bounds;
    self.vibrancyView.frame = self.blurView.bounds;
    self.failedLabel.frame = self.vibrancyView.bounds;
    
}

- (void)tintColorDidChange {
    [super tintColorDidChange];
    self.activityIndicator.color = self.tintColor;
    self.zoomLabel.textColor = self.tintColor;
    self.nameLabel.textColor = self.player.motion ? self.tintColor : [UIColor whiteColor];
}

#pragma mark - UIScrollViewDelegate

- (nullable UIView *)viewForZoomingInScrollView:(nonnull UIScrollView *)scrollView {
    return self.avPlayerView;
}

- (void)scrollViewDidZoom:(nonnull UIScrollView *)scrollView {
    self.zoomLabel.text = self.scrollView.zoomScale > 1.0 ? [NSString stringWithFormat:@"%.1fx", self.scrollView.zoomScale] : nil;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
