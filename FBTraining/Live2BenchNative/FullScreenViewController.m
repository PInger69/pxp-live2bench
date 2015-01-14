//
//  FullScreenViewController.m
//  Live2BenchNative
//
//  Created by dev on 9/25/2014.
//  Copyright (c) 2014 DEV. All rights reserved.
//



/**
 *  This is meant to manage all the functionality of all object that will be in full screen mode
 *
 *  This is an Abstract class
 *
 *
 */
#import "FullScreenViewController.h"

@interface FullScreenViewController ()
{
    id                  observerCloseFullScreen;
    id                  observerOpenFullScreen;
    NSDictionary        * smallScreenFramesParts;
    NSDictionary        * fullScreenFramesParts;
}


@end

@implementation FullScreenViewController

@synthesize player   = _player;
@synthesize enable   = _enable;
@synthesize context  = _context;
@synthesize animated = _animated;

-(id)initWithVideoPlayer:(VideoPlayer *) videoPlayer
{
    self = [super init];
    if (self) {
        
        // getting all videoPlayer data
        _player          = videoPlayer;
        _enable          = NO;
        _animated        = YES;
        screenBounds     = CGRectMake(0, 0, 1024, 768);

       
        self.view = [[UIView alloc]initWithFrame:screenBounds];
        //[self.view setBackgroundColor:[UIColor redColor]];
        [self.view setHidden:YES];
        [self   buildAddSubview:_player];
        
        // this is so we know what Video Player belongs to what
        _context = @"";
        
        
        observerCloseFullScreen = [[NSNotificationCenter defaultCenter]addObserverForName:NOTIF_SMALLSCREEN object:nil queue:nil usingBlock:^(NSNotification *note) {
            if ([[note.userInfo objectForKey:@"context"] isEqualToString:_context] && _enable ){
                if ([note.userInfo objectForKey:@"animated"]){
                    _animated = [[note.userInfo objectForKey:@"animated"]boolValue];
                }
                [self setEnable:NO];
            }
        }];
        
        observerOpenFullScreen  = [[NSNotificationCenter defaultCenter]addObserverForName:NOTIF_FULLSCREEN object:nil queue:nil usingBlock:^(NSNotification *note) {
            if ([[note.userInfo objectForKey:@"context"] isEqualToString:_context] && !_enable){
                if ([note.userInfo objectForKey:@"animated"]){
                    _animated = [[note.userInfo objectForKey:@"animated"]boolValue];
                }
                [self setEnable:YES];
            }
        }];
        
       
    }
    return self;
}



/**
 *  This is meant to be overriden to allow for customization
 */
-(void)buildAddSubview:(VideoPlayer*)player {

}


-(void)moveVideoToFullScreen:(BOOL)animated
{
    if (_player.view.superview == self.view) return;
    
    if (!smallScreenFramesParts){
        smallScreenFramesParts = @{
                                   @"light" : [NSValue valueWithCGRect:_player.liveIndicatorLight.frame],
                                   @"bar"   : [NSValue valueWithCGRect:_player.richVideoControlBar.frame],
                                   @"slide" : [NSValue valueWithCGRect:_player.richVideoControlBar.timeSlider.frame]
                                   //@"status" : [NSValue valueWithCGRect:_player.liveIndicatorLight.frame]
                                   };
        fullScreenFramesParts = @{
                                   @"light" : [NSValue valueWithCGRect:CGRectMake(screenBounds.size.width-32,
                                                                                  60,
                                                                                  _player.liveIndicatorLight.frame.size.width,
                                                                                  _player.liveIndicatorLight.frame.size.height)],
                                   
                                   @"bar"   : [NSValue valueWithCGRect:CGRectMake(0,
                                                                                  640,
                                                                                  screenBounds.size.width,
                                                                                  _player.richVideoControlBar.frame.size.height)],
                                   @"slide" : [NSValue valueWithCGRect:CGRectMake(0,
                                                                                  0,
                                                                                  screenBounds.size.width-200,
                                                                                  _player.richVideoControlBar.timeSlider.frame.size.height)]
                                   //@"status" : [NSValue valueWithCGRect:_player.liveIndicatorLight.frame],
                                   };
    }
    
    

    prevView                = (_player.view.superview)?_player.view.superview:nil;
    prevDispayIndex         = [[prevView subviews]indexOfObject:_player.view];
    prevPlayerViewRect      = _player.view.frame;
    prevPlayerViewBounds    = _player.view.bounds;
    prevPlayerLayerRect     = _player.playerLayer.frame;
    prevPlayerLayerBounds   = _player.playerLayer.bounds;
    [_player.playerLayer removeAllAnimations];
   // setting to external screen
    
    if (animated){
        [UIView beginAnimations:@"scaleAnimation" context:nil];
        [UIView setAnimationDuration:0.22];
    }
    _player.view.frame                              = screenBounds;
    _player.view.bounds                             = screenBounds;
    _player.playerLayer.frame                       = screenBounds;
    _player.playerLayer.bounds                      = screenBounds;
    _player.liveIndicatorLight.frame                = [((NSValue *)[fullScreenFramesParts objectForKey:@"light"]) CGRectValue];
    _player.richVideoControlBar.frame               = [((NSValue *)[fullScreenFramesParts objectForKey:@"bar"]) CGRectValue];
    _player.richVideoControlBar.timeSlider.frame    = [((NSValue *)[fullScreenFramesParts objectForKey:@"slide"]) CGRectValue];
    if (animated){
        [UIView commitAnimations];
    }
    [self.view insertSubview:_player.view atIndex:0];
    
}

-(void)returnVideoToPreviousViewFromFullScreen:(BOOL)animated
{
    if (_player.view.superview == prevView || prevView == nil) return;
    
    [prevView insertSubview:_player.view atIndex:prevDispayIndex];
    [_player.playerLayer removeAllAnimations];
    if (animated){
        [UIView beginAnimations:@"scaleAnimation" context:nil];
        [UIView setAnimationDuration:0.22];
    }
    _player.view.frame              = prevPlayerViewRect;
    _player.view.bounds             = prevPlayerViewBounds;
    _player.playerLayer.frame       = prevPlayerLayerRect;
    _player.playerLayer.bounds      = prevPlayerLayerBounds;
    _player.liveIndicatorLight.frame                = [((NSValue *)[smallScreenFramesParts objectForKey:@"light"]) CGRectValue];
    _player.richVideoControlBar.frame               = [((NSValue *)[smallScreenFramesParts objectForKey:@"bar"]) CGRectValue];
    _player.richVideoControlBar.timeSlider.frame    = [((NSValue *)[smallScreenFramesParts objectForKey:@"slide"]) CGRectValue];
    if (animated){
        [UIView commitAnimations];
    }
    
    prevView                        = nil;
    [_player.view addSubview:_player.richVideoControlBar];
}





-(void)setEnable:(BOOL)enable
{
    if (enable == _enable) return;
    
   
    if (_enable && !enable){
        // to false
        [self.view setHidden:YES];
        [self viewDidDisappear:NO];
        [self returnVideoToPreviousViewFromFullScreen:_animated];
        _player.isFullScreen = NO;
    } else if (!_enable && enable){
        // to true
        [self.view setHidden:NO];
        [self viewDidAppear:NO];
        [self moveVideoToFullScreen:_animated];
        _player.isFullScreen = YES;
    }
    [self willChangeValueForKey:@"enable"];
    _enable = enable;
    [self didChangeValueForKey:@"enable"];
}

-(BOOL)enable
{
    return _enable;
}


- (void)didReceiveMemoryWarning
{
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_RECEIVE_MEMORY_WARNING object:self userInfo:nil];
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
