//
//  SeekButton.m
//  QuickTest
//
//  Created by dev on 6/16/2014.
//  Copyright (c) 2014 dev. All rights reserved.
//

#import "SeekButton.h"
#import "NumberedSeekerButton.h"


#pragma clang diagnostic ignored "-Warc-performSelector-leaks"

#define LITTLE_ICON_DIMENSIONS      30 //the image is really 33x36
#define LARGE_ICON_DIMENSIONS       50 // this image is really 46x51
#define NORMAL_MARGIN               5
#define LARGE_MARGIN                10

#define NOTIF_SEEK_BUTTON_SYNC_TEXT_NUMBER @"seekButtonSyncTextNumber"

@interface SeekButton ()

@property (assign, nonatomic) BOOL showsSeekControlView;
@property (readonly, assign, nonatomic) CGRect marginBounds;

@end

@implementation SeekButton
{
    NumberedSeekerButton * __nonnull _mainButton;
    SEL __nullable _onSeekSelector;
    id __nullable _seekingTarget;
    
    NSMutableArray * __nonnull _buttons;
    UIView * __nonnull _backPlate;
}

static NSNotificationCenter * __nonnull _localCenter;
static NSArray * __nonnull _defaultSpeeds;
static CGFloat _textNumbers[2] = { 1.0, 1.0 };

+ (void)initialize {
    _localCenter = [[NSNotificationCenter alloc] init];
    _defaultSpeeds                = @[ // in seconds
                                    [NSNumber numberWithFloat:0.1f],
                                    [NSNumber numberWithFloat:0.25f],
                                    [NSNumber numberWithFloat:1.00f],
                                    [NSNumber numberWithFloat:5.00f],
                                    [NSNumber numberWithFloat:10.00f],
                                    [NSNumber numberWithFloat:15.00f],
                                    [NSNumber numberWithFloat:20.00f]
                                    ];
}

+ (nonnull instancetype)makeForwardAt:(CGPoint)pt {
    return [[self alloc] initWithFrame:CGRectMake(pt.x, pt.y, LITTLE_ICON_DIMENSIONS + NORMAL_MARGIN, LITTLE_ICON_DIMENSIONS + NORMAL_MARGIN) backward:NO margin:NORMAL_MARGIN / 2.0];
}

+ (nonnull instancetype)makeBackwardAt:(CGPoint)pt {
    return [[self alloc] initWithFrame:CGRectMake(pt.x, pt.y, LITTLE_ICON_DIMENSIONS + NORMAL_MARGIN, LITTLE_ICON_DIMENSIONS + NORMAL_MARGIN) backward:YES margin:NORMAL_MARGIN / 2.0];
}

+ (nonnull instancetype)makeFullScreenForwardAt:(CGPoint)pt {
    return [[self alloc] initWithFrame:CGRectMake(pt.x, pt.y, LARGE_ICON_DIMENSIONS + LARGE_MARGIN, LARGE_ICON_DIMENSIONS + LARGE_MARGIN) backward:NO margin:LARGE_MARGIN / 2.0];
}

+ (nonnull instancetype)makeFullScreenBackwardAt:(CGPoint)pt {
    return [[self alloc] initWithFrame:CGRectMake(pt.x, pt.y, LARGE_ICON_DIMENSIONS + LARGE_MARGIN, LARGE_ICON_DIMENSIONS + LARGE_MARGIN) backward:YES margin:LARGE_MARGIN / 2.0];
}

- (nonnull instancetype)initWithFrame:(CGRect)frame {
    return [self initWithFrame:frame backward:NO margin:0.0 speeds:_defaultSpeeds];
}

- (nonnull instancetype)initWithFrame:(CGRect)frame backward:(BOOL)backward {
    return [self initWithFrame:frame backward:backward margin:0.0 speeds:_defaultSpeeds];
}

- (nonnull instancetype)initWithFrame:(CGRect)frame backward:(BOOL)backward margin:(CGFloat)margin {
    return [self initWithFrame:frame backward:backward margin:margin speeds:_defaultSpeeds];
}

- (nonnull instancetype)initWithFrame:(CGRect)frame backward:(BOOL)backward margin:(CGFloat)margin speeds:(nonnull NSArray *)speeds {
    self = [super initWithFrame:frame];
    if (self) {
        _backward = backward;
        _speeds = speeds;
        _margin = margin;
        _independent = NO;
        
        _buttons = [NSMutableArray arrayWithCapacity:_speeds.count];
        
        _backPlate = [[UIView alloc] initWithFrame:self.bounds];
        _backPlate.backgroundColor = [UIColor colorWithRed:(195/255.0) green:(207/255.0) blue:(216/255.0) alpha:0.3];
        _backPlate.hidden = YES;
        
        _mainButton = [[NumberedSeekerButton alloc] initWithFrame:self.bounds backward:_backward];
        _mainButton.textNumber = _textNumbers[_backward ? 1 : 0];
        [_mainButton addTarget:self action:@selector(seekAction:) forControlEvents:UIControlEventTouchUpInside];
        
        UILongPressGestureRecognizer *recognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(onLongPressSeekControl:)];
        recognizer.minimumPressDuration = 0.5; //seconds
        [_mainButton addGestureRecognizer:recognizer];
        
        [self addSubview:_backPlate];
        [self addSubview:_mainButton];
        [self rebuildButtons];
        
        [_localCenter addObserver:self selector:@selector(syncTextNumberHandler:) name:NOTIF_SEEK_BUTTON_SYNC_TEXT_NUMBER object:nil];
    }
    return self;
}

- (void)dealloc {
    [_localCenter removeObserver:self];
}

#pragma mark - Overrides

- (void)layoutSubviews {
    [super layoutSubviews];
    
    const CGFloat x = self.bounds.origin.x, y = self.bounds.origin.y, w = self.bounds.size.width, h = self.bounds.size.height;
    const NSUInteger i = _buttons.count;
    
    _backPlate.frame = _showsSeekControlView ? CGRectMake(x, y - (i * h), w, h + (i * h)) : self.bounds;
    _mainButton.frame = self.marginBounds;
    
    for (NSUInteger i = 0; i < _buttons.count; i++) {
        NumberedSeekerButton *button = _buttons[i];
        button.frame = [self marginBoundsForBounds:CGRectMake(x, y - (i + 1) * h, w, h)];
    }
}

- (BOOL)pointInside:(CGPoint)point withEvent:(nullable UIEvent *)event {
    return self.isOpen ? [_backPlate pointInside:[_backPlate convertPoint:point fromView:self] withEvent:event] : [super pointInside:point withEvent:event];
}

- (UIControlEvents)allControlEvents {
    return UIControlEventTouchUpInside;
}

#pragma mark - Getters / Setters

- (void)setBackward:(BOOL)backward {
    _backward = backward;
    
    _mainButton.backward = backward;
    for (NumberedSeekerButton *button in _buttons) {
        button.backward = backward;
    }
}

- (void)setMargin:(CGFloat)margin {
    _margin = margin;
    
    [self setNeedsLayout];
}

- (void)setSpeeds:(nonnull NSArray *)speeds {
    _speeds = speeds;
    
    [self rebuildButtons];
}

-(void)setEnabled:(BOOL)enabled{
    [super setEnabled:enabled];
    
    _mainButton.enabled = enabled;
    if (!enabled) {
        self.showsSeekControlView = NO;
    }
}

- (void)setShowsSeekControlView:(BOOL)showsSeekControlView {
    _showsSeekControlView = showsSeekControlView;
    
    const CGFloat x = self.bounds.origin.x, y = self.bounds.origin.y, w = self.bounds.size.width, h = self.bounds.size.height;
    const NSUInteger i = _buttons.count;
    
    _backPlate.frame = showsSeekControlView ? CGRectMake(x, y - (i * h), w, h + (i * h)) : self.bounds;
    _backPlate.hidden = !showsSeekControlView;
    for (NumberedSeekerButton *button in _buttons) {
        button.hidden = !showsSeekControlView;
    }
}

- (BOOL)isOpen {
    return !_backPlate.hidden;
}

- (CGFloat)speed {
    return self.textNumber * (_backward ? -1.0 : 1.0);
}

- (void)setTextNumber:(CGFloat)textNumber {
    _mainButton.textNumber = textNumber;
    _textNumbers[_backward ? 1 : 0] = textNumber;
    
    if (!_independent) {
        [_localCenter postNotificationName:NOTIF_SEEK_BUTTON_SYNC_TEXT_NUMBER object:self];
    }
}

- (CGFloat)textNumber {
    return _mainButton.textNumber;
}

- (CGRect)marginBounds {
    return [self marginBoundsForBounds:self.bounds];
}

#pragma mark - Notification Handlers

- (void)syncTextNumberHandler:(NSNotification *)note {
    SeekButton *sender = note.object;
    if (!_independent && [sender isKindOfClass:[SeekButton class]] && sender != self && sender.backward == _backward) {
        _mainButton.textNumber = sender.textNumber;
    }
}

#pragma mark - Actions

- (void)speedSelectAction:(NumberedSeekerButton *)button {
    self.textNumber = button.textNumber;
    self.showsSeekControlView = NO;
}

- (void)seekAction:(NumberedSeekerButton *)button {
    [self sendActionsForControlEvents:UIControlEventTouchUpInside];
    if (_seekingTarget && _onSeekSelector) {
        [_seekingTarget performSelector:_onSeekSelector withObject:self];
    }
}

- (void)hideSeekControlViewAction:(NumberedSeekerButton *)button {
    self.showsSeekControlView = NO;
}

#pragma mark - Gesture Recognizers

- (void)onLongPressSeekControl:(UILongPressGestureRecognizer *)gestureRecognizer {
    self.showsSeekControlView = YES;
}

#pragma mark - Public Methods

- (void)onPressSeekPerformSelector:(nullable SEL)sel addTarget:(nullable id)target {
    _seekingTarget = target;
    _onSeekSelector = sel;
}

#pragma mark - Private Methods

/// Rebuilds the numbered seeker buttons in the view
- (void)rebuildButtons {
    const CGFloat x = self.bounds.origin.x, y = self.bounds.origin.y, w = self.bounds.size.width, h = self.bounds.size.height;
    
    // remove existing buttons
    for (NumberedSeekerButton *button in _buttons) {
        [button removeFromSuperview];
    }
    [_buttons removeAllObjects];
    
    // create new buttons
    for (NSUInteger i = 0; i < _speeds.count; i++) {
        NSNumber *speed = _speeds[i];
        
        NumberedSeekerButton *button = [[NumberedSeekerButton alloc] initWithFrame:[self marginBoundsForBounds:CGRectMake(x, y - (i + 1) * h, w, h)] backward:_backward];
        button.textNumber = speed.floatValue;
        
        [_buttons addObject:button];
        [self addSubview:button];
        
        [button addTarget:self action:@selector(speedSelectAction:) forControlEvents:UIControlEventTouchUpInside];
        [button addTarget:self action:@selector(hideSeekControlViewAction:) forControlEvents:UIControlEventTouchDragInside];
        button.hidden = YES;
    }
}

/// Returns the given bounds with the button's margin applied
- (CGRect)marginBoundsForBounds:(CGRect)bounds {
    return CGRectMake(bounds.origin.x + _margin, bounds.origin.y + _margin, bounds.size.height - 2.0 * _margin, bounds.size.height - 2.0 * _margin);
}

@end

