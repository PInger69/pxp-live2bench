//
//  VideoBarListViewController.m
//  Live2BenchNative
//
//  Created by dev on 9/8/2014.
//  Copyright (c) 2014 DEV. All rights reserved.
//

#import "VideoBarListViewController.h"
#import "Slomo.h"
#import "SeekButton.h"
#import "VideoBarContainerView.h"

@interface VideoBarListViewController ()

@end

@implementation VideoBarListViewController
{
//    VideoBarContainerView   * container;
//    UIView                  * background;
//    UILabel                 * tagLabel;
//    Slomo                   * slomoButton;
//    SeekButton              * forwardButton;
//    SeekButton              * backwardButton;
//    VideoPlayer             * videoPlayer;
//    NSArray                 * activeElements;
}

-(id)initWithVideoPlayer:(VideoPlayer *)vidPlayer
{
    
    self = [super init];
    if (self) {
        videoPlayer = vidPlayer;
        container   = [[VideoBarContainerView alloc]init];
        self.view   = container;
        
        background = [[UIView alloc]init];
        
        
        background.backgroundColor = [UIColor colorWithWhite:0.9f alpha:1.0f];
        [container addSubview:background];
        
        forwardButton   = [self makeSeekButton:SEEK_DIRECTION_RIGHT];
        [container addTouchableSubview:forwardButton];
        [forwardButton onPressSeekPerformSelector:  @selector(seekWithSeekerButton:) addTarget:videoPlayer];
        
        backwardButton  = [self makeSeekButton:SEEK_DIRECTION_LEFT];
        [container addTouchableSubview:backwardButton];
        [backwardButton onPressSeekPerformSelector: @selector(seekWithSeekerButton:) addTarget:videoPlayer];
        
        slomoButton     = [self makeSlomo];
        [container addTouchableSubview:slomoButton];
        [slomoButton addTarget:videoPlayer action:  @selector(toggleSlowmo) forControlEvents:UIControlEventTouchUpInside];
        
        tagLabel        = [self makeTagLabel];
        [container addSubview:tagLabel];
        activeElements = @[forwardButton,backwardButton,tagLabel,slomoButton];
    }
    return self;
}




-(SeekButton*)makeSeekButton:(Direction)dir
{
    SeekButton  * btn;
    
    switch (dir ) {
        case SEEK_DIRECTION_LEFT:
            btn = [SeekButton makeBackwardAt:CGPointMake(0, -5)];
            break;
            
        default:
            btn = [SeekButton makeForwardAt:CGPointMake(0, -5)];
            break;
    }
    return btn;
}

-(Slomo*)makeSlomo
{
    Slomo *  btn = [[Slomo alloc]initWithFrame:CGRectMake(80, 0, 50, 30)];
    return btn;
}

-(UILabel *)makeTagLabel
{
    UILabel * tagEventName = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMidX(self.view.frame)- (150/2), 0, 150, 30)];
    [tagEventName setBackgroundColor:[UIColor clearColor]];
    tagEventName.layer.borderColor = [UIColor orangeColor].CGColor;
    tagEventName.layer.borderWidth = 1;
    [tagEventName setText:@"Event Name"];
    [tagEventName setTextColor:[UIColor orangeColor]];
    [tagEventName setTextAlignment:NSTextAlignmentCenter];
    
    return tagEventName;
}




-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    int buttonSideOffset = 90;
    
    [self.view setFrame:CGRectMake(videoPlayer.view.frame.origin.x,
                                   videoPlayer.view.frame.origin.y + videoPlayer.view.frame.size.height+30,
                                   videoPlayer.view.frame.size.width ,
                                   30)];
    
    [background setFrame:CGRectMake(0,
                                    0,
                                    self.view.frame.size.width ,
                                    self.view.frame.size.height)];
    
    [tagLabel setFrame:CGRectMake(CGRectGetMidX(self.view.frame)- (150/2), 0, 150, 30)];
    
    
    [forwardButton  setFrame:CGRectMake(self.view.frame.size.width - (buttonSideOffset +forwardButton.frame.size.width),
                                        forwardButton.frame.origin.y,
                                        forwardButton.frame.size.width,
                                        forwardButton.frame.size.height)];
    
    

    [backwardButton  setFrame:CGRectMake(buttonSideOffset,
                                         backwardButton.frame.origin.y,
                                         backwardButton.frame.size.width,
                                         backwardButton.frame.size.height)];
    
    
    [slomoButton setFrame:CGRectMake(35, slomoButton.frame.origin.y, slomoButton.frame.size.width, slomoButton.frame.size.height)];
    
    [self.view.superview insertSubview:self.view aboveSubview:videoPlayer.view];
    

    for (UIView * item in activeElements){
        [item setHidden:YES];
    }
    

}


@end


