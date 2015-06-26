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

#define LITTLE_ICON_DIMENSIONS 40
@interface VideoBarListViewController ()

@end

@implementation VideoBarListViewController
{
    /*VideoBarContainerView   * container;
    UIView                  * background;
    UILabel                 * tagLabel;
    Slomo                   * slomoButton;
    SeekButton              * forwardButton;
    SeekButton              * backwardButton;
    UIViewController <PxpVideoPlayerProtocol>            * videoPlayer;
    NSArray                 * activeElements;*/
    
}

@synthesize startRangeModifierButton    = _startRangeModifierButton;
@synthesize endRangeModifierButton      = _endRangeModifierButton;
@synthesize mode                        = _mode;

-(id)initWithVideoPlayer:(UIViewController <PxpVideoPlayerProtocol>*)vidPlayer
{
    
    self = [super init];
    if (self) {
        videoPlayer = vidPlayer;
        
        
        

        
        container   = [[VideoBarContainerView alloc]init];
        self.view   = container;
        [self.view setFrame:CGRectMake(videoPlayer.view.frame.origin.x,videoPlayer.view.frame.origin.y + videoPlayer.view.frame.size.height,videoPlayer.view.frame.size.width ,30)];
        
        
        background = [[UIView alloc]init];
        [background setFrame:CGRectMake(0,0,self.view.frame.size.width ,self.view.frame.size.height)];
        background.backgroundColor = [UIColor colorWithWhite:0.9f alpha:1.0f];
        [self.view addSubview:background];
        
        //[forwardButton  setFrame:CGRectMake(self.view.frame.size.width - (buttonSideOffset +forwardButton.frame.size.width),forwardButton.frame.origin.y,forwardButton.frame.size.width,forwardButton.frame.size.height)];
        forwardButton   = [self makeSeekButton:SEEK_DIRECTION_RIGHT];
        [container addTouchableSubview:forwardButton];
        [forwardButton onPressSeekPerformSelector:  @selector(seekWithSeekerButton:) addTarget:videoPlayer];
        
        
        //[backwardButton  setFrame:CGRectMake(buttonSideOffset,backwardButton.frame.origin.y,backwardButton.frame.size.width,backwardButton.frame.size.height)];
        backwardButton  = [self makeSeekButton:SEEK_DIRECTION_LEFT];
        [container addTouchableSubview:backwardButton];
        [backwardButton onPressSeekPerformSelector: @selector(seekWithSeekerButton:) addTarget:videoPlayer];
        
        
        [slomoButton setFrame:CGRectMake(35, slomoButton.frame.origin.y, slomoButton.frame.size.width, slomoButton.frame.size.height)];
        slomoButton     = [self makeSlomo];
        [container addTouchableSubview:slomoButton];
        [slomoButton addTarget:self action:  @selector(toggleSlowmo:) forControlEvents:UIControlEventTouchUpInside];
        
        
        [tagLabel setFrame:CGRectMake(CGRectGetMidX(self.view.frame)- (150/2), 0, 150, 30)];
        tagLabel        = [self makeTagLabel];
        [container addSubview:tagLabel];
        
        
        _startRangeModifierButton = [CustomButton buttonWithType:UIButtonTypeCustom];
        _startRangeModifierButton = [[CustomButton alloc]initWithFrame:CGRectMake(0,0, LITTLE_ICON_DIMENSIONS-5, LITTLE_ICON_DIMENSIONS-10)];
        [_startRangeModifierButton setContentMode:UIViewContentModeScaleAspectFill];
        [_startRangeModifierButton setImage:[UIImage imageNamed:@"extendstartsec.png"] forState:UIControlStateNormal];
        [_startRangeModifierButton setAccessibilityValue:@"extend"];
        [container addSubview:_startRangeModifierButton];

        
        _endRangeModifierButton = [CustomButton buttonWithType:UIButtonTypeCustom];
        _endRangeModifierButton = [[CustomButton alloc]initWithFrame:CGRectMake(500, 0, LITTLE_ICON_DIMENSIONS-5, LITTLE_ICON_DIMENSIONS-10)];
        [_endRangeModifierButton setContentMode:UIViewContentModeScaleAspectFit];
        [_endRangeModifierButton setImage:[UIImage imageNamed:@"extendendsec.png"] forState:UIControlStateNormal];
        [_endRangeModifierButton setAccessibilityValue:@"extend"];
        [container addSubview:_endRangeModifierButton];
        
        //[background addSubview:forwardButton];
        //[background addSubview:backwardButton];
        //[background addSubview:tagLabel];
        //[background addSubview:slomoButton];
        //[background addSubview:_startRangeModifierButton];
        //[background addSubview:_endRangeModifierButton];
        
        
        activeElements = @[forwardButton,backwardButton,tagLabel,slomoButton,_startRangeModifierButton,_endRangeModifierButton];
        [self _revealThese: @[]];
        
    
        
        [self.view.superview insertSubview:self.view aboveSubview:videoPlayer.view];

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

-(void)setTagName:(NSString *)name
{
    tagLabel.text = name;
}

-(SeekButton*)makeSeekButton:(Direction)dir
{
    SeekButton  * btn;
    int buttonSideOffset = 50;
    
    switch (dir ) {
        case SEEK_DIRECTION_LEFT:
            //btn = [SeekButton makeBackwardAt:CGPointMake(0, -5)];
            btn = [SeekButton makeBackwardAt:CGPointMake(buttonSideOffset, backwardButton.frame.origin.y-5)];
            break;
            
        default:
            //btn = [SeekButton makeForwardAt:CGPointMake(0, -5)];
            btn = [SeekButton makeForwardAt:CGPointMake(self.view.frame.size.width - (buttonSideOffset + 60), forwardButton.frame.origin.y-5)];
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
    tagEventName.layer.borderColor = PRIMARY_APP_COLOR.CGColor;
    tagEventName.layer.borderWidth = 1;
    [tagEventName setText:@"Event Name"];
    [tagEventName setTextColor:PRIMARY_APP_COLOR];
    [tagEventName setTextAlignment:NSTextAlignmentCenter];
    
    return tagEventName;
}




/*-(void)viewDidAppear:(BOOL)animated
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
        [item setHidden:NO];
        [background addSubview:item];
    }
    

}*/

-(void)setMode:(ListViewModes)mode
{
    if (_mode == mode) return;
    _mode = mode;
    
    switch (_mode) {
        case ListViewModeDisable :
            [self _revealThese:@[]];
            break;
        case ListViewModeRegular :
            [self _revealThese:@[forwardButton,backwardButton,slomoButton]];
            break;
        case ListViewModeClip:
            [self _revealThese: @[forwardButton,backwardButton,tagLabel,slomoButton,_startRangeModifierButton,_endRangeModifierButton]];
            break;
        default:
            break;
    }
}

-(ListViewModes)mode
{
    return _mode;
}

-(void)_revealThese:(NSArray*)list
{
    for (UIView * v in activeElements) {
        [v setHidden:YES];
    }
    for (UIView * v in list) {
        [v setHidden:NO];
    }
}


@end


