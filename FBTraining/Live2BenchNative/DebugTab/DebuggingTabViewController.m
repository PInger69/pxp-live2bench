//
//  DebuggingTabViewController.m
//  Live2BenchNative
//
//  Created by dev on 10/10/2014.
//  Copyright (c) 2014 DEV. All rights reserved.
//

#import "DebuggingTabViewController.h"
#import "Pip.h"
#import "EncoderManager.h"
//#import "Globals.h"
#import "FeedSwitchView.h"
#import "PipViewController.h"
#import "BitrateMonitor.h"
#import "BitRateViewController.h"
#import "Feed.h"
#import "ListPopoverController.h"
#import "FullScreenViewController.h"
#import "L2BFullScreenViewController.h"
#import "VideoPlayer.h"
#import "RJLVideoPlayer.h"

@interface DebuggingTabViewController ()
{
    RJLVideoPlayer              * testPlayer;
    
    
    VideoPlayer                 * videoPlayer;
    Pip    * pip;
    Pip    * pip2;
    UIView * rectOutline;
    
    EncoderManager       * EM;
    FeedSwitchView              * feedSwitch ;
    PipViewController           * pipController;
    BitrateMonitor              * testRate;
    BitRateViewController       * brViewController;
    ListPopoverController       * testPopup;
    L2BFullScreenViewController    * fullScreen;
}
@end

@implementation DebuggingTabViewController

/**
 *  New init method
 *
 *  @param mainappDelegate
 *
 *  @return
 */
-(id)initWithAppDelegate:(AppDelegate *)mainappDelegate
{
    self = [super initWithAppDelegate:mainappDelegate];
    if (self) {
        
        EM = _appDel.encoderManager;
        [self setMainSectionTab:@"DEBUG" imageName:@""];
        [self.view setBackgroundColor:[UIColor lightGrayColor]];
        
        
        rectOutline = [[UIView alloc]initWithFrame:CGRectMake(100, 100, 10, 10)];
        rectOutline.layer.borderColor = [[UIColor redColor]CGColor];
        rectOutline.layer.borderWidth = 1;
    
    }

    return self;
    
}

- (void)viewDidLoad
{
    
    
    
    testPlayer = [[RJLVideoPlayer alloc]init];
    

    
    
    
    
    
    // buid video player
    videoPlayer     = [[VideoPlayer alloc]init];
    [videoPlayer initializeVideoPlayerWithFrame:CGRectMake(0, 60, 400, 300)];
    [self.view addSubview:videoPlayer.view];
    videoPlayer.playerContext = @"debug";
    
//     Build pip
    pip             = [[Pip alloc]initWithFrame:CGRectMake(300, 300, 200, 150)];
    pip.isDragAble  = YES;
    pip.hidden      = YES;
    pip.dragBounds  = videoPlayer.playerLayer.frame;

   [videoPlayer.view addSubview:pip];
    
    
    feedSwitch = [[FeedSwitchView alloc]initWithFrame:CGRectMake(100, 80, 100, 100) encoderManager:EM];

   [videoPlayer.view addSubview:feedSwitch];
    
//     build pip controller
    pipController = [[PipViewController alloc]initWithVideoPlayer:videoPlayer f:feedSwitch encoderManager:EM];
    [pipController addPip:pip];
    


//     build full screen
    fullScreen = [[L2BFullScreenViewController alloc]initWithVideoPlayer:videoPlayer];
    fullScreen.context = @"debug";
    [self.view addSubview:fullScreen.view];


    [super viewDidLoad];
    [pipController viewDidLoad];
    
   
//
//        pip2 = [[Pip alloc]initWithFrame:CGRectMake(30, 500, 200, 150)];
//
//        [self.view addSubview:pip2];
//    [pip2 playerURL:[[NSURL alloc]initWithString:@"http://192.168.1.111/events/live/video/list_00hq.m3u8"]];
    
    [self multiPip:@[@"http://192.168.1.111/events/live/video/list_00hq.m3u8",
                     @"http://192.168.1.111/events/live/video/list_01hq.m3u8",
                     @"http://192.168.1.111/events/live/video/list_02hq.m3u8"]];
    
    
    
    UIButton * butt = [[UIButton alloc]initWithFrame:CGRectMake(50, 400, 50, 50)];
    [butt addTarget:self action:@selector(buttonPress:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:butt];
    butt.layer.borderWidth = 1;
    [self.view addSubview:testPlayer.view];
  
}




-(void)buttonPress:(id)sender
{
    
    Feed * myFeed = [[Feed alloc]initWithURLString:@"http://192.168.1.111/events/live/video/list_00hq.m3u8" quality:1];
    
//    NSURL * urls = [[NSURL alloc]initWithString:@"http://192.168.1.111/events/live/video/list_00hq.m3u8"];
//    [testPlayer setURL:urls];
    
    
    
    
//    [testPlayer live];
    
    NSDictionary * command = @{  @"command":[NSNumber numberWithInteger:VideoPlayerCommandPlayFeed],
                                    @"feed":myFeed,
                                   };//@"range":NSvalue
    
    
    [[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_COMMAND_VIDEO_PLAYER object:nil userInfo:command];

}



-(void)multiPip:(NSArray*)paths
{
    int row = 0;
    int col = 0;
    float w = 200;
    float h = 150;
    for (int i = 0; i<[paths count]; i++) {
        Pip * tt = [[Pip alloc]initWithFrame:CGRectMake(w *col, 500+(h*row), w, h)];
        [tt playerURL:  [NSURL URLWithString:paths[i]]];
        tt.isDragAble = YES;
        [self.view addSubview:tt];
        if (col++ > 3){
            col = 0;
            row++;
        }
        
    }
}



-(void)viewWillAppear:(BOOL)animated
{

    [super viewWillAppear:animated];
}


-(void)viewDidAppear:(BOOL)animated
{



    
//    [testPlayer performSelector:@selector(play) withObject:nil afterDelay:5];
    NSLog(@"DEBUG APPEAR!");

//    [self performSelector:@selector(delayed) withObject:nil afterDelay:10];
    [super viewDidAppear:animated];
    
    EM.currentEvent = EM.liveEventName;
    [videoPlayer playFeed:feedSwitch.primaryFeed];
    
    
    
}

- (void)didReceiveMemoryWarning
{
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_RECEIVE_MEMORY_WARNING object:self userInfo:nil];
    [super didReceiveMemoryWarning];
    if ([self.view window] == nil) self.view = nil;
    
}



@end
