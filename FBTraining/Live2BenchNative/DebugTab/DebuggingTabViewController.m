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
#import "DownloadItem.h"
#import "Downloader.h"
#import "DownloadEventItem.h"
#import "UserCenter.h"
#import "PxpLog.h"

@interface DebuggingTabViewController ()
{
    RJLVideoPlayer              * testPlayer;
    
    
    VideoPlayer                 * videoPlayer;
    Pip    * pip;
    Pip    * pip2;
    UIView * rectOutline;
    
    EncoderManager       * EM;
    UserCenter          * UC;
    FeedSwitchView              * feedSwitch ;
    PipViewController           * pipController;
    BitrateMonitor              * testRate;
    BitRateViewController       * brViewController;
    ListPopoverController       * testPopup;
    L2BFullScreenViewController    * fullScreen;
    
    
    DownloadItem * DOWNLOADITEM;
    DownloadItem * DOWNLOADITEM1;
    DownloadItem * DOWNLOADITEM2;
    DownloadItem * dddd;
    UIProgressView * proBar;
    UILabel * lbl;
    
    UIButton * playButton;
    UIButton * pauseButton;
    UIButton * stepButton;
    __block DebuggingTabViewController * weakSelf;
    PxpLog * l;
}
@end

static void *  debugContext = &debugContext;


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
        UC = _appDel.userCenter;
        EM = _appDel.encoderManager;
        [self setMainSectionTab:@"DEBUG" imageName:@""];
        [self.view setBackgroundColor:[UIColor lightGrayColor]];
        
        weakSelf = self;
        
        
        testPlayer = [[RJLVideoPlayer alloc]initWithFrame:CGRectMake(100, 100, 400, 400)];
        testPlayer.playerContext = @"Test";
        [self .view addSubview:testPlayer.view];

        
    }
    
    return self;
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
}




-(void)viewWillAppear:(BOOL)animated
{
//        testPlayer = [[RJLVideoPlayer alloc]initWithFrame:CGRectMake(100, 100, 400, 400)];
//    [self .view addSubview:testPlayer.view];
//        Feed * fff =[[Feed alloc]initWithURLString:@"http://192.168.1.154/events/2015-04-21_09-38-18_3dc550ff6dfb7df9cc4668cdcbf8bb779758c36b_local/video/main.mp4" quality:0];
//    [testPlayer playFeed:fff];

}



- (void)didReceiveMemoryWarning
{
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_RECEIVE_MEMORY_WARNING object:self userInfo:nil];
    [super didReceiveMemoryWarning];
    if ([self.view window] == nil) self.view = nil;
    
}


@end