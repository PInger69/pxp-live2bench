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

#import "VKPlayerViewController.h"
#import "FeedMapDisplay.h"
#import "StreamViewVideoKit.h"
#import "AVAsset+Image.h"
#import <MediaPlayer/MediaPlayer.h>

@interface DebuggingTabViewController ()
{

    EncoderManager              * EM;
    UserCenter                  * UC;
}

@property (nonatomic,strong) NSMutableArray * list;


//@property (nonatomic,strong) VKPlayer;


@end







@implementation DebuggingTabViewController



-(id)initWithAppDelegate:(AppDelegate *)mainappDelegate
{
    self = [super initWithAppDelegate:mainappDelegate];
    if (self) {
        UC = _appDel.userCenter;
        EM = _appDel.encoderManager;
        [self setMainSectionTab:@"Debug" imageName:@""];
        
        self.list = [NSMutableArray new];
    }
    
    return self;
    
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    return;
    NSString * urls;
    //    urls = @"rtsp://172.18.2.105:554/stream1";
    urls = @"rtsp://172.18.2.102:9000/pxpstr";
    NSDictionary *options = @{ @"rtsp_transport":@"tcp"};
    
    
    VKPlayerController * playerView2 =  [[VKPlayerController alloc]initWithURLString:@"rtsp://172.18.2.102:8600/pxpstr"];
    playerView2.decoderOptions = options;
    [self.list addObject:playerView2];
    [playerView2.view setFrame:CGRectMake(100, 100, 150, 100)];
    [self.view addSubview:playerView2.view];
    playerView2.controlStyle = kVKPlayerControlStyleNone;
    [playerView2 play];
    
    
    VKPlayerController * playerView1 =  [[VKPlayerController alloc]initWithURLString:@"rtsp://172.18.2.102:8900/pxpstr"];
    playerView1.decoderOptions = options;
    [self.list addObject:playerView1];
    [playerView1.view setFrame:CGRectMake(100, 400, 150, 100)];
    [self.view addSubview:playerView1.view];
    playerView1.controlStyle = kVKPlayerControlStyleNone;
    [playerView1 play];
    
    
    StreamViewVideoKit * stream = [[StreamViewVideoKit alloc]initWithFrame:CGRectMake(200, 400, 150, 100)];
    [stream url:@"rtsp://172.18.2.102:8600/pxpstr"];
    [self.view addSubview:stream.view];
    
    
    
    
    
    
    
    [self sessionTest];
    
    
    
}

-(void)sessionTest
{
    NSURLSession * sess;
    
    NSURLSessionConfiguration*sessionConfig        = [NSURLSessionConfiguration defaultSessionConfiguration];
    sessionConfig.allowsCellularAccess              = NO;
    sessionConfig.timeoutIntervalForRequest         = 10;
    sessionConfig.timeoutIntervalForResource        = 10;
    sessionConfig.HTTPMaximumConnectionsPerHost     = 1;

    
    sess    = [NSURLSession sessionWithConfiguration:sessionConfig delegate:self delegateQueue:nil];
    NSURL * theUrl = [NSURL URLWithString: @"http://172.18.2.102/min/ajax/auth/%7B%22id%22:%22356a192b7913b04c54574d18c28d46e6395428ab%22%7D"];
    
    NSURLSessionTask *task;
    
    
    task= [sess dataTaskWithURL:theUrl completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        
        // Parse JSON
        NSError* parseError;
        id object = (NSDictionary*)[NSJSONSerialization
                                    JSONObjectWithData:data
                                    options:0
                                    error:&parseError];
        
        
              
    }];
    
    
//    task= sess da
    
    [task resume];


}





-(void)viewDidAppear:(BOOL)animated
{
    
    NSString * path = @"http://192.168.1.104/events/live/video/list_01hq.m3u8";
    NSLog(@"");
    
    UIImage * test = [self thumbnailForSource:path time:100];
    
    
    
    NSLog(@"DONE Thumb from LIVE");
}




- (nullable UIImage *)thumbnailForSource:(nullable NSString *)source time:(NSTimeInterval)time{
    
//    CGSize size = CGSizeMake(100, 100);
    
    NSURL * url = [NSURL URLWithString:source];
    
    AVAsset *asset;
    asset = [AVAsset assetWithURL:url];
//    AVURLAsset *asset;
//    asset =  [AVURLAsset URLAssetWithURL:url options:nil];
//    asset = [[AVURLAsset alloc]initWithURL:url options:nil];
    
    
//    AVAsset * copyAsset = [asset copy];
    // for some starange reason if you call .metadata on the av asset before it goes in to AVAssetImageGenerator it will no error out
    
    
    AVAssetImageGenerator *generator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    generator.appliesPreferredTrackTransform = YES;
    generator.maximumSize = CGSizeMake(100, 100);
    
    NSError *error = NULL;
    CMTime ttime = CMTimeMake(1, 65);
    
    CGImageRef imageRef = [generator copyCGImageAtTime:ttime actualTime:NULL error:&error];
    
    
    [generator generateCGImagesAsynchronouslyForTimes:@[[NSValue valueWithCMTime:ttime]] completionHandler:^(CMTime requestedTime, CGImageRef  _Nullable image, CMTime actualTime, AVAssetImageGeneratorResult result, NSError * _Nullable error) {
        NSLog(@"");
    }];
    
    
    NSLog(@"error==%@, Refimage==%@", error, imageRef);
    
    UIImage *thumb = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    
    if (error) {
        
    }
    

    
    
    
    

    UIGraphicsBeginImageContext(thumb.size);
    
    [thumb drawInRect:CGRectMake(0.0, 0.0, thumb.size.width, thumb.size.height)];
//    [self.telestration.thumbnail drawInRect:CGRectMake(0.0, 0.0, size.width, size.height)];
    
    thumb = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    
    
    
    MPMoviePlayerController *player = [[MPMoviePlayerController alloc] initWithContentURL:url];
    UIImage  *thumbnail = [player thumbnailImageAtTime:100.0 timeOption:MPMovieTimeOptionNearestKeyFrame];
    
    
    
    return thumb;
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