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
    
    __weak EncoderManager       * EM;
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
        [self setMainSectionTab:@"DEBUG" imageName:@""];
        [self.view setBackgroundColor:[UIColor lightGrayColor]];
        EM = _appDel.encoderManager;
        
        rectOutline = [[UIView alloc]initWithFrame:CGRectMake(100, 100, 10, 10)];
        rectOutline.layer.borderColor = [[UIColor redColor]CGColor];
        rectOutline.layer.borderWidth = 1;
    
    }

    return self;
    
}

- (void)viewDidLoad
{
    videoPlayer     = [[VideoPlayer alloc]init];
    [videoPlayer initializeVideoPlayerWithFrame:CGRectMake(0, 60, 800, 600)];
    [self.view addSubview:videoPlayer.view];
    
    
    pip             = [[Pip alloc]initWithFrame:CGRectMake(300, 300, 200, 150)];
    pip.isDragAble  =YES;
    pip.dragBounds  = videoPlayer.playerLayer.frame;

   // [self.view addSubview:pip];
   [videoPlayer.view addSubview:pip];
    
    feedSwitch = [[FeedSwitchView alloc]initWithFrame:CGRectMake(100, 80, 100, 100) encoderManager:EM];
    [feedSwitch buildButtonsWithData:@{
                                       @"F1":[[Feed alloc]initWithURLString:@"http://192.168.3.100:80/events/live/video/list.m3u8" quality:0],
                                       @"F2":[[Feed alloc]initWithURLString:@"http://192.168.3.100/events/2014-11-28_11-41-38_7e302f17b954d23b0a1ed1e1d21f3532233febdb_local/video/list.m3u8" quality:0],
//                                       @"F3":[[Feed alloc]initWithURLString:@"http://192.168.3.100:80/events/2014-09-11_15-08-31_796a5299fad628f2670afeda035d42674ad9f559_local/video/list.m3u8" quality:0]
                                       }];
    
   [videoPlayer.view addSubview:feedSwitch];
    pipController = [[PipViewController alloc]initWithVideoPlayer:videoPlayer pip:pip f:feedSwitch];
    videoPlayer.context = @"debug";


    fullScreen = [[L2BFullScreenViewController alloc]initWithVideoPlayer:videoPlayer];
    fullScreen.context = @"debug";
    [self.view addSubview:fullScreen.view];


//    
//    pip2 = [[Pip alloc]initWithFrame:CGRectMake(200, 200, 200, 150)];
//    [pip2 playerURL:[NSURL URLWithString:@"http://192.168.3.100:80/events/2014-09-11_15-08-31_796a5299fad628f2670afeda035d42674ad9f559_local/video/list.m3u8"]];
//    pip2.isDragAble = YES;
//    pip2.muted      = YES;
//    pip2.dragBounds = videoPlayer.playerLayer.frame;
//    [videoPlayer.view addSubview:pip2];
//
//    [pipController addPip:pip2];
//    
//    
//    Pip * pip3 = [[Pip alloc]initWithFrame:CGRectMake(100, 100, 200, 150)];
//    [pip3 playerURL:[NSURL URLWithString:@"http://192.168.3.100:80/events/2014-09-11_15-08-31_796a5299fad628f2670afeda035d42674ad9f559_local/video/list.m3u8"]];
//    pip3.isDragAble = YES;
//    pip3.muted      = YES;
//    pip3.dragBounds = videoPlayer.playerLayer.frame;
//    [videoPlayer.view addSubview:pip3];
//    
//    [pipController addPip:pip3];
    
    
//    [self.view addSubview:rectOutline];

   // [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(delayedCall:) name:NOTIF_ENCODER_AUTHENTICATED object:nil];
//    brViewController = [[BitRateViewController alloc]initWithEncoderManager:EM];
//    [self.view addSubview:brViewController.view];
    
    

    


    [super viewDidLoad];

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


-(void)handleSingleTap
{

}


- (void)handleTapGesture2:(UITapGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateRecognized) {
        // handling code
        NSLog(@"TAP2");
        [Pip swapPip:pip with:pip2];
        [feedSwitch swap];
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    
    

    
    
    [super viewWillAppear:animated];



}


-(void)viewDidAppear:(BOOL)animated
{
    
    NSString * myPath = @"http://192.168.3.100:80/events/live/video/list.m3u8";
//    [pip playerURL:[NSURL URLWithString:myPath]];
    NSLog(@"DEBUG APPEAR!");

    [self performSelector:@selector(delayed) withObject:nil afterDelay:10];
    [super viewDidAppear:animated];
    [videoPlayer setPlayerWithURL:[NSURL URLWithString:myPath]];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
