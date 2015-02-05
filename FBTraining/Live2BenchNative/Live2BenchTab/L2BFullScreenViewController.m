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
    NSArray                 * demoElements;
    NSArray                 * activeElements;
    float                   controlOffsetY;
}



@synthesize seekForward                 = _seekForward;
@synthesize seekBackward                = _seekBackward;
@synthesize slomo                       = _slomo ;
@synthesize teleButton                  = _teleButton;
@synthesize mode                        = _mode;
@synthesize liveButton                  = _liveButton;
@synthesize tagEventName                =_tagEventName;
@synthesize continuePlay                =_continuePlay;
@synthesize startRangeModifierButton    = _startRangeModifierButton;
@synthesize endRangeModifierButton      = _endRangeModifierButton;
@synthesize saveTeleButton              = _saveTeleButton;
@synthesize clearTeleButton             = _clearTeleButton;
@synthesize teleViewController          = _teleViewController;

-(id)initWithVideoPlayer:(UIViewController <PxpVideoPlayerProtocol>*)videoPlayer
{
    
    controlOffsetY  = 700.0f;
    self            = [super initWithVideoPlayer:videoPlayer];
    if (self){
        self.mode   = L2B_FULLSCREEN_MODE_DISABLE;
    }
    return self;
}

-(void)buildAddSubview:(VideoPlayer *)player {
    _seekForward                = [self _makeSeekButton:SEEK_DIRECTION_RIGHT targetVideoPlayer:player];
    _seekBackward               = [self _makeSeekButton:SEEK_DIRECTION_LEFT targetVideoPlayer:player];
    _slomo                      = [self _makeSlomo:player];
    _teleButton                 = [self _makeTeleButton];
    _liveButton                 = [self _makeLiveButton];
    _tagEventName               = [self _makeTagEventName];
    _continuePlay               = [self _makeContinueButton];
    _startRangeModifierButton   = [self _makeStartRange];
    _endRangeModifierButton     = [self _makeEndRange];
    _saveTeleButton             = [self _makeTeleSaveButton];
    _clearTeleButton            = [self _makeTeleClearButton];
    
    
    [self.view addSubview:_seekForward];
    [self.view addSubview:_seekBackward];
    [self.view addSubview:_slomo];
    [self.view addSubview:_teleButton];
    [self.view addSubview:_liveButton];
    [self.view addSubview:_continuePlay];
    [self.view addSubview:_tagEventName];
    [self.view addSubview:_startRangeModifierButton];
    [self.view addSubview:_endRangeModifierButton];
    [self.view addSubview:_saveTeleButton];
    [self.view addSubview:_clearTeleButton];
    
    
    
    liveElements    = @[_seekForward, _seekBackward, _slomo, _teleButton];
    clipElements    = @[_seekForward, _seekBackward, _slomo, _teleButton,_liveButton,_tagEventName,_continuePlay,_startRangeModifierButton,_endRangeModifierButton];
    teleElements    = @[_saveTeleButton,_clearTeleButton];
    
    activeElements  = [@[]              arrayByAddingObjectsFromArray:liveElements];
    activeElements  = [activeElements   arrayByAddingObjectsFromArray:clipElements];
    activeElements  = [activeElements   arrayByAddingObjectsFromArray:teleElements];
   // [self _revealThese:@[]];
    
    demoElements    = @[_seekForward, _seekBackward, _slomo];
    
    // Tele init
//    _teleViewController
    
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


-(Slomo*)_makeSlomo:(VideoPlayer*)vp
{
    Slomo *  btn = [[Slomo alloc]initWithFrame:CGRectMake(75, controlOffsetY, 65, 50)];
    [btn addTarget:self action:  @selector(toggleSlowmo) forControlEvents:UIControlEventTouchUpInside];

    return btn;
}

-(void)toggleSlowmo:(id)sender
{
    if ([self.player respondsToSelector:@selector(toggleSlowmo)]){
        [self.player performSelector:@selector(toggleSlowmo)];
    } else {
        self.player.slowmo = !self.player.slowmo;
    }
    
    
}



-(BorderButton *)_makeContinueButton
{
    BorderButton * btn       = [[BorderButton alloc]init];
    btn = [BorderButton buttonWithType:UIButtonTypeCustom];
    [btn setFrame:CGRectMake( (CGRectGetMidX(screenBounds)-(130/2))-180 ,controlOffsetY+10, 130, 30)];
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
    [btn setFrame:          CGRectMake(CGRectGetMaxX(screenBounds)-5.0f-64.0f, controlOffsetY-150, 64.0f, 64.0f)];
    [btn setContentMode:    UIViewContentModeScaleAspectFill];
    [btn setImage:          [UIImage imageNamed:@"teleButton"] forState:UIControlStateNormal];
    [btn setImage:          [UIImage imageNamed:@"teleButtonSelect"] forState:UIControlStateHighlighted];
    
    return btn;
}

-(LiveButton *)_makeLiveButton
{
    LiveButton * button = [[LiveButton alloc]initWithFrame:CGRectMake( (CGRectGetMidX(screenBounds)-(130/2))+180 ,controlOffsetY+10, 130, 30)];
    
    return button;
}

-(CustomButton *)_makeStartRange
{
    CustomButton * btn       = [CustomButton buttonWithType:UIButtonTypeCustom];
    [btn setContentMode:UIViewContentModeScaleAspectFill];
    [btn setTag:0];
//    NSString *accesibilityString = startRangeModifierButton.accessibilityValue;
//    NSString *imageName;
//    if ([accesibilityString isEqualToString:@"extend"]) {
//        imageName = @"extendstartsec";
//    }else{
//        imageName = @"subtractstartsec";
//    }
    [btn setImage:[UIImage imageNamed: @"extendstartsec"] forState:UIControlStateNormal];

    btn.frame = CGRectMake(20,controlOffsetY-5 ,65 ,65);
    [btn setAccessibilityValue:@"extend"];
    
    return btn;
}

-(CustomButton *)_makeEndRange
{
    CustomButton * btn       = [CustomButton buttonWithType:UIButtonTypeCustom];
    [btn setContentMode:UIViewContentModeScaleAspectFill];
    [btn setTag:1];
//    accesibilityString = endRangeModifierButton.accessibilityValue;
//    if ([accesibilityString isEqualToString:@"extend"]) {
//        imageName = @"extendendsec";
//    }else{
//        imageName = @"subtractendsec";
//    }
    [btn setImage:[UIImage imageNamed: @"extendendsec"] forState:UIControlStateNormal];
    
    btn.frame = CGRectMake(CGRectGetMaxX(screenBounds)-20.0f-65,controlOffsetY-5 ,65 ,65);
    [btn setAccessibilityValue:@"extend"];
    return btn;
}

-(SeekButton*)_makeSeekButton:(Direction)dir targetVideoPlayer:(VideoPlayer*)vp
{
    SeekButton  * btn;
    switch ( dir ) {
        case SEEK_DIRECTION_LEFT:
            btn = [SeekButton makeFullScreenBackwardAt:CGPointMake(0, controlOffsetY-10)];
            break;
            
        default: ///SEEK_DIRECTION_RIGHT
            btn = [SeekButton makeFullScreenForwardAt:CGPointMake(0, controlOffsetY-10)];
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
    [label setText:@"None"];
    [label setFont:[UIFont boldFontOfSize:20.f]];
    [label setTextAlignment:NSTextAlignmentCenter];
    label.alpha = 1.0f;
    label.frame = CGRectMake( CGRectGetMidX(screenBounds) - (165/2) ,controlOffsetY,165 ,50);
    
    
    return label;
}

-(BorderButton *)_makeTeleSaveButton
{
    BorderButton * btn       = [[BorderButton alloc]init];
    btn = [BorderButton buttonWithType:UIButtonTypeCustom];
    [btn setFrame:CGRectMake(377.0f, 700.0f, 123.0f, 33.0f)];
    [btn setTitle:NSLocalizedString(@"Save",nil) forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(_saveButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    return btn;
}

-(BorderButton *)_makeTeleClearButton
{
    BorderButton * btn       = [[BorderButton alloc]init];
    btn = [BorderButton buttonWithType:UIButtonTypeCustom];
    [btn setFrame:CGRectMake(500, 700.0f,123.0f, 33.0f)];
    [btn setTitle:NSLocalizedString(@"Close",nil) forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(_clearButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    return btn;
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
        case L2B_FULLSCREEN_MODE_DEMO :
            [self _revealThese:demoElements];
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



//save button clicked, send notification to the teleview controller
-(void)_saveButtonClicked
{
    [[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_SAVE_TELE object:nil];
}

//clear button clicked, send notification to the teleview controller
-(void)_clearButtonClicked
{
    [[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_CLEAR_TELE object:nil];
}



@end
