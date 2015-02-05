//
//  VideoControlBar.m
//  Live2BenchNative
//
//  Created by dev on 9/16/2014.
//  Copyright (c) 2014 DEV. All rights reserved.
//

#import "VideoControlBarSlider.h"
#import "OBSlider.h"

#define SLIDER_HEIGHT       30
#define BUTTON_HEIGHT       40
#define LABEL_WIDTH         60
#define CONTROL_BAR_HEIGHT  44

@implementation VideoControlBarSlider
{
    id player;
    SEL playSEL;
    SEL pauseSEL;
    
}

@synthesize timeSlider;
@synthesize playButton;
@synthesize leftTimeLabel;
@synthesize rightTimeLabel;
@synthesize enable =_enable;

- (id)initWithFrame:(CGRect)frame
{
    CGRect videoConrolBarFrame = CGRectMake(0.0f, frame.size.height - CONTROL_BAR_HEIGHT, frame.size.width, CONTROL_BAR_HEIGHT);
    self = [super initWithFrame:videoConrolBarFrame];
    if (self) {
        _enable                             = YES;
        CGRect slideFrame                   = CGRectMake(SLIDER_HEIGHT, 0.0, frame.size.width-220, SLIDER_HEIGHT);
        self.barStyle                       = UIBarStyleBlackTranslucent;
        
        self.timeSlider                     = [self buildSlider:slideFrame];
        self.playButton                     = [self buildPlayButton];
        self.leftTimeLabel                  = [self buildSideLabel:CGRectMake(0, 0, LABEL_WIDTH, BUTTON_HEIGHT)];
        self.rightTimeLabel                 = [self buildSideLabel:CGRectMake(0, 0, LABEL_WIDTH, BUTTON_HEIGHT)];
        self.timeSliderItem                 = [[UIBarButtonItem alloc] initWithCustomView:self.timeSlider];
        UIBarButtonItem *playButtonItem     = [[UIBarButtonItem alloc] initWithCustomView:self.playButton];
        UIBarButtonItem *leftTimeLabelItem  = [[UIBarButtonItem alloc] initWithCustomView:self.leftTimeLabel];
        UIBarButtonItem *rightTimeLabelItem = [[UIBarButtonItem alloc] initWithCustomView:self.rightTimeLabel];
        
        [self setItems:@[playButtonItem,leftTimeLabelItem,self.timeSliderItem,rightTimeLabelItem]];
    }
    return self;
}

-(void)setupPlay:(SEL)onPlaySel Pause:(SEL)onPauseSel target:(id)target
{
    player      = target;
    playSEL     = onPlaySel;
    pauseSEL    = onPauseSel;
    [self.playButton addTarget:self action:@selector(playPause:)
                         forControlEvents:UIControlEventTouchUpInside];

}

-(void)playPause:(id)sender
{
    UIButton * button = sender;
    if (!button.selected) {
        button.selected = NO;
        IMP imp = [player methodForSelector:pauseSEL];
        void (*func)(id, SEL) = (void *)imp;
        func(player, pauseSEL);
   
       } else if (button.selected) {
           button.selected = YES;
        IMP imp = [player methodForSelector:playSEL];
        void (*func)(id, SEL) = (void *)imp;
        func(player, playSEL);
    }

}


// UI items

-(OBSlider *)buildSlider:(CGRect)sFrame
{
    OBSlider * slider       = [[OBSlider alloc] initWithFrame:sFrame];
    slider.minimumValue     = 0.0;
    slider.value            = 0.0;
    slider.maximumValue     = 0.0;
    slider.continuous       = YES; //if set, value change events are generated any time the value changes due to dragging. default = YES
    
    [slider setMaximumTrackTintColor:[UIColor grayColor]];
    [slider setMinimumTrackTintColor:[UIColor whiteColor]];
    [slider setBackgroundColor:[UIColor clearColor]];
    
    
    UIImage *currentImage = [UIImage imageNamed:@"sliderthumb.png"];
    [slider setThumbImage:currentImage forState:UIControlStateNormal];
    [slider setThumbImage:currentImage forState:UIControlStateHighlighted];
    return slider;
}
-(UIButton *)buildPlayButton
{
    UIButton * pb = [UIButton buttonWithType:UIButtonTypeCustom];
    //set different image for different control state
    [pb setImage:[UIImage imageNamed:@"play.png"] forState:UIControlStateSelected];
    [pb setImage:[UIImage imageNamed:@"pause.png"] forState:UIControlStateNormal];
    //by default, the button is not seleted and the button image is pause image
    pb.selected = FALSE;
    //set play button frame
    [pb setFrame:CGRectMake(0, 0, BUTTON_HEIGHT, BUTTON_HEIGHT)];
    return pb;
}

-(UILabel *)buildSideLabel:(CGRect)rect
{
    UILabel * lbl  = [[UILabel alloc]initWithFrame:rect];
    [lbl setText:@"--:--"];
    [lbl setFont:[UIFont systemFontOfSize:13.0]];
    [lbl setTextColor:[UIColor whiteColor]];
    [lbl setBackgroundColor:[UIColor clearColor]];
    
    return lbl;
}

#pragma mark -
#pragma mark Getter and setter

-(BOOL)enable
{
    return _enable;
}

-(void)setEnable:(BOOL)enable
{
    if (_enable == enable) return;
    [self willChangeValueForKey:@"enable"];
    _enable = enable;
    [self didChangeValueForKey:@"enable"];

    if (enable) {
        self.playButton.enabled = YES;
        self.timeSlider.enabled = YES;

    } else {

        [self.leftTimeLabel setText:@"--:--"];
        [self.rightTimeLabel setText:@"--:--"];
        self.playButton.enabled = NO;
        self.timeSlider.enabled = NO;
    }
    


}

@end
