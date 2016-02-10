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

        
        
        
        
        
        
        

        
        _liveButton.frame                   = CGRectMake(0,0, 130.0, 30.0);
        _startRangeModifierButton.frame     = CGRectMake(0,0, 44.0, 44.0);
        _endRangeModifierButton.frame       = CGRectMake(0,0, 44.0, 44.0);
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
        
        _backwardSeekButton.center  = CGPointMake(maxx*0.1, alignY);
        _forwardSeekButton.center   = CGPointMake(maxx*0.9, alignY);
        _slomoButton.center         = CGPointMake(maxx*0.2, alignY);
        _fullscreenButton.center    = CGPointMake(maxx*0.8, alignY);
        
        _startRangeModifierButton.center       = CGPointMake(maxx*0.96, alignY);
        _endRangeModifierButton.center         = CGPointMake(maxx*0.04, alignY);
        _currentTagLabel.center                = CGPointMake(midx, alignY);
        _liveButton.center                     = CGPointMake(maxx*0.67, alignY);
        
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
      
        

        _liveObject       = @[_controlBar, _backwardSeekButton, _forwardSeekButton, _slomoButton, _fullscreenButton, _liveButton];
        _eventObject      = @[_controlBar, _backwardSeekButton, _forwardSeekButton, _slomoButton, _fullscreenButton, _liveButton];
        _clipObject       = @[_controlBar, _backwardSeekButton, _forwardSeekButton, _slomoButton, _fullscreenButton, _liveButton, _startRangeModifierButton, _endRangeModifierButton, _currentTagLabel];
        _allObjects       = @[_controlBar, _backwardSeekButton, _forwardSeekButton, _slomoButton, _fullscreenButton, _liveButton, _startRangeModifierButton, _endRangeModifierButton, _currentTagLabel];
        _disabledObject   = @[_controlBar, _fullscreenButton];
        _listObject       = @[_controlBar, _backwardSeekButton, _forwardSeekButton, _slomoButton, _fullscreenButton, _currentTagLabel];
        _listNonTagObject = @[_controlBar, _backwardSeekButton, _forwardSeekButton, _slomoButton, _fullscreenButton];
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


@end
