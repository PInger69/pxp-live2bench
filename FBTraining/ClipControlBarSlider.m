//
//  ClipControlBarSlider.m
//  Live2BenchNative
//
//  Created by dev on 2015-04-14.
//  Copyright (c) 2015 DEV. All rights reserved.
//

#import "ClipControlBarSlider.h"

#define SLIDER_HEIGHT       30
#define BUTTON_HEIGHT       40
#define LABEL_WIDTH         55
#define CONTROL_BAR_HEIGHT  44

@implementation ClipControlBarSlider

{
    id player;
    SEL playSEL;
    SEL pauseSEL;
    SEL cancelSEL;
    
}

@synthesize timeSlider;
@synthesize playButton;
@synthesize leftClipTimeLabel;
@synthesize rightClipTimeLabel;
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
        self.leftClipTimeLabel              = [self buildSideLabel:CGRectMake(0, 0, LABEL_WIDTH, CONTROL_BAR_HEIGHT/2)];
        [self.leftClipTimeLabel setTextAlignment: NSTextAlignmentCenter];
        self.rightClipTimeLabel             = [self buildSideLabel:CGRectMake(0, 0, LABEL_WIDTH, CONTROL_BAR_HEIGHT/2)];
        [self.rightClipTimeLabel setTextAlignment: NSTextAlignmentCenter];
        self.leftVideoTimeLabel             = [self buildSideLabel:CGRectMake(0, CONTROL_BAR_HEIGHT/2, LABEL_WIDTH, CONTROL_BAR_HEIGHT/2)];
        [self.leftVideoTimeLabel setTextAlignment: NSTextAlignmentCenter];
        self.rightVideoTimeLabel            = [self buildSideLabel:CGRectMake(0, CONTROL_BAR_HEIGHT/2, LABEL_WIDTH,CONTROL_BAR_HEIGHT/2)];
        [self.rightVideoTimeLabel setTextAlignment: NSTextAlignmentCenter];

        UIView *leftLabelsView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, LABEL_WIDTH, CONTROL_BAR_HEIGHT)];
        [leftLabelsView addSubview: self.leftClipTimeLabel];
        [leftLabelsView addSubview: self.leftVideoTimeLabel];
        
        UIView *rightLabelsView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, LABEL_WIDTH, CONTROL_BAR_HEIGHT)];
        [rightLabelsView addSubview: self.rightClipTimeLabel];
        [rightLabelsView addSubview: self.rightVideoTimeLabel];

        
        self.timeSliderItem                 = [[UIBarButtonItem alloc] initWithCustomView:self.timeSlider];
        UIBarButtonItem *playButtonItem     = [[UIBarButtonItem alloc] initWithCustomView:self.playButton];
        UIBarButtonItem *leftTimeLabelItem  = [[UIBarButtonItem alloc] initWithCustomView:leftLabelsView];
        UIBarButtonItem *rightTimeLabelItem = [[UIBarButtonItem alloc] initWithCustomView:rightLabelsView];
//        UIBarButtonItem *leftVideoTimeLabelItem = [[UIBarButtonItem alloc] initWithCustomView:self.rightClipTimeLabel];
//        UIBarButtonItem *rightVideoTimeLabelItem = [[UIBarButtonItem alloc] initWithCustomView:self.rightClipTimeLabel];
        //UIImageView *cancelButtonView = [[UIImageView alloc]initWithImage:[self cancelClipImage]];
        //UIBarButtonItem *cancelClipButton = [[UIBarButtonItem alloc]initWithCustomView:cancelButtonView];
        UIBarButtonItem *cancelClipButton = [[UIBarButtonItem alloc]initWithImage:[self cancelClipImage] style:UIBarButtonItemStylePlain target:self action:@selector(cancelClip)];
        cancelClipButton.image = [[self cancelClipImage] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];

        [self setItems:@[playButtonItem,leftTimeLabelItem, self.timeSliderItem, rightTimeLabelItem, cancelClipButton]];
        
        self.backgroundColor = [UIColor orangeColor];
        self.tintColor = [UIColor blueColor];
        self.barTintColor = [UIColor orangeColor];
    }
    return self;
}

-(void)setValue:(double)value{
    _value = value;
    self.leftClipTimeLabel.text = [self translateTimeFormat: value *(self.maximumClipTime - self.minimumClipTime)];
    self.leftVideoTimeLabel.text = [self translateTimeFormat:(self.minimumClipTime + value *(self.maximumClipTime - self.minimumClipTime))];
    self.rightClipTimeLabel.text = [self translateTimeFormat: (self.maximumClipTime - self.minimumClipTime)];
    self.rightVideoTimeLabel.text = [self translateTimeFormat: self.maximumClipTime];   
}
-(void)cancelClip{
    [player performSelector:cancelSEL];
}

-(NSString*)translateTimeFormat:(float)time{
    NSUInteger dTotalSeconds = fabsf(time);
    NSUInteger dHours = floor(dTotalSeconds / 3600);
    NSUInteger dMinutes = floor(dTotalSeconds % 3600 / 60);
    NSUInteger dSeconds = floor(dTotalSeconds % 3600 % 60);
    NSString *displayTime;
    if (time < 0) {
        if (dHours > 0) {
            displayTime = [NSString stringWithFormat:@"-%i:%02i:%02i",dHours, dMinutes, dSeconds];
        }else{
            displayTime = [NSString stringWithFormat:@"-%02i:%02i", dMinutes, dSeconds];
        }
    }else{
        if (dHours > 0) {
            displayTime = [NSString stringWithFormat:@"%i:%02i:%02i",dHours, dMinutes, dSeconds];
        }else{
            displayTime = [NSString stringWithFormat:@"%02i:%02i", dMinutes, dSeconds];
        }
    }
    return displayTime;
}

-(void)setupPlay:(SEL)onPlaySel Pause:(SEL)onPauseSel onCancelClip: (SEL)cancelClipSel target:(id)target
{
    player      = target;
    playSEL     = onPlaySel;
    pauseSEL    = onPauseSel;
    cancelSEL   = cancelClipSel;
    [self.playButton addTarget:self action:@selector(playPause:)
              forControlEvents:UIControlEventTouchUpInside];
    
}

-(void)playPause:(id)sender
{
    UIButton * button = sender;
    if (!button.selected) {
        button.selected = YES;
        IMP imp = [player methodForSelector:pauseSEL];
        void (*func)(id, SEL) = (void *)imp;
        func(player, pauseSEL);
        
    } else if (button.selected) {
        button.selected = NO;
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
        
        [self.leftClipTimeLabel setText:@"--:--"];
        [self.rightClipTimeLabel setText:@"--:--"];
        [self.leftVideoTimeLabel setText:@"--:--"];
        [self.rightVideoTimeLabel setText:@"--:--"];
        self.playButton.enabled = NO;
        self.timeSlider.enabled = NO;
    }
    
    
    
}

-(UIImage *) cancelClipImage{
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(20, 20), NO, [UIScreen mainScreen].scale);
    
    UIBezierPath *cancelPath = [UIBezierPath bezierPath];
    cancelPath.lineCapStyle = kCGLineCapRound;
    cancelPath.lineWidth = 4.0;
    
    [cancelPath moveToPoint:CGPointMake(1, 1)];
    [cancelPath addLineToPoint: CGPointMake(19, 19)];
    
    [cancelPath moveToPoint:CGPointMake(19, 1)];
    [cancelPath addLineToPoint: CGPointMake(1, 19)];

    [[UIColor redColor] setStroke];
    
    [cancelPath stroke];
    
    UIImage *returnImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return returnImage;
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
