//
//  HockeyBottomViewController.m
//  Live2BenchNative
//
//  Created by DEV on 2013-01-24.
//  Copyright (c) 2013 DEV. All rights reserved.
//

#import "HockeyBottomViewController.h"
#import "NSArray+BinarySearch.h"
#import "Tag.h"
#import "Event.h"
#import "ContentViewController.h"
#import "LeagueTeam.h"
#import "UserCenter.h"
#import "TeamPlayer.h"

@interface HockeyBottomViewController ()

@end

@implementation HockeyBottomViewController{
    UIView *_segmentControlView;
    UIView *_leftView;
    UIView *_rightView;
    
    ContentViewController *_playerDrawerLeft;
    UIImageView *_leftArrow;
    
    ContentViewController *_playerDrawerRight;
    UIImageView *_rightArrow;
    
    NSArray *playerList;
    NSDictionary *lineDic;
    BOOL stopUpdateOffense;
    BOOL stopUpdateDefense;
    
    CustomLabel *_periodLabel;
    NSArray *periodValueArray;
    UISegmentedControl *_periodSegmentedControl;
    
    CustomLabel *_strengthLabel;
    CustomLabel *_strengthHomeLabel;
    CustomLabel *_strengthAwayLabel;
    NSArray *strengthValueArray;
    UISegmentedControl *_homeSegControl;
    UISegmentedControl *_awaySegControl;
    
    CustomLabel *_offenseLabel;
    CustomLabel *_defenseLabel;
    NSMutableDictionary *offenseButton;
    NSMutableDictionary *defenseButton;
    
    id periodBoundaryObserver;
    UIColor *tintColor;
    
   
}

@synthesize currentEvent = _currentEvent;
@synthesize videoPlayer = _videoPlayer;
@synthesize mainView  = _mainView;
//@synthesize leftView;
//@synthesize middleView;
//@synthesize rightView;
//@synthesize tagNames =_tagNames;
//@synthesize playerDrawerLeft=_playerDrawerLeft;
//@synthesize leftArrow=_leftArrow;
//@synthesize rightArrow=_rightArrow;
//@synthesize playerDrawerRight=_playerDrawerRight;
//@synthesize periodLabel=_periodLabel;
//@synthesize periodSegmentedControl=_periodSegmentedControl;
//@synthesize homeSegControl=_homeSegControl;
//@synthesize awaySegControl =_awaySegControl;
//@synthesize moviePlayer=_moviePlayer;
//@synthesize oldName;
//@synthesize responseData;

/*- (id)initWithController:(Live2BenchViewController *)l2b
{
    self = [super init];
    live2BenchViewController = l2b;
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
//     globals= [Globals instance];
    
     [self setupView];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(updateControlInfo) name:@"EventInformationUpdated" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(updateControlInfo) name:@"UpdateBottomViewControInfo" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(restartUpdateTimerHockey) name:@"RestartUpdate" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(stopUpdateTimerHockey) name:@"StopUpdate" object:nil];
  
    leftLineButtonArr = [[NSMutableArray alloc]init];
    rightLineButtonArr = [[NSMutableArray alloc]init];
     updateSeekInfoHockeyTimer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                         target:self
                                                       selector:@selector(updateControlInfoWhileSeekingHockey)
                                                       userInfo:nil
                                                        repeats:YES];
    
    [self initLayout];
    
   
    NSMutableArray *lineOne = [[NSMutableArray alloc]init];
    NSMutableArray *lineTwo = [[NSMutableArray alloc]init];
    NSMutableArray *lineThree = [[NSMutableArray alloc]init];
    NSMutableArray *lineFour = [[NSMutableArray alloc]init];
    arrayOfLines = [[NSMutableArray alloc]initWithObjects:lineOne,lineTwo,lineThree,lineFour, nil];
   leftLineButtonWasSelected = nil;//[[CustomButton alloc]init];
    rightLineButtonWasSelected =nil;// [[CustomButton alloc]init];
    [self updateControlInfo];
    // Do any additional setup after loading the view from its nib.
}



-(void)restartUpdateTimerHockey
{
    if(updateSeekInfoHockeyTimer==nil)
    {
        updateSeekInfoHockeyTimer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                               target:self
                                                             selector:@selector(updateControlInfoWhileSeekingHockey)
                                                             userInfo:nil
                                                              repeats:YES];
    }
    
}

-(void)stopUpdateTimerHockey
{
    [updateSeekInfoHockeyTimer invalidate];
    updateSeekInfoHockeyTimer=nil;
}*/

-(id)init{
    self = [super init];
    
    if (self) {
        
        self.view.frame = CGRectMake(0, 540, self.view.frame.size.width, self.view.frame.size.height);
        tintColor = PRIMARY_APP_COLOR;
        _mainView = self.view;
        
        
        offenseButton = [[NSMutableDictionary alloc]init];
        defenseButton = [[NSMutableDictionary alloc]init];
        LeagueTeam *team = [UserCenter getInstance].taggingTeam;
        lineDic = [self populateLine:[team.players allValues]];
        playerList = [self populatePlayerList:[team.players allValues]] ;
        
        // Period Setup
        _periodLabel = [CustomLabel labelWithStyle:CLStyleBlack];
        _periodLabel.frame = CGRectMake(0.0f, 10.0f, 80.0f, 30.0f);
        [_periodLabel setText:@"Period"];
        
        periodValueArray = @[@"1",@"2",@"3",@"OT",@"PS"];
        _periodSegmentedControl = [[UISegmentedControl alloc] initWithItems:periodValueArray];
        [_periodSegmentedControl setFrame:CGRectMake(_periodLabel.frame.origin.x, CGRectGetMaxY(_periodLabel.frame) + 5.0f, _periodSegmentedControl.numberOfSegments*50.0f, 30.0f)];
        [_periodSegmentedControl setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin];
        [_periodSegmentedControl addTarget:self action:@selector(periodSegmentValueChanged:) forControlEvents:UIControlEventValueChanged];
        
        
        // Base View
        _segmentControlView = [[UIView alloc] initWithFrame:CGRectMake((self.view.frame.size.width - (_periodSegmentedControl.numberOfSegments)*50.0f)/2, 0.0f, (_periodSegmentedControl.numberOfSegments)*50.0f, self.view.frame.size.height)];
        _segmentControlView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        [self.view addSubview:_segmentControlView];
        [_segmentControlView addSubview:_periodSegmentedControl];
        [_segmentControlView addSubview:_periodLabel];
        
        _leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _segmentControlView.frame.origin.x, self.view.frame.size.height)];
        [_leftView setAutoresizingMask:UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
        _rightView = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_segmentControlView.frame), 0, _leftView.frame.size.width, _leftView.frame.size.height)];
        [_rightView setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
        [self.view addSubview:_leftView];
        [self.view addSubview:_rightView];

        
        // Strength Setup
        _strengthLabel = [CustomLabel labelWithStyle:CLStyleBlack];
        _strengthLabel.frame = CGRectMake(_periodLabel.frame.origin.x, CGRectGetMaxY(_periodSegmentedControl.frame) + 15.0f, 100.0f, 30.0f);
        [_strengthLabel setText:@"Strength"];
        [_segmentControlView addSubview:_strengthLabel];
        
        strengthValueArray = @[@"3",@"4",@"5",@"6"];
        _homeSegControl = [[UISegmentedControl alloc] initWithItems:strengthValueArray];
        [_homeSegControl setFrame:CGRectMake(_strengthLabel.frame.origin.x + 45.0f, CGRectGetMaxY(_strengthLabel.frame) + 5.0f, _homeSegControl.numberOfSegments*50.0f, 30.0f)];
        [_homeSegControl setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin];
        [_homeSegControl addTarget:self action:@selector(segmentValueChanged:) forControlEvents:UIControlEventValueChanged];
        [_segmentControlView addSubview:_homeSegControl];
        
        _awaySegControl = [[UISegmentedControl alloc] initWithItems:strengthValueArray];
        [_awaySegControl setFrame:CGRectMake(_homeSegControl.frame.origin.x, CGRectGetMaxY(_homeSegControl.frame) + 10.0f, _awaySegControl.numberOfSegments*50.0f, 30.0f)];
        [_awaySegControl setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin];
        [_awaySegControl addTarget:self action:@selector(segmentValueChanged:) forControlEvents:UIControlEventValueChanged];
        [_segmentControlView addSubview:_awaySegControl];
        
        
        _strengthHomeLabel = [CustomLabel labelWithStyle:CLStyleWhite];
        _strengthHomeLabel.frame = CGRectMake(_periodSegmentedControl.frame.origin.x + 5.0f, _homeSegControl.frame.origin.y, 30.0f, 30.0f);
        [_strengthHomeLabel setText:@"H"];
        _strengthHomeLabel.backgroundColor = [UIColor grayColor];
        [_strengthHomeLabel setTextAlignment:NSTextAlignmentCenter];
        [_segmentControlView addSubview:_strengthHomeLabel];
        
        _strengthAwayLabel = [CustomLabel labelWithStyle:CLStyleWhite];
        _strengthAwayLabel.frame = CGRectMake(_strengthHomeLabel.frame.origin.x, _awaySegControl.frame.origin.y, 30.0f, 30.0f);
        [_strengthAwayLabel setText:@"A"];
        _strengthAwayLabel.backgroundColor = [UIColor grayColor];
        [_strengthAwayLabel setTextAlignment:NSTextAlignmentCenter];
        [_segmentControlView addSubview:_strengthAwayLabel];
        
        //Offense Setup
        _offenseLabel = [CustomLabel labelWithStyle:CLStyleBlack];
        _offenseLabel.frame = CGRectMake(50.0f, 0.0f, 60.0f, 44.0f);
        _offenseLabel.autoresizingMask = UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleBottomMargin;
        _offenseLabel.textAlignment = NSTextAlignmentRight;
        [_offenseLabel setText:@"Offense"];
        [_leftView addSubview:_offenseLabel];
        
        UIButton *O1 = [[UIButton alloc]initWithFrame:CGRectMake(40.0f,40.0f,45.0f,45.0f)];
        O1.layer.borderColor = tintColor.CGColor;
        O1.layer.borderWidth = 1;
        [O1 setTitle:@"1" forState:UIControlStateNormal];
        [O1 setTitleColor:tintColor forState:UIControlStateNormal];
        [O1 setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
        [O1 addTarget:self action:@selector(OffensePressed:) forControlEvents:UIControlEventTouchUpInside];
        [O1 addTarget:self action:@selector(OffenseSwipe:) forControlEvents:UIControlEventTouchDragOutside];
        [_leftView addSubview:O1];
        [offenseButton setValue:O1 forKey:O1.titleLabel.text];
        
        UIButton *O2 = [[UIButton alloc]initWithFrame:CGRectMake(90.0f,40.0f,45.0f,45.0f)];
        O2.layer.borderColor = tintColor.CGColor;
        O2.layer.borderWidth = 1;
        [O2 setTitle:@"2" forState:UIControlStateNormal];
        [O2 setTitleColor:tintColor forState:UIControlStateNormal];
        [O2 setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
        [O2 addTarget:self action:@selector(OffensePressed:) forControlEvents:UIControlEventTouchUpInside];
        [O2 addTarget:self action:@selector(OffenseSwipe:) forControlEvents:UIControlEventTouchDragOutside];
        [_leftView addSubview:O2];
        [offenseButton setValue:O2 forKey:O2.titleLabel.text];
        
        UIButton *O3 = [[UIButton alloc]initWithFrame:CGRectMake(140.0f,40.0f,45.0f,45.0f)];
        O3.layer.borderColor = tintColor.CGColor;
        O3.layer.borderWidth = 1;
        [O3 setTitle:@"3" forState:UIControlStateNormal];
        [O3 setTitleColor:tintColor forState:UIControlStateNormal];
        [O3 setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
        [O3 addTarget:self action:@selector(OffensePressed:) forControlEvents:UIControlEventTouchUpInside];
        [O3 addTarget:self action:@selector(OffenseSwipe:) forControlEvents:UIControlEventTouchDragOutside];
        [_leftView addSubview:O3];
        [offenseButton setValue:O3 forKey:O3.titleLabel.text];
        
        UIButton *O4 = [[UIButton alloc]initWithFrame:CGRectMake(190.0f,40.0f,45.0f,45.0f)];
        O4.layer.borderColor = tintColor.CGColor;
        O4.layer.borderWidth = 1;
        [O4 setTitle:@"4" forState:UIControlStateNormal];
        [O4 setTitleColor:tintColor forState:UIControlStateNormal];
        [O4 setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
        [O4 addTarget:self action:@selector(OffensePressed:) forControlEvents:UIControlEventTouchUpInside];
        [O4 addTarget:self action:@selector(OffenseSwipe:) forControlEvents:UIControlEventTouchDragOutside];
        [_leftView addSubview:O4];
        [offenseButton setValue:O4 forKey:O4.titleLabel.text];
        
        _leftArrow = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"ortri.png"]];
        [_leftArrow setContentMode:UIViewContentModeScaleAspectFit];
        [_leftArrow setAlpha:0.0f];
        [_leftView addSubview:_leftArrow];
        [_leftArrow setHidden:true];
        
        _playerDrawerLeft = [[ContentViewController alloc] initWithFrame:CGRectMake(40, O1.center.y+37, 300, 110) playerList:playerList];
        [_playerDrawerLeft.view setBackgroundColor:[UIColor clearColor]];
        [_playerDrawerLeft.view.layer setBorderColor:PRIMARY_APP_COLOR.CGColor];
        [_playerDrawerLeft.view.layer setBorderWidth:1.0f];
        [_playerDrawerLeft.view setHidden:true];
        [_leftView addSubview:_playerDrawerLeft.view];
        //_playerDrawerLeft.playerList = playerList;
        
        _defenseLabel = [CustomLabel labelWithStyle:CLStyleBlack];
        _defenseLabel.frame = CGRectMake(110.0f, 0.0f, 60.0f, 44.0f);
        _defenseLabel.autoresizingMask = UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleBottomMargin;
        _defenseLabel.textAlignment = NSTextAlignmentRight;
        [_defenseLabel setText:@"Defense"];
        [_rightView addSubview:_defenseLabel];
        
        UIButton *D1 = [[UIButton alloc]initWithFrame:CGRectMake(100.0f,40.0f,45.0f,45.0f)];
        D1.layer.borderColor = tintColor.CGColor;
        D1.layer.borderWidth = 1;
        [D1 setTitle:@"1" forState:UIControlStateNormal];
        [D1 setTitleColor:tintColor forState:UIControlStateNormal];
        [D1 setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
        [D1 addTarget:self action:@selector(DefensePressed:) forControlEvents:UIControlEventTouchUpInside];
        [D1 addTarget:self action:@selector(DefenseSwipe:) forControlEvents:UIControlEventTouchDragOutside];
        [_rightView addSubview:D1];
        [defenseButton setValue:D1 forKey:D1.titleLabel.text];
        
        UIButton *D2 = [[UIButton alloc]initWithFrame:CGRectMake(150.0f,40.0f,45.0f,45.0f)];
        D2.layer.borderColor = tintColor.CGColor;
        D2.layer.borderWidth = 1;
        [D2 setTitle:@"2" forState:UIControlStateNormal];
        [D2 setTitleColor:tintColor forState:UIControlStateNormal];
        [D2 setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
        [D2 addTarget:self action:@selector(DefensePressed:) forControlEvents:UIControlEventTouchUpInside];
        [D2 addTarget:self action:@selector(DefenseSwipe:) forControlEvents:UIControlEventTouchDragOutside];
        [_rightView addSubview:D2];
        [defenseButton setValue:D2 forKey:D2.titleLabel.text];
        
        
        UIButton *D3 = [[UIButton alloc]initWithFrame:CGRectMake(200.0f,40.0f,45.0f,45.0f)];
        D3.layer.borderColor = tintColor.CGColor;
        D3.layer.borderWidth = 1;
        [D3 setTitle:@"3" forState:UIControlStateNormal];
        [D3 setTitleColor:tintColor forState:UIControlStateNormal];
        [D3 setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
        [D3 addTarget:self action:@selector(DefensePressed:) forControlEvents:UIControlEventTouchUpInside];
        [D3 addTarget:self action:@selector(DefenseSwipe:) forControlEvents:UIControlEventTouchDragOutside];
        [_rightView addSubview:D3];
        [defenseButton setValue:D3 forKey:D3.titleLabel.text];

        
        UIButton *D4 = [[UIButton alloc]initWithFrame:CGRectMake(250.0f,40.0f,45.0f,45.0f)];
        D4.layer.borderColor = tintColor.CGColor;
        D4.layer.borderWidth = 1;
        [D4 setTitle:@"4" forState:UIControlStateNormal];
        [D4 setTitleColor:tintColor forState:UIControlStateNormal];
        [D4 setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
        [D4 addTarget:self action:@selector(DefensePressed:) forControlEvents:UIControlEventTouchUpInside];
        [D4 addTarget:self action:@selector(DefenseSwipe:) forControlEvents:UIControlEventTouchDragOutside];
        [_rightView addSubview:D4];
        [defenseButton setValue:D4 forKey:D4.titleLabel.text];
        
        
        _rightArrow = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"ortri.png"]];
        [_rightArrow setContentMode:UIViewContentModeScaleAspectFit];
        [_rightArrow setAlpha:0.0f];
        [_rightView addSubview:_rightArrow];
        [_rightArrow setHidden:true];
        
        _playerDrawerRight = [[ContentViewController alloc] initWithFrame:CGRectMake(-5,D1.center.y+37,300,110) playerList:playerList];
        [_playerDrawerRight.view setBackgroundColor:[UIColor clearColor]];
        [_playerDrawerRight.view.layer setBorderColor:PRIMARY_APP_COLOR.CGColor];
        [_playerDrawerRight.view.layer setBorderWidth:1.0f];
        [_playerDrawerRight.view setHidden:true];
        [_rightView addSubview:_playerDrawerRight.view];
        //_playerDrawerRight.playerList = playerList;

        stopUpdateOffense = false;
        stopUpdateDefense = false;
    }
    return self;
}

#pragma mark - Helper Methods

//Populate Offense and Defense Line
-(NSDictionary*)populateLine:(NSArray*)players{
    NSMutableArray *O1 = [[NSMutableArray alloc]init];
    NSMutableArray *O2 = [[NSMutableArray alloc]init];
    NSMutableArray *O3 = [[NSMutableArray alloc]init];
    NSMutableArray *O4 = [[NSMutableArray alloc]init];
    NSMutableArray *D1 = [[NSMutableArray alloc]init];
    NSMutableArray *D2 = [[NSMutableArray alloc]init];
    NSMutableArray *D3 = [[NSMutableArray alloc]init];
    NSMutableArray *D4 = [[NSMutableArray alloc]init];
    for (TeamPlayer *player in players) {
        NSArray *words = [player.line componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"G,L"]];
        if ([words[0] isEqualToString:@"O"] ) {
            if ([words[1] isEqualToString:@"1"]) {
                [O1 addObject:player.jersey];
            }else if([words[1] isEqualToString:@"2"]){
                [O2 addObject:player.jersey];
            }else if ([words[1] isEqualToString:@"3"]){
                [O3 addObject:player.jersey];
            }else if ([words[1] isEqualToString:@"4"]){
                [O4 addObject:player.jersey];
            }
        }else if ([words[0] isEqualToString:@"D"]){
            if ([words[1] isEqualToString:@"1"]) {
                [D1 addObject:player.jersey];
            }else if ([words[1] isEqualToString:@"2"]){
                [D2 addObject:player.jersey];
            }else if ([words[1] isEqualToString:@"3"]){
                [D3 addObject:player.jersey];
            }else if ([words[1] isEqualToString:@"4"]){
                [D4 addObject:player.jersey];
            }
        }
    }
    NSDictionary *offenseLine = @{@"1":O1,@"2":O2,@"3":O3,@"4":O4};
    NSDictionary *defenseLine = @{@"1":D1,@"2":D2,@"3":D3,@"4":D4};
    NSDictionary *final = @{@"offense":offenseLine,@"defense":defenseLine};
    return final;
}

//Populate Player List with all Player jersey
-(NSArray*)populatePlayerList:(NSArray *)players{
    NSMutableArray *pleaseWork = [[NSMutableArray alloc]init];
    for (TeamPlayer *player in players) {
        [pleaseWork addObject:player.jersey];
    }
    return [pleaseWork copy];
}

// Pass the name of the tag you want and you will get the tag if it exists and get nill if it doesn't exist
-(Tag *)checkTags:(NSString *)name{
    for (Tag *tag in _currentEvent.tags) {
        if ([tag.name isEqualToString:name]) {
            return tag;
        }
    }
    return nil;
}

// Get all the tags that was asked for in the order from highest time to lowest time as an array
-(NSArray*)getTags:(TagType)type secondType:(TagType)secondType{
    // Get a dictionary with all the times and names
    NSMutableDictionary *timeDicUnordered = [[NSMutableDictionary alloc]init];
    for (Tag *tag in _currentEvent.tags) {
        if (tag.type == type || tag.type == secondType) {
            timeDicUnordered[[NSNumber numberWithFloat:tag.time]] = tag.name;
        }
    }
    
    // sort the times form smallest to biggest
    NSSortDescriptor *highestToLowest = [NSSortDescriptor sortDescriptorWithKey:@"self" ascending:NO];
    NSMutableArray *timesArray = [[NSMutableArray alloc]initWithArray:[timeDicUnordered allKeys]];
    [timesArray sortUsingDescriptors:[NSArray arrayWithObject:highestToLowest]];
    
    // populate the dic with all the times and names in order
    NSMutableArray *timeDicOrdered = [[NSMutableArray alloc]init];
    for (int i  = 0; i < timesArray.count; i++) {
        NSDictionary *dic = @{@"time":timesArray[i],@"name":timeDicUnordered[timesArray[i]]};
        [timeDicOrdered insertObject:dic atIndex:i];
    }
    
    return [timeDicOrdered copy];
}

//Unhighlightt all Button
-(void)unHighlightOffenseButtons{
    for (UIButton *button in [offenseButton allValues]) {
        button.selected = false;
        button.backgroundColor = [UIColor clearColor];
    }
}

-(void)unHighlightDefenseButtons{
    for (UIButton *button in [defenseButton allValues]) {
        button.selected = false;
        button.backgroundColor = [UIColor clearColor];
    }
}

// Post tags at the very beginning of a new event
-(void)postTagsAtBeginning{
    if ([self getTags:TagTypeHockeyPeriodStart secondType:TagTypeHockeyPeriodStop].count == 0) {
        NSDictionary *dic = @{@"name":@"1",@"period":@"1",@"time":[NSString stringWithFormat:@"%f",0.0],@"type":[NSNumber numberWithInteger:TagTypeHockeyPeriodStart]};
        _periodSegmentedControl.selectedSegmentIndex = 0;
        [super postTag:dic];
    }
    
    if ([self getTags:TagTypeHockeyStrengthStart secondType:TagTypeHockeyStrengthStop].count == 0) {
        NSDictionary *dic = @{@"name":@"5,5",@"strength":@"5,5",@"time":[NSString stringWithFormat:@"%f",0.0],@"type":[NSNumber numberWithInteger:TagTypeHockeyStrengthStart],@"period":[self currentPeriod]};
        _homeSegControl.selectedSegmentIndex = 2;
        _awaySegControl.selectedSegmentIndex = 2;
        [super postTag:dic];
    }
    
    if ([self getTags:TagTypeHockeyStartOLine secondType:TagTypeHockeyStopOLine].count == 0) {
        NSDictionary *dic = @{@"name":@"line_f_1",@"time":[NSString stringWithFormat:@"%f",0.0],@"type":[NSNumber numberWithInteger:TagTypeHockeyStartOLine],@"period":[self currentPeriod],@"line":@"line_f_1"};
        UIButton *button = [offenseButton objectForKey:@"1"];
        button.backgroundColor = tintColor;
        button.selected = true;
        [offenseButton setValue:button forKey:@"current"];
        [super postTag:dic];

    }
    
    if ([self getTags:TagTypeHockeyStartDLine secondType:TagTypeHockeyStartDLine].count == 0) {
        NSDictionary *dic = @{@"name":@"line_d_1",@"time":[NSString stringWithFormat:@"%f",0.0],@"type":[NSNumber numberWithInteger:TagTypeHockeyStartDLine],@"period":[self currentPeriod],@"line":@"line_d_1"};
        UIButton *button = [defenseButton objectForKey:@"1"];
        button.backgroundColor = tintColor;
        button.selected = true;
        [defenseButton setValue:button forKey:@"current"];
        [super postTag:dic];
        
    }

}

// add observer so the period segment get updated
-(void)update{
    [self updatePeriodSegment];
    [self updateStrengthSegment];
    [self updateOffenseButtons];
    [self updateDefenseButtons];
    
    __block HockeyBottomViewController *weakSelf = self;
    periodBoundaryObserver = [_videoPlayer addPeriodicTimeObserverForInterval:CMTimeMake(1, 1) queue:NULL usingBlock:^(CMTime time){
        [weakSelf updatePeriodSegment];
        [weakSelf updateStrengthSegment];
        [weakSelf updateOffenseButtons];
        [weakSelf updateDefenseButtons];
    }];
}

// get Current Period
-(NSString *)currentPeriod{
    NSNumber *time = [NSNumber numberWithFloat:CMTimeGetSeconds(_videoPlayer.currentTime)];
    NSArray *array = [self getTags:TagTypeHockeyPeriodStart secondType:TagTypeHockeyPeriodStop];
    
    if (array.count > 0) {
        NSNumber *startTime;
        for (int i = 0; i < array.count; i++) {
            startTime = array[i][@"time"];
            if ( [time floatValue] >= [startTime floatValue] ) {
                NSString *name = array[i][@"name"];
                return name;
            }
        }
        
    }
    return @"1";
}

#pragma mark - Period Tags Related Methods
// Post period tag
-(void)periodSegmentValueChanged:(UISegmentedControl *)segment
{
    float time = CMTimeGetSeconds(_videoPlayer.currentTime);
    NSString *name = [periodValueArray objectAtIndex:_periodSegmentedControl.selectedSegmentIndex];
    
    if (![self checkTags:name]) {
        NSDictionary *tagDic = @{@"name":name,@"period":name, @"type":[NSNumber numberWithInteger:TagTypeHockeyPeriodStart],@"time":[NSString stringWithFormat:@"%f",time]};
        [super postTag:tagDic];
    }
    
    /*if ([self checkTags:name]) {
        Tag *tag = [self checkTags:name];
        tag.time = time;
        [super modifyTag:tag];
    }else{
         NSDictionary *tagDic = @{@"name":name,@"period":name, @"type":[NSNumber numberWithInteger:TagTypeHockeyPeriodStart],@"time":[NSString stringWithFormat:@"%f",time]};
        [super postTag:tagDic];
    }*/
}

// Actually update the period segment
-(void)updatePeriodSegment{
    NSString *name = [self currentPeriod];
    NSInteger index = [periodValueArray indexOfObject:name];
    _periodSegmentedControl.selectedSegmentIndex = index;
}


#pragma mark - Strength Tags Related Methods

// Post Tag when Strength Segment pressed
-(void)segmentValueChanged:(UISegmentedControl *)segment
{
    float time = CMTimeGetSeconds(_videoPlayer.currentTime);
    
    NSInteger homeIndex = _homeSegControl.selectedSegmentIndex;
    NSInteger awayIndex = _awaySegControl.selectedSegmentIndex;
    int homeValue = [[strengthValueArray  objectAtIndex:homeIndex] intValue];
    int awayValue = [[strengthValueArray objectAtIndex:awayIndex] intValue];
    NSString *name = [NSString stringWithFormat:@"%d,%d",homeValue,awayValue];
    
    NSDictionary *dic = @{@"name":name,@"time":[NSString stringWithFormat:@"%f",time],@"type":[NSNumber numberWithInteger:TagTypeHockeyStrengthStart],@"strength":name,@"period":[self currentPeriod]};
    [super postTag:dic];
        
    //if i have more players the the other team then the H view is green, other wise it is red
    [self updateStrengthLabelTintsWithAwayValue:awayValue HomeValue:homeValue];
}

//Update home and away labels' color
-(void)updateStrengthLabelTintsWithAwayValue:(int)awayValue  HomeValue:(int)homeValue {
    
    float tintValue = (homeValue - awayValue)*(0.1f);
    
    if (awayValue == homeValue) {
        _strengthHomeLabel.backgroundColor = [UIColor grayColor];
        _strengthAwayLabel.backgroundColor = [UIColor grayColor];
    } else if (awayValue < homeValue) {
        _strengthHomeLabel.backgroundColor = [UIColor colorWithRed:0.6f green:0.6f+tintValue blue:0.6f alpha:1.0f];
        _strengthAwayLabel.backgroundColor = [UIColor colorWithRed:0.6f+tintValue green:0.6f blue:0.6f alpha:1.0f];

    } else if (awayValue > homeValue){ 
        _strengthHomeLabel.backgroundColor = [UIColor colorWithRed:0.6f-tintValue green:0.6f blue:0.6f alpha:1.0f];
        _strengthAwayLabel.backgroundColor = [UIColor colorWithRed:0.6f green:0.6f-tintValue blue:0.6f alpha:1.0f];
    }
}

// Actually Update the strengths' segment
-(void)updateStrengthSegment{
    
    NSNumber *time = [NSNumber numberWithFloat:CMTimeGetSeconds(_videoPlayer.currentTime)];
    NSArray *array = [self getTags:TagTypeHockeyStrengthStart secondType:TagTypeHockeyStrengthStop];
    
    if (array.count > 0) {
        NSNumber *startTime;
        for (int i = 0; i < array.count; i++) {
            startTime = array[i][@"time"];
            if ( [time floatValue] >= [startTime floatValue] ) {
                NSString *name = array[i][@"name"];
                NSArray *words = [name componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@","]];
                _homeSegControl.selectedSegmentIndex = [strengthValueArray indexOfObject:words[0]];
                _awaySegControl.selectedSegmentIndex = [strengthValueArray indexOfObject:words[1]];
                [self updateStrengthLabelTintsWithAwayValue:[words[1] intValue] HomeValue:[words[0] intValue]];
                return;
            }
        }
        
    }
}


#pragma mark - Offense Tags Related Methods

// Post an Offense Tag
-(void)OffensePressed:(id)sender
{
    float time = CMTimeGetSeconds(_videoPlayer.currentTime);
    CustomButton *button = (CustomButton*)sender;
    
    [_leftArrow setHidden:true];
    [_playerDrawerLeft.view setHidden:true];
    
    
    if (![button isEqual:[offenseButton objectForKey:@"current"]] || stopUpdateOffense) {
        [self unHighlightOffenseButtons];
        button.backgroundColor = tintColor;
        button.selected = true;
        [offenseButton setValue:button forKey:@"current"];
        NSString *name =[[@"line_" stringByAppendingString:@"f_"] stringByAppendingString:button.titleLabel.text];
        NSDictionary *dic = @{@"name":name,@"time":[NSString stringWithFormat:@"%f",time],@"type":[NSNumber numberWithInteger:TagTypeHockeyStartOLine],@"period":[self currentPeriod],@"line":name};
        [super postTag:dic];

    }
    
    stopUpdateOffense = false;
    
}

// Actually Update Offense Buttons
-(void)updateOffenseButtons{
    
    if (stopUpdateOffense == true) {
        return;
    }
    
    NSNumber *time = [NSNumber numberWithFloat:CMTimeGetSeconds(_videoPlayer.currentTime)];
    NSArray *array = [self getTags:TagTypeHockeyStartOLine secondType:TagTypeHockeyStopOLine];
    
    if (array.count > 0) {
        NSNumber *startTime;
        for (int i = 0; i < array.count; i++) {
            startTime = array[i][@"time"];
            if ( [time floatValue] >= [startTime floatValue] ) {
                NSString *name = array[i][@"name"];
                NSArray *words = [name componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"_"]];
                UIButton *but = [offenseButton objectForKey:words[2]];
                [self unHighlightOffenseButtons];
                but.backgroundColor = tintColor;
                but.selected = true;
                [offenseButton setValue:but forKey:@"current"];
                return;
            }
        }
        
    }
}

-(void)OffenseSwipe:(id)sender{
    
    stopUpdateOffense = true;
    
    CustomButton *button = (CustomButton*)sender;
    
    if (![button isEqual:[offenseButton objectForKey:@"current"]]) {
    
        [self unHighlightOffenseButtons];
        button.backgroundColor = tintColor;
        button.selected = true;
        [offenseButton setValue:button forKey:@"current"];
    }
    
    [_playerDrawerLeft.view setHidden:false];
    [_leftArrow setHidden:false];

    [UIView animateWithDuration:0.2
                     animations:^{
                         [_leftArrow setAlpha:1.0f];
                         [_leftArrow setFrame:CGRectMake(button.center.x-7, button.center.y+22, 15, 15)];
                     }
                     completion:^(BOOL finished){ }];
    
    NSArray *array = lineDic[@"offense"][button.titleLabel.text];
    [_playerDrawerLeft selectPlayers:array];
}


#pragma mark - Defense Tags Related Methods

// Post an Defense Tag
-(void)DefensePressed:(id)sender
{
    float time = CMTimeGetSeconds(_videoPlayer.currentTime);
    CustomButton *button = (CustomButton*)sender;
    
    [_playerDrawerRight.view setHidden:true];
    [_rightArrow setHidden:true];
    
    if (![button isEqual:[defenseButton objectForKey:@"current"]] || stopUpdateDefense) {
        [self unHighlightDefenseButtons];
        button.backgroundColor = tintColor;
        button.selected = true;
        [defenseButton setValue:button forKey:@"current"];
        NSString *name =[[@"line_" stringByAppendingString:@"d_"] stringByAppendingString:button.titleLabel.text];
        NSDictionary *dic = @{@"name":name,@"time":[NSString stringWithFormat:@"%f",time],@"type":[NSNumber numberWithInteger:TagTypeHockeyStartDLine],@"period":[self currentPeriod],@"line":name};
        [super postTag:dic];
        
    }
    
    stopUpdateDefense = false;
    
}

// Actually Update Defense Buttons
-(void)updateDefenseButtons{
    
    if (stopUpdateDefense == true) {
        return;
    }
    
    NSNumber *time = [NSNumber numberWithFloat:CMTimeGetSeconds(_videoPlayer.currentTime)];
    NSArray *array = [self getTags:TagTypeHockeyStartDLine secondType:TagTypeHockeyStopDLine];
    
    if (array.count > 0) {
        NSNumber *startTime;
        for (int i = 0; i < array.count; i++) {
            startTime = array[i][@"time"];
            if ( [time floatValue] >= [startTime floatValue] ) {
                NSString *name = array[i][@"name"];
                NSArray *words = [name componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"_"]];
                UIButton *but = [defenseButton objectForKey:words[2]];
                [self unHighlightDefenseButtons];
                but.backgroundColor = tintColor;
                but.selected = true;
                [defenseButton setValue:but forKey:@"current"];
                return;
            }
        }
        
    }
}

-(void)DefenseSwipe:(id)sender{
    
    stopUpdateDefense = true;
    
    CustomButton *button = (CustomButton*)sender;
    
    if (![button isEqual:[defenseButton objectForKey:@"current"]]) {
        
        [self unHighlightOffenseButtons];
        button.backgroundColor = tintColor;
        button.selected = true;
        [defenseButton setValue:button forKey:@"current"];
    }
    
    [_playerDrawerRight.view setHidden:false];
    [_rightArrow setHidden:false];
    
    [UIView animateWithDuration:0.2
                     animations:^{
                         [_rightArrow setAlpha:1.0f];
                         [_rightArrow setFrame:CGRectMake(button.center.x-7, button.center.y+22, 15, 15)];
                     }
                     completion:^(BOOL finished){ }];
    
    NSArray *array = lineDic[@"defense"][button.titleLabel.text];
    [_playerDrawerRight selectPlayers:array];
}




//-(void)OffenseSwipe





/*-(void)setupView
{
    self.periodSegmentedControl = [[UISegmentedControl alloc] initWithItems:@[@"1",@"2",@"3",@"OT",@"PS"]];
    self.homeSegControl = [[UISegmentedControl alloc] initWithItems:@[@"3",@"4",@"5",@"6"]];
    self.awaySegControl = [[UISegmentedControl alloc] initWithItems:@[@"3",@"4",@"5",@"6"]];
    
    self.segmentControlView = [[UIView alloc] initWithFrame:CGRectMake((self.view.frame.size.width - (self.periodSegmentedControl.numberOfSegments)*50.0f)/2, 0.0f, (self.periodSegmentedControl.numberOfSegments)*50.0f, self.view.frame.size.height)];
    self.segmentControlView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    
    self.periodLabel = [CustomLabel labelWithStyle:CLStyleBlack];
    self.periodLabel.frame = CGRectMake(0.0f, 10.0f, 80.0f, 30.0f);
    [self.periodLabel setText:@"Period"];
    [self.segmentControlView addSubview:self.periodLabel];
    
    [self.periodSegmentedControl setFrame:CGRectMake(self.periodLabel.frame.origin.x, CGRectGetMaxY(self.periodLabel.frame) + 5.0f, self.periodSegmentedControl.numberOfSegments*50.0f, 30.0f)];
    [self.periodSegmentedControl setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin];
    [self.periodSegmentedControl addTarget:self action:@selector(periodSegmentValueChanged:) forControlEvents:UIControlEventValueChanged];
    [self.segmentControlView addSubview:self.periodSegmentedControl];
    
    self.strengthLabel = [CustomLabel labelWithStyle:CLStyleBlack];
    self.strengthLabel.frame = CGRectMake(self.periodLabel.frame.origin.x, CGRectGetMaxY(self.periodSegmentedControl.frame) + 15.0f, 100.0f, 30.0f);
    [self.strengthLabel setText:@"Strength"];
    [self.segmentControlView addSubview:self.strengthLabel];
    
//    [self.homeSegControl setSegmentedControlStyle:UISegmentedControlStyleBezeled];
    [self.homeSegControl setFrame:CGRectMake(self.strengthLabel.frame.origin.x + 45.0f, CGRectGetMaxY(self.strengthLabel.frame) + 5.0f, self.homeSegControl.numberOfSegments*50.0f, 30.0f)];
    [self.homeSegControl setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin];
    [self.homeSegControl addTarget:self action:@selector(segmentValueChanged:) forControlEvents:UIControlEventValueChanged];
    [self.segmentControlView addSubview:self.homeSegControl];
    
//    [self.awaySegControl setSegmentedControlStyle:UISegmentedControlStyleBar];
    [self.awaySegControl setFrame:CGRectMake(self.homeSegControl.frame.origin.x, CGRectGetMaxY(self.homeSegControl.frame) + 10.0f, self.awaySegControl.numberOfSegments*50.0f, 30.0f)];
    [self.awaySegControl setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin];
    [self.awaySegControl addTarget:self action:@selector(segmentValueChanged:) forControlEvents:UIControlEventValueChanged];
    [self.segmentControlView addSubview:self.awaySegControl];
    
    [self.view addSubview:self.segmentControlView];
    
    leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.segmentControlView.frame.origin.x, self.view.frame.size.height)];
    [leftView setAutoresizingMask:UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
    rightView = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.segmentControlView.frame), 0, leftView.frame.size.width, leftView.frame.size.height)];
    [rightView setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
    [self.view addSubview:leftView];
    [self.view addSubview:rightView];
}

- (void)updateStrengthLabelTintsWithAwayValue:(int)awayValue andHomeValue:(int)homeValue {
    float tintValue = (homeValue - awayValue)*(0.1f);
    if (tintValue > 0){
        strengthHomeLabel.backgroundColor = [UIColor colorWithRed:0.6f green:0.6f+tintValue blue:0.6f alpha:1.0f];
        strengthAwayLabel.backgroundColor = [UIColor colorWithRed:0.6f+tintValue green:0.6f blue:0.6f alpha:1.0f];
    } else {
        strengthHomeLabel.backgroundColor = [UIColor colorWithRed:0.6f-tintValue green:0.6f blue:0.6f alpha:1.0f];
        strengthAwayLabel.backgroundColor = [UIColor colorWithRed:0.6f green:0.6f-tintValue blue:0.6f alpha:1.0f];
    }
}

//timer that highlights lines, period, strength
-(void)updateControlInfo{
//
//    //1. if current playig event is not hockey event 2. if the current event is live but the the event is not started completed yet (![globals.CURRENT_ENC_STATUS isEqualToString:encStateLive]), just return.
//    if (![globals.WHICH_SPORT isEqualToString:@"hockey"] || (![globals.CURRENT_ENC_STATUS isEqualToString:encStateLive] && [globals.EVENT_NAME isEqual:@"live"])) {
//        return;
//    }
//    //highlight current period, globals.CURRENT_PERIOD is the int value of segment control index
//    if (globals.CURRENT_PERIOD>=0) {
//       [self.periodSegmentedControl setSelectedSegmentIndex:globals.CURRENT_PERIOD];
//    }else {
//        [self.periodSegmentedControl setSelectedSegmentIndex:0];
//        
////         if(globals.HAS_MIN)
////         {
//           [self.periodSegmentedControl sendActionsForControlEvents:UIControlEventValueChanged];
//         //}
//    }
//    
//    if(globals.CURRENT_STRENGTH)
//    {
//        NSArray *arrayOfStrength;
//        
//        if ([globals.CURRENT_STRENGTH rangeOfString:@"VS"].location == NSNotFound) {
//            //if the strength ie: 4,5
//            arrayOfStrength = [globals.CURRENT_STRENGTH componentsSeparatedByString:@","];
//        }else{
//            if ([globals.CURRENT_STRENGTH rangeOfString:@" VS "].location == NSNotFound) {
//                //if the strength ie: 4VS5
//                arrayOfStrength = [globals.CURRENT_STRENGTH componentsSeparatedByString:@"VS"];
//            }
//            else{
//                //if the strength ie: 4 VS 5
//                arrayOfStrength = [globals.CURRENT_STRENGTH componentsSeparatedByString:@" VS "];
//                
//            }
//        }
//
//        //if the globals.CURRENT_STRENGTH is some random value, then set the strength as default one
//        if (2<[[arrayOfStrength objectAtIndex:0]integerValue]<7) {
//             [self.homeSegControl setSelectedSegmentIndex:[globals.ARRAY_OF_POSS_PLAYERS indexOfObject:[arrayOfStrength objectAtIndex:0] ]];
//        }else{
//            [self.homeSegControl setSelectedSegmentIndex:2];
//        }
//       if (2<[[arrayOfStrength objectAtIndex:1]integerValue]<7) {
//            [self.awaySegControl setSelectedSegmentIndex:[globals.ARRAY_OF_POSS_PLAYERS indexOfObject:[arrayOfStrength objectAtIndex:1] ]];
//       }else{
//           [self.awaySegControl setSelectedSegmentIndex:2];
//       }
//        int homeValue = [[self.homeSegControl titleForSegmentAtIndex:[self.homeSegControl selectedSegmentIndex]]integerValue];
//        int awayValue = [[self.awaySegControl titleForSegmentAtIndex:[self.awaySegControl selectedSegmentIndex]]integerValue];
//        
//        [self updateStrengthLabelTintsWithAwayValue:awayValue andHomeValue:homeValue];
//        
//    }else{
////        //set the selected segment index for both home and away, then send action to value changed function once;
//        [self.homeSegControl setSelectedSegmentIndex:2];
//        [self.awaySegControl setSelectedSegmentIndex:2];
//        //if (globals.HAS_MIN) {
//            [self.homeSegControl sendActionsForControlEvents:UIControlEventValueChanged];
//        //}
//    }
//    
//    //highlight the button of the current forward line
//    
//    if(globals.CURRENT_F_LINE>=1){
//        ////////////NSLog(@"updateControlInfo current_f_line: %d, leftLineButtonWasSelected: %@,[leftLineButtonArr objectAtIndex:globals.CURRENT_F_LINE-1]: %@ ",globals.CURRENT_F_LINE,leftLineButtonWasSelected,[leftLineButtonArr objectAtIndex:globals.CURRENT_F_LINE-1]);
//        if (![leftLineButtonWasSelected isEqual:[leftLineButtonArr objectAtIndex:globals.CURRENT_F_LINE-1]]) {
//            if (leftLineButtonWasSelected) {
//                leftLineButtonWasSelected.selected = FALSE;
//            }
//            [[leftLineButtonArr objectAtIndex:globals.CURRENT_F_LINE-1] setSelected:TRUE];
//            leftLineButtonWasSelected = [leftLineButtonArr objectAtIndex:globals.CURRENT_F_LINE-1];
//            //update player box in bottom view according to the line changing
//            CustomButton *button = (CustomButton*)[leftLineButtonArr objectAtIndex:globals.CURRENT_F_LINE-1];
//            if (self.leftArrow.alpha == 1.0) {
//                
//                if(self.playerDrawerLeft)
//                {
//                    [self.playerDrawerLeft.view removeFromSuperview];
//                    self.playerDrawerLeft = nil;
//                    
//                    
//                }
//                
//                [UIView animateWithDuration:0.2
//                                 animations:^{
//                                     [self.leftArrow setAlpha:1.0f];
//                                     [self.leftArrow setFrame:CGRectMake(button.center.x-15, self.leftArrow.frame.origin.y, self.leftArrow.frame.size.width, self.leftArrow.frame.size.height)];
//                                 }
//                                 completion:^(BOOL finished){ }];
//                
//                self.playerDrawerLeft = [[ContentViewController alloc] initWithIndex:button.tag side:@"Forward"];
//                [self.playerDrawerLeft.view setBackgroundColor:[UIColor clearColor]];
//                [self.playerDrawerLeft.view.layer setBorderColor:PRIMARY_APP_COLOR.CGColor];
//                [self.playerDrawerLeft.view.layer setBorderWidth:1.0f];
//                [self.playerDrawerLeft.view setFrame:CGRectMake(45,CGRectGetMaxY(self.leftArrow.frame),300,110)];
//                [self.leftView addSubview:self.playerDrawerLeft.view];
//                
//                [self.leftArrow setAlpha:1.0f];
//                [self.playerDrawerLeft.view setAlpha:1.0f];
//                
//            }
//            
//        }
//        
//    }else {
//            leftLineButtonWasSelected = nil;
//            [[leftLineButtonArr objectAtIndex:0] sendActionsForControlEvents:UIControlEventTouchUpInside];
//
//    }
//    ////highlight the button of the current defense line
//    if(globals.CURRENT_D_LINE>= 1){
//        if (![rightLineButtonWasSelected isEqual:[rightLineButtonArr objectAtIndex:globals.CURRENT_D_LINE-1]]) {
//            if (rightLineButtonWasSelected) {
//                rightLineButtonWasSelected.selected = FALSE;
//            }
//            [[rightLineButtonArr objectAtIndex:globals.CURRENT_D_LINE-1] setSelected:TRUE];
//            rightLineButtonWasSelected = [rightLineButtonArr objectAtIndex:globals.CURRENT_D_LINE-1];
//            //update player box in bottom view according to the line changing
//            CustomButton *button = (CustomButton*)rightLineButtonWasSelected;
//            if (self.rightArrow.alpha == 1.0) {
//                if(self.playerDrawerRight)
//                {
//                    [self.playerDrawerRight .view removeFromSuperview];
//                    self.playerDrawerRight = nil;
//                    
//                    
//                }
//                [UIView animateWithDuration:0.2
//                                 animations:^{
//                                     [self.rightArrow setAlpha:1.0f];
//                                     [self.rightArrow setFrame:CGRectMake(button.center.x-15, self.rightArrow.frame.origin.y, self.rightArrow.frame.size.width, self.rightArrow.frame.size.height)];
//                                 }
//                                 completion:^(BOOL finished){ }];
//                
//                
//                self.playerDrawerRight = [[ContentViewController alloc] initWithIndex:button.tag side:@"Defense"];
//                [self.playerDrawerRight.view setBackgroundColor:[UIColor clearColor]];
//                [self.playerDrawerRight.view.layer setBorderColor:PRIMARY_APP_COLOR.CGColor];
//                [self.playerDrawerRight.view.layer setBorderWidth:1.0f];
//                [self.playerDrawerRight.view setFrame:CGRectMake(0,CGRectGetMaxY(self.rightArrow.frame),300,110)];
//                [self.rightView addSubview:self.playerDrawerRight.view];
//                
//                [self.rightArrow setAlpha:1.0f];
//                [self.playerDrawerRight.view setAlpha:1.0f];
//            }
//            
//        }
//    }
//    else{
//
//            rightLineButtonWasSelected = nil;
//            [[rightLineButtonArr objectAtIndex:0] sendActionsForControlEvents:UIControlEventTouchUpInside];
//        //}
//    }
//    
}

//we want to make sure the periods and lines are updated when the user is scrolling, the bottom view controller should always show the current
//state of the game at that specific time

//take the time thats passed in, do a binary search and find which period, line, strength, etc...

//we want to make sure the periods and lines are updated when the user is scrolling, the bottom view controller should always show the current
//state of the game at that specific time

//take the time thats passed in, do a binary search and find which period, line, strength, etc...

-(void)updateControlInfoWhileSeekingHockey
{
  
    
//    Float64 currentTime = [live2BenchViewController.videoPlayer currentTimeInSeconds];
//    NSString *tagTime= [NSString stringWithFormat:@"%.f",currentTime];
//    NSMutableArray *p = [[NSMutableArray alloc] initWithArray:[globals.DURATION_TYPE_TIMES objectForKey:@"8"]]; //will hold all the period times
//    if(globals.HAS_MIN &&[globals.DURATION_TYPE_TIMES objectForKey:@"7"] )
//    {
//        [p addObjectsFromArray:[globals.DURATION_TYPE_TIMES objectForKey:@"7"]];
//    }
//    
//    
//    NSMutableArray *o =[[NSMutableArray alloc] initWithArray:[globals.DURATION_TYPE_TIMES objectForKey:@"2"]]; //holds all the offensive line times
//    
//    if(globals.HAS_MIN &&[globals.DURATION_TYPE_TIMES objectForKey:@"1"] )
//    {
//        [o addObjectsFromArray:[globals.DURATION_TYPE_TIMES objectForKey:@"1"]];
//    }
//    
//    NSMutableArray *d =[[NSMutableArray alloc] initWithArray:[globals.DURATION_TYPE_TIMES objectForKey:@"6"]]; //holds all the defensive line times
//    
//    if(globals.HAS_MIN &&[globals.DURATION_TYPE_TIMES objectForKey:@"5"] )
//    {
//        [d addObjectsFromArray:[globals.DURATION_TYPE_TIMES objectForKey:@"5"]];
//    }
//    
//    NSMutableArray *s =[[NSMutableArray alloc] initWithArray:[globals.DURATION_TYPE_TIMES objectForKey:@"10"]]; //holds all the defensive line times
//    
//    if(globals.HAS_MIN &&[globals.DURATION_TYPE_TIMES objectForKey:@"9"] )
//    {
//        [s addObjectsFromArray:[globals.DURATION_TYPE_TIMES objectForKey:@"9"]];
//    }
//    
//    
//    NSString *closestPeriodTagTime=[self getClosestTagTime:tagTime withArray:p];
//    NSString *closestOLineTime=[self getClosestTagTime:tagTime withArray:o];
//    NSString *closestDLineTime=[self getClosestTagTime:tagTime withArray:d];
//    NSString *closestStrengthTime=[self getClosestTagTime:tagTime withArray:s];
//    
//    NSDictionary *timePeriodDict=[[NSDictionary alloc]initWithDictionary:[globals.DURATION_TAGS_TIME objectForKey:closestPeriodTagTime] ];
//    NSDictionary *timeOLineDict=[[NSDictionary alloc]initWithDictionary:[globals.DURATION_TAGS_TIME objectForKey:closestOLineTime] ];
//    NSDictionary *timeDLineDict=[[NSDictionary alloc]initWithDictionary:[globals.DURATION_TAGS_TIME objectForKey:closestDLineTime] ];
//    NSDictionary *timeStrengthDict=[[NSDictionary alloc]initWithDictionary:[globals.DURATION_TAGS_TIME objectForKey:closestStrengthTime] ];
//    
//    
//    globals.CURRENT_PERIOD=[uController extractIntFromStr:[timePeriodDict objectForKey:@"8"]] ? [uController extractIntFromStr:[timePeriodDict objectForKey:@"8"]] :[uController extractIntFromStr:[timePeriodDict objectForKey:@"7"] ];
////    //offline mode, if period 1 starts (globals.DURATION_TYPE_TIMES.count > 0), but not closed (no type 8 available), set to the default value
////    if (!globals.HAS_MIN && globals.CURRENT_PERIOD < 0 && globals.DURATION_TYPE_TIMES.count > 0 ) {
////        globals.CURRENT_PERIOD = 0;
////    }
//    globals.CURRENT_STRENGTH=[timeStrengthDict objectForKey:@"10"] ? [timeStrengthDict objectForKey:@"10"] :[timeStrengthDict objectForKey:@"9"];
//    globals.CURRENT_F_LINE=[uController extractIntFromStr:[timeOLineDict objectForKey:@"2"]] ? [uController extractIntFromStr:[timeOLineDict objectForKey:@"2"]] :[uController extractIntFromStr:[timeOLineDict objectForKey:@"1"] ];
//
//    globals.CURRENT_D_LINE=[uController extractIntFromStr:[timeDLineDict objectForKey:@"6"]] ? [uController extractIntFromStr:[timeDLineDict objectForKey:@"6"]] :[uController extractIntFromStr:[timeDLineDict objectForKey:@"5"] ];
////    //offline mode, if line_d_1 starts (globals.DURATION_TYPE_TIMES.count > 0), but not closed (no type 6 available), set to the default value
////    if (!globals.HAS_MIN && globals.CURRENT_D_LINE < 1 && globals.DURATION_TYPE_TIMES.count > 0) {
////        globals.CURRENT_D_LINE = 1;
////    }
//    
//    [self.periodSegmentedControl setSelectedSegmentIndex:globals.CURRENT_PERIOD];
//    
//    if (leftLineButtonWasSelected) {
//        leftLineButtonWasSelected.selected = FALSE;
//    }
//    //if the current offense line value is not valid, set it to 1
//    if (!globals.CURRENT_F_LINE || globals.CURRENT_F_LINE < 1) {
//        globals.CURRENT_F_LINE = 1;
//    }
//    [[leftLineButtonArr objectAtIndex:globals.CURRENT_F_LINE-1] setSelected:TRUE];
//    
//  
//    leftLineButtonWasSelected = [leftLineButtonArr objectAtIndex:globals.CURRENT_F_LINE-1];
//
//    if (rightLineButtonWasSelected) {
//        rightLineButtonWasSelected.selected = FALSE;
//    }
//    
//    //if the current defense line value is not valid, set it to 1
//    if (!globals.CURRENT_D_LINE || globals.CURRENT_D_LINE < 1) {
//        globals.CURRENT_D_LINE = 1;
//    }
//    [[rightLineButtonArr objectAtIndex:globals.CURRENT_D_LINE-1] setSelected:TRUE];
//   
//    rightLineButtonWasSelected = [rightLineButtonArr objectAtIndex:globals.CURRENT_D_LINE-1];
//
//    NSArray *arrayOfStrength;
//    
//    if ([globals.CURRENT_STRENGTH rangeOfString:@"VS"].location == NSNotFound) {
//        //if the strength ie: 4,5
//        arrayOfStrength = [globals.CURRENT_STRENGTH componentsSeparatedByString:@","];
//    }else{
//        if ([globals.CURRENT_STRENGTH rangeOfString:@" VS "].location == NSNotFound) {
//            //if the strength ie: 4VS5
//            arrayOfStrength = [globals.CURRENT_STRENGTH componentsSeparatedByString:@"VS"];
//        }
//        else{
//            //if the strength ie: 4 VS 5
//            arrayOfStrength = [globals.CURRENT_STRENGTH componentsSeparatedByString:@" VS "];
//            
//        }
//    }
//
//    //if the globals.CURRENT_STRENGTH is some random value, then set the strength as default one
//    if (2<[[arrayOfStrength objectAtIndex:0]integerValue]<7) {
//        [self.homeSegControl setSelectedSegmentIndex:[globals.ARRAY_OF_POSS_PLAYERS indexOfObject:[arrayOfStrength objectAtIndex:0] ]];
//    }else{
//        [self.homeSegControl setSelectedSegmentIndex:2];
//    }
//    if (2<[[arrayOfStrength objectAtIndex:1]integerValue]<7) {
//        [self.awaySegControl setSelectedSegmentIndex:[globals.ARRAY_OF_POSS_PLAYERS indexOfObject:[arrayOfStrength objectAtIndex:1] ]];
//    }else{
//        [self.awaySegControl setSelectedSegmentIndex:2];
//    }
//    int homeValue = [[self.homeSegControl titleForSegmentAtIndex:[self.homeSegControl selectedSegmentIndex]]integerValue];
//    int awayValue = [[self.awaySegControl titleForSegmentAtIndex:[self.awaySegControl selectedSegmentIndex]]integerValue];
//    
//    [self updateStrengthLabelTintsWithAwayValue:awayValue andHomeValue:homeValue];
//
}

-(NSString*)getClosestTagTime:(NSString*)tagTime withArray:(NSArray*)a
{
    NSMutableArray *t = [[NSMutableArray alloc] initWithArray:a];
    [t sortUsingComparator:^NSComparisonResult(NSString *str1, NSString *str2) {
        return [str1 compare:str2 options:(NSNumericSearch)];
    }];
    
    NSInteger sortedIndex;
    NSString *closestTagTime;
    if (t.count > 1) {
        NSInteger binSearchIndex =[t binarySearch:tagTime] ; // binsearch returns -1 if time not found
        binSearchIndex = binSearchIndex <0 ? 0:binSearchIndex; // make sure the binary search index is greater then 0
        
        sortedIndex= binSearchIndex >t.count-1 ? t.count-1 : binSearchIndex-1;
        sortedIndex= sortedIndex <0 ? 0:sortedIndex; //make sure index isn't less then 0
        
        closestTagTime = [t objectAtIndex:sortedIndex];
    }else if(t.count==1){
        closestTagTime = [t objectAtIndex:0];
    }
    return closestTagTime;
}


-(void)initLayout
{
    [self populateTagNames];
    
    
    //left line buttons
    for(int i=0;i<4;i++)
    {
        ////TODO: optimise button creation
        //left buttons
        BorderButton *leftLineButton = [BorderButton buttonWithType:UIButtonTypeCustom];
        [leftLineButton setFrame:CGRectMake((i*50.0f)+45.0f, self.periodSegmentedControl.frame.origin.y - 5.0f, 44.0f, 44.0f)];
        [leftLineButton setTitle:[NSString stringWithFormat:@"%d",(i+1)] forState:UIControlStateNormal];
        [leftLineButton addTarget:self action:@selector(buttonSelected:) forControlEvents:UIControlEventTouchUpInside];
        [leftLineButton addTarget:self action:@selector(buttonSwiped:) forControlEvents:UIControlEventTouchDragOutside];
        //[leftLineButton.titleLabel setShadowOffset:CGSizeMake(0, 0)];
        [leftLineButton setTag:i];
        //highlight the button of the current forward line
        //[leftLineButton setSelected:globals.CURRENT_F_LINE == (i+1)];

        [leftLineButton setAccessibilityLabel:@"left"];
        
        //No shadows = better performance
        [leftLineButton.layer setShadowColor:[[UIColor blackColor] CGColor]];
        [leftLineButton.layer setShadowOpacity:0.5f];
        [leftLineButton.layer setShadowRadius:1.0f];
        [leftLineButton.layer setShadowOffset:CGSizeMake(-1, 1)];
        
        [self.leftView addSubview:leftLineButton];
        if(i==0)
        {
            self.leftArrow = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"ortri.png"]];
            [self.leftArrow setFrame:CGRectMake(leftLineButton.center.x-15, CGRectGetMaxY(leftLineButton.frame), 25, 15)];
            [self.leftArrow setContentMode:UIViewContentModeScaleAspectFit];
            [self.leftArrow setAlpha:0.0f];
            [self.leftView addSubview:self.leftArrow];
        }
        
        //right buttons
        BorderButton *rightLineButton = [BorderButton buttonWithType:UIButtonTypeCustom];
        [rightLineButton setFrame:CGRectMake((i*50.0f)+105.0f, self.periodSegmentedControl.frame.origin.y - 5.0f, 44.0f, 44.0f)];
        [rightLineButton setTitle:[NSString stringWithFormat:@"%d",(i+1)] forState:UIControlStateNormal];
        [rightLineButton addTarget:self action:@selector(buttonSelected:) forControlEvents:UIControlEventTouchUpInside];
        [rightLineButton addTarget:self action:@selector(buttonSwiped:) forControlEvents:UIControlEventTouchDragOutside];
        [rightLineButton setTag:i];
        ////highlight the button of the current defense line
        //[rightLineButton setSelected:globals.CURRENT_D_LINE == (i+1)];
        [rightLineButton setAccessibilityLabel:@"right"];
         
         //No shadows = better performance
        [rightLineButton.layer setShadowColor:[[UIColor blackColor] CGColor]];
        [rightLineButton.layer setShadowOpacity:0.5f];
        [rightLineButton.layer setShadowRadius:1.0f];
        [rightLineButton.layer setShadowOffset:CGSizeMake(-1, 1)];
        
        [self.rightView addSubview:rightLineButton];
        
        //we only show triangle if they select a gbutton
        if(i==0)
        {
            self.rightArrow = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"ortri.png"]];
            [self.rightArrow setFrame:CGRectMake(leftLineButton.center.x-15, CGRectGetMaxY(leftLineButton.frame), 25, 15)];
            [self.rightArrow setContentMode:UIViewContentModeScaleAspectFit];
            [self.rightArrow setAlpha:0.0f];
            [self.rightView addSubview:self.rightArrow];
        }
        
        [leftLineButtonArr addObject:leftLineButton];
        [rightLineButtonArr addObject:rightLineButton];
        
    }
    
//    for(NSString *possPlayer in globals.ARRAY_OF_POSS_PLAYERS)
//    {
//        int i = [globals.ARRAY_OF_POSS_PLAYERS indexOfObject:possPlayer];
//        [self.homeSegControl setTitle:possPlayer forSegmentAtIndex:i];
//        [self.awaySegControl setTitle:possPlayer forSegmentAtIndex:i];
//    }
    
    strengthHomeLabel = [CustomLabel labelWithStyle:CLStyleWhite];
    strengthHomeLabel.frame = CGRectMake(self.periodSegmentedControl.frame.origin.x + 5.0f, self.homeSegControl.frame.origin.y, 30.0f, 30.0f);
    [strengthHomeLabel setText:@"H"];
    [strengthHomeLabel setFont:[UIFont regularFontOfSize:17.0f]];
    [strengthHomeLabel setTextAlignment:NSTextAlignmentCenter];
    [self.segmentControlView addSubview:strengthHomeLabel];
    
    strengthAwayLabel = [CustomLabel labelWithStyle:CLStyleWhite];
    strengthAwayLabel.frame = CGRectMake(strengthHomeLabel.frame.origin.x, self.awaySegControl.frame.origin.y, 30.0f, 30.0f);
    [strengthAwayLabel setText:@"A"];
    [strengthAwayLabel setFont:[UIFont regularFontOfSize:17.0f]];
    [strengthAwayLabel setTextAlignment:NSTextAlignmentCenter];
    [self.segmentControlView addSubview:strengthAwayLabel];
    
    CustomLabel *offenseLabel = [CustomLabel labelWithStyle:CLStyleBlack];
    offenseLabel.frame = CGRectMake(50.0f, 0.0f, 60.0f, 44.0f);
    offenseLabel.autoresizingMask = UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleBottomMargin;
    offenseLabel.textAlignment = NSTextAlignmentRight;
    [offenseLabel setText:@"Offense"];
    [self.leftView addSubview:offenseLabel];
    
    CustomLabel *defenseLabel = [CustomLabel labelWithStyle:CLStyleBlack];
    defenseLabel.frame = CGRectMake(110.0f, offenseLabel.frame.origin.y, 60.0f, 44.0f);
    [defenseLabel setText:@"Defense"];
    [self.rightView addSubview:defenseLabel];
}

- (void)buttonSelected:(id)sender{
       [[NSNotificationCenter defaultCenter ]postNotificationName:@"StopUpdate" object:nil];
    
//    CustomButton *button = (CustomButton*)sender;
//    NSString *name;
//    NSString *tagTime;
//    NSString *offlineType;
//    
//    int type=0;

//    if([button.accessibilityLabel isEqualToString:@"left"])
//    {
//        
//        if (globals.CURRENT_F_LINE == -1 ) {
//            tagTime = @"0.01";
//        }else{
//            //tagTime= [NSString stringWithFormat:@"%f",firstViewController.moviePlayer.currentPlaybackTime];
//            tagTime= [NSString stringWithFormat:@"%.f",[live2BenchViewController.videoPlayer currentTimeInSeconds]];
//        }
//        if (globals.CURRENT_F_LINE < 1) {
//            //first time press line button, create odd type tag, won't show up in clip view or list view
//            offlineType = @"1";
//        }else{
//             offlineType=@"2";
//        }
//       
//       name =[[@"line_" stringByAppendingString:@"f_"] stringByAppendingString:button.titleLabel.text];
//        [self.leftArrow setAlpha:0.0f];
//        [self.playerDrawerLeft.view setAlpha:0.0f];
//        
//        if ([leftLineButtonWasSelected isEqual:button]) {
//            return;
//        }
//        
//        if (leftLineButtonWasSelected) {
//            leftLineButtonWasSelected.selected = FALSE;
//        }
//        button.selected = TRUE;
//        leftLineButtonWasSelected = button;
//        globals.CURRENT_F_LINE = button.tag +1;
//        type = 1;
//        
//        
//    }else {
//        if (globals.CURRENT_D_LINE == -1) {
//            tagTime = @"0.01";
//        }else{
//            //tagTime= [NSString stringWithFormat:@"%f",live2BenchViewController.moviePlayer.currentPlaybackTime];
//            tagTime= [NSString stringWithFormat:@"%.f",[live2BenchViewController.videoPlayer currentTimeInSeconds]];
//        }
//        if (globals.CURRENT_D_LINE < 1) {
//            //first time press line button, create odd type tag, won't show up in clip view or list view
//            offlineType = @"5";
//        }else{
//             offlineType=@"6";
//        }
//       
//        name =[[@"line_" stringByAppendingString:@"d_"] stringByAppendingString:button.titleLabel.text];
//        [self.rightArrow setAlpha:0.0f];
//        [self.playerDrawerRight.view setAlpha:0.0f];
//        
//        if ([rightLineButtonWasSelected isEqual:button]) {
//            return;
//        }
//        
//        if (rightLineButtonWasSelected) {
//            rightLineButtonWasSelected.selected = FALSE;
//        }
//        button.selected = TRUE;
//        rightLineButtonWasSelected = button;
//        globals.CURRENT_D_LINE = button.tag +1;
//        type = 5;
//        
//    }
    
   
//    globals.DID_CREATE_NEW_TAG = TRUE;
//    dict = [[NSDictionary alloc]initWithObjectsAndKeys:globals.EVENT_NAME,@"event",name,@"name",[globals.ACCOUNT_INFO objectForKey:@"hid"],@"user",tagTime,@"time",[globals.ACCOUNT_INFO objectForKey:@"tagColour"],@"colour",name,@"line", [NSString stringWithFormat:@"%d",type],@"type", nil];//,nil];
//
//    if(globals.HAS_MIN)
//    {
//        [self sendTagInfo:dict];
//    }else{
//         //send dict to offlinedurtagoftype
//        
//        NSMutableDictionary *d = [[NSMutableDictionary alloc]initWithDictionary:dict];
//        [d setObject:[NSString stringWithFormat:@"%@_%@",offlineType,tagTime] forKey:@"id"];
//        NSUInteger dTotalSeconds = [tagTime floatValue];
//        NSUInteger dHours = floor(dTotalSeconds / 3600);
//        NSUInteger dMinutes = floor(dTotalSeconds % 3600 / 60);
//        NSUInteger dSeconds = floor(dTotalSeconds % 3600 % 60);
//        NSString *displayTime = [NSString stringWithFormat:@"%01i:%02i:%02i",dHours, dMinutes, dSeconds];
//        [d setObject:displayTime forKey:@"displaytime"];
//        [d setObject:offlineType forKey:@"type"];
//        [d setObject:@"1" forKey:@"own"];
//        [d setObject:@"1" forKey:@"local"];
//        [self createOfflineDurationTagOfType:offlineType withDict:d];
//
//    }
    
    
}

//we need to find the length of the duration tag -- will be from the beginning of this tag to either the end of the whole game of the beginning of the next tag
-(float)findTagDurationStarting:(float)startTime withType:(NSString*)type
{
    //check if there are any tags at all with this type -- if not, return duration of video - start time
    //if there are, and this is the last item in the index , return duration of video -start time
    //else return time of the tag after this one minus this tag time
//    
//    if(![globals.OFFLINE_DURATION_TAGS objectForKey:type])
//    {
//        if(live2BenchViewController.videoPlayer.durationInSeconds<startTime)
//        {
//            return 0.0f;
//        }
//        return  live2BenchViewController.videoPlayer.durationInSeconds-startTime;
//    }else {
//        int binIndex= [[globals.DURATION_TYPE_TIMES objectForKey:type] binarySearch:[NSNumber numberWithFloat:startTime]];
//        if(binIndex >= [[globals.DURATION_TYPE_TIMES objectForKey:type]count]-1)
//        {
//            return  live2BenchViewController.videoPlayer.durationInSeconds-startTime;
//        }else{
//            return [[[[globals.OFFLINE_DURATION_TAGS objectForKey:type] objectAtIndex:binIndex] objectForKey:@"time"] floatValue]-startTime;
//        }
//    }
    return 0;
}

- (void)addToGlobalDurations:(NSMutableDictionary *)nDict type:(NSString *)type
{
//    if([[nDict objectForKey:@"type" ] isEqualToString:@"0"]) //we don't care about normal tags, they don't have durations
//    {
//        return;
//    }
//    //we are going to save the duration tag to the global duration dictionary by key time
//    NSString *timeStr = [nDict objectForKey:@"time"]; //grab time
//    if(![[globals.DURATION_TAGS_TIME allKeys] containsObject:timeStr]) //if the duration dictionary doesn't already have this time then add it
//    {
//        //use the type value as the key, and the name value as the object in keyvalue pair
//        NSMutableDictionary *t = [[NSMutableDictionary alloc] initWithObjectsAndKeys:[nDict objectForKey:@"name"],[NSString stringWithFormat:@"%@",[nDict objectForKey:@"type"] ], nil];
//        [globals.DURATION_TAGS_TIME setObject: t forKey:timeStr]; // set the new dictionary to the global duration dict
//        ////NSLog(@"addtoglobalduration1 globals.DURATION_TAGS_TIME  %@",globals.DURATION_TAGS_TIME );
//    }else{ //if for some odd reason the time already exists as a key -- will probably only happen at the beginning of the game
//        NSMutableDictionary *t = [[NSMutableDictionary alloc]initWithDictionary:[globals.DURATION_TAGS_TIME objectForKey:timeStr]];
//        int typeInt = [type intValue];
//        NSString *typeStrStart = [NSString stringWithFormat:@"%d",typeInt-1];// string reprsentation of the starting tag for whatever tag you are on ... we want to make sure that it doesn't already exist at this time, and if it does we will delete it
//        if([[t allKeys]containsObject:typeStrStart])
//        {
//            [t removeObjectForKey:typeStrStart];
//        }
//        [t setObject:[nDict objectForKey:@"name"] forKey:[NSString stringWithFormat:@"%@",[nDict objectForKey:@"type"]]];
//        [globals.DURATION_TAGS_TIME setObject:t forKey:timeStr];// replace the old dictionary with the new one.
//        ////NSLog(@"addtoglobalduration2 globals.DURATION_TAGS_TIME  %@",globals.DURATION_TAGS_TIME );
//    }
//    
//    //// Now we put the time tagged into the global time array, but it has to be chronologically sorted
//    if([[globals.DURATION_TYPE_TIMES objectForKey:type] count]>0) // only use the sorting algorithm if there is something in the array
//    {
//        NSMutableArray *ty = [[NSMutableArray alloc]initWithArray:[globals.DURATION_TYPE_TIMES objectForKey:type]];
//        if(![ty containsObject:timeStr])
//        {
//            NSInteger *index = [ty binarySearch:timeStr];
//            index = (int)index > 0 ? index : 0;
//            [ty insertObject:timeStr atIndex:index];
//            [globals.DURATION_TYPE_TIMES setObject:ty forKey:type];
//        }
//        
//    }else{//otherwise just add the time to the array
//        NSMutableArray *ty = [[NSMutableArray alloc] initWithObjects:timeStr, nil];
//        [globals.DURATION_TYPE_TIMES setObject:ty forKey:type];
//    }
}

-(void)createOfflineDurationTagOfType:(NSString*)type withDict:(NSMutableDictionary*)nDict
{
    
    //if no min
    //grab the array of lines
    //take the last one in the index
    //update its duration
    //create current line, set it to the current line
    //set its duration from start time till end time
    //add it to the big array
//    if(globals.HAS_MIN)
//    {
//        return; //dont bother if there is min, we don't need this method
//    }else{
//        //check if there is anything in the dictionary with this type, if not then create it
//        //grab the time of the current tag
//        NSString* currentTime = [nDict objectForKey:@"time"];
//        
//        //if tag type does not exist or type is odd, do not create thumbnails
//        if(![globals.OFFLINE_DURATION_TAGS objectForKey:type] || [type intValue]&1)
//        {
//            //NSString* currentTime= [NSString stringWithFormat:@"%f",[live2BenchViewController.videoPlayer currentTimeInSeconds]];
//            [nDict setObject:type forKey:@"type"];
//            [nDict setObject:[NSNumber numberWithFloat:[self findTagDurationStarting:[currentTime floatValue] withType:type]] forKey:@"duration"];
//
//            NSMutableArray *t = [[NSMutableArray alloc] initWithObjects:nDict, nil];
//            [globals.OFFLINE_DURATION_TAGS setObject:t forKey:type];
//            
//            //for testing
//            [globals.OFFLINE_DURATION_TAGS setObject:t forKey:[NSString stringWithFormat:@"%d",[type intValue]+1]];
//            
//            //NSString *filePath = [[globals.EVENTS_PATH stringByAppendingPathComponent:globals.EVENT_NAME] stringByAppendingPathComponent:@"Thumbnails.plist"];
//            [self addToGlobalDurations:nDict type:type];
//            [self addToGlobalDurations:nDict type:[NSString stringWithFormat:@"%d",[type intValue]+1]];
//            //save tag information in global dictionary
//            [globals.CURRENT_EVENT_THUMBNAILS setObject:nDict forKey:[NSString stringWithFormat:@"%@",[nDict objectForKey:@"id"]]];
//            return;
//        }
//        
//        NSMutableArray *allTimes = [[NSMutableArray alloc] init]; //we'll store all of the duration tagtimes here of this type
//        for(NSMutableDictionary *d in [globals.OFFLINE_DURATION_TAGS objectForKey:type])
//        {
//            int i =[[globals.OFFLINE_DURATION_TAGS objectForKey:type] indexOfObject:d];
//            if(![allTimes containsObject:[d objectForKey:@"time"]])
//            {
//                if ([[d objectForKey:@"time"] isKindOfClass:[NSNumber class]]) {
//                    
//                    [allTimes addObject:[NSString stringWithFormat:@"%@",[d objectForKey:@"time"]]];
//                    
//                    [d setObject:[NSString stringWithFormat:@"%@",[d objectForKey:@"time"]] forKey:@"time"];
//                    [[globals.OFFLINE_DURATION_TAGS objectForKey:@"type"] replaceObjectAtIndex:i withObject:d];
//                }else{
//                    [allTimes addObject:[d objectForKey:@"time"]];//grab the tagtimes of all the tags and add them to the array
//                }
//            }
//        }
//        //sorting
//        [allTimes sortUsingComparator:^NSComparisonResult(NSString *str1, NSString *str2) {
//            return [str1 compare:str2 options:(NSNumericSearch)];
//        }];
//
//        //NSMutableArray *allTimesD = [[NSMutableArray alloc] init];
//        
//      
//       
//        NSArray *sortedArray;
//        sortedArray = [[globals.OFFLINE_DURATION_TAGS objectForKey:type] sortedArrayUsingComparator:(NSComparator)^(id a, id b) {
//            NSNumber *num1 =[ NSNumber numberWithFloat:[[a objectForKey:@"time"] floatValue]];
//            NSNumber *num2 = [ NSNumber numberWithFloat:[[b objectForKey:@"time"] floatValue]];
//            
//            return [num1 compare:num2];
//        }];
//        
//         NSMutableArray *allTimesD =(NSMutableArray*)[sortedArray mutableCopy];
//        int binIndex = [allTimes binarySearch:currentTime]; //binary search to find where this tag lies
//        
//        if (binIndex>allTimesD.count-1)
//        {
//            binIndex=allTimesD.count-1;
//        }
//        
//        if(binIndex<0)
//        {
//            binIndex=0;
//        }
//        
//        NSMutableDictionary *tdict = [[NSMutableDictionary alloc] initWithDictionary:[allTimesD objectAtIndex:binIndex]]; //grab dictionary for the tag previous to this one
//        
//        [tdict setObject:type forKey:@"type"];
//       // [tdict setObject:[NSNumber numberWithFloat:[self findTagDurationStarting:[[tdict objectForKey:@"time" ] floatValue] withType:type]] forKey:@"duration"];
//                //save tag information in global dictionary
//                //[globals.CURRENT_EVENT_THUMBNAILS setObject:tdict forKey:[NSString stringWithFormat:@"%@",[tdict objectForKey:@"id"]]];
//        NSString *duration = [NSString stringWithFormat:@"%d",(int)([currentTime floatValue]-[[tdict objectForKey:@"time"]floatValue])];
//        [tdict setObject:duration forKey:@"duration"];
//        //update the old dictionary
//        [[globals.OFFLINE_DURATION_TAGS objectForKey:type] replaceObjectAtIndex:binIndex withObject:tdict];
//        
//        if(!(binIndex==[[globals.OFFLINE_DURATION_TAGS objectForKey:type] count]-1))
//        {
//            [[globals.OFFLINE_DURATION_TAGS objectForKey:type] insertObject:nDict atIndex:binIndex+1];
//        }else{
//            [[globals.OFFLINE_DURATION_TAGS objectForKey:type] addObject:nDict];
//        }
//
//      
//        [self addToGlobalDurations:nDict type:type];
//        
//        NSString *filePath = [[globals.EVENTS_PATH stringByAppendingPathComponent:globals.EVENT_NAME] stringByAppendingPathComponent:@"Thumbnails.plist"];
//        NSString *imageName = [NSString stringWithFormat:@"%@.jpg",[tdict objectForKey:@"id"]];
//        NSString *imagePath = [globals.THUMBNAILS_PATH stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@",imageName]];
//        [tdict setObject:imagePath forKey:@"url"];
//        //save tag information in global dictionary
//        [globals.CURRENT_EVENT_THUMBNAILS setObject:tdict forKey:[NSString stringWithFormat:@"%@",[tdict objectForKey:@"id"]]];
//
//        [self restartUpdateTimerHockey];
//
//                //save the thumbnail image in local storage. This is running in the background thread
//                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,
//                                                        (unsigned long)NULL), ^(void) {
//                    BOOL isDir;
//                    if(![[NSFileManager defaultManager] fileExistsAtPath:globals.THUMBNAILS_PATH isDirectory:&isDir])
//                    {
//                        [[NSFileManager defaultManager] createDirectoryAtPath:globals.THUMBNAILS_PATH withIntermediateDirectories:YES attributes:nil error:NULL];
//                    }
//                    
//                    //create thumbnail using avfoundation and save it in the local dir
//                    NSURL *videoURL = live2BenchViewController.videoPlayer.videoURL;
//                    AVAsset *asset = [AVAsset assetWithURL:videoURL];
//                    AVAssetImageGenerator *imageGenerator = [[AVAssetImageGenerator alloc]initWithAsset:asset];
//                    [imageGenerator setMaximumSize:CGSizeMake(190, 106)];
//                    [imageGenerator setApertureMode:AVAssetImageGeneratorApertureModeProductionAperture];
//                    //CMTime time = [[dict objectForKey:@"cmtime"] CMTimeValue];//CMTimeMake(30, 1);
//                    CMTime time = CMTimeMakeWithSeconds([[tdict objectForKey:@"time"] floatValue], 1);
//                    CGImageRef imageRef = [imageGenerator copyCGImageAtTime:time actualTime:NULL error:NULL];
//                    UIImage *thumbnail = [UIImage imageWithCGImage:imageRef];
//                    CGImageRelease(imageRef);
//                    
//                    NSData *imageData = UIImageJPEGRepresentation(thumbnail, 0.5);
//                    if(![[NSFileManager defaultManager] fileExistsAtPath:filePath isDirectory:&isDir])
//                    {
//                        [[NSFileManager defaultManager] createFileAtPath:filePath contents:nil attributes:nil];
//                    }
//                    //add image to directory
//                    [imageData writeToFile:imagePath atomically:YES ];
//
//                    
//              });
//            }
}

- (void)buttonSwiped:(id)sender
{
    [updateSeekInfoHockeyTimer invalidate];
    updateSeekInfoHockeyTimer =nil;
    CustomButton *button = (CustomButton*)sender;
     NSString *name;

    if([button.accessibilityLabel isEqualToString:@"left"])
    {
        if(self.playerDrawerLeft)
        {
            [self.playerDrawerLeft.view removeFromSuperview];
            self.playerDrawerLeft = nil;
            
            
        }
        
        
        [UIView animateWithDuration:0.2
                         animations:^{
                             [self.leftArrow setAlpha:1.0f];
                             [self.leftArrow setFrame:CGRectMake(button.center.x-15, self.leftArrow.frame.origin.y, self.leftArrow.frame.size.width, self.leftArrow.frame.size.height)];
                         }
                         completion:^(BOOL finished){ }];
        
        self.playerDrawerLeft = [[ContentViewController alloc] initWithIndex:button.tag side:@"Forward"];
         //[self.playerDrawerLeft.view setBackgroundColor:[UIColor colorWithRed:224/255.0f green:229/255.0f blue:240/255.0f alpha:1.0f]];
        [self.playerDrawerLeft.view setBackgroundColor:[UIColor clearColor]];
        [self.playerDrawerLeft.view.layer setBorderColor:PRIMARY_APP_COLOR.CGColor];
        [self.playerDrawerLeft.view.layer setBorderWidth:1.0f];
        [self.playerDrawerLeft.view setFrame:CGRectMake(45,CGRectGetMaxY(self.leftArrow.frame),300,110)];

         [self.leftView addSubview:self.playerDrawerLeft.view];
        
        if ([leftLineButtonWasSelected isEqual:button]) {
            return;
        }
        
        [self.leftArrow setAlpha:1.0f];
        [self.playerDrawerLeft.view setAlpha:1.0f];
        
        name =[[@"line_" stringByAppendingString:@"f_"] stringByAppendingString:button.titleLabel.text];
        
        if (leftLineButtonWasSelected) {
            leftLineButtonWasSelected.selected = FALSE;
        }
        button.selected = TRUE;
        leftLineButtonWasSelected = button;
//        globals.CURRENT_F_LINE = button.tag +1;
        
    }else {
        if(self.playerDrawerRight)
        {
            [self.playerDrawerRight .view removeFromSuperview];
            self.playerDrawerRight = nil;
            
            
        }
        
        
        [UIView animateWithDuration:0.2
                         animations:^{
                             [self.rightArrow setAlpha:1.0f];
                             [self.rightArrow setFrame:CGRectMake(button.center.x-15, self.rightArrow.frame.origin.y, self.rightArrow.frame.size.width, self.rightArrow.frame.size.height)];
                         }
                         completion:^(BOOL finished){ }];
        
        
        self.playerDrawerRight = [[ContentViewController alloc] initWithIndex:button.tag side:@"Defense"];
        [self.playerDrawerRight.view setBackgroundColor:[UIColor clearColor]];
        [self.playerDrawerRight.view.layer setBorderColor:PRIMARY_APP_COLOR.CGColor];
        [self.playerDrawerRight.view.layer setBorderWidth:1.0f];
        [self.playerDrawerRight.view setFrame:CGRectMake(0,CGRectGetMaxY(self.rightArrow.frame),300,110)];

      
        [self.rightView addSubview:self.playerDrawerRight.view];
        [self.rightArrow setAlpha:1.0f];
        [self.playerDrawerRight.view setAlpha:1.0f];
        
        if ([rightLineButtonWasSelected isEqual:button]) {
            return;
        }
        
        name =[[@"line_" stringByAppendingString:@"d_"] stringByAppendingString:button.titleLabel.text];
        if (rightLineButtonWasSelected) {
            rightLineButtonWasSelected.selected = FALSE;
        }
        button.selected = TRUE;
        rightLineButtonWasSelected = button;
//        globals.CURRENT_D_LINE = button.tag +1;

    }
//    globals.DID_CREATE_NEW_TAG = TRUE;
//    NSString *tagTime= [NSString stringWithFormat:@"%.f",[live2BenchViewController.videoPlayer currentTimeInSeconds]];
//    dict = [[NSDictionary alloc]initWithObjectsAndKeys:globals.EVENT_NAME,@"event",name,@"name",[globals.ACCOUNT_INFO objectForKey:@"hid"],@"user",tagTime,@"time",[globals.ACCOUNT_INFO objectForKey:@"tagColour"],@"colour",name,@"line", @"1",@"type", nil];//,nil];
//    [self sendTagInfo:dict];
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
//    //[connection start];
}

-(void)sendTagInfo:(NSDictionary *)newDict{
    
//    if (!globals.HAS_MIN) {
//        return;
//    }
//    
//    NSError *error;
//    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:newDict options:0 error:&error];
//    NSString *jsonString;
//    if ( jsonData)
//    {
//        jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
//        jsonString = [jsonString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
//    }
//    NSString *url = [NSString stringWithFormat:@"%@/min/ajax/tagset/%@",globals.URL,jsonString];
//    
//    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
//    
//    [[NSURLConnection alloc] initWithRequest:urlRequest delegate:self];
//    
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    // A response has been received, this is where we initialize the instance var you created
    
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    
    if (data != nil) {
        if (responseData == nil){
            //            initialize responseData with first packet
            responseData = [NSMutableData dataWithData:data];
        }
        else{
            //            for multiple packets, the data should be appended
            [responseData appendData:data];
        }
    }

}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection
                  willCacheResponse:(NSCachedURLResponse*)cachedResponse {
    // Return nil to indicate not necessary to store a cached response for this connection
    return nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {

    id json;
    if(responseData)
    {
        json = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:nil];
        if ([[json objectForKey:@"success"]intValue] == 0 && [json objectForKey:@"msg"] ) {
            CustomAlertView *alert = [[CustomAlertView alloc]initWithTitle:@"myplayXplay" message:[json objectForKey:@"msg"] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
//            [globals.ARRAY_OF_POPUP_ALERT_VIEWS addObject:alert];
        }
//        if(!json){
//            NSString *foo = [[NSString alloc]initWithData:responseData encoding:NSASCIIStringEncoding];
//            NSLog(@"foo %@",foo);
//        }

    }

    responseData = nil;
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    
//    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"myplayXplay" message:@"Error in making tags." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
//    [alert show];
//    [globals.ARRAY_OF_POPUP_ALERT_VIEWS addObject:alert];
//    
}

-(void) nullFunction{
    
}

//create thumbnail images
-(void)handleNewThumbnail:(id)jsonArray
{

//    thumbId = [jsonArray objectForKey:@"id"];
//    //extract url from jsonarray
//    NSString *url = [jsonArray objectForKey:@"url"];
//    NSURL *jurl;
//    if (url != nil) {
//        jurl = [[NSURL alloc]initWithString:[jsonArray objectForKey:@"url"]];
//        NSMutableDictionary *thumbInfoSubDict = [jsonArray mutableCopy];
//        
//        //NSString *pathToThumbPlist = [[globals.EVENTS_PATH stringByAppendingPathComponent:globals.EVENT_NAME] stringByAppendingPathComponent:@"Thumbnails.plist"];
//        
//
//        NSString *imageName = [jurl lastPathComponent];
//       
//        [thumbInfoSubDict setObject:imageName forKey:@"imageName"];
//        
//        float tagTime = [[thumbInfoSubDict objectForKey:@"time"] floatValue];
//        //NSString *tagName = [thumbInfoSubDict objectForKey:@"name"];
//        UIColor *tagColour =[uController colorWithHexString:[thumbInfoSubDict objectForKey:@"colour"]];
//        //create tagmaker for this tag
////        [live2BenchViewController markTagAtTime:tagTime colour:tagColour tagID:[NSString stringWithFormat:@"%@",[thumbInfoSubDict objectForKey:@"id"]]];
//        //[live2BenchViewController markTag:tagTime colour:tagColour tagID:[NSString stringWithFormat:@"%@",[thumbInfoSubDict objectForKey:@"id"]]];
//        NSString *tagId = [NSString stringWithFormat:@"%@",[thumbInfoSubDict objectForKey:@"id"]];
//        //[globals.CURRENT_EVENT_THUMBNAILS addObject:thumbInfoSubDict];
//        [globals.CURRENT_EVENT_THUMBNAILS setObject:thumbInfoSubDict forKey:tagId];
//        
//        //create second thread to create the thumbnail
//        dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//            
//            NSData *imgData= [NSData dataWithContentsOfURL:jurl options:0 error:nil];
//           
//            
//            //get image name
//            
//            
//            NSError* error;
//            
//            //create thumbnail directory in documents directory
//            if(  [[NSFileManager defaultManager] createDirectoryAtPath:globals.THUMBNAILS_PATH withIntermediateDirectories:YES attributes:nil error:&error])
//            {
//
//            }
//                else
//            {
//
//                NSAssert( FALSE, @"Failed to create directory maybe out of disk space?");
//            }
//            
//            //add image to directory
//            NSString *filePath = [globals.THUMBNAILS_PATH stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@",imageName]];
//            
//            
//            
//            [imgData writeToFile:filePath atomically:NO ];
//            
//            dispatch_async( dispatch_get_main_queue(), ^{
//                //back to main thread
//
//                
//            });
//        });
//
//    }

}

- (void)updateArray:(NSMutableArray*)arr index:(int)i
{
    [arrayOfLines replaceObjectAtIndex:i withObject:arr];
}

- (void)populateTagNames
{
    NSString *path = [[NSBundle mainBundle] pathForResource:
                      @"ToolBarValues" ofType:@"plist"];
    // Build the array from the plist
    self.tagNames = [[NSMutableDictionary alloc] initWithContentsOfFile:path];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    if ([self.view window] == nil) self.view = nil;
    // Dispose of any resources that can be recreated.
}

//strength segment value(s) changed
- (void)segmentValueChanged:(id)sender {
//    [[NSNotificationCenter defaultCenter ]postNotificationName:@"StopUpdate" object:nil];
//    
//    //get the integer values of the current strengths (we need to compare)
//    
//    int homeIndex =self.homeSegControl.selectedSegmentIndex>=0 ?self.homeSegControl.selectedSegmentIndex:2  ;
//    int awayIndex =self.awaySegControl.selectedSegmentIndex>=0 ?self.awaySegControl.selectedSegmentIndex:2;
//    int homeValue = [[globals.ARRAY_OF_POSS_PLAYERS objectAtIndex:homeIndex] intValue];
//    int awayValue = [[globals.ARRAY_OF_POSS_PLAYERS objectAtIndex:awayIndex] intValue];
//    
//    //if i have more players the the other team then the H view is green, other wise it is red
//    [self updateStrengthLabelTintsWithAwayValue:awayValue andHomeValue:homeValue];
//    
//    NSString *tagTime;
//    if (!globals.CURRENT_STRENGTH) {
//        tagTime = @"0.01";
//    }else{
//        tagTime= [live2BenchViewController getCurrentTimeforNewTag];
//    }
//
//    ////NSLog(@"segmentvalue changed globals.CURRENT_STRENGTH: %@",globals.CURRENT_STRENGTH);
//    NSString *name = [NSString stringWithFormat:@"%d,%d",homeValue,awayValue];
//    
//    dict= [[NSDictionary alloc]initWithObjectsAndKeys:globals.EVENT_NAME,@"event",[NSString stringWithFormat:@"%d,%d",homeValue,awayValue],@"strength",name,@"name",[globals.ACCOUNT_INFO objectForKey:@"hid"],@"user",tagTime,@"time",[globals.ACCOUNT_INFO objectForKey:@"tagColour"],@"colour",@"9",@"type",nil];
//    if (globals.HAS_MIN) {
//         [self sendTagInfo:dict];
//    }else{
//        NSMutableDictionary *d = [[NSMutableDictionary alloc]initWithDictionary:dict];
//        [d setObject:[@"strength_" stringByAppendingString:tagTime] forKey:@"id"];
//        NSUInteger dTotalSeconds = [tagTime floatValue];
//        NSUInteger dHours = floor(dTotalSeconds / 3600);
//        NSUInteger dMinutes = floor(dTotalSeconds % 3600 / 60);
//        NSUInteger dSeconds = floor(dTotalSeconds % 3600 % 60);
//        NSString *displayTime = [NSString stringWithFormat:@"%01i:%02i:%02i",dHours, dMinutes, dSeconds];
//        [d setObject:displayTime forKey:@"displaytime"];
//        NSString *offlineType;
//        if (!globals.CURRENT_STRENGTH) {
//            //first time press strength buttons, create odd type tag, won't show up in clip view or list view
//            offlineType = @"9";
//        }else{
//            offlineType = @"10";
//        }
//        [d setObject:offlineType forKey:@"type"];
//        [d setObject:@"1" forKey:@"local"];
//        [self createOfflineDurationTagOfType:offlineType withDict:d];
//    }
//    
//    globals.CURRENT_STRENGTH=(NSMutableString*)[NSString stringWithFormat:@"%d,%d",homeValue,awayValue];
//    ////NSLog(@"segment value changed end part globals.CURRENT_STRENGTH: %@",globals.CURRENT_STRENGTH);
}
//select or change period button
- (void)periodSegmentValueChanged:(id)sender {
//    
//    [[NSNotificationCenter defaultCenter ]postNotificationName:@"StopUpdate" object:nil];
//    
//    NSString *tagTime;
//    if (globals.CURRENT_PERIOD == -1) {
//        tagTime = @"0.01";
//    }else{
//        tagTime= [live2BenchViewController getCurrentTimeforNewTag];
//    }
//    dict= [[NSDictionary alloc]initWithObjectsAndKeys:globals.EVENT_NAME,@"event",[NSString stringWithFormat:@"%d",[self.periodSegmentedControl selectedSegmentIndex]],@"name",[NSString stringWithFormat:@"%d",[self.periodSegmentedControl selectedSegmentIndex]],@"period",[globals.ACCOUNT_INFO objectForKey:@"hid"],@"user",tagTime,@"time",[globals.ACCOUNT_INFO objectForKey:@"tagColour"],@"colour",@"7",@"type",nil];
//    
//    if (globals.HAS_MIN) {
//         [self sendTagInfo:dict];
//    }else{
//        NSMutableDictionary *d = [[NSMutableDictionary alloc]initWithDictionary:dict];
//        [d setObject:[@"period_" stringByAppendingString:[dict objectForKey:@"time"]] forKey:@"id"];
//        NSString *offlineType;
//        if (globals.CURRENT_PERIOD < 0) {
//            //first time press period button, create odd type tag, won't show up in clip view or list view
//            offlineType = @"7";
//        }else{
//            offlineType = @"8";
//        }
//        [d setObject:offlineType forKey:@"type"];
//        [d setObject:@"1" forKey:@"own"];
//        [d setObject:@"1" forKey:@"local"];
//        [self createOfflineDurationTagOfType:offlineType withDict:d];
//    }
//    
//    globals.CURRENT_PERIOD = [self.periodSegmentedControl selectedSegmentIndex];
}

-(void)viewWillDisappear:(BOOL)animated{
    [self.leftArrow setAlpha:0.0f];
    [self.playerDrawerLeft.view setAlpha:0.0f];
    [self.rightArrow setAlpha:0.0f];
    [self.playerDrawerRight.view setAlpha:0.0f];
}*/
@end
