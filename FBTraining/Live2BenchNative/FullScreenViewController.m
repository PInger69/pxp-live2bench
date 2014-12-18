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
    id      observerCloseFullScreen;
    id      observerOpenFullScreen;
}


@end

@implementation FullScreenViewController

@synthesize player  = _player;
@synthesize enable  = _enable;
@synthesize context = _context;

-(id)initWithVideoPlayer:(VideoPlayer *) videoPlayer
{
    self = [super init];
    if (self) {
        
        // getting all videoPlayer data
        _player          = videoPlayer;
        _enable          = NO;
        screenBounds     = CGRectMake(0, 0, 1024, 768);

       
        self.view = [[UIView alloc]initWithFrame:screenBounds];
        //[self.view setBackgroundColor:[UIColor redColor]];
        [self.view setHidden:YES];
        [self   buildAddSubview:_player];
        
        // this is so we know what Video Player belongs to what
        _context = @"";
        
        
        observerCloseFullScreen = [[NSNotificationCenter defaultCenter]addObserverForName:NOTIF_SMALLSCREEN object:nil queue:nil usingBlock:^(NSNotification *note) {
            if ([[note.userInfo objectForKey:@"context"] isEqualToString:_context]){
                self.enable = NO;
            }
        }];
        
        observerOpenFullScreen  = [[NSNotificationCenter defaultCenter]addObserverForName:NOTIF_FULLSCREEN object:nil queue:nil usingBlock:^(NSNotification *note) {
            if ([[note.userInfo objectForKey:@"context"] isEqualToString:_context]){
                self.enable = YES;
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


-(void)moveVideoToFullScreen
{
    if (_player.view.superview == self.view) return;
    

    prevView                = (_player.view.superview)?_player.view.superview:nil;
    prevDispayIndex         = [[prevView subviews]indexOfObject:_player.view];
    prevPlayerViewRect      = _player.view.frame;
    prevPlayerViewBounds    = _player.view.bounds;
    prevPlayerLayerRect     = _player.playerLayer.frame;
    prevPlayerLayerBounds   = _player.playerLayer.bounds;
    [_player.playerLayer removeAllAnimations];
   // setting to external screen
    
    [UIView beginAnimations:@"scaleAnimation" context:nil];
    [UIView setAnimationDuration:0.22];
    _player.view.frame              = screenBounds;
    _player.view.bounds             = screenBounds;
    _player.playerLayer.frame       = screenBounds;
    _player.playerLayer.bounds      = screenBounds;
    [UIView commitAnimations];

    [self.view insertSubview:_player.view atIndex:0];
    
}

-(void)returnVideoToPreviousViewFromFullScreen
{
    if (_player.view.superview == prevView || prevView == nil) return;
    
    
    [prevView insertSubview:_player.view atIndex:prevDispayIndex];
    [_player.playerLayer removeAllAnimations];

    [UIView beginAnimations:@"scaleAnimation" context:nil];
    [UIView setAnimationDuration:0.22];
    _player.view.frame              = prevPlayerViewRect;
    _player.view.bounds             = prevPlayerViewBounds;
    _player.playerLayer.frame       = prevPlayerLayerRect;
    _player.playerLayer.bounds      = prevPlayerLayerBounds;
    [UIView commitAnimations];
    prevView                        = nil;
    [_player.view addSubview:_player.richVideoControlBar];
}





-(void)setEnable:(BOOL)enable
{
    if (enable == _enable) return;
    
    [self willChangeValueForKey:@"enable"];
    if (_enable && !enable){
        // to false
        [self.view setHidden:YES];
        [self viewDidDisappear:NO];
        [self returnVideoToPreviousViewFromFullScreen];
    } else if (!_enable && enable){
        // to true
        [self.view setHidden:NO];
        [self viewDidAppear:NO];
        [self moveVideoToFullScreen];
    }
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
