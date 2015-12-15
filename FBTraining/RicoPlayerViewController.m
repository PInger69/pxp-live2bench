//
//  RicoPlayerViewController.m
//  Live2BenchNative
//
//  Created by dev on 2015-11-26.
//  Copyright © 2015 DEV. All rights reserved.
//

#import "RicoPlayerViewController.h"

@interface RicoPlayerViewController ()

@property (nonatomic, strong) NSMutableSet * depedencyPlayers; // all players in this list depend on each other
@property (nonatomic, strong) RicoSyncOperation * syncBlock;

@end


@implementation RicoPlayerViewController
static CMClockRef _masterClock;

+(void)initialize
{
    _masterClock = CMClockGetHostTimeClock();
}





- (instancetype)init
{
    self = [super init];
    if (self) {
        self.depedencyPlayers   = [NSMutableSet new];
        self.players            = [NSMutableDictionary new];
        self.operationQueue     = [NSOperationQueue new];
        self.operationQueue.maxConcurrentOperationCount = 1;
        self.syncronizePlayers  = YES;
    }
    return self;
}





- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

-(void)addPlayers:(RicoPlayer *)aPlayer
{

    self.players[aPlayer.name] = aPlayer;
    [self.depedencyPlayers addObject:aPlayer];
    aPlayer.delegate = self;
//    aPlayer.avPlayer.masterClock = _masterClock;
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(onPlayerFail:) name:RicoPlayerDidPlayerItemFailNotification object:aPlayer];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(onSyncReady:)  name:RicoPlayerWillWaitForSynchronizationNotification object:aPlayer];
    
}

-(void)removePlayers:(RicoPlayer *)aPlayer
{
    [self.players removeObjectForKey:aPlayer.instanceName];
    [self.depedencyPlayers removeObject:aPlayer];
    
    [[NSNotificationCenter defaultCenter]removeObserver:self name:RicoPlayerDidPlayerItemFailNotification object:aPlayer];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:RicoPlayerWillWaitForSynchronizationNotification object:aPlayer];
    [aPlayer destroy];
}



-(void)onPlayerFail:(NSNotification*)note
{
   __weak RicoPlayer * aPlayer = note.object;
    [self.depedencyPlayers removeObject:aPlayer]; // the player is unreliable
    [self onSyncReady:nil];// this is if a player fails while a sync is happening

}


-(void)onSyncReady:(NSNotification*)notification
{
    // set up
    static dispatch_once_t pred;
    static NSMutableSet * idlePlayers = nil;
    dispatch_once(&pred, ^{
        idlePlayers = [NSMutableSet new];
    });
    
    
    // This is so the method can be run with out notifications when a player fails
    if (notification && notification.object){
        __weak RicoPlayer * aPlayer = notification.object;
        [idlePlayers addObject:aPlayer];
    }
    
    
    NSLog(@"Idle player set count %lu",(unsigned long)[idlePlayers count]);
    if ([idlePlayers count] == 0 ) return; // if not players do nothing
//    isSubsetOfSet:

    
    // This goes thru all the waiting players and checks to see they are dependable and if they are ready to be synced
    for (RicoPlayer * ply in idlePlayers) {
        if ([self.depedencyPlayers containsObject:ply] && ply.waitingForSynchronization && [idlePlayers count] < [self.depedencyPlayers count]) {
            return; // if not then keep waiting
        }
    }
    
    // changing the flad on the player will resume the process
    for (RicoPlayer * resumePlayers in idlePlayers) {
        resumePlayers.waitingForSynchronization = NO;
    }
    
    // Sync complete clean up
    [idlePlayers removeAllObjects];

    if (self.syncBlock) {
        [self.syncBlock syncComplete];
        self.syncBlock = nil;
    }
}



-(void)play
{


    
    
    for (RicoPlayer * player in [self.players allValues]) {
        if (player.syncronized) {
            if (!self.syncBlock) {
                self.syncBlock = [RicoSyncOperation new];
            }
            [[player play] addDependency:self.syncBlock];
        } else {
            (void)[player play];
        }
    }
    
    if (self.syncBlock) {
        [self.operationQueue addOperation:self.syncBlock];
    }




}
#pragma mark - RicoPlayerObserverDelegate Method

-(void)tick:(RicoPlayer*)player
{

    RicoPlayer * primaryPLayer = [[self.depedencyPlayers allObjects]firstObject];
    
    if (primaryPLayer == player ) {
      
        // calculate range
//        CMTimeRange range = CMTimeRangeMake(kCMTimeZero, primaryPLayer.duration);
        
        // calculate time to seek to
//        CMTime time = primaryPLayer.currentTime;
        
        [self.playerControlBar update:primaryPLayer.currentTime duration:primaryPLayer.duration];

    }
}



#pragma mark - RicoPlayerControlBarDelegate Recognizers


// When scrubbing starts disabled Auto updating cancelAll othere oparations then pause
-(void)startScrubbing:(UISlider *)slider
{
    self.playerControlBar.delegateUpdateEnabled = NO;
    for (RicoPlayer * dplayers in self.depedencyPlayers) {
        [dplayers.operationQueue cancelAllOperations];
        (void)[dplayers pause];
    }
}

-(void)updateScrubbing:(UISlider *)slider
{
    
    // get any player
    RicoPlayer * primaryPLayer = [[self.depedencyPlayers allObjects]firstObject];
    
    // calculate range
    CMTimeRange range = CMTimeRangeMake(kCMTimeZero, primaryPLayer.duration);
    
    // calculate time to seek to
    CMTime time = CMTimeAdd(range.start, CMTimeMultiplyByFloat64(range.duration, slider.value));
    
    // update UI
    [self.playerControlBar update:time duration:primaryPLayer.duration];
    
    // cancel any seeking and start a new seek
    for (RicoPlayer * dplayers in self.depedencyPlayers) {
        [dplayers.avPlayer.currentItem cancelPendingSeeks];
        [dplayers.avPlayer seekToTime:time];
    }
}

-(void)finishScrubbing:(UISlider *)slider
{
    
    RicoPlayer * primaryPLayer = [[self.depedencyPlayers allObjects]firstObject];
    
    // calculate range
    CMTimeRange range = CMTimeRangeMake(kCMTimeZero, primaryPLayer.duration);
    
    // calculate time to seek to
    CMTime time = CMTimeAdd(range.start, CMTimeMultiplyByFloat64(range.duration, slider.value));

    NSArray * playerList = [self.depedencyPlayers allObjects];
    
    
    [self.operationQueue cancelAllOperations]; // cancel any prvious seeks
    self.syncBlock = [RicoSyncOperation new];
    
    for (NSInteger i = 0; i<[playerList count]; i++) {
        RicoPlayer * p = playerList[i];
        [p.avPlayer.currentItem cancelPendingSeeks];
        [p.operationQueue cancelAllOperations];
  
        NSOperation * seeking = [p seekToTime:time toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero completionHandler:^(BOOL finished) {
            
        }];
        
        [self.syncBlock addDependency:seeking]; // the syncBlock will only clear when all seeking is done
        
        NSOperation * playing = [p play];
        [playing addDependency:self.syncBlock]; // the play will only play when the synblock is gone
        
        __block RicoPlayerViewController * weakSelf = self;
        
        [self.syncBlock setCompletionBlock:^{
            weakSelf.playerControlBar.delegateUpdateEnabled = YES;
             NSLog(@"delegateUpdateEnabled");
        }];

    }

}






-(void)playPausePressed:(RicoPlayerControlBar *)playerControlBar didChangeToPaused:(BOOL)paused
{
    
    for (RicoPlayer * dplayers in self.depedencyPlayers) {
        if (paused) {
            [dplayers pause];
            NSLog(@" pause");
        } else {
             [dplayers play];
            NSLog(@"play ");
        }
    }
}


- (void)stepByCount:(NSInteger)stepCount
{
//    NSLog(@"%s this only works for downloaded MP4",__FUNCTION__);
    NSLog(@"Step By: %ld",(long)stepCount);
    for (RicoPlayer * dplayers in self.depedencyPlayers) {
        [dplayers.avPlayer.currentItem stepByCount:stepCount];
    }
}




-(void)cancelPressed:(RicoPlayerControlBar *)playerControlBar
{
    

}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
