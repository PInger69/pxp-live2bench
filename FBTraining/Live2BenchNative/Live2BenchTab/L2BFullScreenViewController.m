//
//  L2BFullScreenViewController.m
//  Live2BenchNative
//
//  Created by dev on 2014-12-17.
//  Copyright (c) 2014 DEV. All rights reserved.
//

#import "L2BFullScreenViewController.h"

@implementation L2BFullScreenViewController
{

    NSArray                 * liveElements;
    NSArray                 * clipElements;
    NSArray                 * teleElements;
    NSArray                 * activeElements;
    float                   controlOffsetY;
}



@synthesize seekForward     = _seekForward;
@synthesize seekBackward    = _seekBackward;
@synthesize slomo           = _slomo ;
@synthesize teleButton      = _teleButton;
@synthesize mode            = _mode;
@synthesize liveButton      = _liveButton;
@synthesize tagEventName    =_tagEventName;
@synthesize continuePlay    =_continuePlay;


-(id)initWithVideoPlayer:(VideoPlayer *)videoPlayer
{
    controlOffsetY  = 585.0f;
    self            = [super initWithVideoPlayer:videoPlayer];
    if (self){
        self.mode   = L2B_FULLSCREEN_MODE_DISABLE;
    }
    return self;
}

-(void)buildAddSubview:(VideoPlayer *)player {
    _seekForward     = [self _makeSeekButton:SEEK_DIRECTION_LEFT targetVideoPlayer:player];
    _seekBackward    = [self _makeSeekButton:SEEK_DIRECTION_RIGHT targetVideoPlayer:player];
    _slomo           = [self _makeSlomo:player];
    _teleButton      = [self _makeTeleButton];
    _liveButton      = [self _makeLiveButton];
    _tagEventName    = [self _makeTagEventName];
    _continuePlay    = [self _makeContinueButton];
    
    
    [self.view addSubview:_seekForward];
    [self.view addSubview:_seekBackward];
    [self.view addSubview:_slomo];
    [self.view addSubview:_teleButton];
    [self.view addSubview:_liveButton];
    [self.view addSubview:_continuePlay];
    
    liveElements    = @[_seekForward, _seekBackward, _slomo, _teleButton];
    
    clipElements    = @[_liveButton,_tagEventName,_continuePlay];
    teleElements    = @[];
    
    activeElements  = [@[]              arrayByAddingObjectsFromArray:liveElements];
    activeElements  = [activeElements   arrayByAddingObjectsFromArray:clipElements];
    activeElements  = [activeElements   arrayByAddingObjectsFromArray:teleElements];
   // [self _revealThese:@[]];
}

-(void)viewDidAppear:(BOOL)animated
{
    
    
    
    [self.seekForward  setFrame:CGRectMake(self.view.frame.size.width - (100 +self.seekForward.frame.size.width),
                                           self.seekForward.frame.origin.y,
                                           self.seekForward.frame.size.width,
                                           self.seekForward.frame.size.height)];
    
    [self.seekBackward  setFrame:CGRectMake(100,
                                            self.seekBackward.frame.origin.y,
                                            self.seekBackward.frame.size.width,
                                            self.seekBackward.frame.size.height)];
    
    [self.slomo setFrame:CGRectMake(190,
                                     self.slomo.frame.origin.y,
                                     self.slomo.frame.size.width,
                                     self.slomo.frame.size.height)];

    
    
    // adjust control bar size and position
    
    [super viewDidAppear:animated];
}

-(void)viewDidDisappear:(BOOL)animated
{

// return controll bar back to normal
    // set touch areas

}


/**
 *  Makes Slomo button
 *
 *  @param vp target video player
 *
 *  @return instance
 */
-(Slomo*)_makeSlomo:(VideoPlayer*)vp
{
    Slomo *  btn = [[Slomo alloc]initWithFrame:CGRectMake(80, controlOffsetY, 65, 50)];
    [btn addTarget:vp action:  @selector(toggleSlowmo) forControlEvents:UIControlEventTouchUpInside];
    return btn;
}

-(BorderButton *)_makeContinueButton
{
    BorderButton * btn       = [[BorderButton alloc]init];
    btn = [BorderButton buttonWithType:UIButtonTypeCustom];
    [btn setFrame:CGRectMake(10,controlOffsetY, 130, 30)];
    [btn setContentMode:UIViewContentModeScaleAspectFill];
    [btn setBackgroundImage:[UIImage imageNamed:@"continue_unselected.png"] forState:UIControlStateNormal];
    [btn setBackgroundImage:[UIImage imageNamed:@"continue.png"] forState:UIControlStateSelected];
    [btn setTitle:@"Continue" forState:UIControlStateNormal];
    [btn setTitleColor:PRIMARY_APP_COLOR forState:UIControlStateNormal];
    [btn setContentEdgeInsets:UIEdgeInsetsMake(0, 15, 0, 0)];
    [btn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    [btn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    return btn;
}

-(CustomButton *)_makeTeleButton
{
    CustomButton * btn       = [CustomButton buttonWithType:UIButtonTypeCustom];
    [btn setFrame:          CGRectMake(939.0f, controlOffsetY, 64.0f, 64.0f)];
    [btn setContentMode:    UIViewContentModeScaleAspectFill];
    [btn setImage:          [UIImage imageNamed:@"teleButton"] forState:UIControlStateNormal];
    [btn setImage:          [UIImage imageNamed:@"teleButtonSelect"] forState:UIControlStateHighlighted];
    //btn.transform         =CGAffineTransformMakeRotation(M_PI/2);
    [btn addTarget:self action:@selector(initTele:) forControlEvents:UIControlEventTouchUpInside];
    
    return btn;
}

-(LiveButton *)_makeLiveButton
{
    LiveButton * button = [[LiveButton alloc]initWithFrame:CGRectMake(500,controlOffsetY, 40 + 90, 30)];
    
/*
 liveButtoninFullScreen = [BorderButton buttonWithType:UIButtonTypeCustom];
 [liveButtoninFullScreen setFrame:CGRectMake(screenRect.size.height/2.0+150,screenRect.size.width- CONTROL_SPACER_Y-10, LITTLE_ICON_DIMENSIONS + 90, LITTLE_ICON_DIMENSIONS-10)];
 [liveButtoninFullScreen setContentMode:UIViewContentModeScaleAspectFill];
 [liveButtoninFullScreen setBackgroundImage:[UIImage imageNamed:@"gotolive"] forState:UIControlStateNormal];
 [liveButtoninFullScreen setBackgroundImage:[UIImage imageNamed:@"gotoliveSelect"] forState:UIControlStateHighlighted];
 [liveButtoninFullScreen setTitle:@"Live" forState:UIControlStateNormal];
 //[liveButtoninFullScreen changeBackgroundColor:[UIColor whiteColor] :0.8];
 [liveButtoninFullScreen addTarget:self action:@selector(goToLive) forControlEvents:UIControlEventTouchUpInside];
 */
    
    return button;
}



/**
 *  Makes Direction seek button
 *
 *  @param dir forward or backward
 *  @param vp  target video player
 *
 *  @return instance
 */
-(SeekButton*)_makeSeekButton:(Direction)dir targetVideoPlayer:(VideoPlayer*)vp
{
    SeekButton  * btn;
    switch ( dir ) {
        case SEEK_DIRECTION_LEFT:
            btn = [SeekButton makeFullScreenBackwardAt:CGPointMake(0, controlOffsetY)];
            break;
            
        default: ///SEEK_DIRECTION_RIGHT
            btn = [SeekButton makeFullScreenForwardAt:CGPointMake(0, controlOffsetY)];
            break;
    }
    [btn onPressSeekPerformSelector: @selector(seekWithSeekerButton:) addTarget:vp];
    return btn;
}


-(UILabel*)_makeTagEventName
{
    UILabel * label = [[UILabel alloc]init];
    [label setBackgroundColor:[UIColor clearColor]];
    label.layer.borderWidth = 1;
    label.layer.borderColor = PRIMARY_APP_COLOR.CGColor;
    [label setTextColor:PRIMARY_APP_COLOR];
    [label setText:@""];
    [label setFont:[UIFont boldFontOfSize:20.f]];
    [label setTextAlignment:NSTextAlignmentCenter];
    label.alpha = 1.0f;
    label.frame = CGRectMake(500,controlOffsetY,165 ,50);
    

    return label;
}



-(void)setMode:(int)mode
{
    if (mode==_mode) return;
    
    [self willChangeValueForKey:@"mode"];
    _mode = mode;
    
    switch (_mode) {
        case L2B_FULLSCREEN_MODE_DISABLE :
            [self _revealThese:@[]];
            break;
        case L2B_FULLSCREEN_MODE_LIVE :
            [self _revealThese:liveElements];
            break;
        case L2B_FULLSCREEN_MODE_CLIP :
            [self _revealThese:clipElements];
            break;
        case L2B_FULLSCREEN_MODE_TELE :
            [self _revealThese:teleElements];
            break;
        default:
            break;
    }
    [self didChangeValueForKey:@"mode"];
}

-(int)mode
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
