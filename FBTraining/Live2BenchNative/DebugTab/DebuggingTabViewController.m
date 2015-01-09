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
#import "Globals.h"
#import "FeedSwitchView.h"
#import "PipViewController.h"
#import "BitrateMonitor.h"
#import "BitRateViewController.h"
#import "Feed.h"
#import "ListPopoverController.h"
#import "FullScreenViewController.h"
#import "L2BFullScreenViewController.h"
#import "VideoPlayer.h"

@interface DebuggingTabViewController ()
{
    
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
    // buid video player
    videoPlayer     = [[VideoPlayer alloc]init];
    [videoPlayer initializeVideoPlayerWithFrame:CGRectMake(0, 60, 800, 600)];
    [self.view addSubview:videoPlayer.view];
    
    
    // Build pip
    pip             = [[Pip alloc]initWithFrame:CGRectMake(300, 300, 200, 150)];
    pip.isDragAble  = YES;
    pip.hidden      = YES;
    pip.dragBounds  = videoPlayer.playerLayer.frame;

   [videoPlayer.view addSubview:pip];
    
    
    feedSwitch = [[FeedSwitchView alloc]initWithFrame:CGRectMake(100, 80, 100, 100) encoderManager:EM];

   [videoPlayer.view addSubview:feedSwitch];
    
    // build pip controller
    pipController = [[PipViewController alloc]initWithVideoPlayer:videoPlayer f:feedSwitch encoderManager:EM];
    [pipController addPip:pip];
    videoPlayer.context = @"debug";


    // build full screen
    fullScreen = [[L2BFullScreenViewController alloc]initWithVideoPlayer:videoPlayer];
    fullScreen.context = @"debug";
    [self.view addSubview:fullScreen.view];


  //  [videoPlayer playFeed:[[Feed alloc]initWithURLString:@"http://192.168.3.100/events/live/video/list_01.m3u8" quality:0]];
    [super viewDidLoad];
    [pipController viewDidLoad];
    


}


-(void)delayed
{
    
    
    fullScreen.enable = YES;
    
    
//    playerStatus st =  PS_Stop;
  
//    videoPlayer.status = st;
    
//    testPopup = [[ListPopoverController alloc]initWithMessage:@"cool" buttonListNames:@[@"Richard",@"Robert"]];
//    [testPopup addOnCompletionBlock:^(NSString *pick) {
//        NSLog(@"First Block %@",pick);
//    }];
//    
//    [testPopup addOnCompletionBlock:^(NSString *pick) {
//        NSLog(@"Second Block %@",pick);
//    }];
//    [testPopup presentPopoverCenteredIn:[UIApplication sharedApplication].keyWindow.rootViewController.view animated:NO];
//    [testPopup presentPopoverFromRect:CGRectMake(0, 0 , 400, 380) inView:[UIApplication sharedApplication].keyWindow.rootViewController.view permittedArrowDirections:0 animated:NO];
}


-(void)multiPip:(NSArray*)paths
{
    int row = 0;
    int col = 0;
    float w = 200;
    float h = 150;
    for (int i = 0; i<5; i++) {
        Pip * tt = [[Pip alloc]initWithFrame:CGRectMake(w *col, 50+(h*row), w, h)];
        [tt playerURL:  [NSURL URLWithString:paths[0]]];
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
    
    
    NSLog(@"DEBUG APPEAR!");

    [self performSelector:@selector(delayed) withObject:nil afterDelay:10];
    [super viewDidAppear:animated];
    
    EM.currentEvent = EM.liveEventName;
    [videoPlayer playFeed:feedSwitch.primaryFeed];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
