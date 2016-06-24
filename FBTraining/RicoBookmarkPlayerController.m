//
//  RicoBookmarkPlayerController.m
//  Live2BenchNative
//
//  Created by dev on 2016-05-17.
//  Copyright © 2016 DEV. All rights reserved.
//

#import "RicoBookmarkPlayerController.h"

@interface RicoBookmarkPlayerController ()
@property (strong, nonatomic) NSArray                    * players;
@property (strong, nonatomic) RicoPlayer                  * ricoPlayer1;
@property (strong, nonatomic) RicoPlayer                  * ricoPlayer2;
@property (strong, nonatomic) RicoPlayer                  * ricoPlayer3;
@property (strong, nonatomic) RicoPlayer                  * ricoPlayer4;
//@property (strong, nonatomic) RicoPlayerControlBar        * ricoPlayerControlBar;

@property (strong, nonatomic) RicoZoomContainer           * ricoZoomer;
@property (strong, nonatomic) RicoFullScreenControlBar    * ricoFullScreenControlBar;
@property (strong, nonatomic, nonnull) RicoPlayerGroupContainer         * ricoGroup;

@property (strong, nonatomic) UITapGestureRecognizer     * doubleTapOnGrid;

@end



@implementation RicoBookmarkPlayerController

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super init];
    if (self) {
        self.players = @[
                         [[RicoPlayer alloc]initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)],
                         [[RicoPlayer alloc]initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)],
                         [[RicoPlayer alloc]initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)],
                         [[RicoPlayer alloc]initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)]
                         ];
        
                // this controlls the bar
        self.ricoPlayerController               = [RicoPlayerViewController new];
        
        
        // zoooming ability
        self.ricoZoomer = [[RicoZoomContainer alloc]initWithFrame:frame];
        

        // Build Quad player
        self.ricoGroup              = [[RicoPlayerGroupContainer alloc]initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        
        [self.ricoGroup setBackgroundColor:[UIColor greenColor]];
        
        
        
        
        
        [self.ricoZoomer addToContainer:self.ricoGroup];
        
        _fullscreenViewController               = [[RicoBaseFullScreenViewController alloc] initWithView:self.ricoZoomer];
        
        
        _ricoFullScreenControlBar               = [[RicoFullScreenControlBar alloc]init];
        [_fullscreenViewController.bottomBar addSubview:_ricoFullScreenControlBar];
        
        self.ricoPlayerController = [RicoPlayerViewController new];
        
        for (RicoPlayer * p in self.players) {
            p.looping = YES;
            [self.ricoGroup addSubview:p];
            [self.ricoPlayerController addPlayers:p];
            [p.debugOutput removeFromSuperview];
            [p.streamStatus removeFromSuperview];
            
        }
        
//        self.ricoGroup.gridMode = YES;
        self.doubleTapOnGrid = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(onTapOnQuad:)];
        self.doubleTapOnGrid.numberOfTapsRequired = 2;
        [self.ricoGroup addGestureRecognizer:self.doubleTapOnGrid];
    }
    return self;
}


-(void)playClip:(Clip *)clip
{
    NSInteger c = 0;
    
    NSMutableDictionary *videos = [clip.videosBySrcKey mutableCopy];
    
    if (c != 0) {
        [videos setObject:@"/var/mobile/Containers/Data/Application/FF2D24CA-2CB3-45A5-8D1A-E51899C1236B/Documents/bookmark/bookmarkvideo/2016-05-18_11-01-56_ec594b21d7146478d513918e9488bd5f816724bb_local_vid_10+00hq.mp4" forKey:@"01"];
    }
    for (RicoPlayer * p in self.players) {
        p.reliable = NO;
        p.feed = nil;
  
        
    }
    
    
    Feed * feed;
    if (videos.allKeys.count > 0) {
        NSString * akey;
        
        for (RicoPlayer * p in self.players) {
            p.hidden = YES;
            [p.streamStatus removeFromSuperview];
            [p.debugOutput removeFromSuperview];
            
        }
        
        for (NSInteger i=0; i<videos.allKeys.count; i++) {
            
            akey = videos.allKeys[i];
            feed = [[Feed alloc] initWithFileURL:videos[akey]];

            RicoPlayer * p = self.players[i];
            [p loadFeed:feed];
            p.hidden = NO;
            p.reliable = YES;
            [p.streamStatus removeFromSuperview];
            [p.debugOutput removeFromSuperview];
            
        }
        [self.ricoPlayerController play];
        self.ricoGroup.gridMode = (videos.allKeys.count >1);
//        self.ricoGroup.gridMode = ! self.ricoGroup.gridMode ;
    }
    
    

    
    [[NSNotificationCenter defaultCenter]postNotificationName:BOOKMARK_PLAYER_CONTROLLER_CHANGE object:self];
}


-(void)onTapOnQuad:(id)sender
{

    UITapGestureRecognizer * gest = sender;
    
    RicoPlayerGroupContainer * group =  (RicoPlayerGroupContainer *) gest.view;
    
    
    
    if (group.gridMode) {
        
        CGPoint loc = [gest locationInView:group];
        UIView* subview = [group hitTest:loc withEvent:nil];
        
        for (RicoPlayer * p in self.players) {
            p.hidden = YES;
        }
        
        if ([subview isKindOfClass:[RicoPlayer class]]) {
            RicoPlayer * aPlayer = (RicoPlayer *)subview;
            group.gridMode = NO;
            aPlayer.hidden = NO;
        }
        
    } else {
        
        group.gridMode = YES;
    }
}


-(UIView*)view
{
    return self.ricoZoomer;

}

-(void)clear
{

}

@end
