//
//  RugbyBottomViewController.m
//  Live2BenchNative
//
//  Created by dev on 2015-07-27.
//  Copyright © 2015 DEV. All rights reserved.
//

#import "RugbyBottomViewController.h"
#import "CustomLabel.h"
#import "Tag.h"
#import "TeamPlayer.h"
#import "LeagueTeam.h"
#import "UserCenter.h"
#import "SideTagButton.h"
#import "BorderButton.h"
#define PLAYERBUTTON_X              190
#define PLAYERBUTTON_Y              100
#define PLAYERBUTTON_WIDTH           42
#define PADDING                      10
#define SUBSBUTTON_Y                160
#define SUBSLABEL_WIDTH              50


@implementation RugbyBottomViewController{
    
    CustomLabel *_zoneLabel;
    NSArray *zoneValueArray;
    NSString *currentZone;
    UISegmentedControl *_zoneSegmentedControl;
    
    CustomLabel *_halfLabel;
    NSArray *periodValueArray;
    UISegmentedControl *_periodSegmentedControl;
    
    CustomLabel *_subLabel;
    NSMutableArray *_cellList;
    NSArray *_playerList;
    
    id periodBoundaryObserver;
    UIColor *tintColor;
    
    NSMutableArray *currentlyPostingTags;
}

@synthesize currentEvent = _currentEvent;
@synthesize mainView = _mainView;

-(id)init{
    self = [super init];
    
    if (self) {
        
        self.view.frame = CGRectMake(0, 540, self.view.frame.size.width, self.view.frame.size.height);
        tintColor = PRIMARY_APP_COLOR;
        _cellList = [[NSMutableArray alloc]init];
        _mainView = self.view;
        currentlyPostingTags = [[NSMutableArray alloc]init];
        
        // Setup period Lable
        float halfLabelX = 80.0f;
        float periodSegmentY = 30;
        
        _halfLabel = [CustomLabel labelWithStyle:CLStyleBlack];
        _halfLabel.frame = CGRectMake(halfLabelX, 0, 80.0f, 30.0f);
        [_halfLabel setText:@"Half"];
        
        periodValueArray = @[@"1",@"2",@"EXTRA"];
        _periodSegmentedControl = [[UISegmentedControl alloc] initWithItems:periodValueArray];
        [_periodSegmentedControl setFrame:CGRectMake(_halfLabel.frame.origin.x, periodSegmentY, _periodSegmentedControl.numberOfSegments*80.0f, 30.0f)];
        [_periodSegmentedControl setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin];
        [_periodSegmentedControl addTarget:self action:@selector(halfValueChanged:) forControlEvents:UIControlEventValueChanged];
        
        
        // Base View
        UIView *segmentControlView = [[UIView alloc] initWithFrame:CGRectMake((self.view.frame.size.width - (_zoneSegmentedControl.numberOfSegments + _periodSegmentedControl.numberOfSegments + 1)*80.0f)/2, 20.0f, (_zoneSegmentedControl.numberOfSegments + _periodSegmentedControl.numberOfSegments + 1)*80.0f, 70.0f)];
        segmentControlView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        [self.view addSubview:segmentControlView];
        [segmentControlView addSubview:_zoneLabel];
        [segmentControlView addSubview:_zoneSegmentedControl];
        [segmentControlView addSubview:_halfLabel];
        [segmentControlView addSubview:_periodSegmentedControl];
        
        // Player
        LeagueTeam *team = [UserCenter getInstance].taggingTeam;
        _playerList = [self populatePlayerList:[team.players allValues]];
        _subLabel = [CustomLabel labelWithStyle:CLStyleGrey];
        [_subLabel setFrame:CGRectMake(187-SUBSLABEL_WIDTH, SUBSBUTTON_Y, SUBSLABEL_WIDTH, PLAYERBUTTON_WIDTH)];
        [_subLabel setText:@"Subs:"];
        [_subLabel setHidden:true];
        [self.view addSubview:_subLabel];
        [self createPlayerButton];
    }
    return self;
}


-(void)viewDidLoad
{
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(updatePeriodSegment) name:NOTIF_RICO_PLAYER_VIEW_CONTROLLER_UPDATE object:nil];
    
    [super viewDidLoad];
}

#pragma mark - Helper Methods
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
    
    // Look for the tags that are just posted but encoder haven't respond back
    for (NSDictionary *dict in currentlyPostingTags) {
        if ([[dict objectForKey:@"type"] intValue] == type | [[dict objectForKey:@"type"] intValue] == secondType) {
            timeDicUnordered[dict[@"time"]] = dict[@"name"];
        }
    }
    
    // sort the times from biggest to smallest
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


// Post tags at the very beginning of a new event
-(void)postTagsAtBeginning{
    if ([self getTags:TagTypeSoccerHalfStart secondType:TagTypeSoccerHalfStop].count == 0) {
        NSDictionary *dic = @{@"name":@"1",@"period":@"1",@"time":[NSString stringWithFormat:@"%f",0.0],@"type":[NSNumber numberWithInteger:TagTypeSoccerHalfStart]};
        _periodSegmentedControl.selectedSegmentIndex = 0;
        [super postTag:dic];
    }
}

// add observer so the period segment get updated
-(void)update{
    [self updatePeriodSegment];
    
    
    
//    __block RugbyBottomViewController *weakSelf = self;
//    periodBoundaryObserver = [_videoPlayer addPeriodicTimeObserverForInterval:CMTimeMake(1, 1) queue:NULL usingBlock:^(CMTime time){
//        [weakSelf updatePeriodSegment];
//    }];
}

// get Current Period
-(NSString *)currentPeriod{
    
    CMTime cTime = kCMTimeZero;
    if (self.delegate) {
        cTime = self.delegate.currentTime;
    }
    
    
    NSNumber *time = [NSNumber numberWithFloat:CMTimeGetSeconds(cTime)];
    NSArray *array = [self getTags:TagTypeSoccerHalfStart secondType:TagTypeSoccerHalfStop];
    
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

// when the encoder respond back and now have the just made tag,remove it from currentlyPostingTags array
-(void)clearCurrentlyPostingTags{
    if (currentlyPostingTags.count == 0) {
        return;
    }
    
    NSDictionary *toBeRemoved;
    for (NSDictionary *dict in currentlyPostingTags) {
        Tag *tag = [self checkTags:dict[@"name"]];
        if (tag.type == [dict[@"type"]intValue] && tag.time == [dict[@"time"] doubleValue]) {
            toBeRemoved = dict;
        }
    }
    [currentlyPostingTags removeObject:toBeRemoved];
}

-(void)clear
{

    [self clearCurrentlyPostingTags];
    [super clear];    
}

-(void)setCurrentEvent:(Event * __nullable)currentEvent{
    _currentEvent = currentEvent;
    [self enableButton];
    [self clearCurrentlyPostingTags];
}


#pragma mark - Half Tags Related Methods
// Post half tag
-(void)halfValueChanged:(UISegmentedControl *)segment{
    
    CMTime cTime = kCMTimeZero;
    if (self.delegate) {
        cTime = self.delegate.currentTime;
    }
    
    float time = CMTimeGetSeconds(cTime);
    NSString *name = [periodValueArray objectAtIndex:_periodSegmentedControl.selectedSegmentIndex];
    
    NSDictionary *tagDic = @{@"name":name,@"period":name, @"type":[NSNumber numberWithInteger:TagTypeSoccerHalfStart],@"time":[NSString stringWithFormat:@"%f",time]};
    [currentlyPostingTags addObject:@{@"name":name,@"time":[NSNumber numberWithFloat:time],@"type":[NSNumber numberWithInteger:TagTypeSoccerHalfStart]}];
    [super postTag:tagDic];
    
}

// Actually update the period segment
-(void)updatePeriodSegment{
    NSString *name = [self currentPeriod];
    NSInteger index = [periodValueArray indexOfObject:name];
    _periodSegmentedControl.selectedSegmentIndex = index;
}


#pragma mark - Player Button Related Methods
//Populate Player List with all Player jersey
-(NSArray*)populatePlayerList:(NSArray *)players{
    NSMutableArray *regularPlayer = [[NSMutableArray alloc]init];
    NSMutableArray *subPlayer = [[NSMutableArray alloc]init];
    for (TeamPlayer *player in players) {
        
        if ([player.role intValue] == 8) {
            [subPlayer addObject:player.jersey];
        }else{
            [regularPlayer addObject:player.jersey];
        }
        
    }
    
    NSArray *array = @[regularPlayer,subPlayer];
    
    return array;
}

// Create all player buttons
-(void)createPlayerButton{
    //players' buttons
    int playerCount=1;
    
    NSArray *regularPlayers = [_playerList objectAtIndex:0];
    NSArray *subPlayers = [_playerList objectAtIndex:1];
    
    //get all the non sub players count which will be used to center all the player buttons
    int notSubPlayersCount = (int)regularPlayers.count;
    float buttonWidth = 800/(notSubPlayersCount+5);
    
    for(NSString *jersey in regularPlayers)
    {
        float playerButtonY = (notSubPlayersCount == (notSubPlayersCount + subPlayers.count)) ? PLAYERBUTTON_Y + 25.0f : PLAYERBUTTON_Y;
        SideTagButton *playerButton = [[SideTagButton alloc]initWithFrame:CGRectMake((playerCount-1)*(buttonWidth+10)+(1024 - notSubPlayersCount*(buttonWidth+10) +10)/2.0, playerButtonY, buttonWidth, PLAYERBUTTON_WIDTH)];
        [playerButton setTitle:jersey forState:UIControlStateNormal];
        [playerButton setMode:SideTagButtonModeRegular];
        [playerButton addTarget:self action:@selector(playerButtonSelected:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:playerButton];
        [_cellList addObject:playerButton];
        playerCount++;
        
    }
    
    if (subPlayers.count != 0) {
        [_subLabel setHidden:false];
        
    }
    
    int count=1;
    for(NSString *jersey in subPlayers)
    {
        SideTagButton *subsButton = [[SideTagButton alloc]initWithFrame:CGRectMake(((count-1)*(buttonWidth+PADDING))+CGRectGetMaxX(_subLabel.frame), SUBSBUTTON_Y, buttonWidth, PLAYERBUTTON_WIDTH)];
        [subsButton setTitle:jersey forState:UIControlStateNormal];
        [subsButton setMode:SideTagButtonModeRegular];
        [subsButton addTarget:self action:@selector(playerButtonSelected:) forControlEvents:UIControlEventTouchUpInside];
        [_cellList addObject:subsButton];
        [self.view addSubview:subsButton];
        count++;
    }
    
}

// post tag(regular or duration) when player button is pressed
-(void)playerButtonSelected:(id)sender{
    
    CMTime cTime = kCMTimeZero;
    if (self.delegate) {
        cTime = self.delegate.currentTime;
    }
    
    
    float time = CMTimeGetSeconds(cTime);
    
    SideTagButton *button = sender;
    NSString *name = [NSString stringWithFormat:@"Pl. %@",button.titleLabel.text];
    
    if (button.mode == SideTagButtonModeRegular) {
        
        NSDictionary *tagDic = @{@"name":name,@"period":[self currentPeriod], @"type":[NSNumber numberWithInteger:TagTypeNormal],@"time":[NSString stringWithFormat:@"%f",time],@"player":@[button.titleLabel.text]};
        [super postTag:tagDic];
        
    }else if (button.mode == SideTagButtonModeToggle && !button.isOpen) {
        //Open Duration Tag
        [self disEnableButton];
        button.isOpen = YES;
        NSDictionary *tagDic = @{@"name":name,@"period":[self currentPeriod], @"type":[NSNumber numberWithInteger:TagTypeOpenDuration],@"time":[NSString stringWithFormat:@"%f",time],@"player":@[button.titleLabel.text],@"dtagid": button.durationID};
        [super postTag:tagDic];
        
    } else if (button.mode == SideTagButtonModeToggle && button.isOpen) {
        
        // Close Duration Tag, Collect and mod tag data for close tag
        Tag * tagToBeClosed;
        if ([Tag getOpenTagByDurationId:button.durationID]) {
            tagToBeClosed = [Tag getOpenTagByDurationId:button.durationID];
        }else{
            for (Tag *tag in _currentEvent.tags) {
                NSArray *words = [tag.name componentsSeparatedByString:@" "];
                if ([[words lastObject] isEqualToString:button.titleLabel.text] && tag.type == TagTypeOpenDuration) {
                    tagToBeClosed = tag;
                }
            }
        }
        
        NSMutableDictionary * tagData   = [NSMutableDictionary dictionaryWithDictionary:[tagToBeClosed makeTagData]];
        
        [tagData setValue:[NSString stringWithFormat:@"%f",time] forKey:@"closetime"];
        [tagData setValue:[NSNumber numberWithInteger:TagTypeCloseDuration] forKey:@"type"];
        [tagData setValue:button.durationID forKey:@"dtagid"];
        
        [self modifyTag:tagData];
        button.isOpen = NO;
        
    }
}

//set player button mode
-(void)setIsDurationVariable:(SideTagButtonModes)buttonMode{
    for (SideTagButton *button in _cellList) {
        [button setMode:buttonMode];
    }
}

// close all duration tags
-(void)closeAllOpenTagButtons
{
    for (SideTagButton * btn1 in _cellList){
        if (btn1.isOpen) {
            [btn1 sendActionsForControlEvents:UIControlEventTouchUpInside];
        }
    }
    
}

// diable user interaction for all the side button until we receive the open duration tag from the server
-(void)disEnableButton
{
    for (SideTagButton * btn1 in _cellList){
        if (btn1.mode == SideTagButtonModeToggle) {
            btn1.userInteractionEnabled = false;
        }
    }
    
}

// enable all the buttons again
-(void)enableButton
{
    for (SideTagButton * btn1 in _cellList){
        if (btn1.mode == SideTagButtonModeToggle) {
            btn1.userInteractionEnabled = true;
        }
    }
}

// hightlight any duration tag that is still open and is made on this device
-(void)allToggleOnOpenTags
{
    NSArray *eventTags = _currentEvent.tags;
    
    for (SideTagButton * btn1 in _cellList) {
        btn1.isOpen = NO;
    }
    
    for (Tag * tag in eventTags) {
        //NSCharacterSet *filters = [[NSCharacterSet alloc]ini]
        NSArray *words = [tag.name componentsSeparatedByString:@" "];
        
        //NSArray *words = [tag.name componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"."]];
        for (SideTagButton * btn2 in _cellList) {
            // if the tag is open and has a duration Id and is from this divice
            if ([[words lastObject] isEqualToString:btn2.titleLabel.text] && tag.type == TagTypeOpenDuration && [tag.deviceID isEqualToString:[[[UIDevice currentDevice] identifierForVendor]UUIDString]]){
                btn2.isOpen = YES;
                btn2.durationID = tag.durationID;
            }
        }
    }
}

#pragma mark - Methods That Needs To Be Here
-(void)addData:(NSString *)type name:(NSString *)name{
    
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}
@end
