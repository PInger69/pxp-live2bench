
//
//  VideoBarMyClipViewController.m
//  Live2BenchNative
//
//  Created by dev on 9/2/2014.
//  Copyright (c) 2014 DEV. All rights reserved.
//

#import "VideoBarMyClipViewController.h"
#import "VideoBarContainerView.h"


@interface VideoBarMyClipViewController ()

@end

@implementation VideoBarMyClipViewController


-(id)initWithVideoPlayer:(UIViewController <PxpVideoPlayerProtocol>*)vidPlayer
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
        //[container addTouchableSubview:forwardButton];
        [forwardButton onPressSeekPerformSelector:  @selector(seekWithSeekerButton:) addTarget:videoPlayer];
        
        backwardButton  = [self makeSeekButton:SEEK_DIRECTION_LEFT];
        //[container addTouchableSubview:backwardButton];
        [backwardButton onPressSeekPerformSelector: @selector(seekWithSeekerButton:) addTarget:videoPlayer];
        
        slomoButton     = [self makeSlomo];
        [container addTouchableSubview:slomoButton];
        [slomoButton addTarget:self action:  @selector(toggleSlowmo:) forControlEvents:UIControlEventTouchUpInside];
        
        tagLabel        = [self makeTagLabel];
        [container addSubview:tagLabel];
        
        self.playNextButton = [[UIButton alloc]init];
        self.playPreButton = [[UIButton alloc]init];
        
        [self.playNextButton setImage:[UIImage imageNamed:@"playbackRateButtonBack"] forState:UIControlStateNormal];
        [self.playNextButton setImage:[UIImage imageNamed:@"playbackRateButtonBackSelected"] forState:UIControlStateHighlighted];
        [self.playNextButton setImage:[UIImage imageNamed:@"playbackRateButtonBackSelected"] forState:UIControlStateSelected];
        
        [self.playPreButton setImage:[UIImage imageNamed:@"playbackRateButtonBack"] forState:UIControlStateNormal];
        [self.playPreButton setImage:[UIImage imageNamed:@"playbackRateButtonBackSelected"] forState:UIControlStateHighlighted];
        [self.playPreButton setImage:[UIImage imageNamed:@"playbackRateButtonBackSelected"] forState:UIControlStateSelected];
        
        [container addTouchableSubview:self.playNextButton];
        [container addTouchableSubview:self.playPreButton];
        
        activeElements = @[forwardButton,backwardButton,tagLabel,slomoButton,self.playNextButton,self.playPreButton];
        
        
        
    }
    return self;
}



-(void)toggleSlowmo:(id)sender
{
    if ([videoPlayer respondsToSelector:@selector(toggleSlowmo)]){
        [videoPlayer performSelector:@selector(toggleSlowmo)];
    } else {
        videoPlayer.slowmo = !videoPlayer.slowmo;
    }
    
    
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
//    tagEventName.layer.borderColor = self.view.tintColor.CGColor;
//    tagEventName.layer.borderWidth = 1;
    [tagEventName setText:@"Event Name"];
    [tagEventName setTextColor:[UIColor darkGrayColor]];//self.view.tintColor
    [tagEventName setTextAlignment:NSTextAlignmentCenter];

    return tagEventName;
}


-(void)setTagName:(NSString*)name
{
    tagLabel.text = name;
    for (UIView * item in activeElements){
        [item setHidden:NO];
    }
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

-(void)viewDidAppear:(BOOL)animated
{
 
    [self.view setFrame:CGRectMake(videoPlayer.view.frame.origin.x,
                                   videoPlayer.view.frame.origin.y + videoPlayer.view.frame.size.height,
                                   videoPlayer.view.frame.size.width ,
                                   30)];
    
    [background setFrame:CGRectMake(0,
                                    0,
                                    self.view.frame.size.width ,
                                    self.view.frame.size.height)];
    
    [tagLabel setFrame:CGRectMake(CGRectGetMidX(self.view.frame)- (150/2), 0, 150, 30)];
    
    
    [forwardButton  setFrame:CGRectMake(self.view.frame.size.width - (10 +forwardButton.frame.size.width),
                                        forwardButton.frame.origin.y,
                                        forwardButton.frame.size.width,
                                        forwardButton.frame.size.height)];
    
    [backwardButton  setFrame:CGRectMake(10,
                                         backwardButton.frame.origin.y,
                                         backwardButton.frame.size.width,
                                         backwardButton.frame.size.height)];
    
    [self.playPreButton setFrame:CGRectMake(self.view.frame.size.width - (forwardButton.frame.size.width),
                                       self.playPreButton.frame.origin.y,
                                       self.playPreButton.frame.size.width,
                                       self.playPreButton.frame.size.height)];
    
    [self.playNextButton     setFrame:CGRectMake(0,
                                            self.playNextButton.frame.origin.y,
                                            self.playNextButton.frame.size.width,
                                            self.playNextButton.frame.size.height)];
    
    [self.view.superview insertSubview:self.view aboveSubview:videoPlayer.view];
    
    
    for (UIView * item in activeElements){
        [item setHidden:YES];
    }
    
    return [super viewDidAppear:animated];
}
- (void)didReceiveMemoryWarning
{
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_RECEIVE_MEMORY_WARNING object:self userInfo:nil];
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
