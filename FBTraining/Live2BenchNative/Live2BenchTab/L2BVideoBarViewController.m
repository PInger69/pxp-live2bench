//
//  L2BVideoBarViewController.m
//  Live2BenchNative
//
//  Created by dev on 2014-12-16.
//  Copyright (c) 2014 DEV. All rights reserved.
//

#import "L2BVideoBarViewController.h"
#import "VideoBarContainerView.h"

#define BAR_HEIGHT      40
#define LABEL_WIDTH     150
#define LITTLE_ICON_DIMENSIONS 40

@interface L2BVideoBarViewController ()

@end

@implementation L2BVideoBarViewController


@synthesize barMode                     =_barMode;
@synthesize startRangeModifierButton    = _startRangeModifierButton;
@synthesize endRangeModifierButton      = _endRangeModifierButton;
@synthesize tagMarkerController         = _tagMarkerController;
@synthesize videoPlayer                 = _videoPlayer;
-(id)initWithVideoPlayer:(UIViewController <PxpVideoPlayerProtocol>*)vidPlayer
{
    
    self = [super init];
    if (self) {
        _videoPlayer = vidPlayer;
        container   = [[VideoBarContainerView alloc]init];
        self.view   = container;
        
        background = [[UIView alloc]init];
        
        
        background.backgroundColor = [UIColor colorWithWhite:0.9f alpha:1.0f];
        [self.view addSubview:background];
        
        // frame does nothign now
         _tagMarkerController    = [[TagFlagViewController alloc]initWithFrame:background.frame videoPlayer:_videoPlayer];
        [background addSubview:_tagMarkerController.view];
        
        
        forwardButton   = [self makeSeekButton:SEEK_DIRECTION_RIGHT];
        [container addTouchableSubview:forwardButton];
        [forwardButton onPressSeekPerformSelector:  @selector(seekWithSeekerButton:) addTarget:_videoPlayer];
        
        backwardButton  = [self makeSeekButton:SEEK_DIRECTION_LEFT];
        [container addTouchableSubview:backwardButton];
        [backwardButton onPressSeekPerformSelector: @selector(seekWithSeekerButton:) addTarget:_videoPlayer];
        
        
        
        [forwardButton  setFrame:CGRectMake(0,
                                            forwardButton.frame.origin.y+5,
                                            forwardButton.frame.size.width,
                                            forwardButton.frame.size.height)];
        
        [backwardButton  setFrame:CGRectMake(0,
                                             backwardButton.frame.origin.y+5,
                                             backwardButton.frame.size.width,
                                             backwardButton.frame.size.height)];

        slomoButton     = [self makeSlomo];
        [container addTouchableSubview:slomoButton];
        [slomoButton addTarget:self action:  @selector(toggleSlowmo:) forControlEvents:UIControlEventTouchUpInside];

        
        tagLabel        = [self makeTagLabel];
        [container addSubview:tagLabel];
        
        
        
        
        // range mod Buttons
        
        _endRangeModifierButton = [CustomButton buttonWithType:UIButtonTypeCustom];
//        _endRangeModifierButton = [[CustomButton alloc]initWithFrame:CGRectMake(MEDIA_PLAYER_WIDTH + 115,5 + videoPlayer.view.frame.size.height + 100, LITTLE_ICON_DIMENSIONS-5, LITTLE_ICON_DIMENSIONS-10)];
        [_endRangeModifierButton setContentMode:UIViewContentModeScaleAspectFit];
        [_endRangeModifierButton setImage:[UIImage imageNamed:@"extendendsec.png"] forState:UIControlStateNormal];
        [_endRangeModifierButton setAccessibilityValue:@"extend"];
        [background addSubview:_endRangeModifierButton];
        
        _startRangeModifierButton = [CustomButton buttonWithType:UIButtonTypeCustom];
        _startRangeModifierButton = [[CustomButton alloc]initWithFrame:CGRectMake(160,5 + _videoPlayer.view.frame.size.height + 100, LITTLE_ICON_DIMENSIONS-5, LITTLE_ICON_DIMENSIONS-10)];
        [_startRangeModifierButton setContentMode:UIViewContentModeScaleAspectFill];
        [_startRangeModifierButton setImage:[UIImage imageNamed:@"extendstartsec.png"] forState:UIControlStateNormal];
        [_startRangeModifierButton setAccessibilityValue:@"extend"];
        [background addSubview:_startRangeModifierButton];

        
        
        activeElements = @[_startRangeModifierButton,
                           _endRangeModifierButton,
                           forwardButton,
                           backwardButton,
                           tagLabel,
                           slomoButton,
                           _tagMarkerController.view,
                           _tagMarkerController.currentPositionMarker];
        
        
        
        [self _revealThese:activeElements];
        
        
        
        
        
        
        [_videoPlayer addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew  | NSKeyValueObservingOptionOld context:nil];
    }
    return self;
}
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    int oldStatus = [[change objectForKey:@"old"]intValue];
    int newStatus = [[change objectForKey:@"new"]intValue];
    if (oldStatus == newStatus) return;
    
    if ([keyPath isEqualToString:@"status"]) {
       UIViewController <PxpVideoPlayerProtocol>* ply = (UIViewController <PxpVideoPlayerProtocol>* )object;
       // watching for only change in slomo
//        if (newStatus & RJLPS_Slomo && !(oldStatus & RJLPS_Slomo)) {
//           NSLog(@"slomow");
            slomoButton.slomoOn = ply.slowmo;
//        } else if (oldStatus & RJLPS_Slomo && !(newStatus & RJLPS_Slomo)) {
//             slomoButton.slomoOn = ply.slowmo;
//        }
      
    }

}


-(void)toggleSlowmo:(id)sender
{

        _videoPlayer.slowmo = !_videoPlayer.slowmo;
    ((Slomo*)sender).slomoOn = _videoPlayer.slowmo;
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
    Slomo *  btn = [[Slomo alloc]initWithFrame:CGRectMake(50+30, 0, 50, BAR_HEIGHT)];
    return btn;
}

-(UILabel *)makeTagLabel
{
    UILabel * tagEventName = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMidX(background.frame)- (LABEL_WIDTH/2), 5, LABEL_WIDTH, BAR_HEIGHT-10)];
    tagEventName.layer.borderColor      = [UIColor darkGrayColor].CGColor;
    tagEventName.layer.borderWidth      = .5;
    tagEventName.layer.cornerRadius     = 5;
    tagEventName.layer.backgroundColor  = [UIColor colorWithWhite:1.0f alpha:0.9f].CGColor;
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
    
  //  [_videoPlayer.liveIndicatorLight setHidden:NO];
    
    [self.view setFrame:CGRectMake(_videoPlayer.view.frame.origin.x,
                                   _videoPlayer.view.frame.origin.y + _videoPlayer.view.frame.size.height,
                                   _videoPlayer.view.frame.size.width ,
                                   BAR_HEIGHT)];
    
    
    
    [background setFrame:CGRectMake(0,
                                    0,
                                    self.view.frame.size.width ,
                                    self.view.frame.size.height)];
    
    [_tagMarkerController.background setFrame:background.frame];
    
    [tagLabel setFrame:CGRectMake(CGRectGetMidX(background.frame)- (LABEL_WIDTH/2), 5, LABEL_WIDTH, BAR_HEIGHT-10)];
    
    
    [forwardButton  setFrame:CGRectMake(self.view.frame.size.width - (35 +forwardButton.frame.size.width),
                                        forwardButton.frame.origin.y,
                                        forwardButton.frame.size.width,
                                        forwardButton.frame.size.height)];
    
    [backwardButton  setFrame:CGRectMake(35,
                                         backwardButton.frame.origin.y,
                                         backwardButton.frame.size.width,
                                         backwardButton.frame.size.height)];
    
    [self.view.superview insertSubview:self.view aboveSubview:_videoPlayer.view];
    
    

    [_startRangeModifierButton setFrame:CGRectMake(5,
                                                   5,
                                                   LITTLE_ICON_DIMENSIONS-5,
                                                   LITTLE_ICON_DIMENSIONS-10)];

    [_endRangeModifierButton setFrame:CGRectMake(self.view.frame.size.width - (5 +_endRangeModifierButton.frame.size.width),
                                                 5 ,
                                                 LITTLE_ICON_DIMENSIONS-5,
                                                 LITTLE_ICON_DIMENSIONS-10)];
    

    
    //    for (UIView * item in activeElements){
//        [item setHidden:NO];
//    }
    
  //  [self _hideAll];
    [_tagMarkerController viewDidAppear:animated];
    return [super viewDidAppear:animated];
}
- (void)didReceiveMemoryWarning
{
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_RECEIVE_MEMORY_WARNING object:self userInfo:nil];
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)update
{


}



-(void)createTagMarkers
{
    [_tagMarkerController createTagMarkers];
}


-(void)setBarMode:(int)barMode
{
    [self willChangeValueForKey:@"barMode"];
    _barMode = barMode;
    
    switch (_barMode) {
        case L2B_VIDEO_BAR_MODE_CLIP:
            [self _hideAll];//,slomoButton
            [self _revealThese:@[_startRangeModifierButton,_endRangeModifierButton,tagLabel,_tagMarkerController.view,_tagMarkerController.currentPositionMarker]];
            break;
        case L2B_VIDEO_BAR_MODE_LIVE:
        case L2B_VIDEO_BAR_MODE_EVENT:
            [self _hideAll];
            [self _revealThese:@[_tagMarkerController.view,forwardButton,backwardButton,slomoButton]];     
            break;
        case L2B_VIDEO_BAR_MODE_DISABLE:
            [self _hideAll];
            break;

            
        default:
            break;
    }
    
    [self didChangeValueForKey:@"barMode"];
    
    
}

-(int)barMode
{
    return _barMode;
}




-(void)_hideAll
{
    for (UIView * v in activeElements) {
        [v setHidden:YES];
    }
}

-(void)_revealThese:(NSArray*)list
{
    for (UIView * v in list) {
        [v setHidden:NO];
        [background addSubview: v];
    }
}




@end
