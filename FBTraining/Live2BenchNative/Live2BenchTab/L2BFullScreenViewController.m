//
//  L2BFullScreenViewController.m
//  Live2BenchNative
//
//  Created by dev on 2014-12-17.
//  Copyright (c) 2014 DEV. All rights reserved.
//

#import "L2BFullScreenViewController.h"
#import "PxpVideoPlayerProtocol.h"



@implementation L2BFullScreenViewController
{

    NSArray                 * liveElements;
    NSArray                 * eventElements;
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
@synthesize prevMode;

-(id)initWithVideoPlayer:(UIViewController <PxpVideoPlayerProtocol>*)videoPlayer
{
    
    controlOffsetY  = 700.0f;
    self            = [super initWithVideoPlayer:videoPlayer];
    if (self){
        self.mode   = L2BFullScreenModeDisable;
        //self.teleViewController = [[TeleViewController alloc] initWithController:self];
    }
    return self;
}

-(void)buildAddSubview:(UIViewController <PxpVideoPlayerProtocol> *)player {
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
    //[self.view addSubview:_teleButton];
    [self.view addSubview:_liveButton];
    [self.view addSubview:_continuePlay];
    [self.view addSubview:_tagEventName];
    [self.view addSubview:_startRangeModifierButton];
    [self.view addSubview:_endRangeModifierButton];
    //[self.view addSubview:_saveTeleButton];
    //[self.view addSubview:_clearTeleButton];
    
    
    eventElements   = @[_seekForward, _seekBackward, _slomo, _teleButton];
    liveElements    = @[_seekForward, _seekBackward, _slomo, _teleButton,_liveButton];
    clipElements    = @[_seekForward, _seekBackward, _slomo, _teleButton,_liveButton,_tagEventName,_continuePlay,_startRangeModifierButton,_endRangeModifierButton];
    teleElements    = @[_saveTeleButton,_clearTeleButton];
     demoElements    = @[_seekForward, _seekBackward, _slomo,_liveButton];
    
    activeElements  = [@[]              arrayByAddingObjectsFromArray:liveElements];
    activeElements  = [activeElements   arrayByAddingObjectsFromArray:clipElements];
    activeElements  = [activeElements   arrayByAddingObjectsFromArray:teleElements];
    activeElements  = [activeElements   arrayByAddingObjectsFromArray:eventElements];
    activeElements = [activeElements arrayByAddingObjectsFromArray:demoElements];
    [self _revealThese: @[]];
    
   
    
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


-(Slomo*)_makeSlomo:(UIViewController <PxpVideoPlayerProtocol>*)vp
{
    Slomo *  btn = [[Slomo alloc]initWithFrame:CGRectMake(75, controlOffsetY, 65, 50)];
    [btn addTarget:self action:  @selector(toggleSlowmo:) forControlEvents:UIControlEventTouchUpInside];

    return btn;
}

-(void)toggleSlowmo:(id)sender
{
    Slomo *  btn = (Slomo*) sender;
    UIViewController <PxpVideoPlayerProtocol> * p = self.player;
    p.slowmo = !p.slowmo;
    [btn setHighlighted:p.slowmo];
}



-(BorderButton *)_makeContinueButton
{
    BorderButton *btn = [BorderButton buttonWithType:UIButtonTypeCustom];
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
    
    [btn addTarget:self action:@selector(teleButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    
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

-(SeekButton*)_makeSeekButton:(Direction)dir targetVideoPlayer:(UIViewController <PxpVideoPlayerProtocol>*)vp
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
    BorderButton *btn = [BorderButton buttonWithType:UIButtonTypeCustom];
    [btn setFrame:CGRectMake(377.0f-10, 700.0f, 123.0f, 33.0f)];
    [btn setTitle:NSLocalizedString(@"Save",nil) forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(_saveButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    return btn;
}

-(BorderButton *)_makeTeleClearButton
{
    BorderButton *btn = [BorderButton buttonWithType:UIButtonTypeCustom];
    [btn setFrame:CGRectMake(500+10, 700.0f,123.0f, 33.0f)];
    [btn setTitle:NSLocalizedString(@"Close",nil) forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(_clearButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    return btn;
}

-(void)setMode:(L2BFullScreenModes)mode
{
    if (mode==_mode) return;
    prevMode = _mode;
    [self willChangeValueForKey:@"mode"];
    _mode = mode;

    switch (_mode) {
        case L2BFullScreenModeDisable :
            //[self _revealThese:liveElements];// should be @[]
            [self _revealThese:@[]];
            
            break;
        case L2BFullScreenModeLive :
            //[self _revealThese:liveElements];
            [self _revealThese:@[_seekForward, _seekBackward, _slomo, _teleButton,_liveButton]];
            break;
        case L2BFullScreenModeEvent:
            //[self _revealThese:eventElements];
            [self _revealThese:@[_seekForward, _seekBackward, _slomo, _teleButton]];
            break;
        case L2BFullScreenModeClip :
            //[self _revealThese:clipElements];
            [self _revealThese:@[_seekForward, _seekBackward, _slomo, _teleButton,_liveButton,_tagEventName,_continuePlay,_startRangeModifierButton,_endRangeModifierButton]];
            break;
        case L2BFullScreenModeTele :
            //[self _revealThese:teleElements];
            [self _revealThese:@[_saveTeleButton,_clearTeleButton]];
            break;
        case L2BFullScreenModeDemo :
            //[self _revealThese:demoElements];
            [self _revealThese:@[_seekForward, _seekBackward, _slomo,_liveButton]];
            break;
        default:
            break;
    }
    [self didChangeValueForKey:@"mode"];
}

-(L2BFullScreenModes)mode
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
    //[[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_SAVE_TELE object:nil];
    [self.player play];
    if (self.teleViewController){
        [self.teleViewController saveTeles];
    }
 //   [self setMode: L2B_FULLSCREEN_MODE_LIVE];
}

//clear button clicked, send notification to the teleview controller
-(void)_clearButtonClicked
{
//    [[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_CLEAR_TELE object:nil];
//  [self setMode: L2B_FULLSCREEN_MODE_LIVE];
    if (self.teleViewController && [self.teleViewController.clearButton.titleLabel.text isEqualToString:NSLocalizedString(@"Close",nil)]){
        [self.teleViewController forceCloseTele];
            [self.player play];
    } else {
        [self.teleViewController.teleView clearTelestration];
    }

}

-(void)teleButtonPressed{
 //   [self setMode: L2B_FULLSCREEN_MODE_TELE];

    //self.teleViewController = [[TeleViewController alloc] initWithController:self];
    //[self.teleViewController viewDidLoad];
    
    if (self.teleViewController){
        [self.teleViewController startTelestration];
    }
    [self.view addSubview: self.saveTeleButton];
    [self.view addSubview: self.clearTeleButton];
}

-(void)setTeleViewController:(TeleViewController *)teleViewController
{
    _teleViewController = teleViewController;
    _teleViewController.saveButton  = _saveTeleButton;
    _teleViewController.clearButton = _clearTeleButton;
}


@end
