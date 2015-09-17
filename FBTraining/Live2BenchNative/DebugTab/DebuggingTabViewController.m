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
#import "Encoder.h"
#import "PxpPlayer.h"
#import "Pip.h"
#import "Feed.h"

@interface DebuggingTabViewController ()
{

    EncoderManager              * EM;
    UserCenter                  * UC;
    PxpPlayer                   * player;
    Pip                         * pip;
    UIView                      * playArea;
    AVPlayer    * pl;
    AVPlayerLayer      * avPlayerLayer;
}
@end

static void *  debugContext = &debugContext;


@implementation DebuggingTabViewController
{
    
    NSURL *url;
    
    AVURLAsset *asset;
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
        
        pip = [[Pip alloc]initWithFrame:CGRectMake(100,100,800,400)];
        
        playArea = [[UIView alloc]initWithFrame:CGRectMake(100,100,800,400)];
        
    }
    
    return self;
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    

}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    url         = [NSURL URLWithString:@"http://192.168.10.220/events/live/video/list.m3u8"];
    asset       = [AVURLAsset URLAssetWithURL:url options:nil];
    AVPlayerItem * item;
    item = [[AVPlayerItem alloc]initWithAsset:asset];
//    item = [[AVPlayerItem alloc]initWithURL:url];
    
    pl = [[AVPlayer alloc]initWithPlayerItem:item];
    avPlayerLayer = [AVPlayerLayer playerLayerWithPlayer:pl];
    avPlayerLayer.frame           =CGRectMake(0,0,800,400);
    [playArea.layer addSublayer:avPlayerLayer];
    playArea.layer.borderWidth = 1;

//   [self performSelector:@selector(setupvideo) withObject:self afterDelay:10];
    [self.view addSubview:playArea];
    [pl play];
}

//-(void)setupvideo
//{
////    player      = [[PxpPlayer alloc]initWithPlayerItem:[[AVPlayerItem alloc] initWithAsset:asset]];
////    [self.view.layer addSublayer:[AVPlayerLayer playerLayerWithPlayer:player]];
//    [pl play];
//}
//

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