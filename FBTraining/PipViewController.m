//
//  PipViewController.m
//  Live2BenchNative
//
//  Created by dev on 10/29/2014.
//  Copyright (c) 2014 DEV. All rights reserved.
//

#import "PipViewController.h"
#import "Feed.h"
static void * primaryContext    = &primaryContext;
static void * secondaryContext  = &secondaryContext;
static void * changeContextPri  = &changeContextPri;
static void * changeContextSec  = &changeContextSec;

// VideoPlayer Context
static void * vpStatusContext  = &vpStatusContext;

/**
 *  This class will tie the interacions with the VideoPlayer class and the FeedSwitch as well as watch the EncoderManager
 */


@interface PipViewController ()

@end





@implementation PipViewController
{
    NSMutableArray  * _gesturePool;
    EncoderManager  * _encoderManager;
}


@synthesize feedSwitchView  = _feedSwitchView;
@synthesize selectPip             = _selectPip;
@synthesize videoPlayer     = _videoPlayer;



/**
 *  In future the pip maybe be a part of the video player class
 *
 *  @param aVideoPlayer
 *  @param f
 *
 *  @return
 */
-(id)initWithVideoPlayer:(VideoPlayer *)aVideoPlayer f:(FeedSwitchView *)f encoderManager:(EncoderManager*)encoderManager
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
        [self.feedSwitchView    addObserver:self forKeyPath:@"primaryPosition" options:(NSKeyValueObservingOptionNew) context:changeContextPri];
        [self.feedSwitchView    addObserver:self forKeyPath:@"secondaryPosition" options:(NSKeyValueObservingOptionNew) context:changeContextSec];
        
        // video player
        [self.videoPlayer       addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:vpStatusContext];
        
        

       
        
        // hides all added pips
        for (Pip * pip in self.pips) {
            [pip setHidden:YES];
        }
    }
    return self;

}

#pragma mark - Observers

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    
    if (context == changeContextSec || context == changeContextPri) {
     [self observerMethodForSwitchForKeyPath:keyPath ofObject:object change:change context:context];
    }
    
    if(context == vpStatusContext) {
        [self observerMethodForVideoPlayerForKeyPath:keyPath ofObject:object change:change context:context];
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
            _selectPip.hidden = NO;
            [_selectPip playWithFeed:feed];
            [_selectPip seekTo:prevTime];
            
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
    playerStatus oldStatus = [[change objectForKey:@"old"]intValue];
    playerStatus newStatus = [[change objectForKey:@"new"]intValue];
    if (oldStatus == newStatus) return;
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
//            [_selectPip playRate:self.videoPlayer.avPlayer.rate];
//            [_selectPip play];
            break;
        default:
            [self.pips makeObjectsPerformSelector:@selector(pause)];
            break;
    }

    NSLog(@"watching player");
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



-(void)swapVideoPlayer:(VideoPlayer*)aVideoPlayer withPip:(Pip*)aPip
{
    
    VideoPlayer * vid   = aVideoPlayer;
    Pip * p             = aPip;
    
    Feed *vpFeed        = vid.feed;
    CMTime playerTime   = vid.avPlayer.currentTime;
    
    Feed *pipFeed       = p.feed;
    
    [vid playFeed:pipFeed];
    [vid.avPlayer seekToTime:playerTime];
    
    [aPip playWithFeed:vpFeed];
    [aPip seekTo:playerTime];


    
// get VideoPlayers Feed
// get players position
// get Pips Feed
    
// load pips feed to player
// load players feed to pip

// all see to correct time
    
// play all if player is play or stop all if player is stop
    

}

-(void)addPip:(Pip *)aPip
{
    if ([self.pips containsObject:aPip]) return;
    
    if (!_selectPip) _selectPip= aPip;

    UITapGestureRecognizer *tap2Times   = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTapPip:)];
    tap2Times.numberOfTapsRequired      = 2;
    
    UITapGestureRecognizer * tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
    tapGesture.numberOfTapsRequired     = 1;
    
    [self.pips addObject:aPip];
    [aPip addGestureRecognizer:tapGesture];
    [aPip addGestureRecognizer:tap2Times];

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
        [pp seekTo: self.videoPlayer.avPlayer.currentTime] ;
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
