//
//  PipViewController.m
//  Live2BenchNative
//
//  Created by dev on 10/29/2014.
//  Copyright (c) 2014 DEV. All rights reserved.
//

#import "PipViewController.h"
#import "Feed.h"
#import "MultiPip.h"
#import <AVFoundation/AVPlayerItem.h>
#import "RJLVideoPlayer.h"
#import "RJLFreezeCounter.h"


static void * primaryContext    = &primaryContext;
static void * secondaryContext  = &secondaryContext;
static void * changeContextPri  = &changeContextPri;
static void * changeContextSec  = &changeContextSec;

// VideoPlayer Context
static void * vpStatusContext  = &vpStatusContext;
static void * vpFrameContext   = &vpFrameContext;

/**
 *  This class will tie the interacions with the VideoPlayer class and the FeedSwitch as well as watch the EncoderManager
 *  This class will also make sure the pips will match dragable in video play frame
 */


@interface PipViewController ()

@end





@implementation PipViewController
{
    NSMutableArray  * _gesturePool;
    EncoderManager  * _encoderManager;

    
   NSTimer          * syncTimer;
}


@synthesize feedSwitchView  = _feedSwitchView;
@synthesize selectPip       = _selectPip;
@synthesize videoPlayer     = _videoPlayer;
@synthesize multi           = _multi;


/**
 *  In future the pip maybe be a part of the video player class
 *
 *  @param aVideoPlayer
 *  @param f
 *
 *  @return
 */
-(id)initWithVideoPlayer:(UIViewController <PxpVideoPlayerProtocol>*)aVideoPlayer f:(FeedSwitchView *)f encoderManager:(EncoderManager*)encoderManager
{
    self = [super init];
    if (self) {
        
        self.videoPlayer                    = aVideoPlayer;
        _encoderManager                    = encoderManager;
       // _selectPip.selected                 = YES;
        _selectPip.hidden                   = YES;
        self.pips                           = [[NSMutableArray alloc]init];
        _gesturePool                        = [[NSMutableArray alloc]init];
        
        // Feed switch
        self.feedSwitchView                 = f;
        [self.feedSwitchView    addObserver:self forKeyPath:@"primaryPosition" options:(NSKeyValueObservingOptionNew) context:&changeContextPri];
        [self.feedSwitchView    addObserver:self forKeyPath:@"secondaryPosition" options:(NSKeyValueObservingOptionNew) context:&changeContextSec];
        
        // video player
        [self.videoPlayer       addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:&vpStatusContext];
        [self.videoPlayer.view  addObserver:self forKeyPath:@"frame" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:&vpFrameContext];
        

        
        NSTimeInterval  inter   =  2;
        syncTimer            = [NSTimer timerWithTimeInterval:inter target:self selector:@selector(syncTimerMethod) userInfo:nil repeats:YES];
        [[NSRunLoop mainRunLoop] addTimer:syncTimer forMode:NSDefaultRunLoopMode];
        
        
        // hides all added pips
        for (Pip * pip in self.pips) {
            [pip setHidden:YES];
        }
        _multi = [[MultiPip alloc]initWithFrame:self.videoPlayer.view.frame];
    }
    return self;

}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(videoPlayerPlayTag:)       name:NOTIF_SET_PLAYER_FEED object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(videoPlayerStartScrub:)    name:NOTIF_START_SCRUB object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(videoPlayerEndScrub:)      name:NOTIF_FINISH_SCRUB object:nil];
}

#pragma mark - Observers



-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    
    if (context == changeContextSec || context == changeContextPri) {
     [self observerMethodForSwitchForKeyPath:keyPath ofObject:object change:change context:context];
        
    }else if(context == vpStatusContext) {
        [self observerMethodForVideoPlayerForKeyPath:keyPath ofObject:object change:change context:context];
        
    } else if(context == &vpFrameContext) {
        [self observerMethodFrameChange:keyPath ofObject:object change:change context:context];
        
    }

}


-(void)observerMethodFrameChange:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    CGRect createdFrame =  [(NSValue *)[change objectForKey:@"new"]CGRectValue];
    
    for (Pip * pip in self.pips) {
        float midx = createdFrame.size.width    * 0.5f;
        float midy = createdFrame.size.height   * 0.5f;
        
        pip.frame = CGRectMake(midx - (pip.frame.size.width * 0.5), midy-(pip.frame.size.width * 0.5), pip.frame.size.width, pip.frame.size.height);
        [pip setDragBounds:CGRectMake(0,0,createdFrame.size.width,createdFrame.size.height)];
     }

}

-(void)observerMethodForSwitchForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
//    _selectPip.hidden = (self.feedSwitchView.secondaryPosition == self.feedSwitchView.primaryPosition)? YES:NO ;
   
    
    
    if (context == changeContextSec){
        FeedSwitchView * fsv = object;
        NSUInteger  arryPos     = [[change objectForKey:@"new"]intValue];
        UIButton    * button    = [self.feedSwitchView.buttonArray objectAtIndex:arryPos];
        Feed        * feed      = [self.feedSwitchView feedFromKey:button.accessibilityValue];
        CMTime      prevTime    = self.videoPlayer.avPlayer.currentTime;
        
        
        if ([fsv secondarySelected]){
            
            [_selectPip playWithFeed:feed];
            [_selectPip seekTo:prevTime];
            _selectPip.avPlayer.rate =self.videoPlayer.avPlayer.rate;

            _selectPip.hidden = NO;
            
        } else {
            _selectPip.hidden = YES;
        }
    } else { //Secondary is already runing what ever till be sent over to primary so swap first before to cutback on loading
        [self swapVideoPlayer:self.videoPlayer withPip:_selectPip];
        [self.feedSwitchView swap];
    }



}


-(void)observerMethodForVideoPlayerForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    int oldStatus = [[change objectForKey:@"old"]intValue];
    int newStatus = [[change objectForKey:@"new"]intValue];
    if (oldStatus == newStatus) return;
    
    if ([object isKindOfClass:[VideoPlayer class]]){
    
        switch (newStatus) {
            case PS_Paused: // PAUSE ALL PIPS
                
                [self.pips makeObjectsPerformSelector:@selector(pause)];
    //            [_selectPip pause];
                break;
            case PS_Slomo: // SLOW MO
                for (Pip * pip in self.pips) {
                    [pip playRate:self.videoPlayer.avPlayer.rate];

                }
    //            [_selectPip playRate:self.videoPlayer.avPlayer.rate];
                break;
            case PS_Play:
                for (Pip * pip in self.pips) {
                    [pip playRate:self.videoPlayer.avPlayer.rate];
                    [pip play];
                }

                break;
            default:
                [self.pips makeObjectsPerformSelector:@selector(pause)];
                break;
        }
    } else if ([object isKindOfClass:[RJLVideoPlayer class]]){
        RJLVideoPlayer * ply = (RJLVideoPlayer * )object;
        
        if (ply.status & RJLPS_Paused) {
            [self.pips makeObjectsPerformSelector:@selector(pause)];
        }
        if (ply.status & RJLPS_Slomo) {
            for (Pip * pip in self.pips) {
                [pip playRate:self.videoPlayer.avPlayer.rate];
            }
        }
        if (ply.status & RJLPS_Play) {
            for (Pip * pip in self.pips) {
                [pip playRate:self.videoPlayer.avPlayer.rate];
                [pip play];
            }
        }
        
        // was main Player Finished Seeking
        if ( (oldStatus & RJLPS_Seeking) && !((newStatus & RJLPS_Seeking)!=0)) {
            [self syncToPlayer];
            
            
            
        }
        
    
    }
    

}

-(void)syncTimerMethod
{

    for (Pip * pp in self.pips) {
        
        __block Pip * weakPip = pp;
        
        double pipTime       = CMTimeGetSeconds(pp.avPlayer.currentTime);
        double playerTime    = CMTimeGetSeconds(self.videoPlayer.avPlayer.currentTime);
      
        if (fabs(pipTime - playerTime) > 2){
            
        
        
            [pp.avPlayer seekToTime:self.videoPlayer.avPlayer.currentTime completionHandler:^(BOOL finished) {
                if (finished) {
                    weakPip.status = weakPip.status & ~(PIP_Seeking);
                } else {
                    NSLog(@"Pip seekBy: out of range");
                }
            }];
        }
    }
}




- (void)doubleTapPip:(UITapGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateRecognized) {
        // handling code
     //   NSLog(@"remove");
       // [self removePip:(Pip *)sender.view];
    }
}


- (void)handleSingleTap:(UITapGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateRecognized) {
       
        for (Pip * item in self.pips) {
            item.selected = false;
        }
        
        _selectPip = (Pip *)sender.view;
        _selectPip.selected = TRUE;
        
        [_selectPip.superview addSubview:_selectPip];

    }
    [self swapVideoPlayer:self.videoPlayer withPip:_selectPip];
    [self.feedSwitchView swap];
    
}

-(void)videoPlayerPlayTag:(NSNotification *)note
{
    NSDictionary * rick     = note.userInfo;
    if (![[rick objectForKey:@"context"] isEqualToString:_videoPlayer.playerContext]) return;
    
    

    
    id <PxpVideoPlayerProtocol> vid   = _videoPlayer;
    vid.live            = NO;


    
    
    float time              = [[rick objectForKey:@"time"]floatValue];
    float dur               = [[rick objectForKey:@"duration"]floatValue];
    CMTime cmtime           = CMTimeMake(time, 1);
    CMTime cmDur            = CMTimeMake(dur, 1);
    
    CMTimeRange timeRange   = CMTimeRangeMake(cmtime, cmDur);

    
    Feed * f = [_feedSwitchView feedFromKey:[rick objectForKey:@"feed"]];
//    playerStatus oldStatus = [[rick objectForKey:@"state"]integerValue];

    
 
//    [vid playFeed:f];
    vid.looping         = NO;
    vid.live            = NO;
    [vid playFeed:f withRange:timeRange];

    vid.looping         = YES;

    
    for (Pip * pip in self.pips) {
        [pip setHidden:YES];
        [pip seekTo:cmtime];
    }
    // set feeds highlight
    
    [_feedSwitchView clear];
    [_feedSwitchView setPrimaryPositionByName:[rick objectForKey:@"feed"]];
    
    

}

-(void)videoPlayerStartScrub:(NSNotification *)note
{
    id <PxpVideoPlayerProtocol> vid   = note.object;
    if ([vid.playerContext isEqualToString:_videoPlayer.playerContext]){
        [self.pips makeObjectsPerformSelector:@selector(pause)];
    }
}


-(void)videoPlayerEndScrub:(NSNotification *)note
{
    id <PxpVideoPlayerProtocol> vid   = note.object;
    if ([vid.playerContext isEqualToString:_videoPlayer.playerContext]){
        
        CMTime time = vid.avPlayer.currentItem.currentTime;
        
        for (Pip * pip in self.pips) {
            [pip seekTo:time];
        }
    }
        

}


-(void)swapVideoPlayer:(UIViewController <PxpVideoPlayerProtocol>*)aVideoPlayer withPip:(Pip*)aPip
{
    
    UIViewController <PxpVideoPlayerProtocol>* vid   = aVideoPlayer;
    Pip * p             = aPip;
    
    Feed *vpFeed        = vid.feed;
    CMTime playerTime   = vid.avPlayer.currentTime;
    
    Feed *pipFeed       = p.feed;
    
    float time              = CMTimeGetSeconds(playerTime);
    float dur               = 0;
    CMTime cmtime           = CMTimeMake(time, 1);
    CMTime cmDur            = CMTimeMake(dur, 1);
    
    CMTimeRange timeRange   = CMTimeRangeMake(cmtime, cmDur);

    
    
    [vid playFeed:pipFeed withRange:timeRange];// just setting the start time
    
    [aPip playWithFeed:vpFeed];
    [aPip seekTo:playerTime];

}

-(void)addPip:(Pip *)aPip
{
    if ([self.pips containsObject:aPip]) return;
    
    if (!_selectPip) _selectPip= aPip;

    UITapGestureRecognizer *tap2Times   = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTapPip:)];
    tap2Times.numberOfTapsRequired      = 2;
    
    UITapGestureRecognizer * tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
    tapGesture.numberOfTapsRequired     = 1;
    
    [self.pips addObject:[self addAntiFreezeOnPip:aPip]]; // add the anti freeze
    [aPip addGestureRecognizer:tapGesture];
    [aPip addGestureRecognizer:tap2Times];
    [aPip.freezeCounter startTimer:1 max:3];
}

-(void)removePip:(Pip *)aPip
{
    if ([self.pips containsObject:aPip]){
        
        NSArray* gestList =aPip.gestureRecognizers;
        for (UITapGestureRecognizer * gest in gestList) {
            [aPip removeGestureRecognizer:gest];

        }
    }
}


-(void)syncToPlayer
{
    for (Pip * pp in self.pips) {
        
        __block Pip * weakPip = pp;
        
//        pp see
        
        
        
        [pp.avPlayer seekToTime:self.videoPlayer.avPlayer.currentTime completionHandler:^(BOOL finished) {
            if (finished) {
                weakPip.status = weakPip.status & ~(PIP_Seeking);
            } else {
                NSLog(@"Pip seekBy: CANCELLED error or out of range");
            }
        }];
        
        
//        [pp seekTo: self.videoPlayer.avPlayer.currentTime] ;
    }
    
    if ([_multi superview] != nil){
        [_multi seekTo:self.videoPlayer.avPlayer.currentTime];
    }
    
}





- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark LIVE
-(void)pipsAndVideoPlayerToLive
{
    _videoPlayer.feed = _feedSwitchView.primaryFeed;
    
    [_videoPlayer gotolive];
    
    
//    CMTime  time = CMTimeMake([_videoPlayer durationInSeconds], 1);
    for (Pip * pp in self.pips) {
                //        [pp seekTo:time];
        [pp live];
    }
    
    
     if ([_multi superview] != nil){
         [_multi live];
     }
    
}



-(void)showMulti
{
    _multi.frame = CGRectMake(0, 0, _videoPlayer.view.frame.size.width, _videoPlayer.view.frame.size.height);
    [_multi makePips:[_encoderManager.feeds allValues]];
    [_multi seekTo:_videoPlayer.avPlayer.currentItem.currentTime];
//    [_videoPlayer.view addSubview:multi];
    [_videoPlayer.view insertSubview:_multi atIndex:1];
    _selectPip.hidden = YES;
}

-(void)hideMulti
{
    [_multi pause];
    [_multi removeFromSuperview];
}


-(Pip*)addAntiFreezeOnPip:(Pip*)aPip
{
    
    __weak Pip                  * weakPip      = aPip;
    __weak PipViewController    * weakSelf     = self;

    void (^onFreeze)(BOOL) = ^void(BOOL isSubzero) {
        if (isSubzero) {
            NSLog(@"IS SUB ZERO");
        } else {
            [weakSelf syncToPlayer];
        }
    };
    
    
    void (^onSubzero)() = ^void() {
        NSLog(@"SUB ZERO DONE");
    
    };
    
    
    
    aPip.freezeCounter  = [[RJLFreezeCounter alloc]initWithOnFreeze:onFreeze onCriticalFreeze:onSubzero];
    
    return aPip;
}


-(void)onButtonPressMulti:(id)sender
{
//    UIButton * button = (UIButton*)sender;
    
    if ([_multi superview] == nil){
        [self showMulti];
    } else {
        [self hideMulti];
    }


}











@end
