//
//  DebuggingTabViewController.m
//  Live2BenchNative
//
//  Created by dev on 10/10/2014.
//  Copyright (c) 2014 DEV. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>

#import "DebuggingTabViewController.h"
#import "EncoderManager.h"
#import "UserCenter.h"
//#import "Encoder.h"
//#import "PxpPlayer.h"
//#import "Pip.h"
//#import "Feed.h"
//#import "RJLVideoPlayer.h"


@interface DebuggingTabViewController ()
{

    EncoderManager              * EM;
    UserCenter                  * UC;
//    PxpPlayer                   * player;
//    Pip                         * pip;
    UIView                      * playArea;
    AVPlayer    * pl;
    AVPlayerLayer      * avPlayerLayer;
//    RJLVideoPlayer              * rjlPlayer;
    
    UIButton                    * playBtn;
    UIButton                    * seekBtn;
    UIButton                    * pauseBtn;
    UIButton                    * switchBtn;
    UILabel                     * label;
}
@end

static void *  debugContext = &debugContext;


@implementation DebuggingTabViewController
{
    
    NSURL *url;
    NSArray * paths;
    AVURLAsset *asset;
    NSInteger  pick;
}
/**
 *  New init method
 *
 *  @param mainappDelegate
 *
 *  @return
 */

@synthesize debug;
@synthesize string;

-(id)initWithAppDelegate:(AppDelegate *)mainappDelegate
{
    self = [super initWithAppDelegate:mainappDelegate];
    if (self) {
        UC = _appDel.userCenter;
        EM = _appDel.encoderManager;
        [self setMainSectionTab:@"Debug" imageName:@""];
        [self.view setBackgroundColor:[UIColor lightGrayColor]];
        
//        pip = [[Pip alloc]initWithFrame:CGRectMake(100,100,800,400)];
        
  
        
    }
    
    return self;
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
//    rjlPlayer = [[RJLVideoPlayer alloc]initWithFrame:CGRectMake(100,200,800,400)];
    
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    // build View
//    
//    UIView             * xxxplayerView;
//    NSURL              * xxxurl;
//    AVPlayerItem       * xxxplayeritem;
//    AVPlayer           * xxxplayer;
//    AVPlayerLayer      * xxxavPlayerLayer;
//    
//    
//    xxxplayerView       = [[UIView alloc]initWithFrame:CGRectMake(0, 40, 800, 400)];
//    xxxurl             = [NSURL URLWithString:@"http://192.168.2.119/events/live/video/list_00lq.m3u8"];
//   xxxplayeritem      = [[AVPlayerItem alloc] initWithURL:xxxurl];
//   xxxplayer          = [AVPlayer playerWithPlayerItem:xxxplayeritem];
//   xxxavPlayerLayer   = [AVPlayerLayer playerLayerWithPlayer:xxxplayer];
//    
//    xxxplayerView.layer.borderWidth  = 1;
//    xxxavPlayerLayer.frame                  = CGRectMake(0,0,800,400);
//// 
////    
//    [xxxplayerView.layer addSublayer:xxxavPlayerLayer ];
//    [self.view addSubview:xxxplayerView];
////   
//    [xxxplayer play];
////    
//   return;
    
    
    playArea = [[UIView alloc]initWithFrame:CGRectMake(100,100,800,400)];

    
     paths = @[
                        [NSURL URLWithString:@"http://walterebert.com/playground/video/hls/sintel-trailer.m3u8"],
                        [NSURL URLWithString:@"http://192.168.2.119/events/live/video/list_00lq.m3u8"],
                        [NSURL URLWithString:@"http://devimages.apple.com/iphone/samples/bipbop/bipbopall.m3u8"],
                        [NSURL URLWithString:@"http://192.168.8.114/events/2015-10-14_09-20-22_8b0077f142d12ba23325ad4dd7ea03c2e64976b0_local/video/list_00hq.m3u8"],
                        [NSURL URLWithString:@"http://192.168.8.114/events/2015-10-14_09-20-22_8b0077f142d12ba23325ad4dd7ea03c2e64976b0_local/video/list_00lq.m3u8"],
                        
                        ];
    
    


    
    
    pick = 4;
    url         = paths[pick];
    
    
    NSLog(@"playing in Debugger: %@",[url absoluteString]);
   AVPlayerItem * item = [[AVPlayerItem alloc]initWithURL:url];
//    item.canUseNetworkResourcesForLiveStreamingWhilePaused = NO;
    pl                  = [[AVPlayer alloc]initWithPlayerItem:item];

    avPlayerLayer       = [AVPlayerLayer playerLayerWithPlayer:pl];
    avPlayerLayer.frame =CGRectMake(0,0,800,400);
   
    [playArea.layer addSublayer:avPlayerLayer];
    playArea.layer.borderWidth = 1;

    [self.view addSubview:playArea];
    
    
    
    

    CGFloat yy = 500;
    CGFloat ww = 100;
    CGFloat hh = 50;
    
    playBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, yy, ww, hh)];
    [playBtn addTarget:self action:@selector(buttonPress:) forControlEvents:UIControlEventTouchUpInside];
    [playBtn setTitle:@"play" forState:UIControlStateNormal];
    
    seekBtn = [[UIButton alloc]initWithFrame:CGRectMake(ww+10, yy, ww, hh)];
    [seekBtn addTarget:self action:@selector(buttonPress:) forControlEvents:UIControlEventTouchUpInside];
    [seekBtn setTitle:@"seek to 30" forState:UIControlStateNormal];
    
    pauseBtn = [[UIButton alloc]initWithFrame:CGRectMake((ww*2)+10, yy, ww, hh)];
    [pauseBtn addTarget:self action:@selector(buttonPress:) forControlEvents:UIControlEventTouchUpInside];
    [pauseBtn setTitle:@"pause" forState:UIControlStateNormal];
    
    switchBtn = [[UIButton alloc]initWithFrame:CGRectMake((ww*3)+10, yy, ww, hh)];
    [switchBtn addTarget:self action:@selector(buttonPress:) forControlEvents:UIControlEventTouchUpInside];
    [switchBtn setTitle:@"Switch" forState:UIControlStateNormal];
    
    [self.view addSubview:playBtn];
    [self.view addSubview:seekBtn];
    [self.view addSubview:pauseBtn];
    [self.view addSubview:switchBtn];
    
    
    label = [[UILabel alloc]initWithFrame:CGRectMake(50, yy+hh+10, 1000, hh)];
     [self.view addSubview:label];
    
    [label setText:[url absoluteString]];
}








-(void)buttonPress:(id)sender
{
    if (sender == playBtn) {
       [pl play];
//        [pl setRate:1];
    }
    else if (sender == seekBtn) {
        [pl seekToTime:CMTimeMakeWithSeconds(60*21, NSEC_PER_SEC)];

    }
    else if (sender == pauseBtn) {
         [pl pause];
//        [pl setRate:0];
//        [pl setRate:0.0000001];
    }
    else if (sender == switchBtn) {
        pick = (pick)?0:1;
        url         = paths[pick];
     
        AVPlayerItem * item = [[AVPlayerItem alloc]initWithURL:url];
        [pl replaceCurrentItemWithPlayerItem:item];
        [label setText:[url absoluteString]];
    }

}


















-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
}

- (void)didReceiveMemoryWarning
{
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_RECEIVE_MEMORY_WARNING object:self userInfo:nil];
    [super didReceiveMemoryWarning];
    if ([self.view window] == nil) self.view = nil;
    
}


@end