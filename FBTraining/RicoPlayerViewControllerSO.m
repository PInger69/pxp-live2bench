//
//  RicoPlayerViewControllerSO.m
//  Live2BenchNative
//
//  Created by dev on 2016-06-15.
//  Copyright © 2016 DEV. All rights reserved.
//

#import "RicoPlayerViewControllerSO.h"

@implementation RicoPlayerViewControllerSO
- (instancetype)init
{
    self = [super init];
    if (self) {
    }
    return self;
}


-(void)addPlayers:(RicoPlayer *)aPlayer
{
    
    [aPlayer.debugOutput removeFromSuperview];
    [aPlayer.streamStatus removeFromSuperview];
    NSArray * pls = [self.players allValues];
    for (NSInteger i = [pls count]-1; i > 0; i--) {
        RicoPlayer * p = (RicoPlayer *)pls[i];
        [self removePlayers:p];
    }
    
    self.players[aPlayer.name] = aPlayer;
    [self.depedencyPlayers addObject:aPlayer];
    if (!self.primaryPlayer) self.primaryPlayer = aPlayer;
    aPlayer.delegate = self;
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(onPlayerFail:) name:RicoPlayerDidPlayerItemFailNotification object:aPlayer];
    
}

-(void)removePlayers:(RicoPlayer *)aPlayer
{
    [self.players removeObjectForKey:aPlayer.instanceName];
    [self.depedencyPlayers removeObject:aPlayer];
    
    [[NSNotificationCenter defaultCenter]removeObserver:self name:RicoPlayerDidPlayerItemFailNotification object:aPlayer];
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
  // overide
}



-(void)play
{
    self.isPlaying = YES;
    (void)[self.primaryPlayer play];
}


-(void)pause
{
    self.isPlaying = NO;

    for (RicoPlayer * dplayers in self.depedencyPlayers) {
        (void)[dplayers pause];
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
    self.primaryPlayer.range = CMTimeRangeMake(CMTimeMakeWithSeconds(timeToGo, NSEC_PER_SEC), CMTimeMakeWithSeconds(tag.duration, NSEC_PER_SEC));
    [self.playerControlBar setRange:range];
}

/*
 If player controller is set to synic it will sync to slowest player
 
 
 */
-(void)live
{
    self.isPlaying = YES;
    self.primaryPlayer.reliable = YES;
    
    
    for (RicoPlayer * dplayers in self.depedencyPlayers) {
        NSOperation * seekOp  = [dplayers seekToTime:self.primaryPlayer.duration toleranceBefore:kCMTimeZero toleranceAfter:kCMTimePositiveInfinity completionHandler:nil];
        NSOperation * playOp  = [dplayers play];
        [playOp addDependency:seekOp];
    }
    if (self.playerControlBar) {
        self.playerControlBar.state = RicoPlayerStateLive;
    }
    
}


-(void)playAtStartWhenReady
{
    if (self.playerControlBar) {
        self.playerControlBar.state = RicoPlayerStateNormal;
    }
    
    RicoPlayer * player = self.primaryPlayer;
        
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
    [playOp addDependency:seekOp];
    
}



#pragma mark - RicoPlayerObserverDelegate Method

-(void)tick:(RicoPlayer*)player
{
    [self makeUnreliable];
    RicoPlayer * primaryPLayer = self.primaryPlayer;
    
    
    if (primaryPLayer == player ) {
        
        
        [self.playerControlBar update:primaryPLayer.currentTime duration:primaryPLayer.duration];
        [[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_RICO_PLAYER_VIEW_CONTROLLER_UPDATE object:self];
    }
    
    
    
    if (self.debugOutput.superview){
        NSMutableString * output = [NSMutableString new];
        
        
        
        for (RicoPlayer * player in [self.players allValues]) {
            
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
        
        self.debugOutput.text = output;
        
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

//// this only works for downloaded MP4
//- (void)stepByCount:(NSInteger)stepCount
//{
//    //    NSLog(@"%s this only works for downloaded MP4",__FUNCTION__);
//    NSLog(@"Step By: %ld",(long)stepCount);
//    for (RicoPlayer * dplayers in self.depedencyPlayers) {
//        [dplayers.avPlayer.currentItem stepByCount:stepCount];
//    }
//}
//



-(void)cancelPressed:(RicoPlayerControlBar *)playerControlBar
{
    for (RicoPlayer * player in [self.players allValues]) {
        player.range = kCMTimeRangeInvalid;
    }
    playerControlBar.range = kCMTimeRangeInvalid;
    
}

-(void)setSlomo:(BOOL)slomo
{
    
    super.slomo = slomo;
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
//            player.streamStatus.text = @"Stream delayed";
            
            //            [self.depedencyPlayers removeObject:player];
        }
    }
    
    
}
@end
