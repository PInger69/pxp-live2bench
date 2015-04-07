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

#import "UserCenter.h"

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
    UIProgressView * proBar;
    UILabel * lbl;
    
    UIButton * playButton;
    UIButton * pauseButton;
    UIButton * stepButton;
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
        
        
        rectOutline = [[UIView alloc]initWithFrame:CGRectMake(100, 100, 10, 10)];
        rectOutline.layer.borderColor = [[UIColor redColor]CGColor];
        rectOutline.layer.borderWidth = 1;
        proBar = [[UIProgressView alloc]initWithFrame:CGRectMake(100, 100, 700, 10)];
        
        lbl = [[UILabel alloc]initWithFrame:CGRectMake(100, 120,200, 20)];

        
        
        
        NSObject * obj1 = [[NSObject alloc]init];
        NSObject * obj2 = [[NSObject alloc]init];
       
        
        NSValue * val1 = [NSValue valueWithNonretainedObject:obj1];
        NSValue * val2 = [NSValue valueWithNonretainedObject:obj2];
        NSMapTable      * map   = [NSMapTable weakToWeakObjectsMapTable];
        NSDictionary    * dict;
        
        NSMutableString * testString = [NSMutableString stringWithString:@"aKey"];
       
        dict = @{val1:@"someValueB" , testString:@"anotherValueB"};
        [map setObject:@"someValueA" forKey:val2];
        [map setObject:@"anotherValueA" forKey:testString];
        
        
        testString = [NSMutableString stringWithString:@"bKey"];

        
        
        
        
        NSLog(@"%@",[dict objectForKey:val1]);
        NSLog(@"%@",[map objectForKey:val2]);
        
        NSLog(@"%@",[dict objectForKey:testString]);
        NSLog(@"%@",[map objectForKey:testString]);
    }

    return self;
    
}

- (void)viewDidLoad
{
   playButton = [[UIButton alloc]initWithFrame:CGRectMake(100, 400, 50, 50)];
    [playButton addTarget:self action:@selector(play) forControlEvents:UIControlEventTouchUpInside];
    [playButton setTitle:@"playButton" forState:UIControlStateNormal];
    
    pauseButton  = [[UIButton alloc]initWithFrame:CGRectMake(200, 400, 50, 50)];
    [pauseButton addTarget:self action:@selector(pause) forControlEvents:UIControlEventTouchUpInside];
    [pauseButton setTitle:@"pauseButton" forState:UIControlStateNormal];
    
   stepButton = [[UIButton alloc]initWithFrame:CGRectMake(300, 400, 50, 50)];
    [stepButton addTarget:self action:@selector(step) forControlEvents:UIControlEventTouchUpInside];
    [stepButton setTitle:@"stepButton" forState:UIControlStateNormal];
    
    [self.view addSubview:playButton];
    [self.view addSubview:pauseButton];
    [self.view addSubview:stepButton];
    
    testPlayer = [[RJLVideoPlayer alloc]init];
    
    
    pip = [[Pip alloc]initWithFrame:CGRectMake(100, 100, 200, 200)];
    [self.view addSubview:pip];

//    Feed * myFeed = [[Feed alloc]initWithURLString:@"/var/mobile/Applications/0DC1A65A-8396-4F64-860A-40773C3F610F/Documents/bookmark/bookmarkvideo/2015-03-10_14-46-56_89b83b667964eb20d4ee2feef88311580b47a25e_local_00hq_vid_3.mp4" quality:1];
 
    NSURL *url = [[NSURL alloc] initFileURLWithPath: @"/Documents/bookmark/bookmarkvideo/2015-03-10_14-46-56_89b83b667964eb20d4ee2feef88311580b47a25e_local_00hq_vid_3.mp4"];
    
    
    NSFileManager *filemanager=[ NSFileManager defaultManager ];
    
    NSError *error;
    
    
    NSString * myPath = [NSString stringWithFormat:@"%@/%@",UC.localPath,@"/bookmark/bookmarkvideo/2015-03-10_14-46-56_89b83b667964eb20d4ee2feef88311580b47a25e_local_00hq_vid_3.mp4" ];
    NSURL * asdfasdfaf =     [[NSURL alloc] initFileURLWithPath:myPath];
    
    if([filemanager fileExistsAtPath:myPath])
    {
        NSLog(@"FILE FOUND");
        //just check existence of files in document directory
    } else {
    
        NSLog(@"FILE NOT FOUND");    
    }

    //    [pip playWithFeed:myFeed];
    [pip playerURL:asdfasdfaf];

//    
//NSString * myPath = [NSString stringWithFormat:@"%@/%@",UC.localPath,@"test.plist" ];
//    
//    DOWNLOADITEM = [Downloader downloadURL:@"http://192.168.1.109/min/ajax/teamsget" to:myPath type:DownloadItem_TypePlist];
//    
//    
//    
    // buid video player
//    videoPlayer     = [[VideoPlayer alloc]init];
//    [videoPlayer initializeVideoPlayerWithFrame:CGRectMake(0, 60, 400, 300)];
//    [self.view addSubview:videoPlayer.view];
//    videoPlayer.playerContext = @"debug";
//    Feed * testFeed = [[Feed alloc]initWithURLString:@"http://myplayxplay.net/events/evt-08743582456b52abe1182f5a5a3e12b457ba28b8/video/list_01hq.m3u8" quality:1];
//    [videoPlayer playFeed:testFeed];
    
//     Build pip
//    pip             = [[Pip alloc]initWithFrame:CGRectMake(300, 300, 200, 150)];
//    pip.isDragAble  = YES;
//    pip.hidden      = YES;
//    pip.dragBounds  = videoPlayer.playerLayer.frame;
//
//   [videoPlayer.view addSubview:pip];
//    
//    
//    feedSwitch = [[FeedSwitchView alloc]initWithFrame:CGRectMake(100, 80, 100, 100) encoderManager:EM];
//
//   [videoPlayer.view addSubview:feedSwitch];
//    
////     build pip controller
//    pipController = [[PipViewController alloc]initWithVideoPlayer:videoPlayer f:feedSwitch encoderManager:EM];
//    [pipController addPip:pip];
//    


//     build full screen
//    fullScreen = [[L2BFullScreenViewController alloc]initWithVideoPlayer:videoPlayer];
//    fullScreen.context = @"debug";
//    [self.view addSubview:fullScreen.view];


    [super viewDidLoad];
//    [pipController viewDidLoad];
    
   
//
//        pip2 = [[Pip alloc]initWithFrame:CGRectMake(30, 500, 200, 150)];
//
//        [self.view addSubview:pip2];
//    [pip2 playerURL:[[NSURL alloc]initWithString:@"http://192.168.1.111/events/live/video/list_00hq.m3u8"]];
    
//    [self multiPip:@[@"http://192.168.1.111/events/live/video/list_00hq.m3u8",
//                     @"http://192.168.1.111/events/live/video/list_01hq.m3u8",
//                     @"http://192.168.1.111/events/live/video/list_02hq.m3u8"]];
//    
//    
//    
//    UIButton * butt = [[UIButton alloc]initWithFrame:CGRectMake(50, 400, 50, 50)];
//    [butt addTarget:self action:@selector(buttonPress:) forControlEvents:UIControlEventTouchUpInside];
//    [self.view addSubview:butt];
//    butt.layer.borderWidth = 1;
//    [self.view addSubview:testPlayer.view];
  
}





//-(void)buttonPress:(id)sender
//{
//    
//    Feed * myFeed = [[Feed alloc]initWithURLString:@"http://192.168.1.111/events/live/video/list_00hq.m3u8" quality:1];
//    
////    NSURL * urls = [[NSURL alloc]initWithString:@"http://192.168.1.111/events/live/video/list_00hq.m3u8"];
////    [testPlayer setURL:urls];
//    
//    
//    
//    
////    [testPlayer live];
//    
//    NSDictionary * command = @{  @"command":[NSNumber numberWithInteger:VideoPlayerCommandPlayFeed],
//                                    @"feed":myFeed,
//                                   };//@"range":NSvalue
//    
//    
//    [[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_COMMAND_VIDEO_PLAYER object:nil userInfo:command];
//
//}
//
//
//
//-(void)multiPip:(NSArray*)paths
//{
//    int row = 0;
//    int col = 0;
//    float w = 200;
//    float h = 150;
//    for (int i = 0; i<[paths count]; i++) {
//        Pip * tt = [[Pip alloc]initWithFrame:CGRectMake(w *col, 500+(h*row), w, h)];
//        [tt playerURL:  [NSURL URLWithString:paths[i]]];
//        tt.isDragAble = YES;
//        [self.view addSubview:tt];
//        if (col++ > 3){
//            col = 0;
//            row++;
//        }
//        
//    }
//}
//


-(void)viewWillAppear:(BOOL)animated
{
//    [pip playWithFeed:EM.feeds[@"s1"]];
//    [pip pause];
    [self.view addSubview:proBar];
    [self.view addSubview:lbl];
    [super viewWillAppear:animated];
    
  

}



-(void)play
{
  [pip play];
    
    if (pip.avPlayerItem.asset) {
        
        AVAsset * ch = pip.avPlayerItem.asset;
        NSArray *asdf  =[ch tracks];
        AVAssetTrack * videoATrack = [[pip.avPlayerItem.asset tracksWithMediaType:AVMediaTypeVideo] lastObject];
        if(videoATrack)
        {
           float  fps = videoATrack.nominalFrameRate;
        }
    }
}

-(void)pause
{
      [pip pause];
    
    NSNumber * myNum = [NSNumber numberWithInt:1];
    
    
    [[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_EM_DOWNLOAD_CLIP object:self userInfo:@{@"id":myNum,@"event":@"live",@"block": ^(DownloadItem* dItem){
        
        NSLog(@"DOWNLOAD CLIP");
    }}];
    
}


-(void)step
{
    double ctime    = CMTimeGetSeconds([pip.avPlayerItem currentTime]);
    [pip.avPlayerItem stepByCount:1];
    ctime    = CMTimeGetSeconds([pip.avPlayerItem currentTime]);
}



-(void)viewDidAppear:(BOOL)animated
{
    
//    colour = 0500ff;
//    comment = "";
//    deleted = 0;
//    displaytime = "0:00:00";
//    duration = 0;
//    event = "2015-03-09_15-47-44_b3a3123f7ede56eba54a685a76933fbbf054f218_local";
//    homeTeam = "Manchester United";
//    id = 1;
//    islive = 1;
//    name = 0;
//    own = 0;
//    period = 0;
//    rating = "";
//    starttime = "0.01";
//    success = 1;
//    time = "0.01";
//    type = 17;
//    url = "http://192.168.1.109/events/live/thumbs/tn1.jpg";
//    user = c255e4e00d1e8081e3b3e0e0f1a6682fb90811f6;
//    visitTeam = Arsenal;
    
    NSString * anID = @"6";
    void(^dItemBlock)(DownloadItem*) =^void(DownloadItem* item) {
        NSLog(@"a;sdlf;alsdfadskfaldkfalsdkfjasdlf");
        
    };
    
//    [[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_EM_DOWNLOAD_CLIP object:nil userInfo:@{@"block":dItemBlock,
//                                                                                                           @"id":anID,
//                                                                                                           @"event":@"live"}];
//    
    
//    NSString * myPath = [NSString stringWithFormat:@"%@/%@",UC.localPath,@"main.mp4" ];
//    DOWNLOADITEM  =   [Downloader downloadURL:@"http://192.168.3.100/events/2015-02-26_15-00-50_959bdd31af143f8b2c4b0c4381457e28e7c66049_local/video/main_00hq.mp4" to:myPath];
//    [DOWNLOADITEM   addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:&debugContext];
//
//    CustomAlertView * ioAlert = [[CustomAlertView alloc]initWithTitle:@"NO SPACE" message:@"make space" delegate:self cancelButtonTitle:@"alskdfj" otherButtonTitles:@"asdf", nil];
//    [Downloader defaultDownloader].IOAlertView = ioAlert;
//    
//    __block UIProgressView  * weakBar = proBar;
//    __block UILabel         * weakLbl = lbl;
//
//    void (^block)(float ,NSInteger) = ^void(float currentProgress, NSInteger kbps){
//        weakBar.progress = currentProgress;
//        weakLbl.text = [NSString stringWithFormat:@"%ld",(long)kbps];
//    };
//    
//    
//    [DOWNLOADITEM addOnProgressBlock:block];
//    
    
    

}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
//    DownloadItem * ch = (DownloadItem *) object;
    
    

}


- (void)didReceiveMemoryWarning
{
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_RECEIVE_MEMORY_WARNING object:self userInfo:nil];
    [super didReceiveMemoryWarning];
    if ([self.view window] == nil) self.view = nil;
    
}



@end
