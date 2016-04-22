//
//  RicoFullScreenControlBar.m
//  Live2BenchNative
//
//  Created by dev on 2016-02-08.
//  Copyright © 2016 DEV. All rights reserved.
//

#import "RicoFullScreenControlBar.h"

@implementation RicoFullScreenControlBar
{
    NSArray * _allObjects;
    NSArray * _liveObject;
    NSArray * _disabledObject;
    NSArray * _clipObject;
    NSArray * _listObject;
    NSArray * _listNonTagObject;
    NSArray * _eventObject;
    NSArray * _bookmarkObject;
    
    NSArray * _teleStill;
    NSArray * _teleAnimated;
}

@synthesize mode = _mode;
- (instancetype)init
{
    self = [super init];
    if (self) {
        _backwardSeekButton = [[SeekButton alloc] initWithBackward:YES];
        _forwardSeekButton  = [[SeekButton alloc] initWithBackward:NO];
        _slomoButton        = [[Slomo alloc] init];

        _fullscreenButton   = [[PxpFullscreenButton alloc] init];
        _fullscreenButton.isFullscreen = YES;
        _controlBar         = [[RicoPlayerControlBar alloc]initWithFrame:CGRectMake(0.0, 0.0, 1024,46)];
        
        _liveButton                 = [[LiveButton alloc] init];
        _startRangeModifierButton   = [[PxpRangeModifierButton alloc] initWithEnd:NO];
        _endRangeModifierButton     = [[PxpRangeModifierButton alloc] initWithEnd:YES];
        _currentTagLabel            = [[PxpBorderLabel alloc] init];

        
        _previousTagButton          = [[PxpBorderButton alloc] init];
        _nextTagButton              = [[PxpBorderButton alloc] init];
        
        _previousTagButton.frame    = CGRectMake(0, 0, 150, 44);
        _nextTagButton.frame        = CGRectMake(0, 0, 150, 44);
        
        
        CGFloat rmSize = 60.0;
        
        _liveButton.frame                   = CGRectMake(0,0, 130.0, 30.0);
        _startRangeModifierButton.frame     = CGRectMake(0,0, rmSize, rmSize);
        _endRangeModifierButton.frame       = CGRectMake(0,0, rmSize, rmSize);
        _currentTagLabel.frame              = CGRectMake(0,0, 150.0, 44.0);

        
        
        
        
        
        
        
        
        self.frame = CGRectMake(0.0, 0.0, 1024,100);
//        self.backgroundColor = [UIColor blueColor];
        CGRect contentRect =  CGRectMake(0.0, 55.0, 1024,713);

        const CGFloat contentWidth = contentRect.size.width, contentHeight = contentRect.size.height;
        
        // player
        const CGFloat playerWidth = contentWidth, playerHeight = playerWidth / (16.0 / 9.0);
        const CGFloat playerX = 0.0, playerY = (contentHeight - playerHeight) / 2.0;
        
        CGFloat alignY = 80;

        // button size
        const CGFloat buttonHeight = contentHeight - playerY - playerHeight;
        
        const CGFloat margin = 8.0;
        
        _slomoButton.frame = CGRectMake(2.5 * buttonHeight + margin, margin, 1.5 * buttonHeight - 2.0 * margin, buttonHeight - 2.0 * margin);
        _fullscreenButton.frame = CGRectMake(contentWidth - buttonHeight - 2.75 * buttonHeight + margin, margin, buttonHeight - 2.0 * margin, buttonHeight - 2.0 * margin);
  
        _backwardSeekButton.frame   = CGRectMake(0,0, buttonHeight, buttonHeight);
        _forwardSeekButton.frame    = CGRectMake(0,0, buttonHeight, buttonHeight);

        
        CGFloat maxx = CGRectGetMaxX(contentRect);
        CGFloat minx = CGRectGetMinX(contentRect);
        CGFloat midx = CGRectGetMidX(contentRect);
        
        _backwardSeekButton.center  = CGPointMake(maxx*0.16, alignY);
        _forwardSeekButton.center   = CGPointMake(maxx*0.84, alignY);
        _slomoButton.center         = CGPointMake(maxx*0.22, alignY);
        _fullscreenButton.center    = CGPointMake(maxx*0.78, alignY);
        
        _startRangeModifierButton.center       = CGPointMake(maxx*0.05, alignY);
        _endRangeModifierButton.center         = CGPointMake(maxx*0.95, alignY);
        _currentTagLabel.center                = CGPointMake(midx, alignY);
        _liveButton.center                     = CGPointMake(maxx*0.67, alignY);
        
        _previousTagButton.center    = CGPointMake(maxx*0.33, alignY);
        _nextTagButton.center        = CGPointMake(maxx*0.67, alignY);
        [_previousTagButton setTitle:NSLocalizedString(@"PREVIOUS", nil) forState:UIControlStateNormal];
        [_nextTagButton setTitle:NSLocalizedString(@"NEXT", nil) forState:UIControlStateNormal];
        // bottom bar buttons
      

        [self addSubview:_controlBar];
        [self addSubview:_backwardSeekButton];
        [self addSubview:_forwardSeekButton];
        
        [self addSubview:_slomoButton];
        [self addSubview:_fullscreenButton];
        [self addSubview:_liveButton];
        
        [self addSubview:_startRangeModifierButton];
        [self addSubview:_endRangeModifierButton];
        [self addSubview:_currentTagLabel];
      
        [self addSubview:_previousTagButton];
        [self addSubview:_nextTagButton];

        _liveObject       = @[_controlBar, _backwardSeekButton, _forwardSeekButton, _slomoButton, _fullscreenButton, _liveButton];
        _eventObject      = @[_controlBar, _backwardSeekButton, _forwardSeekButton, _slomoButton, _fullscreenButton, _liveButton];
        _clipObject       = @[_controlBar, _backwardSeekButton, _forwardSeekButton, _slomoButton, _fullscreenButton, _liveButton, _startRangeModifierButton, _endRangeModifierButton, _currentTagLabel];
        _allObjects       = @[_controlBar, _backwardSeekButton, _forwardSeekButton, _slomoButton, _fullscreenButton, _liveButton, _startRangeModifierButton, _endRangeModifierButton, _currentTagLabel,_previousTagButton,_nextTagButton];
        _disabledObject   = @[_controlBar, _fullscreenButton];
        _listObject       = @[_controlBar, _backwardSeekButton, _forwardSeekButton, _slomoButton, _fullscreenButton, _startRangeModifierButton, _endRangeModifierButton, _currentTagLabel];
        _listNonTagObject = @[_controlBar, _backwardSeekButton, _forwardSeekButton, _slomoButton, _fullscreenButton];
        _bookmarkObject   = @[_controlBar, _backwardSeekButton, _forwardSeekButton, _slomoButton, _fullscreenButton,_previousTagButton,_nextTagButton,_currentTagLabel];
        
        _teleStill        = @[_controlBar, _backwardSeekButton, _forwardSeekButton, _slomoButton, _fullscreenButton, _liveButton, _currentTagLabel];
        _teleAnimated     = @[];
        
        self.mode = RicoFullScreenModeDisable;
    }
    return self;
}


-(void)setMode:(RicoFullScreenModes)mode
{
    for (UIView *v in _allObjects) {
        v.hidden = YES;
    }
    NSArray * obj;
    
    switch (mode) {
        case RicoFullScreenModeLive:
            _controlBar.state = RicoPlayerStateLive;
            obj = _liveObject;
            break;
        
        case RicoFullScreenModeEvent:
            _controlBar.state = RicoPlayerStateNormal;
            obj = _eventObject;
            break;
        case RicoFullScreenModeBookmark:
            _controlBar.state = RicoPlayerStateNormal;
            obj = _bookmarkObject;
            break;
        case RicoFullScreenModeClip:
            _controlBar.state = RicoPlayerStateRange;
            obj = _clipObject;
            break;
        case RicoFullScreenModeList:
            _controlBar.state = RicoPlayerStateRange;
            obj = _listObject;
            break;
        case RicoFullScreenModeListNonTag:
            _controlBar.state = RicoPlayerStateNormal;
            obj = _listNonTagObject;
            break;
            
        case RicoFullScreenModeTeleStill:
            _controlBar.state = RicoPlayerStateTelestrationStill;
            obj = _teleStill;
            break;
        case RicoFullScreenModeTeleAnimated:
            _controlBar.state = RicoPlayerStateTelestrationAnimated;
            obj = _teleAnimated;
            break;
            
        case RicoFullScreenModeDisable:
            obj = _disabledObject;
            [self.controlBar clear];
            break;
            
        default:
            break;
    }
  
    for (UIView *v in obj) {
        v.hidden = NO;
    }
    
    _mode = mode;
}

-(RicoFullScreenModes)mode
{
    return _mode;
}



//
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    if (!self.clipsToBounds && !self.hidden && self.alpha > 0) {
        for (UIView *subview in self.subviews.reverseObjectEnumerator) {
            CGPoint subPoint = [subview convertPoint:point fromView:self];
            UIView *result = [subview hitTest:subPoint withEvent:event];
            if (result != nil) {
                return result;
            }
        }
    }
    
    return [super hitTest:point withEvent:event];;
}



@end
