//
//  FootballBottomViewController.m
//  Live2BenchNative
//
//  Created by DEV on 2013-08-14.
//  Copyright (c) 2013 DEV. All rights reserved.
//

#import "FootballBottomViewController.h"
#import "CustomButton.h"


#define TOTAL_WIDTH                         1024
#define BOTTOM_VIEW_CONTROLLER_WIDTH        854
@interface FootballBottomViewController ()

@end

@implementation FootballBottomViewController{
    
    FootballModes _currentMode;
    NSMutableArray *_everything;
    CustomButton *_nextPlayButton;
    NSNumber *startTime;
    
    UIView *_offLayoutView;
    
    UILabel *_teamSelectionLabel;
    CustomButton *_offButton;
    CustomButton *_defButton;
    CustomButton *_stButton;
    NSString *start;
    
    UILabel *_seriesLabel;
    UIPickerView *_seriesPickerView;
    NSArray *seriesData;
    
    UILabel *_quarterLabel;
    NSArray *arrayOfQuarterButtons;
    
    UILabel *_downLabel;
    NSArray *arrayOfDownButtons;
    
    UILabel *_distanceLabel;
    UIPickerView *_distancePickerView;
    NSArray *distanceData;
    
    UILabel *_typeLabel;
    NSArray *arrayOfTypeButtons;
    
    UILabel *_fieldLabel;
    UILabel *_fieldPosSliderPos;
    UISlider *_fieldPosSlider;
    
    UILabel *_gainLabel;
    UIPickerView *_gainPickerView;
    NSArray *gainData;
    
    UILabel *_playCallLabel;
    UIPickerView *_playCallPickerView;
    //NSArray *playCallData;
    
    UILabel *_playCallOppLabel;
    UIPickerView *_playCallOppPickerView;
    //NSArray *playCallOppData;
    
    UILabel *_sTLabel;
    UIPickerView *_sTPickerView;
    NSArray *stData;


}

@synthesize currentEvent = _currentEvent;

@synthesize mainView = _mainView;

-(id)init{
    self = [super init];
    
    if (self) {
        
         self.view.frame = CGRectMake(0, 540, self.view.frame.size.width, self.view.frame.size.height);
        _mainView = self.view;
        _offLayoutView = [[UIView alloc] initWithFrame:CGRectMake(150, 0, BOTTOM_VIEW_CONTROLLER_WIDTH, self.view.bounds.size.height)];
        [self.view addSubview:_offLayoutView];
        
        
        // Set Up Team Selection
        _teamSelectionLabel = [[UILabel alloc]initWithFrame:CGRectMake(5 , 0, 100, 30)];
        [_teamSelectionLabel setText:@"TEAM SEL."];
        [_teamSelectionLabel setFont:[UIFont systemFontOfSize: 13.0f]];
        [_teamSelectionLabel setTextAlignment:NSTextAlignmentCenter];
        [_teamSelectionLabel setBackgroundColor:[UIColor clearColor]];
        [self.view addSubview:_teamSelectionLabel];
        
        _offButton = [CustomButton buttonWithType:UIButtonTypeCustom];
        [_offButton setFrame:CGRectMake(25, 32, 80, 45)];
        [_offButton setBackgroundImage:[Utility makeOnePixelUIImageWithColor:SECONDARY_APP_COLOR] forState:UIControlStateNormal];
        [_offButton setBackgroundImage:[Utility makeOnePixelUIImageWithColor:[UIColor greenColor]] forState:UIControlStateSelected];
        [_offButton addTarget:self action:@selector(teamButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [_offButton setTitle:@"OFFENSE" forState:UIControlStateNormal];
        [_offButton.titleLabel setTextAlignment:NSTextAlignmentCenter];
        [_offButton.titleLabel setFont:[UIFont systemFontOfSize:16.0f]];
        [_offButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [self.view insertSubview:_offButton aboveSubview:_offLayoutView];
        
        _defButton = [CustomButton buttonWithType:UIButtonTypeCustom];
        [_defButton setFrame:CGRectMake(_offButton.frame.origin.x, _offButton.frame.origin.y + _offButton.frame.size.height+11.5, _offButton.frame.size.width, _offButton.frame.size.height)];
        [_defButton setBackgroundImage:[Utility makeOnePixelUIImageWithColor:SECONDARY_APP_COLOR] forState:UIControlStateNormal];
        [_defButton setBackgroundImage:[Utility makeOnePixelUIImageWithColor:[UIColor redColor]] forState:UIControlStateSelected];
        [_defButton addTarget:self action:@selector(teamButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [_defButton setTitle:@"DEFENSE" forState:UIControlStateNormal];
        [_defButton.titleLabel setTextAlignment:NSTextAlignmentCenter];
        [_defButton.titleLabel setFont:[UIFont systemFontOfSize:16.0f]];
        [_defButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [self.view insertSubview:_defButton aboveSubview:_offLayoutView];
        
        _stButton = [CustomButton buttonWithType:UIButtonTypeCustom];
        [_stButton setFrame:CGRectMake(_defButton.frame.origin.x, _defButton.frame.origin.y + _defButton.frame.size.height+11.5, _defButton.frame.size.width, _defButton.frame.size.height)];
        [_stButton setBackgroundImage:[Utility makeOnePixelUIImageWithColor:SECONDARY_APP_COLOR] forState:UIControlStateNormal];
        [_stButton setBackgroundImage:[Utility makeOnePixelUIImageWithColor:PRIMARY_APP_COLOR] forState:UIControlStateSelected];
        [_stButton addTarget:self action:@selector(specialTeamButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [_stButton setTitle:@"ST" forState:UIControlStateNormal];
        [_stButton.titleLabel setTextAlignment:NSTextAlignmentCenter];
        [_stButton.titleLabel setFont:[UIFont systemFontOfSize:16.0f]];
        [_stButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [self.view insertSubview:_stButton aboveSubview:_offLayoutView];
        
        
        // Set Up Series
        _seriesLabel = [[UILabel alloc]initWithFrame:CGRectMake(0 , 0, 70, 30)];
        [_seriesLabel setText:@"SERIES"];
        [_seriesLabel setFont:[UIFont systemFontOfSize: 13.0f]];
        [_seriesLabel setTextAlignment:NSTextAlignmentCenter];
        [_seriesLabel setBackgroundColor:[UIColor clearColor]];
        [_offLayoutView addSubview:_seriesLabel];
        
        _seriesPickerView = [[UIPickerView alloc]initWithFrame:CGRectMake(_seriesLabel.frame.origin.x-10, _seriesLabel.frame.origin.y + _seriesLabel.frame.size.height - 9,_seriesLabel.frame.size.width + 20,180 )];
        [_seriesPickerView setDataSource:self];
        [_seriesPickerView setDelegate:self];
        [_seriesPickerView setBackgroundColor:[UIColor clearColor]];
        _seriesPickerView.showsSelectionIndicator = YES;
        CALayer* mask = [[CALayer alloc] init];
        [mask setBackgroundColor: [UIColor whiteColor].CGColor];
        [mask setFrame:  CGRectMake(15.0f , 10.0f, 60.0f, 160.f)];
        [mask setCornerRadius: 2.0f];
        [_seriesPickerView.layer setMask: mask];
        [_offLayoutView addSubview:_seriesPickerView];

        seriesData = [self addArrayValueForPickerViews:@"series"];
        
        
        // Set Up Quarter
        _quarterLabel = [[UILabel alloc]initWithFrame:CGRectMake(_seriesLabel.frame.origin.x +_seriesLabel.frame.size.width+15 , _seriesLabel.frame.origin.y, _seriesLabel.frame.size.width, _seriesLabel.frame.size.height)];
        [_quarterLabel setText:@"QUARTER"];
        [_quarterLabel setFont:[UIFont systemFontOfSize: 13.0f]];
        [_quarterLabel setTextAlignment:NSTextAlignmentCenter];
        [_quarterLabel setBackgroundColor:[UIColor clearColor]];
        [_offLayoutView addSubview:_quarterLabel];
        
        arrayOfQuarterButtons = [self createButtons:@[@"Q1",@"Q2",@"Q3",@"Q4"] type:@"Quarter"];
        
        
        // Set Up Down
        _downLabel = [[UILabel alloc]initWithFrame:CGRectMake(_quarterLabel.frame.origin.x +_quarterLabel.frame.size.width+15 , _quarterLabel.frame.origin.y, _quarterLabel.frame.size.width, _quarterLabel.frame.size.height)];
        [_downLabel setText:@"DOWN"];
        [_downLabel setFont:[UIFont systemFontOfSize: 13.0f]];
        [_downLabel setTextAlignment:NSTextAlignmentCenter];
        [_downLabel setBackgroundColor:[UIColor clearColor]];
        [_offLayoutView addSubview:_downLabel];
        
        arrayOfDownButtons = [self createButtons:@[@"D1",@"D2",@"D3"] type:@"Down"];
        
        
        // Set Up Distance
        _distanceLabel = [[UILabel alloc]initWithFrame:CGRectMake(_downLabel.frame.origin.x +_downLabel.frame.size.width+15 , _downLabel.frame.origin.y, _downLabel.frame.size.width, _downLabel.frame.size.height)];
        [_distanceLabel setText:@"DISTANCE"];
        [_distanceLabel setFont:[UIFont systemFontOfSize: 13.0f]];
        [_distanceLabel setTextAlignment:NSTextAlignmentCenter];
        [_distanceLabel setBackgroundColor:[UIColor clearColor]];
        [_offLayoutView addSubview:_distanceLabel];
        
        _distancePickerView = [[UIPickerView alloc]initWithFrame:CGRectMake(_distanceLabel.frame.origin.x -10 , _distanceLabel.frame.origin.y + _distanceLabel.frame.size.height - 9,_distanceLabel.frame.size.width + 20,180 )];
        [_distancePickerView setDataSource:self];
        [_distancePickerView setDelegate:self];
        [_distancePickerView setBackgroundColor:[UIColor clearColor]];
        _distancePickerView.showsSelectionIndicator = TRUE;
        CALayer* yrdsToRunMask = [[CALayer alloc] init];
        [yrdsToRunMask setBackgroundColor: [UIColor whiteColor].CGColor];
        [yrdsToRunMask setFrame:  CGRectMake(15.0f, 10.0f, 60.0f, 160.f)];
        [yrdsToRunMask setCornerRadius: 5.0f];
        [_distancePickerView.layer setMask: yrdsToRunMask];
        [_offLayoutView addSubview:_distancePickerView];
        
        distanceData = [self addArrayValueForPickerViews:@"distance"];
        
        
        // Set Up Type
        _typeLabel = [[UILabel alloc]initWithFrame:CGRectMake(_distanceLabel.frame.origin.x +_distanceLabel.frame.size.width+15 , _distanceLabel.frame.origin.y, _distanceLabel.frame.size.width, _distanceLabel.frame.size.height)];
        [_typeLabel setText:@"TYPE"];
        [_typeLabel setFont:[UIFont systemFontOfSize: 13.0f]];
        [_typeLabel setTextAlignment:NSTextAlignmentCenter];
        [_typeLabel setBackgroundColor:[UIColor clearColor]];
        [_offLayoutView addSubview:_typeLabel];
        
        arrayOfTypeButtons = [self createButtons:@[@"Pass",@"Run",@"Kick"] type:@"Type"];
        
        
        // Set Up Field
        _fieldLabel = [[UILabel alloc]initWithFrame:CGRectMake(_typeLabel.frame.origin.x +_typeLabel.frame.size.width+15 , _typeLabel.frame.origin.y, _typeLabel.frame.size.width, _typeLabel.frame.size.height)];
        [_fieldLabel setText:@"FIELD"];
        [_fieldLabel setFont:[UIFont systemFontOfSize: 13.0f]];
        [_fieldLabel setTextAlignment:NSTextAlignmentCenter];
        [_fieldLabel setBackgroundColor:[UIColor clearColor]];
        [_offLayoutView addSubview:_fieldLabel];
        
        _fieldPosSlider = [[UISlider alloc] initWithFrame:CGRectMake(_fieldLabel.frame.origin.x -25 , _fieldLabel.frame.origin.y + _fieldLabel.frame.size.height +65,160,40)];
        [_fieldPosSlider addTarget:self action:@selector(sliderAction:) forControlEvents:UIControlEventValueChanged];
        [_fieldPosSlider setBackgroundColor:[UIColor clearColor]];
        _fieldPosSlider.minimumValue = -55;
        _fieldPosSlider.maximumValue = 55;
        _fieldPosSlider.continuous = YES;
        _fieldPosSlider.value = 0.0;
        _fieldPosSlider.transform = CGAffineTransformMakeRotation(M_PI/2);
        [_offLayoutView addSubview:_fieldPosSlider];
        
        _fieldPosSliderPos = [[UILabel alloc] initWithFrame:CGRectMake(_fieldPosSlider.frame.origin.x - 30, _fieldPosSlider.value+_fieldPosSlider.frame.origin.y+55, 60, 40)];
        [_fieldPosSliderPos setBackgroundColor:[UIColor clearColor]];
        [_fieldPosSliderPos setText:[NSString stringWithFormat:@"%.0f",[_fieldPosSlider value]+55.0 ]];
        [_offLayoutView addSubview:_fieldPosSliderPos];
        
        
        // Set Up Gain
        _gainLabel = [[UILabel alloc]initWithFrame:CGRectMake(_fieldLabel.frame.origin.x +_fieldLabel.frame.size.width+15 , _fieldLabel.frame.origin.y, _fieldLabel.frame.size.width, _fieldLabel.frame.size.height)];
        [_gainLabel setText:@"GAIN"];
        [_gainLabel setFont:[UIFont systemFontOfSize: 13.0f]];
        [_gainLabel setTextAlignment:NSTextAlignmentCenter];
        [_gainLabel setBackgroundColor:[UIColor clearColor]];
        [_offLayoutView addSubview:_gainLabel];
        
        _gainPickerView = [[UIPickerView alloc]initWithFrame:CGRectMake(_gainLabel.frame.origin.x -10 , _gainLabel.frame.origin.y + _gainLabel.frame.size.height - 9,_gainLabel.frame.size.width + 20,180 )];
        [_gainPickerView setDataSource:self];
        [_gainPickerView setDelegate:self];
        [_gainPickerView setBackgroundColor:[UIColor clearColor]];
        _gainPickerView.showsSelectionIndicator = TRUE;
        CALayer* yrdsGainMask = [[CALayer alloc] init];
        [yrdsGainMask setBackgroundColor: [UIColor whiteColor].CGColor];
        [yrdsGainMask setFrame:  CGRectMake(15.0f, 10.0f, 60.0f, 160.f)];
        [yrdsGainMask setCornerRadius: 5.0f];
        [_gainPickerView.layer setMask: yrdsGainMask];
        [_gainPickerView selectRow:55 inComponent:0 animated:YES];
        [_offLayoutView addSubview:_gainPickerView];
        
        gainData = [self addArrayValueForPickerViews:@"gain"];
        
        
        // Set Up PlayCall
        _playCallLabel = [[UILabel alloc]initWithFrame:CGRectMake(_gainLabel.frame.origin.x +_gainLabel.frame.size.width+25 , _gainLabel.frame.origin.y, _gainLabel.frame.size.width, _gainLabel.frame.size.height)];
        [_playCallLabel setText:@"PLAYCALL"];
        [_playCallLabel setFont:[UIFont systemFontOfSize: 13.0f]];
        [_playCallLabel setTextAlignment:NSTextAlignmentCenter];
        [_playCallLabel setBackgroundColor:[UIColor clearColor]];
        [_offLayoutView addSubview:_playCallLabel];
        
        _playCallPickerView =  [[UIPickerView alloc] initWithFrame:CGRectMake(_playCallLabel.frame.origin.x-25, _playCallLabel.frame.origin.y + _playCallLabel.frame.size.height -7, _playCallLabel.frame.size.width+50, 180)];
        [_playCallPickerView setDataSource:self];
        [_playCallPickerView setDelegate:self];
        [_playCallPickerView setBackgroundColor:[UIColor clearColor]];
        _playCallPickerView.showsSelectionIndicator = TRUE;
        CALayer* playCallMask = [[CALayer alloc] init];
        [playCallMask setBackgroundColor: [UIColor whiteColor].CGColor];
        [playCallMask setFrame:  CGRectMake(10.0f, 10.0f, 100.0f, 160.f)];
        [playCallMask setCornerRadius: 5.0f];
        [_playCallPickerView.layer setMask: playCallMask];
        [_playCallPickerView selectRow:55 inComponent:0 animated:YES];
        [_offLayoutView addSubview:_playCallPickerView];
        
        _playCallData = [[NSMutableArray alloc]initWithArray:@[]];
        
        
        // Set Up PlayCall Opp
        _playCallOppLabel = [[UILabel alloc]initWithFrame:CGRectMake(_playCallLabel.frame.origin.x +_playCallLabel.frame.size.width+35 , _playCallLabel.frame.origin.y, _playCallLabel.frame.size.width, _playCallLabel.frame.size.height)];
        [_playCallOppLabel setText:@"PC OPP."];
        [_playCallOppLabel setFont:[UIFont systemFontOfSize: 13.0f]];
        [_playCallOppLabel setTextAlignment:NSTextAlignmentCenter];
        [_playCallOppLabel setBackgroundColor:[UIColor clearColor]];
        [_offLayoutView addSubview:_playCallOppLabel];
        
        _playCallOppPickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(_playCallOppLabel.frame.origin.x-20, _playCallOppLabel.frame.origin.y + _playCallOppLabel.frame.size.height -7, _playCallOppLabel.frame.size.width+50, 180)];
        [_playCallOppPickerView setDataSource:self];
        [_playCallOppPickerView setDelegate:self];
        [_playCallOppPickerView setBackgroundColor:[UIColor clearColor]];
        _playCallOppPickerView.showsSelectionIndicator = TRUE;
        CALayer* playCallOppMask = [[CALayer alloc] init];
        [playCallOppMask setBackgroundColor: [UIColor whiteColor].CGColor];
        [playCallOppMask setFrame:  CGRectMake(10.0f, 10.0f, 100.0f, 160.f)];
        [playCallOppMask setCornerRadius: 5.0f];
        [_playCallOppPickerView.layer setMask: playCallOppMask];
        [_playCallOppPickerView selectRow:55 inComponent:0 animated:YES];
        [_offLayoutView addSubview:_playCallOppPickerView];
        
        _playCallOppData = [[NSMutableArray alloc]initWithArray:@[]];
        
        // Set Up Special Teams
        _sTLabel = [[UILabel alloc]initWithFrame:CGRectMake(-20 , 0, 70, 30)];
        [_sTLabel setText:@"SPECIAL"];
        [_sTLabel setFont:[UIFont systemFontOfSize: 13.0f]];
        [_sTLabel setTextAlignment:NSTextAlignmentCenter];
        [_sTLabel setBackgroundColor:[UIColor clearColor]];
        [_offLayoutView addSubview:_sTLabel];
        
        _sTPickerView = [[UIPickerView alloc]initWithFrame:CGRectMake(_sTLabel.frame.origin.x-40, _seriesLabel.frame.origin.y + _seriesLabel.frame.size.height - 9,_seriesLabel.frame.size.width + 80,180 )];
        [_sTPickerView setDataSource:self];
        [_sTPickerView setDelegate:self];
        [_sTPickerView setBackgroundColor:[UIColor clearColor]];
        _sTPickerView.showsSelectionIndicator = YES;
        CALayer* tmask = [[CALayer alloc] init];
        [tmask setBackgroundColor: [UIColor whiteColor].CGColor];
        [tmask setFrame:  CGRectMake(15.0f , 10.0f, 120.0f, 160.f)];
        [tmask setCornerRadius: 2.0f];
        [_sTPickerView.layer setMask: tmask];
        [_offLayoutView addSubview:_sTPickerView];
        
        stData = [self addArrayValueForPickerViews:@"special team"];

        
        // Set Up Next Button
        _nextPlayButton = [CustomButton buttonWithType:UIButtonTypeCustom];
        [_nextPlayButton setFrame:CGRectMake(_playCallOppPickerView.frame.origin.x +_playCallOppPickerView.frame.size.width-55, _playCallOppLabel.frame.origin.y+90,160 , _offButton.frame.size.height)];
        [_nextPlayButton setTitle:@"NEXT PLAY" forState:UIControlStateNormal];
        [_nextPlayButton setBackgroundImage:[Utility makeOnePixelUIImageWithColor:SECONDARY_APP_COLOR] forState:UIControlStateNormal];
        [_nextPlayButton.titleLabel setTextAlignment:NSTextAlignmentCenter];
        [_nextPlayButton.titleLabel setFont:[UIFont systemFontOfSize:25.0f]];
        _nextPlayButton.transform = CGAffineTransformMakeRotation(3*M_PI/2.0);
        [_nextPlayButton addTarget:self action:@selector(sendTag:) forControlEvents:UIControlEventTouchUpInside];
        [_nextPlayButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_offLayoutView addSubview:_nextPlayButton];
        
        
        // Populate everything Array
        _everything = [[NSMutableArray alloc]initWithArray:@[_teamSelectionLabel,_offButton,_defButton,_stButton,_seriesLabel,_seriesPickerView,_quarterLabel,_downLabel,_distanceLabel,_distancePickerView,_typeLabel,_fieldLabel,_fieldPosSlider,_fieldPosSliderPos,_gainLabel,_gainPickerView,_playCallLabel,_playCallPickerView,_playCallOppLabel,_playCallOppPickerView,_sTLabel,_sTPickerView,_nextPlayButton]];
        [_everything addObjectsFromArray:arrayOfDownButtons];
        [_everything addObjectsFromArray:arrayOfQuarterButtons];
        [_everything addObjectsFromArray:arrayOfTypeButtons];
        
        
        // Init Original Screen
        [_sTLabel setHidden:true];
        [_sTPickerView setHidden:true];
        [self revealThese:@[_teamSelectionLabel,_offButton,_defButton]];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(update) name:NOTIF_RICO_PLAYER_VIEW_CONTROLLER_UPDATE object:nil];
}

#pragma mark - Buttons Methods

// create all kind of buttons
-(NSArray*)createButtons:(NSArray*)titleArray type:(NSString*)type{
     NSMutableArray *array = [[NSMutableArray alloc]init];
    
    for (int i = 0; i < titleArray.count; i++) {
        CustomButton *button = [CustomButton buttonWithType:UIButtonTypeCustom];
        
        CGRect frame;
        if ([type isEqualToString:@"Down"]) {
            frame = CGRectMake(_downLabel.frame.origin.x, _downLabel.frame.origin.y + _downLabel.frame.size.height+2 + i*54.5 , _downLabel.frame.size.width, 50);
            [button addTarget:self action:@selector(downButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        }else if ([type isEqualToString:@"Type"]){
            frame = CGRectMake(_typeLabel.frame.origin.x, _typeLabel.frame.origin.y + _typeLabel.frame.size.height+2 + i*54.5 , _typeLabel.frame.size.width, 50);
            [button addTarget:self action:@selector(typeButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        }else if ([type isEqualToString:@"Quarter"]){
            frame = CGRectMake(_quarterLabel.frame.origin.x, _quarterLabel.frame.origin.y + _quarterLabel.frame.size.height+2 + i*41 , _quarterLabel.frame.size.width, 36);
            [button addTarget:self action:@selector(quarterButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        }
        
        [button setFrame:frame];
        [button setBackgroundImage:[Utility makeOnePixelUIImageWithColor:SECONDARY_APP_COLOR] forState:UIControlStateNormal];
        [button setBackgroundImage:[Utility makeOnePixelUIImageWithColor:PRIMARY_APP_COLOR] forState:UIControlStateSelected];
        [button setTitle:titleArray[i] forState:UIControlStateNormal];
        [button.titleLabel setTextAlignment:NSTextAlignmentCenter];
        [button.titleLabel setFont:[UIFont boldSystemFontOfSize:28.0f]];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        button.tag = i;
        [_offLayoutView addSubview:button];
        [array addObject:button];
    }
    return array;
}

// Quarter Button Pressed, set property for tag
-(void)quarterButtonPressed:(id)sender{
    
    CMTime cTime = kCMTimeZero;
    if (self.delegate) {
        cTime = self.delegate.currentTime;
    }
    
    NSNumber *time = [NSNumber numberWithFloat:CMTimeGetSeconds(cTime)];
    CustomButton *button = sender;
    [self unSelectButtons:arrayOfQuarterButtons];
    [button setSelected:true];
    
    NSDictionary *dict = @{@"name":[self currentPeriod],@"period":[self currentPeriod],@"time":time,@"type":[NSNumber numberWithInteger:TagTypeFootballQuarterStart]};
    [super postTag:dict];
    
}

// Type Button Pressed, set property for tag
-(void)typeButtonPressed:(id)sender{
    CustomButton *button = sender;
    [self unSelectButtons:arrayOfTypeButtons];
    [button setSelected:true];
}

-(void)specialTeamButtonPressed:(id)sender{
    [self revealTeam:@"special"];
    [_stButton setSelected:true];
}

// Down Button Pressed, abondon the current tag
-(void)downButtonPressed:(id)sender{
    CustomButton *button = sender;
    [self assignNewState:button.titleLabel.text];
    [self unSelectButtons:arrayOfDownButtons];
    [button setSelected:true];
}

// Team Button Pressed, abondon the current tag
-(void)teamButtonPressed:(id)sender{
    if (_currentMode == FootballDisable) {
        [self screenSetUp:sender];
    }else{
        if ([sender isEqual:_offButton]) {
            [self goToOffenseOrDefense:@"offense"];

        }else if ([sender isEqual:_defButton]){
            [self goToOffenseOrDefense:@"defense"];
        }
        [self assignNewState:@"D1"];
    }
}

// Change team when not going in order
-(void)goToOffenseOrDefense:(NSString *)offenseOrDefense{
    if ([offenseOrDefense isEqualToString:@"offense"]) {
        [self unSelectButtons:@[_offButton,_defButton,_stButton]];
        [_offButton setSelected:true];
        
    }else if ([offenseOrDefense isEqualToString:@"defense"]){
        [self unSelectButtons:@[_offButton,_defButton,_stButton]];
        [_defButton setSelected:true];
    }
}

#pragma mark - Helpers Methods

-(void)revealThese:(NSArray*)list
{
    for (UIView * v in _everything) {
        [v setAlpha:0.1f];
        [v setUserInteractionEnabled:false];
    }
    for (UIView * v in list) {
        [v setAlpha:1.0f];
        [v setUserInteractionEnabled:true];
    }
}

-(void)revealTeam:(NSString*)type{
    if ([type isEqualToString:@"special"]) {
        [_seriesLabel setHidden:true];
        [_seriesPickerView setHidden:true];
        [_sTLabel setHidden:false];
        [_sTPickerView setHidden:false];
    }else if ([type isEqualToString:@"normal"]){
        [_sTLabel setHidden:true];
        [_sTPickerView setHidden:true];
        [_seriesLabel setHidden:false];
        [_seriesPickerView setHidden:false];
    }
}

// Unselect the buttons being passed in, in order to make sure only one button of the same type is selected
-(void)unSelectButtons:(NSArray*)data{
    for (CustomButton *button in data) {
        [button setSelected:false];
    }
}

// Get the Down Button that should be selected, use when going from one button to next without actually pressing it
-(CustomButton *)getSelectedButton:(NSArray*)data{
    
    CustomButton *button = [self getCurrentButton:data];
    if (button) {
        NSInteger num = [data indexOfObject:button] + 1;
        if (num == 3) {
            num = 0;
        }
        return [data objectAtIndex:num];
    }
    return  nil;
}

// Get the current Button that is selected in the data given, use when getting property for tag
-(CustomButton *)getCurrentButton:(NSArray*)data{
    for (CustomButton *button in data) {
        if (button.selected) {
            return button;
        }
    }
    return nil;
}

-(nonnull NSString*)currentPeriod{
    CustomButton *quarterButton = [self getCurrentButton:arrayOfQuarterButtons];
    if (quarterButton) {
        NSArray *quarterString = [quarterButton.titleLabel.text componentsSeparatedByString: @"Q"];
        return quarterString[1];
    }
    return @"1";
}

-(void)selectBegPeriod{
    // Get a dictionary with all the times and names
    NSMutableDictionary *timeDicUnordered = [[NSMutableDictionary alloc]init];
    for (Tag *tag in _currentEvent.tags) {
        if (tag.type == TagTypeFootballQuarterStart || tag.type == TagTypeFootballQuarterStop) {
            timeDicUnordered[[NSNumber numberWithFloat:tag.time]] = tag.name;
        }
    }
    
    // sort the times from biggest to smallest
    NSSortDescriptor *highestToLowest = [NSSortDescriptor sortDescriptorWithKey:@"self" ascending:NO];
    NSMutableArray *timesArray = [[NSMutableArray alloc]initWithArray:[timeDicUnordered allKeys]];
    [timesArray sortUsingDescriptors:[NSArray arrayWithObject:highestToLowest]];
    
    NSString *name = [timeDicUnordered objectForKey:[timesArray firstObject]];
    CustomButton *button;
    if ([name isEqualToString:@"4"]) {
        button = arrayOfQuarterButtons[3];
    }else if ([name isEqualToString:@"3"]){
        button = arrayOfQuarterButtons[2];
    }else if ([name isEqualToString:@"2"]){
        button = arrayOfQuarterButtons[1];
    }else{
        button = arrayOfQuarterButtons[0];
    }
    [self unSelectButtons:arrayOfQuarterButtons];
    [button setSelected:true];
}

#pragma mark - State Methods

// Set the screen for the mode
-(void)setMode:(FootballModes)mode
{
    
    CMTime cTime = kCMTimeZero;
    if (self.delegate) {
        cTime = self.delegate.currentTime;
    }
    
    startTime = [NSNumber numberWithFloat:CMTimeGetSeconds(cTime)];
    
    if (((_currentMode == FootballDisable || _currentMode == FootballDefenseSend) && mode == FootballOffenseStart) || ((_currentMode == FootballDisable || _currentMode == FootballOffenseSend) && mode == FootballDefenseStart)) {
        // Setting Buttons To Correct Position
        CustomButton *downButton = arrayOfDownButtons[0];
        [self unSelectButtons:arrayOfDownButtons];
        [downButton setSelected:true];
        
        // Decide what Series would be
        NSInteger num;
        if (([start isEqualToString:@"offense"] && (_currentMode == FootballDisable || _currentMode == FootballDefenseSend) && mode == FootballOffenseStart) || ([start isEqualToString:@"defense"] && (_currentMode == FootballDisable || _currentMode == FootballOffenseSend) && mode == FootballDefenseStart)) {
             num = [_seriesPickerView selectedRowInComponent:0] + 1;
        }else{
            num = [_seriesPickerView selectedRowInComponent:0];
        }
        
        // Setting Picker Views To Correct Position
        [_seriesPickerView selectRow:num inComponent:0 animated:true];
        [_distancePickerView selectRow:10 inComponent:0 animated:true];
        [_gainPickerView selectRow:55 inComponent:0 animated:true];
        [self unSelectButtons:arrayOfTypeButtons];
    }else if ((_currentMode == FootballOffenseStart && mode == FootballOffenseCalculate) ||(_currentMode == FootballDefenseStart && mode == FootballDefenseCalculate)){
        // Setting Buttons To Correct Position
        CustomButton *downButton = [self getSelectedButton:arrayOfDownButtons];
        [self unSelectButtons:arrayOfDownButtons];
        [downButton setSelected:true];
        
        // Setting Picker Views To Correct Position
        NSInteger indexOfSeries = [_seriesPickerView selectedRowInComponent:0];
        NSString *totalDistance = distanceData[[_distancePickerView selectedRowInComponent:0]];
        NSString *traveledDistance = gainData[[_gainPickerView selectedRowInComponent:0]];
        NSInteger indexOfDistance = [totalDistance intValue] - [traveledDistance intValue];
        
        [_seriesPickerView selectRow:indexOfSeries inComponent:0 animated:true];
        [_distancePickerView selectRow:indexOfDistance inComponent:0 animated:true];
        [_gainPickerView selectRow:55 inComponent:0 animated:true];
        [self unSelectButtons:arrayOfTypeButtons];
    }else if ((_currentMode == FootballOffenseCalculate && mode == FootballOffenseSend) || (_currentMode == FootballDefenseCalculate && mode == FootballDefenseSend)){
        // Setting Buttons To Correct Position
        CustomButton *downButton = [self getSelectedButton:arrayOfDownButtons];
        [self unSelectButtons:arrayOfDownButtons];
        [downButton setSelected:true];
        
        // Setting Picker Views To Correct Position
        NSInteger indexOfSeries = [_seriesPickerView selectedRowInComponent:0];
        NSString *totalDistance = distanceData[[_distancePickerView selectedRowInComponent:0]];
        NSString *traveledDistance = gainData[[_gainPickerView selectedRowInComponent:0]];
        NSInteger indexOfDistance = [totalDistance intValue] - [traveledDistance intValue];
        
        [_seriesPickerView selectRow:indexOfSeries inComponent:0 animated:true];
        [_distancePickerView selectRow:indexOfDistance inComponent:0 animated:true];
        [_gainPickerView selectRow:55 inComponent:0 animated:true];
        [self unSelectButtons:arrayOfTypeButtons];
    }
    
    [_playCallData removeAllObjects];
    [_playCallPickerView reloadComponent:0];
    [_playCallOppData removeAllObjects];
    [_playCallOppPickerView reloadComponent:0];
    [_seriesPickerView reloadComponent:0];
    [_distancePickerView reloadComponent:0];
    [_gainPickerView reloadComponent:0];
    
    
    _currentMode = mode;
}

// Decide which state to be
-(void)screenSetUp:(id)sender{
    NSString *totalDistance = distanceData[[_distancePickerView selectedRowInComponent:0]];
    NSString *traveledDistance = gainData[[_gainPickerView selectedRowInComponent:0]];
    NSInteger indexOfDistance = [totalDistance intValue] - [traveledDistance intValue];
 
    switch (_currentMode) {
        case FootballDisable:
            [self revealTeam:@"normal"];
            [self revealThese:_everything];
            [self unSelectButtons:@[_offButton,_defButton,_stButton]];
            
            // Defense Start Or Offense Start
            if ([sender isEqual:_offButton]) {
                [_offButton setSelected:true];
                start = @"offense";
                [self setMode:FootballOffenseStart];
            }else if ([sender isEqual:_defButton]){
                [_defButton setSelected:true];
                start = @"defense";
                [self setMode:FootballDefenseStart];
            }
            
            /*if (![self getCurrentButton:arrayOfQuarterButtons]) {
                [(CustomButton*)arrayOfQuarterButtons[0] setSelected:true];
            }*/
            [self selectBegPeriod];
            break;
        case FootballOffenseStart:
            [self revealTeam:@"normal"];
            [self unSelectButtons:@[_offButton,_defButton,_stButton]];
            [_offButton setSelected:true];
            if (indexOfDistance <= 0) {
                [self assignNewState:@"D1"];
            }else{
                [self setMode:FootballOffenseCalculate];
            }
            break;
        case FootballOffenseCalculate:
            [self revealTeam:@"normal"];
            [self unSelectButtons:@[_offButton,_defButton,_stButton]];
            [_offButton setSelected:true];
            if (indexOfDistance <= 0) {
                [self assignNewState:@"D1"];
            }else{
                [self setMode:FootballOffenseSend];
            }
            break;
        case FootballOffenseSend:
            [self revealTeam:@"normal"];
            if (indexOfDistance <= 0) {
                [self unSelectButtons:@[_offButton,_defButton,_stButton]];
                [_offButton setSelected:true];
                [self assignNewState:@"D1"];
            }else{
                [self unSelectButtons:@[_offButton,_defButton,_stButton]];
                [_defButton setSelected:true];
                [self setMode:FootballDefenseStart];
            }
            break;
        case FootballDefenseStart:
            [self revealTeam:@"normal"];
            [self unSelectButtons:@[_offButton,_defButton,_stButton]];
            [_defButton setSelected:true];
            if (indexOfDistance <= 0) {
                [self assignNewState:@"D1"];
            }else{
                [self setMode:FootballDefenseCalculate];
            }
            break;
        case FootballDefenseCalculate:
            [self revealTeam:@"normal"];
            [self unSelectButtons:@[_offButton,_defButton,_stButton]];
            [_defButton setSelected:true];
            if (indexOfDistance <= 0) {
                [self assignNewState:@"D1"];
            }else{
                [self setMode:FootballDefenseSend];
            }
            break;
        case FootballDefenseSend:
            [self revealTeam:@"normal"];
            if (indexOfDistance <= 0) {
                [self unSelectButtons:@[_offButton,_defButton,_stButton]];
                [_defButton setSelected:true];
                [self assignNewState:@"D1"];
            }else{
                [self unSelectButtons:@[_offButton,_defButton,_stButton]];
                [_offButton setSelected:true];
                [self setMode:FootballOffenseStart];
            }
            break;
        default:
            break;
    }
}

// Use to change state when not going in order
-(void)assignNewState:(NSString *)state{
    if ([state isEqualToString:@"D3"]) {
        NSString *startValue = start;
        start = @" ";
        [_distancePickerView selectRow:10 inComponent:0 animated:true];
        if (_offButton.selected) {
            _currentMode = FootballOffenseCalculate;
            [self setMode:FootballOffenseSend];
        }else if (_defButton.selected){
            _currentMode = FootballDefenseCalculate;
            [self setMode:FootballDefenseSend];
        }
        start = startValue;
    }else if ([state isEqualToString:@"D2"]){
        NSString *startValue = start;
        start = @" ";
        [_distancePickerView selectRow:10 inComponent:0 animated:true];
        if (_offButton.selected) {
            _currentMode = FootballOffenseStart;
            [self setMode:FootballOffenseCalculate];
        }else if (_defButton.selected){
            _currentMode = FootballDefenseStart;
            [self setMode:FootballDefenseCalculate];
        }
        start = startValue;
    }else if ([state isEqualToString:@"D1"]){
        NSString *startValue = start;
        start = @" ";
        [_distancePickerView selectRow:10 inComponent:0 animated:true];
        if (_offButton.selected) {
            _currentMode = FootballDefenseSend;
            [self setMode:FootballOffenseStart];
        }else if (_defButton.selected){
            _currentMode = FootballOffenseSend;
            [self setMode:FootballDefenseStart];
        }
        start = startValue;
    }
}



#pragma mark - Field Methods

-(void)sliderAction:(id)sender{
    
    float newStep = roundf((_fieldPosSlider.value) );
    _fieldPosSlider.value = newStep;
    
    UISlider *slider = (UISlider*)sender;
    float fieldPosToDisplay = slider.value >= 0 ? 55-slider.value : fabsf(slider.value)-55;
    [_fieldPosSliderPos setText:[NSString stringWithFormat:@"%.0f",fieldPosToDisplay]];
    [_fieldPosSliderPos setFrame:CGRectMake(_fieldPosSliderPos.frame.origin.x, _fieldPosSlider.value+_fieldPosSlider.frame.origin.y+55, _fieldPosSliderPos.bounds.size.width, _fieldPosSliderPos.bounds.size.height)];
    
}

#pragma mark - Picker View Related Methods
-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}

// Add all picker values to appropriate data array
-(NSArray*)addArrayValueForPickerViews:(NSString *)type{
    NSMutableArray *array = [[NSMutableArray alloc]init];
    if ([type isEqualToString:@"distance"] || [type isEqualToString:@"series"]) {
        for (int i=0; i<111; i++) {
            [array addObject:[NSString stringWithFormat:@"%d",i]];
        }
    }else if ([type isEqualToString:@"gain"]){
        for (int i=0; i<111; i++) {
            [array addObject:[NSString stringWithFormat:@"%d",(i-55)]];
        }
        
    }else if([type isEqualToString:@"special team"]){
        array = [[NSMutableArray alloc]initWithArray:@[@"Kick-off",@"Kick Ret",@"Punt",@"Punt Ret",@"Field G", @"Field G.R.",@"XPT"]];
    }
    return [array copy];
}

// Total rows in our component.
-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    if ([pickerView isEqual:_seriesPickerView]) {
        return [seriesData count];
    }else if ([pickerView isEqual:_sTPickerView]){
        return [stData count];
    }else if ([pickerView isEqual:_playCallOppPickerView]){
        return [_playCallOppData count];
    }else if ([pickerView isEqual:_playCallPickerView]){
        return [_playCallData count];
    }else if ([pickerView isEqual:_gainPickerView]){
        return [gainData count];
    }else if ([pickerView isEqual:_distancePickerView]){
        return [distanceData count];
    }
    return 0;
}

// Display each row's data.
-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    if ([pickerView isEqual:_seriesPickerView]) {
        return [seriesData objectAtIndex:row];
    }else if ([pickerView isEqual:_sTPickerView]){
        return [stData objectAtIndex:row];
    }else if ([pickerView isEqual:_playCallOppPickerView]){
        return [_playCallOppData objectAtIndex:row];
    }else if ([pickerView isEqual:_playCallPickerView]){
        return [_playCallData objectAtIndex:row];
    }else if ([pickerView isEqual:_gainPickerView]){
        return [gainData objectAtIndex:row];
    }else if ([pickerView isEqual:_distancePickerView]){
        return [distanceData objectAtIndex:row];
    }
    return @" ";
}

-(void)pickerView:(nonnull UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    [pickerView reloadComponent:0];
}

-(UIView*)pickerView:(nonnull UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(nullable UIView *)view{
    UILabel *customView = (id)view;
    if (!customView) {
        customView= [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, [pickerView rowSizeForComponent:component].width, [pickerView rowSizeForComponent:component].height)];
    }
    
    NSString *title;
    NSInteger selectedRow = 0;
    if ([pickerView isEqual:_seriesPickerView]) {
        title = [seriesData objectAtIndex:row];
        selectedRow = [_seriesPickerView selectedRowInComponent:0];
    }else if ([pickerView isEqual:_sTPickerView]){
        title = [stData objectAtIndex:row];
        selectedRow = [_sTPickerView selectedRowInComponent:0];
    }else if ([pickerView isEqual:_playCallOppPickerView]){
        title = [_playCallOppData objectAtIndex:row];
        selectedRow = [_playCallOppPickerView selectedRowInComponent:0];
    }else if ([pickerView isEqual:_playCallPickerView]){
        title = [_playCallData objectAtIndex:row];
        selectedRow = [_playCallPickerView selectedRowInComponent:0];
    }else if ([pickerView isEqual:_gainPickerView]){
        title = [gainData objectAtIndex:row];
        selectedRow = [_gainPickerView selectedRowInComponent:0];
    }else if ([pickerView isEqual:_distancePickerView]){
        title = [distanceData objectAtIndex:row];
        selectedRow = [_distancePickerView selectedRowInComponent:0];
    }
    
    [customView setText:title];
    customView.backgroundColor = [UIColor clearColor];
    customView.textAlignment = NSTextAlignmentCenter;
    
    if (![pickerView isEqual:_playCallPickerView] && ![pickerView isEqual:_playCallOppPickerView] && row == selectedRow) {
        customView.font = [UIFont boldSystemFontOfSize:32.f];
        customView.textColor = PRIMARY_APP_COLOR;
    }else if (![pickerView isEqual:_playCallPickerView] && ![pickerView isEqual:_playCallOppPickerView]){
        customView.font = [UIFont boldSystemFontOfSize:20.f];
        customView.textColor = [UIColor grayColor];
    }else if (row == selectedRow){
        customView.adjustsFontSizeToFitWidth = true;
        customView.textColor = PRIMARY_APP_COLOR;
    }else{
        customView.adjustsFontSizeToFitWidth = true;
        customView.textColor = [UIColor grayColor];
    }
    
    return customView;

}

-(void)addData:(NSString*)type name:(NSString*)name{
    if ([type isEqualToString:@"left"]) {
        [_playCallData addObject:name];
        [_playCallPickerView reloadComponent:0];
    }else if ([type isEqualToString:@"right"]){
        [_playCallOppData addObject:name];
        [_playCallOppPickerView reloadComponent:0];
    }
}
#pragma mark - Tag methods

-(void)sendTag:(id)sender{
    
    CMTime cTime = kCMTimeZero;
    if (self.delegate) {
        cTime = self.delegate.currentTime;
    }
    
    
    NSNumber *duration =  [NSNumber numberWithFloat:(CMTimeGetSeconds(cTime) - [startTime floatValue])];
   
    NSString *type = ((CustomButton*)[self getCurrentButton:arrayOfTypeButtons]).titleLabel.text? ((CustomButton*)[self getCurrentButton:arrayOfTypeButtons]).titleLabel.text:@" ";
    NSString *specialTeam = _sTPickerView.hidden? @" ":[stData objectAtIndex:[_sTPickerView selectedRowInComponent:0]];
    
    NSString *downString = ((CustomButton*)[self getCurrentButton:arrayOfDownButtons]).titleLabel.text;
    NSArray *downArray = [downString componentsSeparatedByString: @"D"];
    NSString *field = _fieldPosSliderPos.text;
    
    NSString *series = [seriesData objectAtIndex:[_seriesPickerView selectedRowInComponent:0]];
    NSString *distance = [distanceData objectAtIndex:[_distancePickerView selectedRowInComponent:0]];
    NSString *gain = [gainData objectAtIndex:[_gainPickerView selectedRowInComponent:0]];
    
    NSString *playCall = @" ";
    if (_playCallData.count > 0) {
        playCall = [_playCallData objectAtIndex:[_playCallPickerView selectedRowInComponent:0]];
    }
    
    NSString *playCallOpp = @" ";
    if (_playCallOppData.count > 0) {
        playCallOpp = [_playCallOppData objectAtIndex:[_playCallOppPickerView selectedRowInComponent:0]];
    }
   
    NSString *name;
    NSString *line;
    
    if (_offButton.selected) {
        name = [NSString stringWithFormat:@"O-Down: %@",downArray[1]];
        line = [NSString stringWithFormat:@"line_f_o_%@",downArray[1]];
    }else if (_defButton.selected){
        name = [NSString stringWithFormat:@"D-Down: %@",downArray[1]];
        line = [NSString stringWithFormat:@"line_f_d_%@",downArray[1]];
    }
    
    if (_stButton.selected){
        name = [NSString stringWithFormat:@"ST: %@",[stData objectAtIndex:[_sTPickerView selectedRowInComponent:0]]];
    }
    
    NSDictionary *extra = @{@"type":type,@"series":series,@"distance":distance,@"field":field,@"gain":gain,@"spoption":specialTeam,@"playCall":playCall,@"playCallOpp":playCallOpp};
    NSDictionary *dict = @{@"period":[self currentPeriod],@"duration":duration,@"name":name,@"extra":extra,@"time":startTime,@"line":line,@"starttime":startTime,@"type":[NSNumber numberWithInteger:TagTypeFootballDownTags]};
    [super postTag:dict];
    
    [self screenSetUp:sender];
}


#pragma mark - Methods That Needs To Be Here

-(void)postTagsAtBeginning{
    
}

-(void)update{
    
}

-(void)setIsDurationVariable:(SideTagButtonModes)buttonMode{
    
}

-(void)closeAllOpenTagButtons{
    
}

-(void)allToggleOnOpenTags{
    
}



-(void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

@end
