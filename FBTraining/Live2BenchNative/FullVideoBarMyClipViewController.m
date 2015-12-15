//
//  FullVideoBarMyClipViewController.m
//  Live2BenchNative
//
//  Created by dev on 9/3/2014.
//  Copyright (c) 2014 DEV. All rights reserved.
//

#import "FullVideoBarMyClipViewController.h"
#import "Slomo.h"
#import "SeekButton.h"
#import "VideoBarContainerView.h"
#import "BorderButton.h"
#import "PxpVideoPlayerProtocol.h"



@interface FullVideoBarMyClipViewController ()
{
    VideoBarContainerView   * container;
    UILabel                 * tagLabel;
    Slomo                   * slomoButton;
    SeekButton              * forwardButton;
    SeekButton              * backwardButton;
    BorderButton            * nextButton;
    BorderButton            * previousButton;
    UIViewController <PxpVideoPlayerProtocol>* videoPlayer;
}
@end

@implementation FullVideoBarMyClipViewController

-(id)initWithVideoPlayer:(UIViewController <PxpVideoPlayerProtocol>*)vidPlayer
{
    self = [super init];
    if (self) {
        videoPlayer = vidPlayer;
        container   = [[VideoBarContainerView alloc]init];
        self.view   = container;
        
        forwardButton   = [self makeSeekButton:SEEK_DIRECTION_RIGHT];
        [container addTouchableSubview:forwardButton];
        [forwardButton onPressSeekPerformSelector:  @selector(seekWithSeekerButton:) addTarget:videoPlayer];
        
        backwardButton  = [self makeSeekButton:SEEK_DIRECTION_LEFT];
        [container addTouchableSubview:backwardButton];
        [backwardButton onPressSeekPerformSelector: @selector(seekWithSeekerButton:) addTarget:videoPlayer];
        
        slomoButton     = [self makeSlomo];
        [container addTouchableSubview:slomoButton];
        [slomoButton addTarget:self action:  @selector(toggleSlowmo:) forControlEvents:UIControlEventTouchUpInside];
        
        tagLabel        = [self makeTagLabel];
        tagLabel.alpha  = 0.7;
        [container addSubview:tagLabel];
        
        previousButton  = [self makeBorderButton:@"PREVIOUS" increment:-1];
        [container addTouchableSubview:previousButton];
        
        nextButton      = [self makeBorderButton:@"NEXT"  increment:1];
        [container addTouchableSubview:nextButton];
        
        
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
            
            btn = [SeekButton makeFullScreenBackwardAt:CGPointMake(0, -5)];
            break;
            
        default:
            btn = [SeekButton makeFullScreenForwardAt:CGPointMake(0, -5)];
            break;
    }
    return btn;
}

-(Slomo*)makeSlomo
{
    Slomo *  btn = [[Slomo alloc]initWithFrame:CGRectMake(80, 0, 65, 50)];
    return btn;
}

-(BorderButton *)makeBorderButton:(NSString*)label increment:(NSInteger)incr
{
    BorderButton * btn = [[BorderButton alloc]init];
    [btn setTag:incr];
    [btn setTitle:label forState:UIControlStateNormal];
    [btn.titleLabel setFont:[UIFont boldSystemFontOfSize:18.f]];
    [btn.titleLabel setTextAlignment:NSTextAlignmentCenter];
    btn.alpha = 1.0;
    btn.frame = CGRectMake(0,10,100 ,30);

       // [btn addTarget:self action:@selector(playPreTag:) forControlEvents:UIControlEventTouchUpInside];
    return btn;
}

-(UILabel *)makeTagLabel
{
    UILabel * tagEventName = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMidX(self.view.frame)- (150/2), 0, 150, 30)];
    [tagEventName setBackgroundColor:[UIColor clearColor]];
    tagEventName.layer.borderColor = PRIMARY_APP_COLOR.CGColor;
    tagEventName.layer.borderWidth = 1;
    [tagEventName setText:@"Event Name"];
    [tagEventName setTextColor:PRIMARY_APP_COLOR];
    [tagEventName setTextAlignment:NSTextAlignmentCenter];
    
    return tagEventName;
}


-(void)setTagName:(NSString*)name
{
    tagLabel.text = name;

}
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_RECEIVE_MEMORY_WARNING object:self userInfo:nil];
    [super didReceiveMemoryWarning];
    
    // Dispose of any resources that can be recreated.
}

-(void)viewDidAppear:(BOOL)animated
{
    
    [self.view setFrame:CGRectMake(videoPlayer.view.frame.origin.x,
                                   videoPlayer.view.frame.origin.y + videoPlayer.view.frame.size.height-70,
                                   videoPlayer.view.frame.size.width ,
                                   30)];
    
    
    [tagLabel setFrame:CGRectMake(CGRectGetMidX(self.view.frame)- (165/2), 0, 165 ,50)];
    
    
    [forwardButton  setFrame:CGRectMake(self.view.frame.size.width - (100 +forwardButton.frame.size.width),
                                        forwardButton.frame.origin.y,
                                        forwardButton.frame.size.width,
                                        forwardButton.frame.size.height)];
    
    [backwardButton  setFrame:CGRectMake(100,
                                         backwardButton.frame.origin.y,
                                         backwardButton.frame.size.width,
                                         backwardButton.frame.size.height)];
    
    [slomoButton setFrame:CGRectMake(190,
                                                slomoButton.frame.origin.y,
                                                slomoButton.frame.size.width,
                                                slomoButton.frame.size.height)];
    
    
    int spacer = 100;

    [previousButton setFrame:CGRectMake(CGRectGetMinX(tagLabel.frame)-spacer - (previousButton.frame.size.width *0.5f),
                                        previousButton.frame.origin.y,
                                        previousButton.frame.size.width,
                                        previousButton.frame.size.height)];
    
    [nextButton     setFrame:CGRectMake(CGRectGetMaxX(tagLabel.frame)+spacer - (nextButton.frame.size.width *0.5f),
                                        nextButton.frame.origin.y,
                                        nextButton.frame.size.width,
                                        nextButton.frame.size.height)];
    
    
    
    [self.view.superview insertSubview:self.view aboveSubview:videoPlayer.view];
    
    

    return [super viewDidAppear:animated];
}

-(void)onPressNextPrevPerformSelector:(SEL)sel addTarget:(id)target
{
    [nextButton     addTarget:target action:sel forControlEvents:UIControlEventTouchUpInside];
    [previousButton addTarget:target action:sel forControlEvents:UIControlEventTouchUpInside];
}



/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
