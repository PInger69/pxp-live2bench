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

#import "RicoPlayer.h"
#import "RicoPlayerViewController.h"
#import "RicoOperations.h"
#import "EncoderOperation.h"
#import "RicoPlayerControlBar.h"
#import "RicoZoomContainer.h"
#import "RicoJogDial.h"
#import "CustomAlertControllerQueue.h"

#import "AnalyzeLoader.h"

#import "UIDrawer.h"

#import "PostOperation.h"
#import "LogoutOperation.h"
#import "LoginOperation.h"
#import "TestGroupOperation.h"

@interface DebuggingTabViewController () <RicoJogDialJogDialDelegate,AnalyzeLoaderDelegate,UIDrawerDelegate>
{

    EncoderManager              * EM;
    UserCenter                  * UC;
//    PxpPlayer                   * player;
//    Pip                         * pip;
    UIView                      * playArea;
    AVPlayer                    * pl;
    AVPlayerLayer               * avPlayerLayer;

    
    UIButton                    * stepForward;
    UIButton                    * stepBackward;
    UIButton                    * pauseBtn;
    UIButton                    * switchBtn;
    UILabel                     * label;
    NSMutableArray              * buttList;
    NSInteger                   speedBuilder;
    NSInteger                   holdAmount;
    
       RicoPlayerControlBar        * controlBar;
    BOOL                        isHeld;
    
    
    PostOperation * post;
}

@property (nonatomic,strong)  RicoPlayerViewController    * playerViewController;

@property (nonatomic,strong) UIAlertController              * alertController;

@end





static void *  debugContext = &debugContext;


@implementation DebuggingTabViewController
{
    
    NSURL *url;
    NSArray * paths;
    AVURLAsset *asset;
    NSInteger  pick;
    
    
    UIDrawer * drawer;
    
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
        
        
    }
    
    return self;
    
}


-(void)willOpen:(UIDrawer*)drawer
{
    NSLog(@"%s",__FUNCTION__);

}

-(void)willClose:(UIDrawer*)drawer
{
    NSLog(@"%s",__FUNCTION__);

}

-(void)didOpen:(UIDrawer*)drawer
{
    NSLog(@"%s",__FUNCTION__);

}
-(void)didClose:(UIDrawer*)drawer
{
    NSLog(@"%s",__FUNCTION__);

}

-(void)openD
{
        [drawer open:YES];

}


-(void)closeD
{
    
      [drawer close:YES];
}


- (void)viewDidLoad
{
    [super viewDidLoad];

   [self.view setBackgroundColor:[UIColor lightGrayColor]];
    drawer = [[UIDrawer alloc]initWithFrame:CGRectMake(100, 100, 500, 100)];
    [self.view addSubview:drawer];
    drawer.layer.borderWidth = 1;
    [drawer.contentArea setBackgroundColor:[UIColor redColor]];
    drawer.openStyle = UIDrawerRight;
    UIButton * openButton = [[UIButton alloc]initWithFrame:CGRectMake(100, 300, 50, 50)];
    UIButton * closeButton = [[UIButton alloc]initWithFrame:CGRectMake(100, 400, 50, 50)];
    [openButton setBackgroundColor:[UIColor greenColor]];
        [closeButton setBackgroundColor:[UIColor redColor]];
    [openButton addTarget:self action:@selector(openD) forControlEvents:UIControlEventTouchUpInside];
    [closeButton addTarget:self action:@selector(closeD) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:openButton];
    [self.view addSubview:closeButton];
    drawer.delegate = self;
 
    NSURLRequest * req= [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.google.ca"]];
    
    
    
    
    TestGroupOperation * testOp = [TestGroupOperation new];
    
   __block TestGroupOperation * weakSelf = testOp;
    
    [testOp setCompletionBlock:^{
        
        
        NSLog(@"%@",weakSelf.name);
    }];

    
    NSBlockOperation * blkS = [NSBlockOperation blockOperationWithBlock:^{
          NSLog(@"start blocks");
    }];

    
    
    NSBlockOperation * blkE = [NSBlockOperation blockOperationWithBlock:^{
       NSLog(@"finish blocks");
    }];

    
    [testOp addDependency:blkS];
    
    [blkE addDependency:testOp];
    
    
    [[NSOperationQueue mainQueue]addOperation:blkS];
    [[NSOperationQueue mainQueue]addOperation:testOp];
    [[NSOperationQueue mainQueue]addOperation:blkE];
    
//    [[NSOperationQueue mainQueue]addOperation:logout];
}


-(void)onCompletion:(AnalyzeLoader*)analyzeLoader finalClip:(Clip*)clip
{

    NSLog(@"Delegate complete");

    
    NSArray * playersTemp = [self.playerViewController.players allValues];
    NSArray * keys = [clip.videosBySrcKey allKeys];
    
    
    for (NSInteger i = 0; i<[keys count]; i++) {
        
        RicoPlayer * _pl = playersTemp[i];
        
        _pl.feed =  [[Feed alloc]initWithFileURL:clip.videosBySrcKey[keys[i]]];
    }
    
    
    
   
    
    
}



-(void)buttonPress:(id)sender
{
//    UIButton * button = sender;
//    
//    if (button.tag == 2) {
//        [playerViewController stepByCount:1];
//    } else {
//        [playerViewController stepByCount:-1];
//        
//    }
    
}

-(void)buttonHold:(id)sender
{
    UIButton * button = sender;
    isHeld = YES;
    NSTimer * timer = [NSTimer scheduledTimerWithTimeInterval:0.3 target:self selector:@selector(updateMethod:) userInfo:@{@"button":button} repeats:YES];
    [timer fire];
}

-(void)buttonRelease:(id)sender
{
        isHeld = NO;
    
//    UIButton * button = sender;
//    
//    if (button.tag == 2) {
//        [playerViewController stepByCount:1];
//    } else {
//        [playerViewController stepByCount:-1];
//        
//    }
    
    
    speedBuilder = 0;
    holdAmount = 0;
}

- (void) updateMethod:(NSTimer*) timer
{
    
  
    UIButton * button = timer.userInfo[@"button"];

    if (!isHeld) {
        [timer invalidate];
        return;
    }
    holdAmount++;
    
    if (button.tag == 2) {
        NSLog(@"---");
        [self.playerViewController stepByCount:(1+speedBuilder)];
    NSLog(@"---");
    } else {
        [self.playerViewController stepByCount:-(1+speedBuilder)];
        
    }

    if(!(holdAmount% 5)){
        speedBuilder++;
    }

}


-(void)viewDidAppear:(BOOL)animated
{
    
  
    
    
    CustomAlertControllerQueue * queue =  [CustomAlertControllerQueue getInstance];
    
    
    
    
    
    self.alertController = [UIAlertController alertControllerWithTitle:@"test" message:@"test" preferredStyle:UIAlertControllerStyleAlert];

    
    UIAlertAction* noButton = [UIAlertAction
                               actionWithTitle:@"Cancel"
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction * action)
                               {

                                   
                                   [queue dismissViewController:self.alertController animated:YES completion:nil];
                               }];

    
    [self.alertController addAction:noButton];
    
//    [self presentViewController:self.alertController animated:YES completion:^{
//        
//    }];
//    
    
    UIAlertController * t =  [UIAlertController alertControllerWithTitle:@"test2" message:@"test2" preferredStyle:UIAlertControllerStyleAlert];
    
    
    UIAlertAction* noButtons = [UIAlertAction
                               actionWithTitle:@"Cancel"
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction * action)
                               {
                                   
                                   
                                   [queue dismissViewController:self.alertController animated:YES completion:nil];
                               }];
    
        [t addAction:noButtons];

    
    [queue presentViewController:self.alertController inController:self animated:NO style:0 completion:^{
        NSLog(@"Test1");
    }];
    
    [queue presentViewController:t inController:self animated:NO style:0 completion:^{
        NSLog(@"Test2");
    }];
    
    
    
//    Event * testEvent = [LocalMediaManager getInstance].allEvents[@"2015-11-20_18-58-40_351eb7bdbc945bc04a5a21390970ccc9eca4b6b1_local"][@"local"];
//    
//    Feed * feed = [[testEvent.feeds allValues]firstObject];
//    NSString * aUrl = [feed.path absoluteString];
//    [super viewDidAppear:animated];
//    NSArray * listOurl = @[
//                           
//                           aUrl
//                           ,aUrl
//                           ,aUrl
//                           ,aUrl
//                           
////                           @"http://192.168.2.122/events/live/video/list_00hq.m3u8"
////                           ,@"http://192.168.2.122/events/live/video/list_00hq.m3u8"
////                           ,@"http://192.168.2.122/events/live/video/list_00hq.m3u8"
////                           ,@"http://192.168.2.122/events/live/video/list_00hq.m3u8"
//                           //                           ,
//                           //                           @"http://walterebert.com/playground/video/hls/sintel-trailer1.m3u8",
//                           //                           @"http://walterebert.com/playground/video/hls/sintel-trailer.m3u8",
//                           //                           @"http://walterebert.com/playground/video/hls/sintel-trailer.m3u8",
//                           //                           @"http://walterebert.com/playground/video/hls/sintel-trailer.m3u8"
//                           ];
//    
//    for (int i =0, r =0, c = 0; i < [listOurl count];  i++,  c = (r==1)? c+1: c , r = (r == 1)? 0 : r+1       ) {
//        
//        RicoPlayer*   ricoPlayer = [[RicoPlayer alloc]initWithFrame:CGRectMake(0,
//                                                                               0,
//                                                                               self.view.frame.size.width/2 ,
//                                                                               self.view.frame.size.height/2)];
//        
//        [self.playerViewController addPlayers:ricoPlayer];
//        ricoPlayer.looping          = YES;
//        ricoPlayer.syncronized      = YES;
//        ricoPlayer.feed             =  [[Feed alloc]initWithURLString:listOurl[i] quality:0];
//        ricoPlayer.name             =[ NSString stringWithFormat:@"Player %d",i];
//        [ricoPlayer.debugOutput setHidden:NO];
//        //        [ricoPlayer pause];
//        [[ricoPlayer seekToTime:CMTimeMake(1, 1) toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero completionHandler:nil] addDependency:ricoPlayer.isReadyOperation];
//        //        [ricoPlayer play];
//        
//        RicoZoomContainer * zoomContainer = [[RicoZoomContainer alloc]initWithFrame:CGRectMake(self.view.frame.size.width/2*c,
//                                                                                               self.view.frame.size.height/2*r,
//                                                                                               self.view.frame.size.width/2 ,
//                                                                                               self.view.frame.size.height/2)];
//        
//        [self.view addSubview:zoomContainer];
//        [zoomContainer addToContainer:ricoPlayer];// temp
//        [zoomContainer addSubview:ricoPlayer];
//    }
//    
//    
//    [self.playerViewController play];
//    
//    controlBar.delegate = self.playerViewController;
//    self.playerViewController.playerControlBar       = controlBar;
//    [self.view addSubview:controlBar];
//    
//    
//    // temp buttons
//    
//    
//    stepBackward = [UIButton new];
//    stepBackward.tag = 1;
//    stepBackward.titleLabel.text = @"B";
//    [stepBackward addTarget:self action:@selector(buttonPress:) forControlEvents:UIControlEventTouchUpInside];
//    [stepBackward addTarget:self action:@selector(buttonHold:) forControlEvents:UIControlEventTouchDown];
//    [stepBackward addTarget:self action:@selector(buttonRelease:) forControlEvents:UIControlEventTouchUpInside];
//    [stepBackward addTarget:self action:@selector(buttonRelease:) forControlEvents:UIControlEventTouchUpOutside];
//    [stepBackward setBackgroundColor:[UIColor grayColor]];
//   
//    [stepBackward setFrame:CGRectMake(CGRectGetMinX(controlBar.frame)-50, CGRectGetMinY(controlBar.frame), 50, 50)];
//    [self.view addSubview:stepBackward];
//    
//    stepForward = [UIButton new];
//    stepForward.tag = 2;
//    stepForward.titleLabel.text = @"F";
//    [stepForward addTarget:self action:@selector(buttonPress:) forControlEvents:UIControlEventTouchUpInside];
//    [stepForward addTarget:self action:@selector(buttonHold:) forControlEvents:UIControlEventTouchDown];
//    [stepForward addTarget:self action:@selector(buttonRelease:) forControlEvents:UIControlEventTouchUpInside];
//    [stepForward addTarget:self action:@selector(buttonRelease:) forControlEvents:UIControlEventTouchUpOutside];
//    
//    [stepForward setBackgroundColor:[UIColor grayColor]];
//
//    [stepForward setFrame:CGRectMake(CGRectGetMaxX(controlBar.frame), CGRectGetMinY(controlBar.frame), 50, 50)];
//    [self.view addSubview:stepForward];
//    
//    RicoJogDial * dial =  [[RicoJogDial alloc]initWithFrame:CGRectMake(CGRectGetMidX(controlBar.frame)-150,CGRectGetMinY(controlBar.frame)-80, 300,80)];
//    [self.view addSubview:dial];
//    dial.sensitivity = 0.8;
//    
//    dial.delegate = self;
}


-(void)onMovement:(RicoJogDial *)dial value:(CGFloat)value
{
    static NSInteger i = 0;
    NSInteger stepAmount = 1;
    CGFloat absVal = fabs(value);
    if ( absVal > 3000) {
        stepAmount = 9;
    } else if ( absVal > 2000) {
        stepAmount = 3;
    }
    
    
    if (value>0) {
        [self.playerViewController stepByCount:stepAmount];
    } else {
        i++;
        if (i%2 )[self.playerViewController stepByCount:-stepAmount*2];
        
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