//
//  ListViewFullScreenViewController.m
//  Live2BenchNative
//
//  Created by dev on 2015-06-17.
//  Copyright © 2015 DEV. All rights reserved.
//

#import "ListViewFullScreenViewController.h"
#define LITTLE_ICON_DIMENSIONS 40

@interface ListViewFullScreenViewController ()

@end

@implementation ListViewFullScreenViewController{
     NSArray                 * activeElements;
     float                   controlOffsetY;
}

@synthesize seekForward                 = _seekForward;
@synthesize seekBackward                = _seekBackward;
@synthesize slomo                       = _slomo ;
@synthesize startRangeModifierButton    = _startRangeModifierButton;
@synthesize endRangeModifierButton      = _endRangeModifierButton;
@synthesize tagLabel                    = _tagLabel;
@synthesize prev                        = _prev;
@synthesize next                        = _next;

-(id)initWithVideoPlayer:(UIViewController <PxpVideoPlayerProtocol>*)videoPlayer
{
    controlOffsetY  = 700.0f;
    self            = [super initWithVideoPlayer:videoPlayer];
    if (self){
        self.mode   = ListViewFullScreenDisable;
    }
    return self;
}

-(void)buildAddSubview:(UIViewController <PxpVideoPlayerProtocol> *)player {
    
    _seekForward                = [self _makeSeekButton:SEEK_DIRECTION_RIGHT targetVideoPlayer:player];
    [self.view addSubview:_seekForward];
    
    
    _seekBackward               = [self _makeSeekButton:SEEK_DIRECTION_LEFT targetVideoPlayer:player];
    [self.view addSubview:_seekBackward];
    
    
    _slomo                      = [self _makeSlomo:player];
    [self.view addSubview:_slomo];

    
    _startRangeModifierButton = [CustomButton buttonWithType:UIButtonTypeCustom];
    _startRangeModifierButton = [[CustomButton alloc]initWithFrame:CGRectMake(0,controlOffsetY-3, 70, 60)];
    [_startRangeModifierButton setContentMode:UIViewContentModeScaleToFill];
    [_startRangeModifierButton setImage:[UIImage imageNamed:@"extendstartsec.png"] forState:UIControlStateNormal];
    [_startRangeModifierButton setAccessibilityValue:@"extend"];
    [self.view addSubview:_startRangeModifierButton];
    
    
    _endRangeModifierButton = [CustomButton buttonWithType:UIButtonTypeCustom];
    _endRangeModifierButton = [[CustomButton alloc]initWithFrame:CGRectMake(910,controlOffsetY-3, 70, 60)];
    [_endRangeModifierButton setContentMode:UIViewContentModeScaleToFill];
    [_endRangeModifierButton setImage:[UIImage imageNamed:@"extendendsec.png"] forState:UIControlStateNormal];
    [_endRangeModifierButton setAccessibilityValue:@"extend"];
    [self.view addSubview:_endRangeModifierButton];
    
    
    _tagLabel        = [self makeTagLabel];
    _tagLabel.alpha  = 0.7;
    [self.view addSubview:_tagLabel];
    
    _prev                   = [[UIButton alloc]initWithFrame:CGRectMake(300, controlOffsetY, 100, 50)];
    [_prev setBackgroundColor:[UIColor clearColor]];
    [_prev setTitleColor:PRIMARY_APP_COLOR forState:UIControlStateNormal];
    [[_prev layer]setBorderWidth:2.0f];
    [[_prev layer]setBorderColor:PRIMARY_APP_COLOR.CGColor];
    [_prev setTitle:@"PREVIOUS" forState:UIControlStateNormal];
    [self.view addSubview:_prev];

    
    _next                   = [[UIButton alloc]initWithFrame:CGRectMake(650, controlOffsetY,100, 50)];
    [_next setBackgroundColor:[UIColor clearColor]];
    [_next setTitleColor:PRIMARY_APP_COLOR forState:UIControlStateNormal];
    [[_next layer]setBorderWidth:2.0f];
    [[_next layer]setBorderColor:PRIMARY_APP_COLOR.CGColor];
    [_next setTitle:@"NEXT" forState:UIControlStateNormal];
    [self.view addSubview:_next];

    activeElements = @[_seekForward, _seekBackward, _slomo, _startRangeModifierButton, _endRangeModifierButton,_tagLabel,_prev,_next];
     [self _revealThese: @[]];
    
    
}

-(void)setTagName:(NSString *)name
{
    _tagLabel.text = name;
}

-(SeekButton*)_makeSeekButton:(Direction)dir targetVideoPlayer:(UIViewController <PxpVideoPlayerProtocol>*)vp
{
    SeekButton  * btn;
    switch ( dir ) {
        case SEEK_DIRECTION_LEFT:
            btn = [SeekButton makeFullScreenBackwardAt:CGPointMake(100, controlOffsetY-10)];
            break;
            
        default: ///SEEK_DIRECTION_RIGHT
            btn = [SeekButton makeFullScreenForwardAt:CGPointMake(800, controlOffsetY-10)];
            break;
    }
    [btn onPressSeekPerformSelector: @selector(seekWithSeekerButton:) addTarget:vp];
    return btn;
}

-(Slomo*)_makeSlomo:(UIViewController <PxpVideoPlayerProtocol>*)vp
{
    Slomo *  btn = [[Slomo alloc]initWithFrame:CGRectMake(190, controlOffsetY, 65, 50)];
    [btn addTarget:self action:  @selector(toggleSlowmo:) forControlEvents:UIControlEventTouchUpInside];
    
    return btn;
}

-(UILabel *)makeTagLabel
{
    UILabel * tagEventName = [[UILabel alloc] initWithFrame:CGRectMake(450, controlOffsetY+13, 150, 30)];
    [tagEventName setBackgroundColor:[UIColor clearColor]];
    tagEventName.layer.borderColor = PRIMARY_APP_COLOR.CGColor;
    tagEventName.layer.borderWidth = 1;
    [tagEventName setText:@"Event Name"];
    [tagEventName setTextColor:PRIMARY_APP_COLOR];
    [tagEventName setTextAlignment:NSTextAlignmentCenter];
    
    return tagEventName;
}


-(void)setMode:(ListViewFullScreenModes)mode
{
    if (_mode == mode) return;
    _mode = mode;
    
    switch (_mode) {
        case ListViewFullScreenDisable :
            [self _revealThese:@[]];
            break;
        case ListViewFullScreenRegular :
            [self _revealThese:@[_seekForward,_seekBackward,_slomo]];
            break;
        case ListViewFullScreenClip:
            [self _revealThese: @[_seekBackward,_seekForward,_startRangeModifierButton,_endRangeModifierButton,_slomo,_tagLabel,_prev,_next]];
            break;
        default:
            break;
    }
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

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    PXPLog(@"*** didReceiveMemoryWarning ***");
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
