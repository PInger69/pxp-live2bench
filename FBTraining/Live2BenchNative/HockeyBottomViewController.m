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
    
    
    NSMutableArray *currentlyPostingTags;
    NSDictionary * periodDict;
    NSDictionary * periodDictRev;
}

@synthesize currentEvent = _currentEvent;
@synthesize videoPlayer = _videoPlayer;
@synthesize mainView  = _mainView;


-(id)init{
    self = [super init];
    
    if (self) {
        periodDict = @{
                       @"1":@"1",
                       @"2":@"2",
                       @"3":@"3",
                       @"OT":@"4",
                       @"PS":@"5"
                       };
        
        periodDictRev = @{
                          @"1":@"1",
                          @"2":@"2",
                          @"3":@"3",
                          @"4":@"OT",
                          @"5":@"PS"
                          };
        
        periodValueArray = @[@"1",@"2",@"3",@"OT",@"PS"];// check if this is still used
        
        self.view.frame = CGRectMake(0, 540, self.view.frame.size.width, self.view.frame.size.height);
        tintColor = PRIMARY_APP_COLOR;
        _mainView = self.view;
        currentlyPostingTags = [[NSMutableArray alloc]init];
        
        
        offenseButton = [[NSMutableDictionary alloc]init];
        defenseButton = [[NSMutableDictionary alloc]init];
        LeagueTeam *team = [UserCenter getInstance].taggingTeam;
        lineDic = [self populateLine:[team.players allValues]];
        playerList = [self populatePlayerList:[team.players allValues]] ;
        
        // Period Setup
        _periodLabel = [CustomLabel labelWithStyle:CLStyleBlack];
        _periodLabel.frame = CGRectMake(0.0f, 10.0f, 80.0f, 30.0f);
        [_periodLabel setText:@"Period"];
        
        
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
    NSMutableArray *array = [[NSMutableArray alloc]init];
    for (TeamPlayer *player in players) {
        [array addObject:player.jersey];
    }
    return [array copy];
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
                if ([name isEqualToString:@"0"])return @"0";
                int segment = [name intValue];
                segment = segment-1;
                NSString * nname = [NSString stringWithFormat:@"%ld",(long)segment ];
                return nname;
            }
        }
        
    }
    return @"0";
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

-(void)setCurrentEvent:(Event * __nullable)currentEvent{
    _currentEvent = currentEvent;
    [self clearCurrentlyPostingTags];
}
#pragma mark - Period Tags Related Methods
// Post period tag
-(void)periodSegmentValueChanged:(UISegmentedControl *)segment
{
    float time = CMTimeGetSeconds(_videoPlayer.currentTime);
    NSString *name = [periodValueArray objectAtIndex:_periodSegmentedControl.selectedSegmentIndex];
    
    if (periodDict[name]) {
        name = periodDict[name];
    }
    
    NSDictionary *tagDic = @{@"name":name,@"period":name, @"type":[NSNumber numberWithInteger:TagTypeHockeyPeriodStart],@"time":[NSString stringWithFormat:@"%f",time]};
    [currentlyPostingTags addObject:@{@"name":name,@"time":[NSNumber numberWithFloat:time],@"type":[NSNumber numberWithInteger:TagTypeHockeyPeriodStart]}];
    [super postTag:tagDic];
    
}

// Actually update the period segment
-(void)updatePeriodSegment{
    NSString *name = [self currentPeriod];
    NSInteger index = [periodValueArray indexOfObject:name];
    index =[periodDictRev[name] integerValue];
    index = [name integerValue];
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
    [currentlyPostingTags addObject:@{@"name":name,@"time":[NSNumber numberWithFloat:time],@"type":[NSNumber numberWithInteger:TagTypeHockeyStrengthStart]}];
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
        [currentlyPostingTags addObject:@{@"name":name,@"time":[NSNumber numberWithFloat:time],@"type":[NSNumber numberWithInteger:TagTypeHockeyStartOLine]}];
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
    
    
    CustomButton *button    = (CustomButton*)sender;
    NSArray *array = lineDic[@"offense"][button.titleLabel.text];
    if(array.count == 0) return;

    
    stopUpdateOffense = true;
    

    
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
        [currentlyPostingTags addObject:@{@"name":name,@"time":[NSNumber numberWithFloat:time],@"type":[NSNumber numberWithInteger:TagTypeHockeyStartDLine]}];
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
    CustomButton *button    = (CustomButton*)sender;
    NSArray *array          = lineDic[@"defense"][button.titleLabel.text];
    if(array.count == 0) return;
    
    stopUpdateDefense = true;
    
    
    
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
    
//    NSArray *array = lineDic[@"defense"][button.titleLabel.text];
    [_playerDrawerRight selectPlayers:array];
}

#pragma mark - Methods That Just Need To Be Here
-(void)setIsDurationVariable:(SideTagButtonModes)buttonMode{
    
}

-(void)closeAllOpenTagButtons{
    
}

-(void)allToggleOnOpenTags{
    
}

-(void)addData:(NSString *)type name:(NSString *)name{
    
}


@end
