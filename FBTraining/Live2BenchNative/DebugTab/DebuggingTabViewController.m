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
#import "FeedSwitchView.h"
#import "PipViewController.h"
#import "BitrateMonitor.h"
#import "BitRateViewController.h"
#import "Feed.h"
#import "ListPopoverController.h"
#import "FullScreenViewController.h"
#import "L2BFullScreenViewController.h"
#import "RJLVideoPlayer.h"
#import "DownloadItem.h"
#import "Downloader.h"
#import "DownloadEventItem.h"
#import "UserCenter.h"
#import "RatingOutput.h"

#import "Encoder.h"

#import "FeedInspector.h"
#import "PxpUserFilter.h"

@interface DebuggingTabViewController ()
{
    RJLVideoPlayer              * testPlayer;
    

    Pip    * pip;
    Pip    * pip2;
    UIView * rectOutline;
    
    EncoderManager              * EM;
    UserCenter                  * UC;
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
    
    UIButton * openButton;
    UIButton * closeButton;
    UIButton * stepButton;
    __block DebuggingTabViewController * weakSelf;

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

@synthesize debug;
@synthesize string;

-(id)initWithAppDelegate:(AppDelegate *)mainappDelegate
{
    self = [super initWithAppDelegate:mainappDelegate];
    if (self) {
        UC = _appDel.userCenter;
        EM = _appDel.encoderManager;
        [self setMainSectionTab:@"DEBUG" imageName:@""];
        [self.view setBackgroundColor:[UIColor lightGrayColor]];
        
        weakSelf = self;
        
        
        
        
        /*testPlayer = [[RJLVideoPlayer alloc]initWithFrame:CGRectMake(100, 100, 400, 400)];
        testPlayer.playerContext = @"Test";
        [self .view addSubview:testPlayer.view];*/

        
        
      
        
        RatingOutput *ratingoutput = [[RatingOutput alloc] initWithFrame:CGRectMake(400, 400, 400, 400) ];
        ratingoutput.rating = 2;

         [self.view addSubview:ratingoutput];
    }
    
    return self;
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    UIImageView * img = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"playbackRateButtonBackSelected.png"]];
    img.frame = CGRectMake(120, 100, 200, 200);
    [self.view addSubview:img];
    UIVisualEffectView          * blurEffect;
    UIBlurEffect * effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    blurEffect = [[UIVisualEffectView alloc]initWithEffect:effect];
    blurEffect.frame = CGRectMake(100, 100, 200, 200);
    
    [self.view addSubview:blurEffect];
    blurEffect.layer.borderWidth = 1;
    
    
    openButton  = [[UIButton alloc]initWithFrame:CGRectMake(300, 300, 100, 50)];
    [openButton setTitle:@"open" forState:UIControlStateNormal];
    [openButton addTarget:self action:@selector(onOpen:) forControlEvents:UIControlEventTouchUpInside];
    closeButton = [[UIButton alloc]initWithFrame:CGRectMake(430, 300, 100, 50)];
    [closeButton setTitle:@"close" forState:UIControlStateNormal];
    [closeButton addTarget:self action:@selector(onClose:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:closeButton];
    [self.view addSubview:openButton];
    
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(checkup:) name:NOTIF_FEED_INSPECTION_COMPLETE object:nil];
    // Encoder * testestset = (Encoder*)EM.primaryEncoder;
    
    // Event * theE = testestset.event;
    
    // Feed * someFeed = [[theE.feeds allValues]firstObject];
    
    Feed * someFeed2 = [[Feed alloc]initWithURLString:@"http://192.168.1.109/events/live/video/listzz.m3u8" quality:0];
    
    [FeedInspector investigate:someFeed2];
    
    ////
    
    
    PxpUserFilter * testFilterUser = [[PxpUserFilter alloc]initWithFrame:CGRectMake(100, 600, 420,50)];
    
    
    [testFilterUser buildButtonsWith:@[
  @{@"user":@"alsdkfj",@"color":[UIColor redColor]},
  @{@"user":@"aaaaa",@"color":[UIColor greenColor]},
  @{@"user":@"bbbb",@"color":[UIColor blueColor]},
  @{@"user":@"ccc",@"color":[UIColor yellowColor]}  ]];
    [self.view addSubview:testFilterUser];
}


-(void)checkup:(NSNotification*)note
{

    // Feed * someFeed = note.object;

}

-(void)onOpen:(id)sender
{
    [[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_TAG_POSTED object:self userInfo:@{
                                                                                                      @"name":@"PP",
                                                                                                      @"time":[NSString stringWithFormat:@"%d",10],
                                                                                                      @"duration":[NSNumber numberWithBool:YES]
                                                                                                      }];
}

-(void)onClose:(id)sender
{
    Tag * tag;
    NSLog(@"");
   // tag.type = TagTypeCloseDuration;
//    tag.time = 60;
    
    NSMutableDictionary * dick = [[NSMutableDictionary alloc]initWithDictionary:[tag makeTagData]];
    [dick setObject:[NSNumber numberWithInteger:TagTypeCloseDuration] forKey:@"type"];    
    [dick setObject:[NSString stringWithFormat:@"%f",60.000000] forKey:@"closetime"];
    
    
//    add close time to the post
//    time gets rest when it gets to the encoder.
//    but make sure that the event is still getting the open tag, just not displaying them in the views
//    
    [[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_MODIFY_TAG object:nil userInfo:dick];
    
    
}

- (void)didReceiveMemoryWarning
{
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_RECEIVE_MEMORY_WARNING object:self userInfo:nil];
    [super didReceiveMemoryWarning];
    if ([self.view window] == nil) self.view = nil;
    
}


@end