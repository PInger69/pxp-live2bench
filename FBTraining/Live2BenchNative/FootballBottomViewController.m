//
//  FootballBottomViewController.m
//  Live2BenchNative
//
//  Created by DEV on 2013-08-14.
//  Copyright (c) 2013 DEV. All rights reserved.
//

#import "FootballBottomViewController.h"


#define TOTAL_WIDTH                         1024
#define BOTTOM_VIEW_CONTROLLER_WIDTH        854
@interface FootballBottomViewController ()

@end

@implementation FootballBottomViewController

@synthesize offLayoutView;
@synthesize live2BenchViewController;
//@synthesize globals;
@synthesize offButton;
@synthesize defButton;
@synthesize stButton;
@synthesize seriesPickerView;
@synthesize arrayOfActionButtons;
@synthesize arrayOfDownButtons;
@synthesize arrayOfQuarterButtons;
@synthesize quarterButtonWasSelected;
@synthesize downButtonWasSelected;
@synthesize actionButtonWasSelected;
@synthesize gainNumber;
@synthesize gainPickerView;
@synthesize fieldNumber;
@synthesize distanceNumber;
@synthesize distancePickerView;
@synthesize playcallEventsView;
@synthesize playcallOppEventsView;
@synthesize seriesNumber;
@synthesize pickerViewDataArr;
@synthesize responseData;
@synthesize selectedRowforDistance;
@synthesize selectedRowforField;
@synthesize selectedRowforGain;
@synthesize selectedRowforSeries;
@synthesize stateButtonWasSelected;
@synthesize isNewTurn;
@synthesize gainPickerViewDataArr;
@synthesize isNextPlay;

- (id)initWithController:(Live2BenchViewController *)fv
{
    self = [super init];
    live2BenchViewController = fv;
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateInfo) name:@"EventInformationUpdated" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateInfo) name:@"UpdateFBBottomViewControInfo" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updatePlayCall:) name:@"UpdatePlayCallOpp" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updatePlayCall:) name:@"UpdatePlayCall" object: nil];
//    globals = [Globals instance];
//    if([globals.WHICH_SPORT isEqualToString:@"football"])
//    {
//        globals.SHOW_TOASTS = FALSE;
//    }
    
    
    arrayOfQuarterButtons = [[NSMutableArray alloc]init];
    arrayOfDownButtons = [[NSMutableArray alloc]init];
    arrayOfActionButtons = [[NSMutableArray alloc]init];
    //pickerViewDataArr is for seriespickerview and distancepickerview
    pickerViewDataArr = [[NSMutableArray alloc]init];
    for (int i=0; i<111; i++) {
        
        [pickerViewDataArr addObject:[NSString stringWithFormat:@"%d",i]];
        
    }
    //specialteams
    specialTeamsArray= [[NSArray alloc] initWithObjects:@"Kick-off",@"Kick Ret",@"Punt",@"Punt Ret",@"Field G", @"Field G.R.",@"XPT", nil];
    

    
    //gainPickerViewDataArr is for gainpickerview
    gainPickerViewDataArr = [[NSMutableArray alloc]init];
    for (int i=0; i<111; i++) {
        
        [gainPickerViewDataArr addObject:[NSString stringWithFormat:@"%d",(i-55)]];
        
    }
    _playCallOppArray = [[NSMutableArray alloc] initWithObjects:@" ", nil];
    _playCallArray = [[NSMutableArray alloc] initWithObjects:@" ", nil];
    [self initLayout];
    [self updateInfo];
    isNewTurn = TRUE;
    // Do any additional setup after loading the view from its nib.
}

-(void)updateInfo{
//    if (![globals.WHICH_SPORT isEqualToString:@"football"]) {
//        return;
//    }
//    
//    if ( globals.CURRENT_QUARTER_FB > -1 && globals.CURRENT_QUARTER_FB < 4) {
//        CustomButton *button = [arrayOfQuarterButtons objectAtIndex:globals.CURRENT_QUARTER_FB];
//        if (quarterButtonWasSelected && ![quarterButtonWasSelected isEqual:button]) {
//            quarterButtonWasSelected.selected = FALSE;
//            button.selected = TRUE;
//            quarterButtonWasSelected = button;
//        }else if(!quarterButtonWasSelected){
//            button.selected = TRUE;
//            quarterButtonWasSelected = button;
//        }
//    }else{
//        CustomButton *button = [arrayOfQuarterButtons objectAtIndex:0];
//        [button sendActionsForControlEvents:UIControlEventTouchUpInside];
//    }
    
}


-(void)initLayout{
    //initialize all the int values
    seriesNumber = 0;
    distanceNumber = 0;
    gainNumber = 0;
    fieldNumber = 55;
    
    offLayoutView = [[UIView alloc] initWithFrame:CGRectMake(150, 0, BOTTOM_VIEW_CONTROLLER_WIDTH, self.view.bounds.size.height)];
    
    [self.view addSubview:offLayoutView];
    
    teamSelectionLabel = [[UILabel alloc]initWithFrame:CGRectMake(5 , 0, 100, 30)];
    [teamSelectionLabel setText:@"TEAM SEL."];
    [teamSelectionLabel setFont:[UIFont systemFontOfSize: 13.0f]];
    [teamSelectionLabel setTextAlignment:NSTextAlignmentCenter];
    [teamSelectionLabel setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:teamSelectionLabel];
    
    offButton = [CustomButton buttonWithType:UIButtonTypeCustom];
    [offButton setFrame:CGRectMake(25, 32, 80, 45)];
    [offButton setBackgroundImage:[UIImage imageNamed:@"line-button-grey.png"] forState:UIControlStateNormal];
    [offButton setBackgroundImage:[UIImage imageNamed:@"green_bar.png"] forState:UIControlStateSelected];
    [offButton addTarget:self action:@selector(stateChanged:) forControlEvents:UIControlEventTouchUpInside];
    [offButton setTitle:@"OFFENSE" forState:UIControlStateNormal];
    [offButton.titleLabel setTextAlignment:NSTextAlignmentCenter];
    [offButton.titleLabel setFont:[UIFont systemFontOfSize:16.0f]];
    [offButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.view insertSubview:offButton aboveSubview:offLayoutView];
    
    defButton = [CustomButton buttonWithType:UIButtonTypeCustom];
    [defButton setFrame:CGRectMake(offButton.frame.origin.x, offButton.frame.origin.y + offButton.frame.size.height+11.5, offButton.frame.size.width, offButton.frame.size.height)];
    [defButton setBackgroundImage:[UIImage imageNamed:@"line-button-grey.png"] forState:UIControlStateNormal];
    [defButton setBackgroundImage:[UIImage imageNamed:@"red_bar.png"] forState:UIControlStateSelected];
    [defButton addTarget:self action:@selector(stateChanged:) forControlEvents:UIControlEventTouchUpInside];
    [defButton setTitle:@"DEFENSE" forState:UIControlStateNormal];
    [defButton.titleLabel setTextAlignment:NSTextAlignmentCenter];
    [defButton.titleLabel setFont:[UIFont systemFontOfSize:16.0f]];
    [defButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.view insertSubview:defButton aboveSubview:offLayoutView];
    
    stButton = [CustomButton buttonWithType:UIButtonTypeCustom];
    [stButton setFrame:CGRectMake(defButton.frame.origin.x, defButton.frame.origin.y + defButton.frame.size.height+11.5, defButton.frame.size.width, defButton.frame.size.height)];
    [stButton setBackgroundImage:[UIImage imageNamed:@"line-button-grey.png"] forState:UIControlStateNormal];
    [stButton setBackgroundImage:[UIImage imageNamed:@"num-button.png"] forState:UIControlStateSelected];
    [stButton addTarget:self action:@selector(stateChanged:) forControlEvents:UIControlEventTouchUpInside];
    [stButton setTitle:@"ST" forState:UIControlStateNormal];
    [stButton.titleLabel setTextAlignment:NSTextAlignmentCenter];
    [stButton.titleLabel setFont:[UIFont systemFontOfSize:16.0f]];
    [stButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.view insertSubview:stButton aboveSubview:offLayoutView];
    
    seriesLabel = [[UILabel alloc]initWithFrame:CGRectMake(0 , 0, 70, 30)];
    [seriesLabel setText:@"SERIES"];
    [seriesLabel setFont:[UIFont systemFontOfSize: 13.0f]];
    [seriesLabel setTextAlignment:NSTextAlignmentCenter];
    [seriesLabel setBackgroundColor:[UIColor clearColor]];
    [offLayoutView addSubview:seriesLabel];
    
    sTLabel = [[UILabel alloc]initWithFrame:CGRectMake(-20 , 0, 70, 30)];
    [sTLabel setText:@"SPECIAL"];
    [sTLabel setFont:[UIFont systemFontOfSize: 13.0f]];
    [sTLabel setTextAlignment:NSTextAlignmentCenter];
    [sTLabel setHidden:TRUE];
    [sTLabel setBackgroundColor:[UIColor clearColor]];
    [offLayoutView addSubview:sTLabel];
    
    seriesPickerView = [[UIPickerView alloc]initWithFrame:CGRectMake(seriesLabel.frame.origin.x-10, seriesLabel.frame.origin.y + seriesLabel.frame.size.height - 9,seriesLabel.frame.size.width + 20,180 )];
    [seriesPickerView setDataSource:self];
    [seriesPickerView setDelegate:self];
    [seriesPickerView setBackgroundColor:[UIColor clearColor]];
    seriesPickerView.showsSelectionIndicator = YES;
    //seriesPickerView.transform = CGAffineTransformMakeScale(1.0f, 1.0f);
    CALayer* mask = [[CALayer alloc] init];
    [mask setBackgroundColor: [UIColor whiteColor].CGColor];
    [mask setFrame:  CGRectMake(15.0f , 10.0f, 60.0f, 160.f)];
    [mask setCornerRadius: 2.0f];
    [seriesPickerView.layer setMask: mask];
    [offLayoutView addSubview:seriesPickerView];
    
    sTPickerView = [[UIPickerView alloc]initWithFrame:CGRectMake(sTLabel.frame.origin.x-40, seriesLabel.frame.origin.y + seriesLabel.frame.size.height - 9,seriesLabel.frame.size.width + 80,180 )];
    [sTPickerView setDataSource:self];
    [sTPickerView setDelegate:self];
    [sTPickerView setBackgroundColor:[UIColor clearColor]];
    sTPickerView.showsSelectionIndicator = YES;
    [sTPickerView setHidden:TRUE];
    CALayer* tmask = [[CALayer alloc] init];
    [tmask setBackgroundColor: [UIColor whiteColor].CGColor];
    [tmask setFrame:  CGRectMake(15.0f , 10.0f, 120.0f, 160.f)];
    [tmask setCornerRadius: 2.0f];
    [sTPickerView.layer setMask: tmask];
    
    //seriesPickerView.transform = CGAffineTransformMakeScale(1.0f, 1.0f);
    [offLayoutView addSubview:sTPickerView];
    
    
    UILabel *quarterLabel = [[UILabel alloc]initWithFrame:CGRectMake(seriesLabel.frame.origin.x +seriesLabel.frame.size.width+15 , seriesLabel.frame.origin.y, seriesLabel.frame.size.width, seriesLabel.frame.size.height)];
    [quarterLabel setText:@"QUARTER"];
    [quarterLabel setFont:[UIFont systemFontOfSize: 13.0f]];
    [quarterLabel setTextAlignment:NSTextAlignmentCenter];
    [quarterLabel setBackgroundColor:[UIColor clearColor]];
    [offLayoutView addSubview:quarterLabel];
    
    for (int i = 0; i<4; i++) {
        CustomButton *quarterButton = [CustomButton buttonWithType:UIButtonTypeCustom];
        [quarterButton setFrame:CGRectMake(quarterLabel.frame.origin.x, quarterLabel.frame.origin.y + quarterLabel.frame.size.height+2 + i*41 , quarterLabel.frame.size.width, 36)];
        [quarterButton setBackgroundImage:[UIImage imageNamed:@"line-button-grey.png"] forState:UIControlStateNormal];
        [quarterButton setBackgroundImage:[UIImage imageNamed:@"num-button.png"] forState:UIControlStateSelected];
        [quarterButton addTarget:self action:@selector(quarterChanged:) forControlEvents:UIControlEventTouchUpInside];
        [quarterButton setTitle:[NSString stringWithFormat:@"Q%d",i+1] forState:UIControlStateNormal];
        [quarterButton.titleLabel setTextAlignment:NSTextAlignmentCenter];
        [quarterButton.titleLabel setFont:[UIFont boldSystemFontOfSize:28.0f]];
        [quarterButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        quarterButton.tag = i;
        [offLayoutView addSubview:quarterButton];
        [arrayOfQuarterButtons addObject:quarterButton];
    }
    
    UILabel *downLabel = [[UILabel alloc]initWithFrame:CGRectMake(quarterLabel.frame.origin.x +quarterLabel.frame.size.width+15 , quarterLabel.frame.origin.y, quarterLabel.frame.size.width, quarterLabel.frame.size.height)];
    [downLabel setText:@"DOWN"];
    [downLabel setFont:[UIFont systemFontOfSize: 13.0f]];
    [downLabel setTextAlignment:NSTextAlignmentCenter];
    [downLabel setBackgroundColor:[UIColor clearColor]];
    [offLayoutView addSubview:downLabel];
    
    for (int i = 1; i<4; i++) {
        CustomButton *downButton = [CustomButton buttonWithType:UIButtonTypeCustom];
        [downButton setFrame:CGRectMake(downLabel.frame.origin.x, downLabel.frame.origin.y + downLabel.frame.size.height+2 + (i-1)*54.5 , downLabel.frame.size.width, 50)];
        [downButton setBackgroundImage:[UIImage imageNamed:@"line-button-grey.png"] forState:UIControlStateNormal];
        [downButton setBackgroundImage:[UIImage imageNamed:@"num-button.png"] forState:UIControlStateSelected];
        [downButton addTarget:self action:@selector(downChanged:) forControlEvents:UIControlEventTouchUpInside];
        [downButton setTitle:[NSString stringWithFormat:@"D%d",i] forState:UIControlStateNormal];
        [downButton.titleLabel setTextAlignment:NSTextAlignmentCenter];
        [downButton.titleLabel setFont:[UIFont boldSystemFontOfSize:28.0f]];
        [downButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        downButton.tag = i;
        [offLayoutView addSubview:downButton];
        [arrayOfDownButtons addObject:downButton];
    }
    
    UILabel *distanceLabel = [[UILabel alloc]initWithFrame:CGRectMake(downLabel.frame.origin.x +downLabel.frame.size.width+15 , downLabel.frame.origin.y, downLabel.frame.size.width, downLabel.frame.size.height)];
    [distanceLabel setText:@"DISTANCE"];
    [distanceLabel setFont:[UIFont systemFontOfSize: 13.0f]];
    [distanceLabel setTextAlignment:NSTextAlignmentCenter];
    [distanceLabel setBackgroundColor:[UIColor clearColor]];
    [offLayoutView addSubview:distanceLabel];
    
    distancePickerView = [[UIPickerView alloc]initWithFrame:CGRectMake(distanceLabel.frame.origin.x -10 , distanceLabel.frame.origin.y + distanceLabel.frame.size.height - 9,distanceLabel.frame.size.width + 20,180 )];
    [distancePickerView setDataSource:self];
    [distancePickerView setDelegate:self];
    [distancePickerView setBackgroundColor:[UIColor clearColor]];
    distancePickerView.showsSelectionIndicator = TRUE;
    CALayer* yrdsToRunMask = [[CALayer alloc] init];
    [yrdsToRunMask setBackgroundColor: [UIColor whiteColor].CGColor];
    [yrdsToRunMask setFrame:  CGRectMake(15.0f, 10.0f, 60.0f, 160.f)];
    [yrdsToRunMask setCornerRadius: 5.0f];
    [distancePickerView.layer setMask: yrdsToRunMask];
    [offLayoutView addSubview:distancePickerView];
    
    UILabel *typeLabel = [[UILabel alloc]initWithFrame:CGRectMake(distanceLabel.frame.origin.x +distanceLabel.frame.size.width+15 , distanceLabel.frame.origin.y, distanceLabel.frame.size.width, distanceLabel.frame.size.height)];
    [typeLabel setText:@"TYPE"];
    [typeLabel setFont:[UIFont systemFontOfSize: 13.0f]];
    [typeLabel setTextAlignment:NSTextAlignmentCenter];
    [typeLabel setBackgroundColor:[UIColor clearColor]];
    [offLayoutView addSubview:typeLabel];
    
    for (int i = 0; i<3; i++) {
        CustomButton *actionButton = [CustomButton buttonWithType:UIButtonTypeCustom];
        [actionButton setFrame:CGRectMake(typeLabel.frame.origin.x, typeLabel.frame.origin.y + typeLabel.frame.size.height+2 + i*54.5 , typeLabel.frame.size.width, 50)];
        [actionButton setBackgroundImage:[UIImage imageNamed:@"line-button-grey.png"] forState:UIControlStateNormal];
        [actionButton setBackgroundImage:[UIImage imageNamed:@"num-button.png"] forState:UIControlStateSelected];
        [actionButton addTarget:self action:@selector(typeChanged:) forControlEvents:UIControlEventTouchUpInside];
        NSString *displayStr;
        if (i==0) {
            displayStr = @"Pass";
        }else if(i==1){
            displayStr = @"Run";
        }else{
            displayStr = @"Kick";
        }
        [actionButton setTitle:displayStr forState:UIControlStateNormal];
        [actionButton.titleLabel setTextAlignment:NSTextAlignmentCenter];
        [actionButton.titleLabel setFont:[UIFont boldSystemFontOfSize:23.0f]];
        [actionButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        actionButton.tag = i;
        [offLayoutView addSubview:actionButton];
        [arrayOfActionButtons addObject:actionButton];
    }
    
    UILabel *fieldLabel = [[UILabel alloc]initWithFrame:CGRectMake(typeLabel.frame.origin.x +typeLabel.frame.size.width+15 , typeLabel.frame.origin.y, typeLabel.frame.size.width, typeLabel.frame.size.height)];
    [fieldLabel setText:@"FIELD"];
    [fieldLabel setFont:[UIFont systemFontOfSize: 13.0f]];
    [fieldLabel setTextAlignment:NSTextAlignmentCenter];
    [fieldLabel setBackgroundColor:[UIColor clearColor]];
    [offLayoutView addSubview:fieldLabel];

    
    CGRect frame = CGRectMake(fieldLabel.frame.origin.x -25 , fieldLabel.frame.origin.y + fieldLabel.frame.size.height +65,160,40);
    fieldPosSlider = [[UISlider alloc] initWithFrame:frame];
    [fieldPosSlider addTarget:self action:@selector(sliderAction:) forControlEvents:UIControlEventValueChanged];
    [fieldPosSlider setBackgroundColor:[UIColor clearColor]];
    fieldPosSlider.minimumValue = -55;
    fieldPosSlider.maximumValue = 55;
    fieldPosSlider.continuous = YES;
    fieldPosSlider.value = 0.0;
    fieldPosSlider.transform = CGAffineTransformMakeRotation(M_PI/2);
    [offLayoutView addSubview:fieldPosSlider];
    
    fieldPosSliderPos = [[UILabel alloc] initWithFrame:CGRectMake(fieldPosSlider.frame.origin.x - 30, fieldPosSlider.value+fieldPosSlider.frame.origin.y+55, 60, 40)];
    [fieldPosSliderPos setBackgroundColor:[UIColor clearColor]];
    [fieldPosSliderPos setText:[NSString stringWithFormat:@"%.0f",[fieldPosSlider value]+55.0 ]];
    [offLayoutView addSubview:fieldPosSliderPos];
    
    UILabel *gainLabel = [[UILabel alloc]initWithFrame:CGRectMake(fieldLabel.frame.origin.x +fieldLabel.frame.size.width+15 , fieldLabel.frame.origin.y, fieldLabel.frame.size.width, fieldLabel.frame.size.height)];
    [gainLabel setText:@"GAIN"];
    [gainLabel setFont:[UIFont systemFontOfSize: 13.0f]];
    [gainLabel setTextAlignment:NSTextAlignmentCenter];
    [gainLabel setBackgroundColor:[UIColor clearColor]];
    [offLayoutView addSubview:gainLabel];
    
    gainPickerView = [[UIPickerView alloc]initWithFrame:CGRectMake(gainLabel.frame.origin.x -10 , gainLabel.frame.origin.y + gainLabel.frame.size.height - 9,gainLabel.frame.size.width + 20,180 )];
    [gainPickerView setDataSource:self];
    [gainPickerView setDelegate:self];
    [gainPickerView setBackgroundColor:[UIColor clearColor]];
    gainPickerView.showsSelectionIndicator = TRUE;
    CALayer* yrdsGainMask = [[CALayer alloc] init];
    [yrdsGainMask setBackgroundColor: [UIColor whiteColor].CGColor];
    [yrdsGainMask setFrame:  CGRectMake(15.0f, 10.0f, 60.0f, 160.f)];
    [yrdsGainMask setCornerRadius: 5.0f];
    [gainPickerView.layer setMask: yrdsGainMask];
    [gainPickerView selectRow:55 inComponent:0 animated:YES];
    [offLayoutView addSubview:gainPickerView];
    
    UILabel *playcallLabel = [[UILabel alloc]initWithFrame:CGRectMake(gainLabel.frame.origin.x +gainLabel.frame.size.width+25 , gainLabel.frame.origin.y, gainLabel.frame.size.width, gainLabel.frame.size.height)];
    [playcallLabel setText:@"PLAYCALL"];
    [playcallLabel setFont:[UIFont systemFontOfSize: 13.0f]];
    [playcallLabel setTextAlignment:NSTextAlignmentCenter];
    [playcallLabel setBackgroundColor:[UIColor clearColor]];
    [offLayoutView addSubview:playcallLabel];
    
    UILabel *playcallOppLabel = [[UILabel alloc]initWithFrame:CGRectMake(playcallLabel.frame.origin.x +playcallLabel.frame.size.width+35 , playcallLabel.frame.origin.y, playcallLabel.frame.size.width, playcallLabel.frame.size.height)];
    [playcallOppLabel setText:@"PC OPP."];
    [playcallOppLabel setFont:[UIFont systemFontOfSize: 13.0f]];
    [playcallOppLabel setTextAlignment:NSTextAlignmentCenter];
    [playcallOppLabel setBackgroundColor:[UIColor clearColor]];
    [offLayoutView addSubview:playcallOppLabel];
    
    if(!_playCallOppPickerView)
    {
        _playCallOppPickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(playcallOppLabel.frame.origin.x-20, playcallOppLabel.frame.origin.y + playcallOppLabel.frame.size.height -7, playcallOppLabel.frame.size.width+50, 180)];
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
    }
    
    if(!_playCallPickerView)
    {
       _playCallPickerView =  [[UIPickerView alloc] initWithFrame:CGRectMake(playcallLabel.frame.origin.x-25, playcallLabel.frame.origin.y + playcallLabel.frame.size.height -7, playcallLabel.frame.size.width+50, 180)];
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
      
    }
    [offLayoutView addSubview:_playCallOppPickerView];

      [offLayoutView addSubview:_playCallPickerView];
    CustomButton *nextPlayButton = [CustomButton buttonWithType:UIButtonTypeCustom];
    [nextPlayButton setFrame:CGRectMake(_playCallOppPickerView.frame.origin.x +_playCallOppPickerView.frame.size.width-55, playcallOppLabel.frame.origin.y+90,160 , offButton.frame.size.height)];
    [nextPlayButton setTitle:@"NEXT PLAY" forState:UIControlStateNormal];
    [nextPlayButton setBackgroundImage:[UIImage imageNamed:@"line-button-grey.png"] forState:UIControlStateNormal];
    [nextPlayButton.titleLabel setTextAlignment:NSTextAlignmentCenter];
    [nextPlayButton.titleLabel setFont:[UIFont systemFontOfSize:25.0f]];
    nextPlayButton.transform = CGAffineTransformMakeRotation(3*M_PI/2.0);
    [nextPlayButton addTarget:self action:@selector(nextPlayButtonSelected:) forControlEvents:UIControlEventTouchUpInside];
    [nextPlayButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [offLayoutView addSubview:nextPlayButton];
    
    [offLayoutView setAlpha:0.2];
    [offLayoutView setUserInteractionEnabled:FALSE];
}

-(void)sliderAction:(id)sender{
    
    float newStep = roundf((fieldPosSlider.value) );
    fieldPosSlider.value = newStep;
    
    UISlider *slider = (UISlider*)sender;
    float fieldPosToDisplay = slider.value >= 0 ? 55-slider.value : fabsf(slider.value)-55;
    [fieldPosSliderPos setText:[NSString stringWithFormat:@"%.0f",fieldPosToDisplay]];
    [fieldPosSliderPos setFrame:CGRectMake(fieldPosSliderPos.frame.origin.x, fieldPosSlider.value+fieldPosSlider.frame.origin.y+55, fieldPosSliderPos.bounds.size.width, fieldPosSliderPos.bounds.size.height)];
    
}

-(void)stateChanged:(id)sender{
//    CustomButton *button = (CustomButton*)sender;
//    if([button isEqual:stButton] && !isNextPlay)
//    { //special teams
//        [self adjustForSpecialTeams:stButton.selected];
//        if (stButton.selected) {
//            
//            stButton.selected = FALSE;
//            
//            return;
//        }else{
//            
//            //special teams depend on whether or not the team is on offense or defense
//            stButton.selected = TRUE;
//            
//            if([globals.CURRENT_STATE_FB isEqualToString:@"def"]) //if defensive special teams then lets update series with current defensive series
//            {
//                [seriesPickerView selectRow:globals.CURRENT_D_SERIES_NUMBER_FB inComponent:0 animated:YES];
//                selectedRowforSeries = globals.CURRENT_D_SERIES_NUMBER_FB;
//                [seriesPickerView reloadComponent:0];
//            }else{ //otherwise we'll update it with the offensive series
//                [seriesPickerView selectRow:globals.CURRENT_O_SERIES_NUMBER_FB inComponent:0 animated:YES];
//                selectedRowforSeries = globals.CURRENT_O_SERIES_NUMBER_FB;
//                [seriesPickerView reloadComponent:0];
//            }
//        }
//        return;
//    }
//    
//    if ([button isEqual:offButton]) { //offense
//        if (offButton.selected) {
//            offButton.selected = FALSE;
//            stateButtonWasSelected = nil;
//            [offLayoutView setAlpha:0.2];
//            [offLayoutView setUserInteractionEnabled:FALSE];
//            return;
//        }else{
//            
//            if (downButtonWasSelected) {
//                [downButtonWasSelected sendActionsForControlEvents:UIControlEventTouchUpInside];
//            }
//            globals.CURRENT_STATE_FB = @"off";
//            stateButtonWasSelected.selected = FALSE;
//            offButton.selected = TRUE;
//            stateButtonWasSelected = offButton;
//            [offLayoutView setAlpha:1.0f];
//            [offLayoutView setUserInteractionEnabled:TRUE];
//            globals.CURRENT_O_SERIES_NUMBER_FB++;
//            [seriesPickerView selectRow:globals.CURRENT_O_SERIES_NUMBER_FB inComponent:0 animated:YES];
//            selectedRowforSeries = globals.CURRENT_O_SERIES_NUMBER_FB;
//            [seriesPickerView reloadComponent:0];
//        }
//    }else if ([button isEqual:defButton]){ //defense
//        if (defButton.selected) {
//            defButton.selected = FALSE;
//            stateButtonWasSelected = nil;
//            [offLayoutView setAlpha:0.2];
//            [offLayoutView setUserInteractionEnabled:FALSE];
//            return;
//        }else{
//            if (downButtonWasSelected) {
//                [downButtonWasSelected sendActionsForControlEvents:UIControlEventTouchUpInside];
//            }
//            globals.CURRENT_STATE_FB = @"def";
//            stateButtonWasSelected.selected = FALSE;
//            defButton.selected = TRUE;
//            stateButtonWasSelected = defButton;
//            globals.CURRENT_D_SERIES_NUMBER_FB++;
//            [offLayoutView setAlpha:1.0f];
//            [offLayoutView setUserInteractionEnabled:TRUE];
//            [seriesPickerView selectRow:globals.CURRENT_D_SERIES_NUMBER_FB inComponent:0 animated:YES];
//            selectedRowforSeries = globals.CURRENT_D_SERIES_NUMBER_FB;
//            [seriesPickerView reloadComponent:0];
//        }
//        
//    }

    
}

-(void)adjustForSpecialTeams:(BOOL)isSelected
{
    if(isSelected)  // button was selected, now deselected, need to bring back the series spinnerview
    {
        [seriesPickerView setHidden:FALSE];
        [seriesLabel setHidden:FALSE];
        [sTLabel setHidden:TRUE];
        [sTPickerView setHidden:TRUE];
        CGRect oldLabelFrame = teamSelectionLabel.frame;
        [teamSelectionLabel setFrame:CGRectMake(oldLabelFrame.origin.x +15, oldLabelFrame.origin.y, oldLabelFrame.size.width, oldLabelFrame.size.height)];
        
        [defButton setFrame:CGRectMake(defButton.frame.origin.x+20,defButton.frame.origin.y , defButton.frame.size.width, defButton.frame.size.height)];
        [offButton setFrame:CGRectMake(offButton.frame.origin.x+20,offButton.frame.origin.y , offButton.frame.size.width, offButton.frame.size.height)];
        [stButton setFrame:CGRectMake(stButton.frame.origin.x+20,stButton.frame.origin.y , stButton.frame.size.width, stButton.frame.size.height)];
        
    }else{ //button wasn't selected now selected, bring in specialteams selector
        [seriesPickerView setHidden:TRUE];
        [seriesLabel setHidden:TRUE];
        [sTLabel setHidden:FALSE];
        [sTPickerView setHidden:FALSE];
        
        CGRect oldLabelFrame = teamSelectionLabel.frame;
        [teamSelectionLabel setFrame:CGRectMake(oldLabelFrame.origin.x -15, oldLabelFrame.origin.y, oldLabelFrame.size.width, oldLabelFrame.size.height)];
        
        [defButton setFrame:CGRectMake(defButton.frame.origin.x-20,defButton.frame.origin.y , defButton.frame.size.width, defButton.frame.size.height)];
        [offButton setFrame:CGRectMake(offButton.frame.origin.x-20,offButton.frame.origin.y , offButton.frame.size.width, offButton.frame.size.height)];
        [stButton setFrame:CGRectMake(stButton.frame.origin.x-20,stButton.frame.origin.y , stButton.frame.size.width, stButton.frame.size.height)];
    }
    
}

-(void)quarterChanged:(id)sender{
//    CustomButton *button = (CustomButton*)sender;
//    if (quarterButtonWasSelected && ![quarterButtonWasSelected isEqual:button]) {
//        quarterButtonWasSelected.selected = FALSE;
//        button.selected = TRUE;
//        quarterButtonWasSelected = button;
//    }else if(!quarterButtonWasSelected){
//        button.selected = TRUE;
//        quarterButtonWasSelected = button;
//    }else{
//        button.selected = FALSE;
//        quarterButtonWasSelected = nil;
//        return;
//    }
//    NSString *tagTime;
//    if (globals.CURRENT_QUARTER_FB == -1) {
//        tagTime = @"0.0";
//    }else{
//        tagTime= [live2BenchViewController getCurrentTimeforNewTag];
//    }
//    int index = [arrayOfQuarterButtons indexOfObject:button];
//    NSDictionary *dict= [[NSDictionary alloc]initWithObjectsAndKeys:globals.EVENT_NAME,@"event",[NSString stringWithFormat:@"%d",index],@"name",[NSString stringWithFormat:@"%d",index],@"period",[globals.ACCOUNT_INFO objectForKey:@"hid"],@"user",tagTime,@"time",[globals.ACCOUNT_INFO objectForKey:@"tagColour"],@"colour",@"7",@"type",nil];
//    [self sendTagInfo:dict];
//    globals.CURRENT_QUARTER_FB = index;
    
}
-(void)downChanged:(id)sender{
//    CustomButton *button = (CustomButton*)sender;
//    int typeOfTag = 1;
//    NSString *tagTime;
//    NSString *name;
//    NSDictionary *dict;
//    NSString *lineStr;
//    
//    [playCallOppArray removeAllObjects];
//    [playCallOppPickerView reloadAllComponents];
//    
//    [playCallArray removeAllObjects];
//    [playCallPickerView reloadAllComponents  ];
//    
//    if(!isNextPlay)
//    {
//        distanceNumber = [distancePickerView selectedRowInComponent:0];
//    }
//    
//    distanceNumber = distanceNumber == 0 ? 10 : distanceNumber; //make sure distance number isn't 0
//    int oldDistanceNumber=distanceNumber;
//    
//    if(!isNextPlay)
//    {
//        if ((button == [arrayOfDownButtons objectAtIndex:0] && ![button isSelected])) // first down
//        {
//            distanceNumber = 10;
//            [distancePickerView selectRow:distanceNumber inComponent:0 animated:YES];
//        }else if(gainNumber<0) // loss of yards
//        {
//            distanceNumber = oldDistanceNumber+abs(gainNumber);
//            [distancePickerView selectRow:distanceNumber inComponent:0 animated:YES];
//        }else{ // gain of yards
//            
//            
//            if(oldDistanceNumber-gainNumber < 0) // crossed 1st down line, new first down
//            {
//                isNewTurn=TRUE;
//                distanceNumber = 10;
//                [distancePickerView selectRow:distanceNumber inComponent:0 animated:YES];
//                [distancePickerView reloadComponent:0];
//                gainNumber =0;
//                [[arrayOfDownButtons objectAtIndex:0] sendActionsForControlEvents:UIControlEventTouchUpInside];
//                return;
//            }else if([[arrayOfDownButtons objectAtIndex:2] isSelected] && !(oldDistanceNumber-gainNumber <= 0)){ // 3rd and didn't reach first down
//                isNewTurn=TRUE;
//                distanceNumber = 10;
//                [distancePickerView selectRow:distanceNumber inComponent:0 animated:YES];
//                gainNumber =0;
//                [[arrayOfDownButtons objectAtIndex:0] sendActionsForControlEvents:UIControlEventTouchUpInside];
//                if([offButton isSelected])
//                {
//                    [defButton sendActionsForControlEvents:UIControlEventTouchUpInside];
//                }else{
//                    [offButton sendActionsForControlEvents:UIControlEventTouchUpInside];
//                }
//            }else{ //first or second down, still yards to go
//                distanceNumber=oldDistanceNumber-gainNumber;
//                [distancePickerView selectRow:distanceNumber inComponent:0 animated:YES];
//            }
//        }
//        selectedRowforDistance = distanceNumber;
//        [distancePickerView reloadComponent:0];
//    }
//    isNextPlay = FALSE;
//    
//    if (button.selected && !isNewTurn) {
//        button.selected = FALSE;
//        [distancePickerView selectRow:0 inComponent:0 animated:YES];
//        selectedRowforDistance = 0;
//        [distancePickerView reloadComponent:0];
//        [gainPickerView selectRow:55 inComponent:0 animated:YES];
//        selectedRowforGain = 55;
//        [gainPickerView reloadComponent:0];
//        distanceNumber = 10;
//        if (downButtonWasSelected) {
//            downButtonWasSelected = nil;
//        }
//        
//    }else if(!button.selected || isNewTurn){
//        
//        
//        if (button.tag != 1) {
//            //if it is not down 1, isnewturn set to false
//            isNewTurn = FALSE;
//        }else{
//            isNewTurn = TRUE;
//            distanceNumber = 10;
//        }
//        
//        ////////NSLog(@"button.tag %d, downbuttonwasselected.tag %d",button.tag, downButtonWasSelected.tag);
//        if (![button isEqual:downButtonWasSelected]) {
//            downButtonWasSelected.selected = FALSE;
//            downButtonWasSelected = button;
//        }
//        
//        button.selected = TRUE;
//        
//        tagTime= [NSString stringWithFormat:@"%f",[live2BenchViewController.videoPlayer currentTimeInSeconds]];
//        
//        //We have to differentiate between offensive downs and defensive downs, so if the current state is 'off' then this is an offensive down, if current state is 'def' then defensive down
//        if([globals.CURRENT_STATE_FB isEqual:@"off"]){//offensive
//            
//            //if this is a special teams down, add an ST to the name just to differentiate
//            NSInteger row;
//            row = [sTPickerView selectedRowInComponent:0];
//            
//            if([stButton isSelected])
//            {
//                name = [NSString stringWithFormat:@"ST: %@",[specialTeamsArray objectAtIndex:row]];
//                typeOfTag=0;
//                
//            }else{
//                name = [NSString stringWithFormat:@"O-Down: %d",button.tag];
//            }
//            lineStr = [NSString stringWithFormat:@"line_f_o_%d",button.tag]; //which down we changed to
//        }else{//defensive
//            //if this is a special teams down, add an ST to the name just to differentiate
//            if([stButton isSelected])
//            {
//                NSInteger row;
//                row = [sTPickerView selectedRowInComponent:0];
//                name = [NSString stringWithFormat:@"ST: %@",[specialTeamsArray objectAtIndex:row]];
//                typeOfTag=0;
//                
//            }else{
//                name = [NSString stringWithFormat:@"D-Down: %d",button.tag];
//            }
//            lineStr = [NSString stringWithFormat:@"line_f_d_%d",button.tag]; //which down we changed to
//        }
//    }
//    double currentSystemTime = CACurrentMediaTime();
//    
//    globals.CURRENT_TYPE_FB = globals.CURRENT_TYPE_FB.length > 0 ? globals.CURRENT_TYPE_FB : @"";
//    
//    NSInteger row;
//    row = [sTPickerView selectedRowInComponent:0];
//    NSString * specialTeamsOption = stButton.selected ? [specialTeamsArray objectAtIndex:row] : @"" ;
//    
//    NSDictionary *extraDictionary = [[NSDictionary alloc]initWithObjectsAndKeys:globals.CURRENT_TYPE_FB,@"type",[NSNumber numberWithInt:[seriesPickerView selectedRowInComponent:0] ],@"series",[NSNumber numberWithInt:oldDistanceNumber ],@"distance" ,fieldPosSliderPos.text,@"field",[NSNumber numberWithInt:[gainPickerView selectedRowInComponent:0]-55],@"gain",specialTeamsOption,@"spoption", nil];
//    
//    dict = [[NSDictionary alloc]initWithObjectsAndKeys:globals.EVENT_NAME,@"event",name,@"name",extraDictionary,@"extra",[globals.ACCOUNT_INFO objectForKey:@"hid"],@"user",[NSString stringWithFormat:@"%f",currentSystemTime],@"requesttime",tagTime,@"time",[globals.ACCOUNT_INFO objectForKey:@"tagColour"],@"colour",lineStr,@"line",[NSNumber numberWithInt: typeOfTag ],@"type", nil];
//    [self sendTagInfo:dict];
//    
//    if (isNewTurn) {
//        //clear all the yrds values for new down 1
//        gainNumber = 0;
//        [gainPickerView selectRow:55 inComponent:0 animated:YES];
//        selectedRowforGain = 55;
//        [gainPickerView reloadComponent:0];
//        isNewTurn = FALSE;
//    }else{
//        gainNumber = 0;
//        [gainPickerView selectRow:55 inComponent:0 animated:YES];
//        selectedRowforGain = 55;
//        [gainPickerView reloadComponent:0];
//    }
//    
//    ////clear the action for previous down tag
//    if (actionButtonWasSelected) {
//        actionButtonWasSelected.selected = FALSE;
//        actionButtonWasSelected = nil;
//    }
//    //clear the events for previous down tag
//    for(UIView *view in playcallEventsView.subviews){
//        [view removeFromSuperview];
//    }
//    //clear the events for previous down tag
//    for(UIView *view in playcallOppEventsView.subviews){
//        [view removeFromSuperview];
//    }
//    
//    if([stButton isSelected])
//    {
//        [stButton sendActionsForControlEvents:UIControlEventTouchUpInside];
//    }
//    
//    
}

-(void)typeChanged:(id)sender{
//    CustomButton *button = (CustomButton*)sender;
//    NSString *zoneStr;
//    NSDictionary *dict;
//    if (offButton.selected) {
//        
//        if (![button isEqual:actionButtonWasSelected]) {
//            if (actionButtonWasSelected) {
//                actionButtonWasSelected.selected = FALSE;
//            }
//            button.selected = TRUE;
//            actionButtonWasSelected = button;
//            zoneStr = [NSString stringWithFormat:@"%d", button.tag];
//            globals.CURRENT_O_ACTION_FB = button.tag;
//            globals.CURRENT_TYPE_FB = button.titleLabel.text;
//            NSInteger row;
//            row = [sTPickerView selectedRowInComponent:0];
//            NSString * specialTeamsOption = stButton.selected ? [specialTeamsArray objectAtIndex:row] : @" " ;
//            
//            
//            NSDictionary *typeDictionary = [[NSDictionary alloc]initWithObjectsAndKeys:globals.CURRENT_TYPE_FB,@"type",[NSNumber numberWithInt:[seriesPickerView selectedRowInComponent:0] ],@"series",[NSNumber numberWithInt:[distancePickerView selectedRowInComponent:0] ],@"distance" ,fieldPosSliderPos.text,@"field",specialTeamsOption,@"spoption", nil];
//            dict = [[NSDictionary alloc]initWithObjectsAndKeys:globals.EVENT_NAME,@"event",typeDictionary,@"extra",globals.CURRENT_DOWN_TAGID,@"id",[globals.ACCOUNT_INFO objectForKey:@"hid"],@"user",nil];//,nil];
//            [self modTagInfo:dict];
//        }
//    }else{
//        
//        if (![button isEqual:actionButtonWasSelected]) {
//            if (actionButtonWasSelected) {
//                actionButtonWasSelected.selected = FALSE;
//            }
//            button.selected = TRUE;
//            actionButtonWasSelected = button;
//            zoneStr = [NSString stringWithFormat:@"%d", button.tag];
//            globals.CURRENT_D_ACTION_FB = button.tag;
//            
//            globals.CURRENT_TYPE_FB = button.titleLabel.text;
//            NSInteger row;
//            row = [sTPickerView selectedRowInComponent:0];
//            NSString * specialTeamsOption = stButton.selected ? [specialTeamsArray objectAtIndex:row] : @" " ;
//            
//            NSDictionary *typeDictionary = [[NSDictionary alloc]initWithObjectsAndKeys:globals.CURRENT_TYPE_FB,@"type",[NSNumber numberWithInt:[seriesPickerView selectedRowInComponent:0] ],@"series",[NSNumber numberWithInt:[distancePickerView selectedRowInComponent:0] ],@"distance" ,fieldPosSliderPos.text,@"field",specialTeamsOption,@"spoption", nil];
//            dict = [[NSDictionary alloc]initWithObjectsAndKeys:globals.EVENT_NAME,@"event",typeDictionary,@"extra",[globals.ACCOUNT_INFO objectForKey:@"hid"],@"user",globals.CURRENT_DOWN_TAGID,@"id",[NSNumber numberWithInt:[seriesPickerView selectedRowInComponent:0] ],@"series",nil];//,nil];
//            [self modTagInfo:dict];
//        }
//    }
    
}
-(void)nextPlayButtonSelected:(id)sender{
//    isNextPlay =TRUE;
//    if(!downButtonWasSelected)
//    {
//        [[arrayOfDownButtons objectAtIndex:0] sendActionsForControlEvents:UIControlEventTouchUpInside];
//        return;
//    }
//    if([globals.CURRENT_STATE_FB isEqualToString:@"off"])
//    {
//        globals.CURRENT_O_PLAY_NUMBER_FB++;
//    }else{
//        globals.CURRENT_D_PLAY_NUMBER_FB++;
//    }
//    
//    //we have to update the current position of the players on the field.
//    gainNumber  = [(NSString*)[gainPickerViewDataArr objectAtIndex:[gainPickerView selectedRowInComponent:0]] intValue];
//    
//    NSInteger row;
//    row = [sTPickerView selectedRowInComponent:0];
//    NSString * specialTeamsOption = stButton.selected ? [specialTeamsArray objectAtIndex:row] : @"" ;
//    
//    NSDictionary *extraDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithInt:globals.CURRENT_O_PLAY_NUMBER_FB],@"play",[NSNumber numberWithInt:[gainPickerView selectedRowInComponent:0]-55],@"gain",[NSNumber numberWithInt:[seriesPickerView selectedRowInComponent:0] ], @"series", specialTeamsOption,@"spoption", nil]; //lets put all of the play information in the extra key
//    if([stButton isSelected])
//    {
//        [stButton sendActionsForControlEvents:UIControlEventTouchUpInside];
//    }
//    
//    NSDictionary * taginfoDict = [[NSDictionary alloc]initWithObjectsAndKeys:globals.EVENT_NAME,@"event",[globals.ACCOUNT_INFO objectForKey:@"hid"],@"user",extraDictionary,@"extra",globals.CURRENT_DOWN_TAGID,@"id",nil];
//    [self modTagInfo:taginfoDict];
//    
//    distanceNumber = [distancePickerView selectedRowInComponent:0];
//    distanceNumber = distanceNumber == 0 ? 10 : distanceNumber; //make sure distance number isn't 0
//    int oldDistanceNumber=distanceNumber;
//    
//   if(gainNumber<0) // loss of yards
//    {
//        if (downButtonWasSelected.tag >2) {
//            [ downButtonWasSelected setTag:2];
//        }
//        distanceNumber = oldDistanceNumber+abs(gainNumber);
//        [[arrayOfDownButtons objectAtIndex:downButtonWasSelected.tag] sendActionsForControlEvents:UIControlEventTouchUpInside];
//        
//    }else{ // gain of yards
//        if(oldDistanceNumber-gainNumber < 0 || oldDistanceNumber-gainNumber == 0) // crossed 1st down line, new first down
//        {
//            isNewTurn=TRUE;
//            distanceNumber = 10;
//            selectedRowforDistance = distanceNumber;
//            [distancePickerView selectRow:distanceNumber inComponent:0 animated:YES];
//            [distancePickerView reloadComponent:0];
//            gainNumber =0;
//            [[arrayOfDownButtons objectAtIndex:0] sendActionsForControlEvents:UIControlEventTouchUpInside];
//            return;
//        }else if([[arrayOfDownButtons objectAtIndex:2] isSelected] && !(oldDistanceNumber-gainNumber <= 0)){ // 3rd and didn't reach first down
//            isNewTurn=TRUE;
//            distanceNumber = 10;
//            [distancePickerView selectRow:distanceNumber inComponent:0 animated:YES];
//            gainNumber =0;
//            [[arrayOfDownButtons objectAtIndex:0] sendActionsForControlEvents:UIControlEventTouchUpInside];
//            if([offButton isSelected])
//            {
//                [defButton sendActionsForControlEvents:UIControlEventTouchUpInside];
//            }else{
//                [offButton sendActionsForControlEvents:UIControlEventTouchUpInside];
//            }
//        }else{ //first or second down, still yards to go
//            distanceNumber=oldDistanceNumber-gainNumber;
//            [[arrayOfDownButtons objectAtIndex:downButtonWasSelected.tag] sendActionsForControlEvents:UIControlEventTouchUpInside];
//            [distancePickerView selectRow:distanceNumber inComponent:0 animated:YES];
//        }
//    }
//    
//    selectedRowforDistance = distanceNumber;
//    [distancePickerView reloadComponent:0];
//    
    
}

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}

// Total rows in our component.
-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    if ([pickerView isEqual:seriesPickerView] || [pickerView isEqual:distancePickerView]) {
        return [pickerViewDataArr count];
    }else if ([pickerView isEqual:sTPickerView])
    {
        return [specialTeamsArray count];
    }else if ([pickerView isEqual:_playCallOppPickerView]){
        return [_playCallOppArray count];
    }else if ([pickerView isEqual:_playCallPickerView]){
        return [_playCallArray count];
    }else{
        return [gainPickerViewDataArr count];
    }
    
}

-(void)updatePlayCall:(id)info
{
//    NSDictionary *dict;
//    if ([[info name] isEqualToString:@"UpdatePlayCallOpp"])
//    {
//        if (globals.playCallOppArray.count)
//        {
//            dict = [[NSDictionary alloc]initWithDictionary:[globals.playCallOppArray objectAtIndex:0]];
//            [globals.playCallOppArray removeObjectAtIndex:0];
//        }
//
//    }else{
//        if (globals.playCallArray.count)
//        {
//            dict = [[NSDictionary alloc]initWithDictionary:[globals.playCallArray objectAtIndex:0]];
//            [globals.playCallArray removeObjectAtIndex:0];
//        }
//    }
//    if(dict)
//    {
//        NSString *tagName = [dict objectForKey:@"name"] ;
//        NSRange rangeOfName = [[tagName lowercaseString] rangeOfString:@"opp"];
//        
//        if([globals.RIGHT_TAG_BUTTONS_NAME containsObject:tagName])
//        {
//            if([playCallOppArray count] < 1 || [[playCallOppArray objectAtIndex:0]length]<2)
//            {
//                [playCallOppArray removeAllObjects];
//            }
//            if (rangeOfName.length) {
//                [playCallOppArray addObject:[tagName stringByReplacingCharactersInRange:rangeOfName withString:@""]];
//            }else{
//                [playCallOppArray addObject:tagName];
//            }
//            [playCallOppPickerView reloadAllComponents];
//            [playCallOppPickerView selectRow:[playCallOppArray count]-1 inComponent:0 animated:YES];
//        }else{
//            if([[dict objectForKey:@"type"] intValue]==0 ||[[dict objectForKey:@"type"] intValue]==100)
//            {
//                if([playCallArray count] < 1 || [[playCallArray objectAtIndex:0]length]<2)
//                {
//                    [playCallArray removeAllObjects];
//                }
//                [playCallArray addObject:tagName];
//                [playCallPickerView reloadAllComponents];
//                [playCallPickerView selectRow:[playCallArray count]-1 inComponent:0 animated:YES];
//            }
//        }
//    }
}

// Display each row's data.
-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    if ([pickerView isEqual:seriesPickerView] || [pickerView isEqual:distancePickerView]) {
        return [pickerViewDataArr objectAtIndex: row];
    }else if ([pickerView isEqual:sTPickerView]){
        return [specialTeamsArray objectAtIndex:row];
    }else if ([pickerView isEqual:_playCallOppPickerView]){
        return [_playCallOppArray objectAtIndex:row];
    }else if ([pickerView isEqual:_playCallPickerView]){
        return [_playCallArray objectAtIndex:row];
    }else{
        return [gainPickerViewDataArr objectAtIndex: row];
    }
    
}

// Do something with the selected row.
//reloadComponent: is used for the highlight the selected row
-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    // //////NSLog(@"You selected this: %@", [pickerViewDataArr objectAtIndex: row]);
    //Send series info to the server
//    if ([pickerView isEqual:seriesPickerView]) {
//        if (offButton.selected) {
//            globals.CURRENT_O_SERIES_NUMBER_FB = row;
//        }else if(defButton.selected){
//            globals.CURRENT_D_SERIES_NUMBER_FB = row;
//        }
//        
//        globals.CURRENT_STATE_FB = @"def";
//        
//        selectedRowforSeries = row;
//        [seriesPickerView reloadComponent:0];
//        
//        seriesNumber = row;
//    }else if([pickerView isEqual:distancePickerView]){
//        //if it is not new down 1, update both distance and field number
//        if (fieldNumber != 0 && downButtonWasSelected) {
//            if (fieldNumber > 0 && fieldNumber - distanceNumber + row > 55) {
//                fieldNumber = fieldNumber - distanceNumber + row - 110;
//            }else if(fieldNumber > 0 && fieldNumber - distanceNumber + row <= 55){
//                fieldNumber = fieldNumber - distanceNumber + row;
//            }else if(fieldNumber <=0 && fieldNumber - distanceNumber + row < -54){
//                fieldNumber = fieldNumber - distanceNumber + row + 110;
//            }else{
//                fieldNumber = fieldNumber - distanceNumber + row;
//            }
//        }
//        distanceNumber = row;
//        //if (row != 0) {
//        selectedRowforDistance = row;
//        [pickerView reloadComponent:0];
//        //}
//    }else{
//        gainNumber = [[gainPickerViewDataArr objectAtIndex: row]integerValue];
//        selectedRowforGain = row;
//        [pickerView reloadComponent:0];
//    }
}
//hight the row we selected
- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view {
    UILabel *customView = (id)view;
    if (!customView) {
        customView= [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, [pickerView rowSizeForComponent:component].width, [pickerView rowSizeForComponent:component].height)];
    }
    
    NSArray *dataArr;
    int selectedRow = 0;
    if ([pickerView isEqual:seriesPickerView]) {
        
        selectedRow = selectedRowforSeries;
        dataArr = [pickerViewDataArr copy];
        
    }else if([pickerView isEqual:distancePickerView]){
        
        selectedRow = selectedRowforDistance;
        dataArr = [pickerViewDataArr copy];
        
    }else if([pickerView isEqual:sTPickerView]){
        selectedRow = 0;
        dataArr = [specialTeamsArray copy];
    }else if([pickerView isEqual:_playCallOppPickerView]){
        selectedRow = 0;
        dataArr = [_playCallOppArray copy];
    }else if([pickerView isEqual:_playCallPickerView]){
        selectedRow = 0;
        dataArr = [_playCallArray copy];
    }else{
        
        selectedRow = selectedRowforGain;
        dataArr = [gainPickerViewDataArr copy];
        
    }
    if([[dataArr objectAtIndex:row] length]>0)
    {
        customView.text = [dataArr objectAtIndex:row];
    }else{
        customView.text=@"";
    }
    customView.backgroundColor = [UIColor clearColor];
    customView.textAlignment = NSTextAlignmentCenter;
    ////////NSLog(@"[seriesPickerView selectedRowInComponent:0] %d, row %d, selectedrow %d",[seriesPickerView selectedRowInComponent:0],row,selectedRow);
    if (row == selectedRow && ((selectedRow != 0 && ![pickerView isEqual:gainPickerView]) || (selectedRow != 55 && [pickerView isEqual:gainPickerView])) ) {
        customView.font = [UIFont boldSystemFontOfSize:32.f];
        customView.textColor = [UIColor orangeColor];
    }else{
        customView.font = [UIFont boldSystemFontOfSize:20.f];
        customView.textColor = [UIColor grayColor];
    }
    return customView;
}


-(void)sendTagInfo:(NSDictionary *)dict{
//    NSError *error;
//    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:0 error:&error];
//    NSString *jsonString;
//    if (! jsonData) {
//        
//    } else {
//        jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
//        jsonString = [jsonString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
//    }
//    NSString *url = [NSString stringWithFormat:@"%@/min/ajax/tagset/%@",globals.URL,jsonString];
//    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
//    
//    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:urlRequest delegate:self]; //[NSURLConnection connectionWithRequest:urlRequest delegate:self];
//    [connection start];
}

-(void)modTagInfo:(NSDictionary *)dict{
//    NSError *error;
//    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:0 error:&error];
//    NSString *jsonString;
//    if (! jsonData) {
//        
//    } else {
//        jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
//        jsonString = [jsonString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
//    }
//    NSString *url = [NSString stringWithFormat:@"%@/min/ajax/tagmod/%@",globals.URL,jsonString];
//    
//    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
//    
//    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:urlRequest delegate:self]; //[NSURLConnection connectionWithRequest:urlRequest delegate:self];
//    [connection start];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    
}


-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
    if (!responseData) {
        responseData = [[NSMutableData alloc]initWithData:data];
    }else{
        [responseData appendData:data];
    }
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection{
//    if (responseData) {
//        id json = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:nil];
//        if (json) {
//            if ([[json objectForKey:@"requrl"]rangeOfString:@"/ajax/tagset/{\"line\""].location != NSNotFound) {
//                globals.CURRENT_DOWN_TAGID = [json objectForKey:@"newTagID"];
//                //                if ([[json objectForKey:@"requrl"]rangeOfString:@"Offense"].location != NSNotFound) {
//                //                    NSDictionary *dict = [[NSDictionary alloc]initWithObjectsAndKeys:globals.EVENT_NAME,@"event",[globals.ACCOUNT_INFO objectForKey:@"customer"],@"user",[NSString stringWithFormat:@"%d",yrdLeftToRun],@"player",globals.CURRENT_DOWN_TAGID,@"id",nil];//,nil];
//                //                    [self modTagInfo:dict];
//                //                }
//                
//            }else{
//                responseData = nil;
//                return;
//            }
//        }else{
//            
//            //leave in for testing purposes
//            //            NSString * foo = [[NSString alloc]initWithData:responseData encoding:NSASCIIStringEncoding];
//            //            //////NSLog(@"jjson -- %@",foo);
//            //            //////NSLog(@"response data is corrupted.");
//        }
//        responseData = nil;
//    }
}

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    
}



- (void)didReceiveMemoryWarning
{
      [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
