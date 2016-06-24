//
//  RicoPlayerViewController.m
//  Live2BenchNative
//
//  Created by dev on 2015-11-26.
//  Copyright © 2015 DEV. All rights reserved.
//

#import "RicoPlayerViewController.h"

@interface RicoPlayerViewController ()


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
        
        _debugOutput = [[UITextView alloc]initWithFrame:CGRectZero];
//        [_debugOutput setHidden:YES];
        [_debugOutput setText:@"*"];
        [_debugOutput setSelectable:NO];
        [_debugOutput setFont:[UIFont fontWithName:@"Courier" size:12.0]];
        [_debugOutput setTextColor:[UIColor whiteColor]];
        [_debugOutput setBackgroundColor:[[UIColor blackColor]colorWithAlphaComponent:0.5]];

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
    if (!self.primaryPlayer) self.primaryPlayer = aPlayer;
    aPlayer.delegate = self;
    aPlayer.avPlayer.masterClock = _masterClock;
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

-(void)onReset:(RicoPlayer *)player playerItemOperation:(NSOperation *)playerItemOperation
{


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
//        [self.syncBlock syncComplete];
        self.syncBlock = nil;
    }
}



-(void)play
{
    self.isPlaying = YES;
    
    [self.depedencyPlayers removeAllObjects];
    

    
    for (RicoPlayer * player in [self.players allValues]) {
        
        if (player.reliable) {
            [self.depedencyPlayers addObject:player];
        }
        
        if (player.syncronized) {
            if (!self.syncBlock) {
                self.syncBlock = [RicoSyncOperation new];
            }
            [[player play] addDependency:self.syncBlock];
        } else {
            (void)[player play];
        }
    }
    
    if (self.syncBlock && !self.syncBlock.isFinished && !self.syncBlock.isExecuting  ) {
        NSLog(@"Queue %@",self.operationQueue);
        [self.operationQueue addOperation:self.syncBlock];
    }
}


-(void)pause
{
        self.isPlaying = NO;
    for (RicoPlayer * player in [self.players allValues]) {
        if (player.syncronized) {
            if (!self.syncBlock) {
                self.syncBlock = [RicoSyncOperation new];
            }
            [[player pause] addDependency:self.syncBlock];
        } else {
            (void)[player pause];
        }
    }
    
    if (self.syncBlock && !self.syncBlock.isFinished && !self.syncBlock.isExecuting  ) {
        NSLog(@"Queue %@",self.operationQueue);
        [self.operationQueue addOperation:self.syncBlock];
    }

}



-(void)playTag:(Tag*)tag
{
    double timeToGo;
    if (tag.type == TagTypeTele) {
        timeToGo = tag.time;
    } else {
        timeToGo = tag.startTime;
    }
    
    CMTimeRange range = CMTimeRangeMake(CMTimeMakeWithSeconds(timeToGo, NSEC_PER_SEC), CMTimeMakeWithSeconds(tag.duration, NSEC_PER_SEC));

    for (RicoPlayer * player in [self.players allValues]) {

        player.range = CMTimeRangeMake(CMTimeMakeWithSeconds(timeToGo, NSEC_PER_SEC), CMTimeMakeWithSeconds(tag.duration, NSEC_PER_SEC));
    }
    [self.playerControlBar setRange:range];
    
}

/*
 If player controller is set to synic it will sync to slowest player
 
 
 */
-(void)live
{
    CMTime liveTime = kCMTimePositiveInfinity;
    self.isPlaying = YES;
    if (self.syncronizePlayers) {
        // Get shortest time
        for (RicoPlayer * p in [self.players allValues]) {
            if (CMTimeCompare(p.duration, liveTime)== -1) {
                liveTime = p.duration;
            }
        }
    }
    
    NSOperation * blk = [NSBlockOperation blockOperationWithBlock:^{}];
    
    for (RicoPlayer * player in [self.players allValues]) {
        
//        if(player.reliable){
//            liveTime = kCMTimePositiveInfinity;
//        }
        
        if(player.reliable && [UserCenter getInstance].preferenceLiveBuffer == 0 ){
            liveTime = kCMTimePositiveInfinity;
        } else if (player.reliable){
            NSInteger inter = [UserCenter getInstance].preferenceLiveBuffer;
            float adjustment = (float)inter;
            CMTime tt = CMTimeMakeWithSeconds(-adjustment,NSEC_PER_SEC);
            liveTime = CMTimeAdd(liveTime,tt );
        }
        player.reliable = YES;
        NSOperation * seekOp  = [player seekToTime:liveTime toleranceBefore:kCMTimeZero toleranceAfter:kCMTimePositiveInfinity completionHandler:nil];
        NSOperation * playOp  = [player play];
        
        [blk addDependency:seekOp];
        [playOp addDependency:blk];
        
        NSOperation * readyOp = (player.isReadyOperation && !player.isReadyOperation.isFinished)?player.isReadyOperation:nil;
        
        if (readyOp) [seekOp addDependency:readyOp];
        [playOp addDependency:seekOp];
        
    }
    [[NSOperationQueue mainQueue]addOperation:blk];

    if (self.playerControlBar) {
        self.playerControlBar.state = RicoPlayerStateLive;
    }
}


-(void)playAtStartWhenReady
{
    if (self.playerControlBar) {
        self.playerControlBar.state = RicoPlayerStateNormal;
    }
    
    
    NSOperation * syncBlock = [NSOperation new];
    
    
    for (RicoPlayer * player in [self.players allValues]) {
        
        (void)[player play];
         NSOperation * seekOp = [player seekToTime:kCMTimeZero toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero completionHandler:^(BOOL finished) {
             NSLog(@"## Player seek Complete %@",(finished)?@"Fail":@"Pass");
             
         }];
        [seekOp setCompletionBlock:^{
            NSLog(@"## Player seek");
        }];
         NSOperation * playOp = [player play];
        [playOp setCompletionBlock:^{
            NSLog(@"## Player play");
        }];
        
        
        NSLog(@"## %@",player.isReadyOperation.isFinished?@"was finished":@"not finished");
        [seekOp addDependency:player.isReadyOperation];
        [playOp addDependency:syncBlock];
        [syncBlock addDependency:seekOp];

        
        
        
    }
    
    [self.operationQueue addOperation:syncBlock];
    
    
    
}



#pragma mark - RicoPlayerObserverDelegate Method

-(void)tick:(RicoPlayer*)player
{
    [self makeUnreliable];
    RicoPlayer * primaryPLayer = self.primaryPlayer;
    
    CMTime mainTime = self.currentTime;
    
    if (primaryPLayer == player ) {
      

        [self.playerControlBar update:primaryPLayer.currentTime duration:primaryPLayer.duration];
        [[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_RICO_PLAYER_VIEW_CONTROLLER_UPDATE object:self];
    }
    
    
    
    if (_debugOutput.superview){
        NSMutableString * output = [NSMutableString new];
        

        
        for (RicoPlayer * player in [self.players allValues]) {
            if ([player.debugValues count]==0) continue;
            
            // check player Drift if a player has drifed 3 seconds behind then it will catch up

            // commented out because of problems for downloaded events
            //            NSLog(@"Drift fixing %f  %@",CMTimeGetSeconds(  CMTimeSubtract(mainTime,player.currentTime) ),player.name);
            
//            float driftTime = CMTimeGetSeconds(  CMTimeSubtract(mainTime,player.currentTime));
////
////            
//            if ( driftTime  < -2.5 &&  player.avPlayer.rate > 0 && self.playerControlBar.state != RicoPlayerStateLive) {
//                [player.operationQueue cancelAllOperations];
//                
//                NSLog(@"Drift fixing %f  %@  %lu",CMTimeGetSeconds(  CMTimeSubtract(mainTime,player.currentTime) ),player.name,(unsigned long)player.operationQueue.operationCount);
//                [player seekToTime:mainTime toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero completionHandler:nil];
//            } else if ( driftTime > 2.5  &&  player.avPlayer.rate > 0 && self.playerControlBar.state != RicoPlayerStateLive) {
//                [player.operationQueue cancelAllOperations];
//                NSLog(@"Drift fixing %f  %@  %lu",CMTimeGetSeconds(  CMTimeSubtract(mainTime,player.currentTime) ),player.name,(unsigned long)player.operationQueue.operationCount);
//                [player seekToTime:mainTime toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero completionHandler:nil];
//            }
            
            
            
            NSMutableString * outputpart = [NSMutableString new];
            
            NSString *nameColumn = [[NSString stringWithFormat:@"%@", player.name] stringByPaddingToLength:10 withString:@" " startingAtIndex:0];
            [outputpart appendString:nameColumn];
     
            NSString *CTColumn = [[NSString stringWithFormat:@"%@", player.debugValues[@"now"]] stringByPaddingToLength:17 withString:@" " startingAtIndex:0];
            [outputpart appendString:CTColumn];

            
            NSString *DTColumn = [[NSString stringWithFormat:@"%@",  player.debugValues[@"dur"]] stringByPaddingToLength:17 withString:@" " startingAtIndex:0];
            [outputpart appendString:DTColumn];

            NSString *STColumn = [[NSString stringWithFormat:@"%@",  player.debugValues[@"itemStatus"]] stringByPaddingToLength:34 withString:@" " startingAtIndex:0];
           [outputpart appendString:STColumn];

            [output appendString:outputpart];
            [output appendString:@"\n"];
            
        }
        
        _debugOutput.text = output;
        
    }
    
}



#pragma mark - RicoPlayerControlBarDelegate Recognizers


// When scrubbing starts disabled Auto updating cancelAll othere oparations then pause
-(void)startScrubbing:(UISlider *)slider
{
    self.playerControlBar.delegateUpdateEnabled = NO;
    for (RicoPlayer * dplayers in self.depedencyPlayers) {
        [dplayers.operationQueue cancelAllOperations];
        [dplayers.avPlayer pause];// Bypass is playing flag
//        (void)[dplayers pause];
    }
}

-(void)updateScrubbing:(UISlider *)slider
{
    
    // get any player
    RicoPlayer * primaryPLayer = [[self.depedencyPlayers allObjects]firstObject];
    CMTimeRange range;

    if (CMTIMERANGE_IS_VALID(primaryPLayer.range)){
        range = primaryPLayer.range;
    } else {
        range = CMTimeRangeMake(kCMTimeZero, primaryPLayer.duration);
    }
    
  
    
    // calculate time to seek to
    CMTime time = CMTimeAdd(range.start, CMTimeMultiplyByFloat64(range.duration, slider.value));
    
    // update UI
     [self.playerControlBar update:time duration:range.duration];
//    [self.playerControlBar update:time duration:primaryPLayer.duration];
    
    // cancel any seeking and start a new seek
    for (RicoPlayer * dplayers in self.depedencyPlayers) {
        [dplayers.avPlayer.currentItem cancelPendingSeeks];
        if (CMTIME_IS_VALID(time)){
            [dplayers.avPlayer seekToTime:time];
        }
    }
}

-(void)finishScrubbing:(UISlider *)slider
{
    
    // get a time  from a player
    RicoPlayer * primaryPLayer = self.primaryPlayer;
    CMTimeRange range;
    if (CMTIMERANGE_IS_VALID(primaryPLayer.range)){
        range = primaryPLayer.range;
    } else {
        range = CMTimeRangeMake(kCMTimeZero, primaryPLayer.duration);
    }
    
    // calculate time to seek to
    CMTime time = CMTimeAdd(range.start, CMTimeMultiplyByFloat64(range.duration, slider.value));

    NSArray * playerList = [self.depedencyPlayers allObjects];
    
    [self.operationQueue cancelAllOperations]; // cancel any prvious seeks
    
    if (self.syncronizePlayers) {
    
    
    }
    
      self.syncBlock = [NSOperation new];
    
    __block RicoPlayerViewController * weakSelf = self;
    
    [self.syncBlock setCompletionBlock:^{
        weakSelf.playerControlBar.delegateUpdateEnabled = YES;
        NSLog(@"delegateUpdateEnabled");
    }];
    
    for (NSInteger i = 0; i<[playerList count]; i++) {
        RicoPlayer * p = playerList[i];
        [p.avPlayer.currentItem cancelPendingSeeks];
        [p.operationQueue cancelAllOperations];
  
        
        NSOperation * seeking = [p seekToTime:time toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero completionHandler:^(BOOL finished) {
            RicoPlayer * pp = p;
            NSLog(@" ---- seek done for Player %@",pp.name );
        }];
        
//        NSOperation * preroll = [p preroll:1];
//        [preroll addDependency:seeking];
//        [self.syncBlock addDependency:preroll];
        
        [self.syncBlock addDependency:seeking]; // the syncBlock will only clear when all seeking is done
        
        
        if ( p.isPlaying) {
            NSOperation * playing = [p play];
            [playing setCompletionBlock:^{
                RicoPlayer * pp = p;
//                NSLog(@"                               Player %@ Time %f  %@",pp.name,CMTimeGetSeconds(pp.currentTime),pp.avPlayer.masterClock );
                pp.slomo =  self.slomo;
            }];
            
            
            
            
            
            [playing addDependency:self.syncBlock]; // the play will only play when the synblock is gone
        }
       
        
    }
    

    
    [self.operationQueue addOperation:self.syncBlock];

}



-(void)seekToTime:(CMTime)seekTime toleranceBefore:(CMTime)toleranceBefore toleranceAfter:(CMTime)toleranceAfter completionHandler:(void(^)(BOOL finished))completionHandler
{
    for (RicoPlayer * dplayers in self.depedencyPlayers) {
        if(dplayers.operationQueue.operationCount > 10) continue;
        [dplayers seekToTime:seekTime toleranceBefore:toleranceBefore toleranceAfter:toleranceAfter completionHandler:completionHandler];
    }
}

-(void)playPausePressed:(RicoPlayerControlBar *)playerControlBar didChangeToPaused:(BOOL)paused
{
    for (RicoPlayer * dplayers in self.depedencyPlayers) {
        if (paused) {
                self.isPlaying = NO;
            [dplayers pause];
            NSLog(@" pause");
        } else {
                self.isPlaying = YES;
            [dplayers play];
            NSLog(@"play ");
        }
    }
}

// this only works for downloaded MP4
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
    for (RicoPlayer * player in [self.players allValues]) {
        player.range = kCMTimeRangeInvalid;
    }
    playerControlBar.range = kCMTimeRangeInvalid;

}

-(void)setSlomo:(BOOL)slomo
{
    for (RicoPlayer * dplayers in self.depedencyPlayers) {
        dplayers.slomo = slomo;
    }
    _slomo = slomo;
}


-(RicoPlayer*)primaryPlayer
{
  
    for (RicoPlayer*p in [self.depedencyPlayers allObjects]) {
        if (p.reliable){
            return p;
        }
    }
    
    
    return [[self.depedencyPlayers allObjects]firstObject];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)setFrame:(CGRect)frame
{
    for (RicoPlayer * player in [self.players allValues]) {
        player.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
    }
    self.view.frame = frame;
}

-(CGRect)frame
{
    return self.view.frame;
}


-(void)setPrimaryPlayerByFeedName:(NSString*)feedName
{

    NSArray * playerList = [self.players allValues];
    
    for (RicoPlayer* p in playerList) {
        if ([p.feed.sourceName isEqualToString:feedName]) {
            self.primaryPlayer = p;
            return;
        }
    }
}



#pragma - mark BottomViewTimeProviderDelegate

//-(void)setCurrentTime:(CMTime)currentTime
//{
//
//}

-(CMTime)currentTime
{
    RicoPlayer * player = self.primaryPlayer;
    if (!player) {
        return kCMTimeZero;
    }
    
    return player.currentTime;
}

-(CMTime)currentTimeFromSourceName:(NSString*)feedName
{
    for (RicoPlayer * player in self.depedencyPlayers) {
        if (player.feed && [player.feed.sourceName isEqualToString:feedName]) {
            return player.currentTime;
        }
    }
    
    RicoPlayer * player = [[self.depedencyPlayers allObjects]firstObject];
    return player.currentTime;
}

// check players and see
-(void)makeUnreliable
{
// get highest player
    
    
    NSArray * list = [self.depedencyPlayers allObjects];
    RicoPlayer * highestPlayer = ( RicoPlayer * )[list firstObject];
    for (RicoPlayer * player in list) {
        if (CMTimeGetSeconds(player.duration) > CMTimeGetSeconds(highestPlayer.duration)) {
            highestPlayer = player;
        }
    }
    
    
    for (RicoPlayer * player in list) {
        if (CMTimeGetSeconds(player.duration) < (CMTimeGetSeconds(highestPlayer.duration) - 10 )) {
//            NSLog(@" %f   %f ",CMTimeGetSeconds(player.duration),(CMTimeGetSeconds(highestPlayer.duration) - 10 ));
            player.reliable = NO;
            player.streamStatus.text = @"Stream delayed";

//            [self.depedencyPlayers removeObject:player];
        }
    }
    

}



@end
