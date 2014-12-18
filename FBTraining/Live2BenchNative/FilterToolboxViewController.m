
//
//  FilterToolboxViewController.m
//  Live2BenchNative
//
//  Created by DEV on 2013-02-11.
//  Copyright (c) 2013 DEV. All rights reserved.
//

//#default			= 0
//
//#deleted			= 3 - this one shouldn't happen on tagSet
//#telestration 		= 4
//
//#start o-line     	= 1 - hockey
//#stop o-line     	= 2 - hockey
//#start d-line		= 5 - hockey
//#stop  d-line		= 6 - hockey
//#period start		= 7 - hockey
//#period	stop		= 8 - hockey
//#opp. o-line start 	= 11 - hockey
//#opp. o-line stop 	= 12- hockey
//#opp. d-line start 	= 13- hockey
//#opp. d-line stop 	= 14- hockey
//#strength start 	= 9- hockey
//#strength stop 		= 10- hockey
//
//#half start 		= 17- soccer
//#half stop 			= 18- soccer
//#zone start 		= 15- soccer
//#zone stop 			= 16- soccer
//
//#down start 		= 19- football
//#down stop 			= 20- football
//#quarter start 		= 21- football
//#quarter stop 		= 22- football


#import "FilterToolboxViewController.h"


#define ROWS_IN_EVENTS                 6
#define ROWS_IN_PLAYERS                6
#define USER_BUTTON_CONTAINER_WIDTH  200

@interface FilterToolboxViewController ()


@end

@implementation FilterToolboxViewController

@synthesize collectionView=_collectionView;
@synthesize typesOfTags,periodorHalfLabel,strengthLabel;
@synthesize taggedAttsDict;
@synthesize selectedFilters;
@synthesize eventsView=_eventsView;

//NEW UI
@synthesize vertDivider,horzDivider,playerView,linePeriodView,usersView,shiftButtons,eventsandPlayerButtons,eventFilterTitleButton,shiftFilterTitleButton,shiftlineHorzDivider,strengthCoachPickButtons,taggedAttsDictShift,viewdidAppeared,taggedButtonDictShift,strengthDivider,taggedButtonArr,offLineandZoneLabel,periodHalfLabel,defLineLabel,selectedButtonsforSoccer,coachPickButtonSoccer,filterTitleSoccer,hockeyZoneLabel;

- (id)initWithArgs:(NSDictionary *)args;
{
    self = [super init];
    if (self) {
        superArgs=args;
        lbController = [superArgs objectForKey:@"controller"];
        return self;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    globals=[Globals instance];
    uController=[[UtilitiesController alloc]init];
    [self setupView];
    
    //save all the buttons and labels in SHIFT/LINE FILTERING TAB, when switch filter Tabs, set all the object in this array to be hidden
    shiftButtons = [[NSMutableArray alloc]init];
    //save all the events and player buttons in EVENT FILTERING TAB, when switch filter Tabs, set all the object in this array to be hidden
    eventsandPlayerButtons = [[NSMutableArray alloc]init];
    //this dictionary is used in SHIFT/LINE FILTERING TAB to record the selected buttons seperately according which section(strength/coach pick/shift line)
    //the button belongs to
    taggedButtonDictShift = [[NSMutableDictionary alloc] init];
    //this dictionary is used  to save all the selected button in EVENT FITERING TAB, when switch filter tab, clear all the selected buttons
    taggedButtonArr = [[NSMutableArray alloc]init];
    
    selectedFilters = [[NSMutableArray alloc]init]; //array of the actual buttons that have been selected -- to be used for unselecting all
    displayArray= [[NSMutableArray alloc]init]; //array of which thumbnails survive the filtering
    taggedAttsDict = [[NSMutableDictionary alloc]init]; // dictionary containg which attributes user wants to filter by in the events window
    taggedAttsDictShift = [[NSMutableDictionary alloc]init];// dictionary containing which attributies user watns to filter in the shift window
    
    ///hides and creates different labels for the bottom view depending on what sport it is (Quarter vs period, etc.)
    
    //for medical testing
    if([globals.WHICH_SPORT isEqualToString:@"soccer"] ||[globals.WHICH_SPORT isEqualToString:@"rugby"]|| [[globals.WHICH_SPORT lowercaseString] isEqualToString:@"medical"] || [globals.WHICH_SPORT isEqualToString:@""])
    {
        [filterTitleSoccer setHidden:FALSE];
        [eventFilterTitleButton setHidden:TRUE];
        [shiftFilterTitleButton setHidden:TRUE];
        [offLineandZoneLabel setText:@"ZONE"];
        [defLineLabel setHidden:TRUE];
        [periodHalfLabel setHidden:TRUE];
        [hockeyZoneLabel setHidden:TRUE];
        //[self createSoccerPlayerTags];
        if ([globals.WHICH_SPORT isEqualToString:@"soccer"]) {
            [self createZoneTags];
            [offLineandZoneLabel setText:@"ZONE"];
        }else{
            [offLineandZoneLabel setHidden:TRUE];
        }
        [self createSoccerHalfTags];
    }else{//for hockey and football
        [filterTitleSoccer setHidden:TRUE];
        [eventFilterTitleButton setHidden:FALSE];
        [shiftFilterTitleButton setHidden:FALSE];
        [periodHalfLabel setHidden:FALSE];
        
        //[self createPlayerTags];
        if ([globals.WHICH_SPORT isEqualToString:@"hockey"]) {
            [self createLinesTags];
            [offLineandZoneLabel setText:@"OFF."];
            [defLineLabel setHidden:FALSE];
            [hockeyZoneLabel setHidden:FALSE];
            [periodHalfLabel setText:@"P/H"];
        }else if([globals.WHICH_SPORT isEqualToString:@"football"]){
            [offLineandZoneLabel setHidden:TRUE];
            [defLineLabel setHidden:TRUE];
            [hockeyZoneLabel setHidden:TRUE];
            [periodHalfLabel setText:@"Q."];
            [self createDownTags];
            [self footballTypeTagsEventFilter];
        }
        [self createPeriodTags];
        [self createStrengthandShiftTags];
    }
    ////////////////////////////////////////////////////////////////////////
}


//now we need to set up the filter tool box itself -- includes adding all the dividers between sections, labels, and the uiviews that will
//hold the filter buttons

-(void)setupView
{
    //background -- chose to just make it a light grey colour to mesh with the rest of the app -- hex value e6e6e6
    UIView *bgview = [[UIView alloc] init];
    [bgview setFrame:CGRectMake(0.0f, 44.0f, self.view.bounds.size.width, self.view.bounds.size.height - 44.0f)];
    [bgview setAutoresizingMask:UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth];
    [bgview setBackgroundColor:[uController colorWithHexString:@"e6e6e6"]];
    
    [self.view addSubview:bgview];
    
    //all the dividers in between the different views , makes it look purty//////////////////////////////////////
    strengthDivider = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"divider"]];
    [strengthDivider setFrame:CGRectMake(330.0f, bgview.frame.origin.y, 3.0f, 200.0f)];
    [strengthDivider setAutoresizingMask:UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleBottomMargin];
    [self.view addSubview:strengthDivider];
    
    vertDivider = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"divider"]];
    [vertDivider setFrame:CGRectMake(510.0f, bgview.frame.origin.y, 3.0f, 200.0f)];
    [vertDivider setAutoresizingMask:UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleBottomMargin];
    [self.view addSubview:vertDivider];
    
    shiftlineHorzDivider = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Line"]];
    [shiftlineHorzDivider setFrame:CGRectMake(0.0f, 95.0f, bgview.bounds.size.width, 3.0f)];
    [shiftlineHorzDivider setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleBottomMargin];
    [self.view addSubview:shiftlineHorzDivider];
    
    horzDivider = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Line"]];
    [horzDivider setFrame:CGRectMake(0.0f, 285.0f, bgview.bounds.size.width, 3.0f)];
    [horzDivider setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleBottomMargin];
    [self.view addSubview:horzDivider];
    ////////////////////////////////////////////////Dividers end/////////////////////////////////////////////////////////
    
    linePeriodView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, CGRectGetMaxY(horzDivider.frame) +40 , 660.0f, bgview.bounds.size.height - CGRectGetMaxY(horzDivider.frame) - 15.0f)];
    [linePeriodView setAutoresizingMask:UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleHeight];
    [linePeriodView setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:linePeriodView];
    
    offLineandZoneLabel = [[UILabel alloc] initWithFrame:CGRectMake(15.0f, 0.0f, 40.0f, 30.0f)];
    [offLineandZoneLabel setAutoresizingMask:UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleBottomMargin];
    [offLineandZoneLabel setText:@"OFF."];
    [offLineandZoneLabel setTextAlignment:NSTextAlignmentRight];
    [offLineandZoneLabel setTextColor:[UIColor darkGrayColor]];
    [offLineandZoneLabel setBackgroundColor:[UIColor clearColor]];
    [offLineandZoneLabel setFont:[UIFont systemFontOfSize:13.0f]];
    [linePeriodView addSubview:offLineandZoneLabel];
    
    defLineLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(offLineandZoneLabel.frame) + 130.0f, offLineandZoneLabel.frame.origin.y, 30.0f, 30.0f)];
    [defLineLabel setAutoresizingMask:UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleBottomMargin];
    [defLineLabel setText:@"DEF."];
    [defLineLabel setTextColor:[UIColor darkGrayColor]];
    [defLineLabel setBackgroundColor:[UIColor clearColor]];
    [defLineLabel setFont:[UIFont systemFontOfSize:13.0f]];
    [linePeriodView addSubview:defLineLabel];
    
    periodHalfLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(defLineLabel.frame) + 130.0f, defLineLabel.frame.origin.y, 30.0f, 30.0f)];
    [periodHalfLabel setAutoresizingMask:UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleBottomMargin];
    [periodHalfLabel setText:@"P/H"];
    [periodHalfLabel setTextColor:[UIColor darkGrayColor]];
    [periodHalfLabel setBackgroundColor:[UIColor clearColor]];
    [periodHalfLabel setFont:[UIFont systemFontOfSize:13.0f]];
    [linePeriodView addSubview:periodHalfLabel];
    
    hockeyZoneLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(periodHalfLabel.frame) + 150.0f, periodHalfLabel.frame.origin.y, 40.0f, 30.0f)];
    [hockeyZoneLabel setAutoresizingMask:UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleBottomMargin];
    [hockeyZoneLabel setText:@"ZONE"];
    [hockeyZoneLabel setTextColor:[UIColor darkGrayColor]];
    [hockeyZoneLabel setBackgroundColor:[UIColor clearColor]];
    [hockeyZoneLabel setFont:[UIFont systemFontOfSize:13.0f]];
    [linePeriodView addSubview:hockeyZoneLabel];
    
    usersView = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(linePeriodView.frame), linePeriodView.frame.origin.y-25, bgview.bounds.size.width - CGRectGetMaxX(linePeriodView.frame)-10, bgview.bounds.size.height - CGRectGetMaxY(horzDivider.frame) +20)];
    [usersView setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
    [usersView setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:usersView];
    
    UILabel *usersLabel = [[UILabel alloc] initWithFrame:CGRectMake(40.0f, hockeyZoneLabel.frame.origin.y-20, 40.0f, 30.0f)];
    [usersLabel setAutoresizingMask:UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleBottomMargin];
    [usersLabel setText:@"USER"];
    [usersLabel setTextColor:[UIColor darkGrayColor]];
    [usersLabel setBackgroundColor:[UIColor clearColor]];
    [usersLabel setFont:[UIFont systemFontOfSize:13.0f]];
    [usersView addSubview:usersLabel];
    
    numTagsLabel = [[UILabel alloc] initWithFrame:CGRectMake(usersView.bounds.size.width-105.0f, usersLabel.frame.origin.y - 3.0f, 100.0f, 30.0f)];
    [numTagsLabel setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleBottomMargin];
    [numTagsLabel setText:@"Tags"];
    [numTagsLabel setTextColor:[UIColor darkGrayColor]];
    [numTagsLabel setBackgroundColor:[UIColor clearColor]];
    [numTagsLabel setTextAlignment:NSTextAlignmentRight];
    [numTagsLabel setFont:[UIFont systemFontOfSize:17.0f]];
    [usersView addSubview:numTagsLabel];
    
    //these are the buttons that are used for the tabs at the top of the filter toolbox
    shiftFilterTitleButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [shiftFilterTitleButton setBackgroundImage:[UIImage imageNamed:@"shiftline_filter_unselected"] forState:UIControlStateNormal];
    [shiftFilterTitleButton setFrame:CGRectMake(bgview.bounds.size.width - 200.0f, 10.0f, 180.0f, 44.0f)];
    [shiftFilterTitleButton setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleBottomMargin];
    [shiftFilterTitleButton addTarget:self action:@selector(shiftLineFilter:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:shiftFilterTitleButton];
    
    eventFilterTitleButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [eventFilterTitleButton setBackgroundImage:[UIImage imageNamed:@"event_filter_unselected"] forState:UIControlStateNormal];
    [eventFilterTitleButton setFrame:CGRectMake(shiftFilterTitleButton.frame.origin.x - 162.0f, 10.0f, 180.0f, 44.0f)];
    [eventFilterTitleButton setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleBottomMargin];
//    [eventFilterTitleButton addTarget:self action:@selector(eventsFilter:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:eventFilterTitleButton];
    
    filterTitleSoccer = [UIButton buttonWithType:UIButtonTypeCustom];
    [filterTitleSoccer setBackgroundImage:[UIImage imageNamed:@"event_filter_unselected"] forState:UIControlStateNormal];
    [filterTitleSoccer setFrame:shiftFilterTitleButton.frame];
    [filterTitleSoccer setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleBottomMargin];
   // [filterTitleSoccer addTarget:self action:@selector(swipeFilter:) forControlEvents:UIControlEventTouchDragInside];
    [filterTitleSoccer setUserInteractionEnabled:FALSE];
    [self.view addSubview:filterTitleSoccer];
    /////////////////////////////////////////////////////////////////////////////////////////////////////////
    
    self.eventsView = [[UIScrollView alloc] initWithFrame:CGRectMake(5.0f, bgview.frame.origin.y, 500.0f, 240.0f)];
    [self.eventsView setAutoresizingMask:UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleBottomMargin];
    [self.eventsView setDelegate:self];
    [self.view addSubview:self.eventsView];
    
    playerView = [[UIScrollView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.eventsView.frame) + 5.0f, bgview.frame.origin.y, bgview.bounds.size.width - CGRectGetMaxX(self.eventsView.frame) - 10.0f, self.eventsView.bounds.size.height)];
    [playerView setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleBottomMargin];
    [playerView setDelegate:self];
    [self.view addSubview:self.playerView];

}


-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    //viewDidAppear function will be called twice, the event tags and colour tags will be created when the function is called in the second time
    //this function will be called, each time when deselecting a button in the filter
    //if (viewdidAppeared) {
    [self createEventTags];
    [self createColourTags];
    [numTagsLabel setText:[NSString stringWithFormat:@"%d Tags", globals.THUMBNAIL_COUNT_REF_ARRAY.count]];
    [self.view setNeedsDisplay];
  
    if([globals.WHICH_SPORT isEqualToString:@"soccer"] || [globals.WHICH_SPORT isEqualToString:@"rugby"])
    {
        [self createSoccerPlayerTags];
    }else if([globals.WHICH_SPORT isEqualToString:@"hockey"]){
        [self createPlayerTags];
    }
    
    [self createClearAll]; //makes the 'clear all ' button, so lonely
    
    viewdidAppeared = FALSE;
    if(globals.TAGGED_ATTS_DICT.count != 0 && globals.TAGGED_ATTS_DICT != nil){
        [self.taggedAttsDict setDictionary:globals.TAGGED_ATTS_DICT];
        [self sortAllClipsWithAttributes];
        
    }
    if(globals.TAGGED_ATTS_DICT_SHIFT.count != 0 && globals.TAGGED_ATTS_DICT_SHIFT != nil){
        [self.taggedAttsDictShift setDictionary:globals.TAGGED_ATTS_DICT_SHIFT];
        [self sortAllClipsBySelectingforShiftFiltering ];
    }
    
    //display right button image for different sport
    if ([globals.WHICH_SPORT isEqualToString:@"hockey"]) {
        [shiftFilterTitleButton setBackgroundImage:[UIImage imageNamed:@"shiftline_filter_unselected.png"] forState:UIControlStateNormal];
    }else if([globals.WHICH_SPORT isEqualToString:@"football"]){
        [shiftFilterTitleButton setBackgroundImage:[UIImage imageNamed:@"shiftdown_filter_unselected.png"] forState:UIControlStateNormal];
    }
    //by default, the events filter is selected
    if ((globals.TAGGED_ATTS_DICT.count == 0 && globals.TAGGED_ATTS_DICT_SHIFT.count == 0)||globals.TAGGED_ATTS_DICT.count > 0) {
         [eventFilterTitleButton sendActionsForControlEvents:UIControlEventTouchUpInside];
    }else if(globals.TAGGED_ATTS_DICT_SHIFT.count > 0){
        [shiftFilterTitleButton sendActionsForControlEvents:UIControlEventTouchUpInside];
    }
   
}

//update the tag numbers in filter view
-(void)updateDisplayedTagsCount{
    [numTagsLabel setText:[NSString stringWithFormat:@"%d Tags", globals.THUMBNAIL_COUNT_REF_ARRAY.count]];
}

//for both soccer and hockey
-(void)createColourTags
{
    NSMutableArray *tempTaggedArr = taggedButtonArr;
    //clearing user colour buttons
    for(UIView *vw in usersView.subviews)
    {
        if(![vw isKindOfClass:[UILabel class]]){
            if ([tempTaggedArr containsObject:vw]) {
                [tempTaggedArr removeObject:vw];
            }
            [vw removeFromSuperview];
        }
    }
    
    for (NSString *colour in globals.ARRAY_OF_COLOURS)
    {
        int i = [globals.ARRAY_OF_COLOURS indexOfObject:colour];
        float bWidth = USER_BUTTON_CONTAINER_WIDTH/globals.ARRAY_OF_COLOURS.count;
        CustomButton *cButton = [CustomButton buttonWithType:UIButtonTypeCustom];
        // [cButton setFrame:CGRectMake(i*bWidth, 0, bWidth, coloursContainer.frame.size.height)];
        [cButton setFrame:CGRectMake(i*bWidth + 50 , 5, bWidth-6, 40)];
        [cButton setBackgroundColor:[uController colorWithHexString:colour]];
        [cButton setTitle:colour forState:UIControlStateNormal];
        [cButton setTitleColor:[UIColor clearColor] forState:UIControlStateNormal];
        [cButton setAccessibilityLabel:@"colours"];
        [cButton addTarget:self action:@selector(cellSelected:) forControlEvents:UIControlEventTouchUpInside];
        [cButton setAlpha:0.1f];
        
        BOOL doesContainColour = [[globals.TAGGED_ATTS_DICT objectForKey:@"colours"] containsObject:colour];
        [cButton setSelected:doesContainColour];
        if (doesContainColour){
            [cButton setAlpha:1.0f];
            [taggedButtonArr addObject:cButton];
        }
        [self.usersView addSubview:cButton];
    }
    
    
}
- (void)didReceiveMemoryWarning
{
    globals.DID_RECEIVE_MEMORY_WARNING = TRUE;
    [super didReceiveMemoryWarning];
    if ([self.view window] == nil) self.view = nil;
    // Dispose of any resources that can be recreated.
}

//for both soccer and hockey
-(void)createEventTags
{
    return;
    //if events buttons need to be updated, delete the old buttons then recreate new events buttons
    NSMutableArray *tempButtonArr = [eventsandPlayerButtons mutableCopy];
    NSMutableArray *tempTaggedButtonArr = [taggedButtonArr mutableCopy];
    for(UIButton *button in tempButtonArr){
        
        if([button.accessibilityLabel isEqualToString:@"events"]){
            [eventsandPlayerButtons removeObject:button];
            if ([tempTaggedButtonArr containsObject:button]) {
                [taggedButtonArr removeObject:button];
            }
            [button removeFromSuperview];
        }
        
    }
    
    //NSMutableArray *typeofTagsArr = [[globals.TYPES_OF_TAGS objectAtIndex:0] mutableCopy];
    NSArray *sortedArray = [[globals.TYPES_OF_TAGS objectAtIndex:0] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    ////NSLog(@"sorted Array %@; globals.TYPES_OF_TAGS %@",sortedArray,globals.TYPES_OF_TAGS);
    for(NSString *eventName in sortedArray)
    {
        int i = [sortedArray indexOfObject:eventName];
        //int i = [typeofTagsArr indexOfObject:eventName];
        int colNum = ceil(i/ROWS_IN_EVENTS);
        
        int rowNum = (i+1)%ROWS_IN_EVENTS>0 ? (i+1)%ROWS_IN_EVENTS : ROWS_IN_EVENTS;
        // //
        CustomButton *eventButton = [CustomButton buttonWithType:UIButtonTypeCustom];
        //[eventButton setFrame:CGRectMake((colNum * 83)-60, (rowNum*28)+2, 80, 25)];
        [eventButton setFrame:CGRectMake((colNum * 123)+10, (rowNum*28)+ 30, 120, 25)];
        [eventButton setBackgroundImage:[UIImage imageNamed:@"line-button-grey.png"] forState:UIControlStateNormal];
        [eventButton setBackgroundImage:[UIImage imageNamed:@"num-button.png"] forState:UIControlStateSelected];
        [eventButton addTarget:self action:@selector(cellSelected:) forControlEvents:UIControlEventTouchUpInside];
        [eventButton setTitle:eventName forState:UIControlStateNormal];
        [eventButton setAccessibilityLabel:@"events"];
        [eventButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [eventButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateSelected];
        eventButton.titleLabel.font=[UIFont systemFontOfSize:14.0f];
        [self.eventsView addSubview:eventButton];
        
        //selects the buttons that are selected already
        BOOL doesContainEvent = [[globals.TAGGED_ATTS_DICT objectForKey:@"events"] containsObject:eventName];
        [eventButton setSelected:doesContainEvent];
        if (doesContainEvent){
            [taggedButtonArr addObject:eventButton];
        }
        
        [eventsandPlayerButtons addObject:eventButton];
    }
    
    
    if ([[globals.TAGGED_ATTS_DICT objectForKey:@"events"] count] > 0){
        NSArray *eventsArray = [[globals.TAGGED_ATTS_DICT objectForKey:@"events"] copy];
        for (NSString *name in eventsArray){
            if (![sortedArray containsObject:name] && ![name isEqualToString:@"telestration"]){
                [[globals.TAGGED_ATTS_DICT objectForKey:@"events"] removeObject:name];
            }
        }
        if ([[globals.TAGGED_ATTS_DICT objectForKey:@"events"] count] == 0){
            [globals.TAGGED_ATTS_DICT removeObjectForKey:@"events"];
        }
    }
    
    
    
    [self.eventsView setContentSize:CGSizeMake(ceil((float)[[globals.TYPES_OF_TAGS objectAtIndex:0] count]/ROWS_IN_EVENTS)*123, self.eventsView.frame.size.height)];
}

-(void)createSoccerPlayerTags
{
    //if player buttons need to be updated, delete the old buttons then recreate new player buttons
    NSMutableArray *tempButtonArr = [eventsandPlayerButtons mutableCopy];
    NSMutableArray *tempTaggedButtonArr = [taggedButtonArr mutableCopy];
    for(UIButton *button in tempButtonArr){
        
        if([button.accessibilityLabel isEqualToString:@"players"]){
            [eventsandPlayerButtons removeObject:button];
            if ([tempTaggedButtonArr containsObject:button]) {
                [taggedButtonArr removeObject:button];
            }
            [button removeFromSuperview];
        }
        
    }
    
    NSMutableArray *intArray = [NSMutableArray arrayWithCapacity:1];
    for (NSString *player in [globals.TYPES_OF_TAGS objectAtIndex:3]){
        [intArray addObject:[NSNumber numberWithInt:[player intValue]]];
    }
    
    NSArray *sortedArray = [intArray sortedArrayUsingSelector:@selector(compare:)];
    for(NSNumber *player in sortedArray)
    {
        NSString *playerString = [NSString stringWithFormat:@"%@",player];
        int i = [sortedArray indexOfObject:player];
        //int i=0;
        // for(NSString *player in globals.ARRAY_OF_SOCCER_PLAYERS){
        int colNum = ceil(i/ROWS_IN_PLAYERS);
        int rowNum = (i+1)%ROWS_IN_PLAYERS>0 ? (i+1)%ROWS_IN_PLAYERS : ROWS_IN_PLAYERS;
        CustomButton *pButton = [CustomButton buttonWithType:UIButtonTypeCustom];
        [pButton setFrame:CGRectMake((colNum * 83)+10, (rowNum*28)+ 30, 80, 25)];
        
        
        [pButton setBackgroundImage:[UIImage imageNamed:@"line-button-grey.png"] forState:UIControlStateNormal];
        [pButton setBackgroundImage:[UIImage imageNamed:@"num-button.png"] forState:UIControlStateSelected];
        [pButton setAccessibilityLabel:@"players"];
        [pButton addTarget:self action:@selector(cellSelected:) forControlEvents:UIControlEventTouchUpInside];
        [pButton setTitle:playerString forState:UIControlStateNormal];
        [pButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [pButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateSelected];
        pButton.titleLabel.font=[UIFont systemFontOfSize:14.0f];
        
        BOOL doesContainPlayer = [[globals.TAGGED_ATTS_DICT objectForKey:@"players"] containsObject:playerString];
        [pButton setSelected:doesContainPlayer];
        if (doesContainPlayer){
            [taggedButtonArr addObject:pButton];
        }
        
        [eventsandPlayerButtons addObject:pButton];
        [self.playerView addSubview:pButton];
        //i++;
    }
    
    if ([[globals.TAGGED_ATTS_DICT objectForKey:@"players"] count] > 0){
        NSArray *playerArray = [[globals.TAGGED_ATTS_DICT objectForKey:@"players"] copy];
        for (NSString *name in playerArray){
            if (![sortedArray containsObject:[NSNumber numberWithInt:[name integerValue]]]){
                [[globals.TAGGED_ATTS_DICT objectForKey:@"players"] removeObject:name];
            }
        }
        if ([[globals.TAGGED_ATTS_DICT objectForKey:@"players"] count] == 0){
            [globals.TAGGED_ATTS_DICT removeObjectForKey:@"players"];
        }
    }
    
    if(ceil([[globals.TYPES_OF_TAGS objectAtIndex:3] count]/ROWS_IN_PLAYERS) <7){
        [self.playerView setContentSize:CGSizeMake(self.playerView.frame.size.width, 200)];
    }else{
        [self.playerView setContentSize:CGSizeMake(self.playerView.frame.size.width+ (ceil(globals.ARRAY_OF_HOCKEY_PLAYERS.count/ROWS_IN_PLAYERS)-5)*83, 200)];
    }
    
    
}

//for soccer zone tags
-(void)createZoneTags{
    //(i*28)+60, offLineandZoneLabel.frame.origin.y, 22, 23
    int i = 0;
    //buttons for off
    for(NSString *zone in globals.ARRAY_OF_ZONES){
        CustomButton *zoneButton = [CustomButton buttonWithType:UIButtonTypeCustom];
        [zoneButton setFrame:CGRectMake((i*70)+60,hockeyZoneLabel.frame.origin.y, 64, 25)];
        [zoneButton setBackgroundImage:[UIImage imageNamed:@"line-button-grey.png"] forState:UIControlStateNormal];
        [zoneButton setBackgroundImage:[UIImage imageNamed:@"num-button.png"] forState:UIControlStateSelected];
        [zoneButton addTarget:self action:@selector(cellSelected:) forControlEvents:UIControlEventTouchUpInside];
        [zoneButton setAccessibilityLabel:@"zone"];
        [zoneButton setTitle:zone forState:UIControlStateNormal];
        [zoneButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [zoneButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateSelected];
        zoneButton.titleLabel.font=[UIFont systemFontOfSize:14.0f];
        [zoneButton setTag:i+1];
        i++;
        
        BOOL doesContainZone = [[globals.TAGGED_ATTS_DICT objectForKey:@"zone"] containsObject:zone];
        [zoneButton setSelected:doesContainZone];
        if (doesContainZone){
            [taggedButtonArr addObject:zoneButton];
        }
        
        [self.linePeriodView addSubview:zoneButton];
    }
}
//soccer half tags and soccer coach pick button
-(void)createSoccerHalfTags
{
    UILabel *halfLabel = [[UILabel alloc]initWithFrame:CGRectMake(280, hockeyZoneLabel.frame.origin.y, 40, 30)];
    [halfLabel setText:@"HALF"];
    [halfLabel setTextColor:[UIColor darkGrayColor]];
    [halfLabel setFont:[UIFont systemFontOfSize:13.0f]];
    [halfLabel setBackgroundColor:[UIColor clearColor]];
    [self.linePeriodView addSubview:halfLabel];
    for(NSString *prd in globals.ARRAY_OF_PERIODS)
    {
        int i = [globals.ARRAY_OF_PERIODS indexOfObject:prd];
        CustomButton *perButton = [CustomButton buttonWithType:UIButtonTypeCustom];
        [perButton setFrame:CGRectMake(320+(i*56), halfLabel.frame.origin.y, 50, 25)];
        [perButton setBackgroundImage:[UIImage imageNamed:@"line-button-grey.png"] forState:UIControlStateNormal];
        [perButton setBackgroundImage:[UIImage imageNamed:@"num-button.png"] forState:UIControlStateSelected];
        [perButton setAccessibilityLabel:@"half"];
        [perButton addTarget:self action:@selector(cellSelected:) forControlEvents:UIControlEventTouchUpInside];
        [perButton setTitle:prd forState:UIControlStateNormal];
        [perButton setTag:i];
        [perButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [perButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateSelected];
        perButton.titleLabel.font=[UIFont systemFontOfSize:14.0f];
        
        BOOL doesContainHalf = [[globals.TAGGED_ATTS_DICT objectForKey:@"half"] containsObject:[NSString stringWithFormat:@"%d",perButton.tag]];
        [perButton setSelected:doesContainHalf];
        if (doesContainHalf){
            [taggedButtonArr addObject:perButton];
            //            if ([globals.WHICH_SPORT isEqualToString:@"soccer"])
            //            {
            //                [selectedButtonsforSoccer addObject:perButton];
            //            }
        }
        [self.linePeriodView addSubview:perButton];
    }
    //Coach pick button for soccer
    coachPickButtonSoccer = [CustomButton buttonWithType:UIButtonTypeCustom];
    [coachPickButtonSoccer setFrame:CGRectMake(550, hockeyZoneLabel.frame.origin.y, 75, 25)];
    [coachPickButtonSoccer setBackgroundImage:[UIImage imageNamed:@"line-button-grey.png"] forState:UIControlStateNormal];
    [coachPickButtonSoccer setBackgroundImage:[UIImage imageNamed:@"num-button.png"] forState:UIControlStateSelected];
    [coachPickButtonSoccer setAccessibilityLabel:@"coachpick"];
    [coachPickButtonSoccer addTarget:self action:@selector(cellSelected:) forControlEvents:UIControlEventTouchUpInside];
    [coachPickButtonSoccer setTitle:@"Coach Pick" forState:UIControlStateNormal];
    [coachPickButtonSoccer setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [coachPickButtonSoccer setTitleColor:[UIColor darkGrayColor] forState:UIControlStateSelected];
    coachPickButtonSoccer.titleLabel.font=[UIFont systemFontOfSize:14.0f];
    
    BOOL doesContainCoach = [[globals.TAGGED_ATTS_DICT objectForKey:@"coachpick"] containsObject:[NSString stringWithFormat:@"%d",1]];//[[globals.TAGGED_ATTS_DICT_SHIFT objectForKey:@"coachpick"]count] >0;
    if (doesContainCoach){
        [taggedButtonArr addObject:coachPickButtonSoccer];
    }
    [coachPickButtonSoccer setSelected:doesContainCoach];
    [self.linePeriodView addSubview:coachPickButtonSoccer];
}

-(void)createClearAll
{
    CustomButton *clearAll = [CustomButton buttonWithType:UIButtonTypeCustom];
    [clearAll setFrame:CGRectMake(self.view.frame.size.width-70, 60, 60, 25)];
    [clearAll setBackgroundImage:[UIImage imageNamed:@"line-button-grey.png"] forState:UIControlStateNormal];
    [clearAll setBackgroundImage:[UIImage imageNamed:@"num-button.png"] forState:UIControlStateSelected];
    [clearAll setAccessibilityLabel:@"allclear"];
    [clearAll addTarget:self action:@selector(clearAllTags:) forControlEvents:UIControlEventTouchUpInside];
    [clearAll setTitle:@"clear all" forState:UIControlStateNormal];
    [clearAll setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [clearAll setTitleColor:[UIColor darkGrayColor] forState:UIControlStateSelected];
    clearAll.titleLabel.font=[UIFont systemFontOfSize:14.0f];
    //[shiftButtons addObject:clearAll];
    //[clearAll setHidden:TRUE];
    [self.view addSubview:clearAll];
}

-(void)clearAllTags:(id)sender
{
    [self clearShiftFilter];
    [self clearEventFilter];
    [self sortAllClipsWithAttributes];
}

//#TODO:fix this crap -- why is there so many if statements?
-(void)clearShiftFilter{
    if ([[taggedButtonDictShift allKeys] count]>0){
        if ([taggedButtonDictShift objectForKey:@"shiftline"]){
            for(CustomButton *button in [taggedButtonDictShift objectForKey:@"shiftline"])
            {
                [button setSelected:FALSE];
            }
        }
        if ([taggedButtonDictShift objectForKey:@"strength"]){
            for(CustomButton *button in [taggedButtonDictShift objectForKey:@"strength"])
            {
                [button setSelected:FALSE];
            }
        }
        
        if ([taggedButtonDictShift objectForKey:@"distance"]){
            for(CustomButton *button in [taggedButtonDictShift objectForKey:@"distance"])
            {
                [button setSelected:FALSE];
            }
        }
        
        if ([taggedButtonDictShift objectForKey:@"allstrength"]){
            for(CustomButton *button in [taggedButtonDictShift objectForKey:@"allstrength"])
            {
                [button setSelected:FALSE];
            }
        }
        if ([[taggedAttsDictShift objectForKey:@"homestr"]count]>0){
            
            for(CustomButton *button in [taggedButtonDictShift objectForKey:@"homestr"])
            {
                [button setSelected:FALSE];
            }
        }
        if ([[taggedAttsDictShift objectForKey:@"awaystr"]count]>0){
            
            for(CustomButton *button in [taggedButtonDictShift objectForKey:@"awaystr"])
            {
                [button setSelected:FALSE];
            }
        }
        if ([[taggedAttsDictShift objectForKey:@"awaystr"]count]>0){
            
            for(CustomButton *button in [taggedButtonDictShift objectForKey:@"allstrength"])
            {
                [button setSelected:FALSE];
            }
        }
        if ([taggedAttsDictShift objectForKey:@"coachpick"]){
            
            for(CustomButton *button in [taggedButtonDictShift objectForKey:@"coachpick"])
            {
                [button setSelected:FALSE];
            }
        }
        
        if ([taggedAttsDictShift objectForKey:@"posgain"]){
            
            for(CustomButton *button in [taggedButtonDictShift objectForKey:@"gain"])
            {
                [button setSelected:FALSE];
            }
        }
        
        if ([taggedAttsDictShift objectForKey:@"neggain"]){
            
            for(CustomButton *button in [taggedButtonDictShift objectForKey:@"gain"])
            {
                [button setSelected:FALSE];
            }
        }

    }
    
    [taggedAttsDictShift removeAllObjects];
    [globals.TAGGED_ATTS_DICT_SHIFT removeAllObjects];
}

-(void)clearEventFilter{
    
    for(CustomButton *button in taggedButtonArr)
    {
        if ([button.accessibilityLabel isEqualToString:@"colours"]){
            [button setAlpha:0.1f];
        } //else {
        [button setSelected:FALSE];
        //}
    }
    [taggedButtonArr removeAllObjects];
    [taggedAttsDict removeAllObjects];
    [globals.TAGGED_ATTS_DICT removeAllObjects];
    
}
//hockey player
-(void)createPlayerTags
{
    //if player buttons need to be updated, delete the old buttons then recreate new player buttons
    NSMutableArray *tempButtonArr = [eventsandPlayerButtons mutableCopy];
    NSMutableArray *tempTaggedButtonArr = [taggedButtonArr mutableCopy];
    for(UIButton *button in tempButtonArr){
        
        if([button.accessibilityLabel isEqualToString:@"players"]){
            [eventsandPlayerButtons removeObject:button];
            if ([tempTaggedButtonArr containsObject:button]) {
                [taggedButtonArr removeObject:button];
            }
            [button removeFromSuperview];
        }
        
    }
    NSMutableArray *intArray = [NSMutableArray arrayWithCapacity:1];
    for (NSString *player in [globals.TYPES_OF_TAGS objectAtIndex:3]){
        [intArray addObject:[NSNumber numberWithInt:[player intValue]]];
    }
    //[globals.TYPES_OF_TAGS objectAtIndex:3]
    NSArray *sortedArray = [intArray sortedArrayUsingSelector:@selector(compare:)];
    for(NSNumber *player in sortedArray)
    {
        int i = [sortedArray indexOfObject:player];
        int colNum = ceil(i/ROWS_IN_PLAYERS);
        int rowNum = (i+1)%ROWS_IN_PLAYERS>0 ? (i+1)%ROWS_IN_PLAYERS : ROWS_IN_PLAYERS;
        CustomButton *pButton = [CustomButton buttonWithType:UIButtonTypeCustom];
        [pButton setFrame:CGRectMake((colNum * 83)+10, (rowNum*28)+ 30, 80, 25)];
        
        
        [pButton setBackgroundImage:[UIImage imageNamed:@"line-button-grey.png"] forState:UIControlStateNormal];
        [pButton setBackgroundImage:[UIImage imageNamed:@"num-button.png"] forState:UIControlStateSelected];
        [pButton setAccessibilityLabel:@"players"];
        [pButton addTarget:self action:@selector(cellSelected:) forControlEvents:UIControlEventTouchUpInside];
        
        NSString* playerString = [NSString stringWithFormat:@"%@",player];
        [pButton setTitle:playerString forState:UIControlStateNormal];
        [pButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [pButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateSelected];
        [pButton.titleLabel setFont:[UIFont systemFontOfSize:14.0f]];
        
        BOOL doesContainPlayers = [[globals.TAGGED_ATTS_DICT objectForKey:@"players"] containsObject:playerString];
        [pButton setSelected:doesContainPlayers];
        if (doesContainPlayers){
            [taggedButtonArr addObject:pButton];
        }
        [eventsandPlayerButtons addObject:pButton];
        [self.playerView addSubview:pButton];
        //i++;
    }
    
    if ([[globals.TAGGED_ATTS_DICT objectForKey:@"players"] count] > 0){
        NSArray *playerArray = [[globals.TAGGED_ATTS_DICT objectForKey:@"players"] copy];
        for (NSString *name in playerArray){
            if (![sortedArray containsObject:[NSNumber numberWithInteger:[name integerValue]]]){
                [[globals.TAGGED_ATTS_DICT objectForKey:@"players"] removeObject:name];
            }
        }
        if ([[globals.TAGGED_ATTS_DICT objectForKey:@"players"] count] == 0){
            [globals.TAGGED_ATTS_DICT removeObjectForKey:@"players"];
        }
    }
    if(ceil(globals.ARRAY_OF_HOCKEY_PLAYERS.count/ROWS_IN_PLAYERS) <7){
        [self.playerView setContentSize:CGSizeMake(self.playerView.frame.size.width, 200)];
    }else{
        [self.playerView setContentSize:CGSizeMake(self.playerView.frame.size.width+ (ceil(globals.ARRAY_OF_HOCKEY_PLAYERS.count/ROWS_IN_PLAYERS)-5)*83, 200)];
    }
    
    
}
//for hockey line tags
-(void)createLinesTags{
    [offLineandZoneLabel setText:@"OFF."];
    [defLineLabel setHidden:FALSE];
    int i = 0;
    //buttons for off
    for(NSString *line in globals.ARRAY_OF_LINES){
        CustomButton *lineButton = [CustomButton buttonWithType:UIButtonTypeCustom];
        [lineButton setFrame:CGRectMake((i*28)+60, offLineandZoneLabel.frame.origin.y, 22, 23)];
        [lineButton setBackgroundImage:[UIImage imageNamed:@"line-button-grey.png"] forState:UIControlStateNormal];
        [lineButton setBackgroundImage:[UIImage imageNamed:@"num-button.png"] forState:UIControlStateSelected];
        [lineButton addTarget:self action:@selector(cellSelected:) forControlEvents:UIControlEventTouchUpInside];
        [lineButton setAccessibilityLabel:@"offline"];
        [lineButton setTitle:line forState:UIControlStateNormal];
        [lineButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [lineButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateSelected];
        lineButton.titleLabel.font=[UIFont systemFontOfSize:14.0f];
        [lineButton setUserInteractionEnabled:TRUE];
        [lineButton setTag:i+1];
        i++;
        BOOL doesContainOffLine = [[globals.TAGGED_ATTS_DICT objectForKey:@"offline"] containsObject:[NSString stringWithFormat:@"line_f_%d",lineButton.tag]];
        [lineButton setSelected:doesContainOffLine];
        if (doesContainOffLine){
            [taggedButtonArr addObject:lineButton];
        }
        [self.linePeriodView addSubview:lineButton];
    }
    i = 0;
    //buttons for def
    for(NSString *line in globals.ARRAY_OF_LINES){
        CustomButton *lineButton = [CustomButton buttonWithType:UIButtonTypeCustom];
        [lineButton setFrame:CGRectMake((i*28)+220, defLineLabel.frame.origin.y, 22, 23)];
        [lineButton setBackgroundImage:[UIImage imageNamed:@"line-button-grey.png"] forState:UIControlStateNormal];
        [lineButton setBackgroundImage:[UIImage imageNamed:@"num-button.png"] forState:UIControlStateSelected];
        [lineButton addTarget:self action:@selector(cellSelected:) forControlEvents:UIControlEventTouchUpInside];
        [lineButton setAccessibilityLabel:@"defline"];
        [lineButton setTitle:line forState:UIControlStateNormal];
        [lineButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [lineButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateSelected];
        lineButton.titleLabel.font=[UIFont systemFontOfSize:14.0f];
        [lineButton setUserInteractionEnabled:TRUE];
        [lineButton setTag:i+1];
        i++;
        BOOL doesContainDefLine = [[globals.TAGGED_ATTS_DICT objectForKey:@"defline"] containsObject:[NSString stringWithFormat:@"line_d_%d",lineButton.tag]];
        [lineButton setSelected:doesContainDefLine];
        if (doesContainDefLine){
            [taggedButtonArr addObject:lineButton];
        }

        [self.linePeriodView addSubview:lineButton];
        
    }
    
}

-(void)createDownTags
{
    UILabel *offLabel =[[UILabel alloc]initWithFrame:CGRectMake(30, 70, 50, 30)];
    [offLabel setText:@"OFF."];
    [offLabel setFont:[UIFont systemFontOfSize:17.0f]];
    [offLabel setTextColor:[UIColor darkGrayColor]];
    [offLabel setBackgroundColor:[UIColor clearColor]];
    [self.playerView addSubview:offLabel];
    
    UILabel *defLabel =[[UILabel alloc]initWithFrame:CGRectMake(260, 55+15, 50, 30)];
    [defLabel setText:@"DEF."];
    [defLabel setFont:[UIFont systemFontOfSize:17.0f]];
    [defLabel setTextColor:[UIColor darkGrayColor]];
    [defLabel setBackgroundColor:[UIColor clearColor]];
    [self.playerView addSubview:defLabel];
    
    //buttons for football
    if([globals.WHICH_SPORT isEqualToString:@"football"])
    {
        int i =0;
        NSArray *shiftArr;
        
        shiftArr = [[NSArray alloc]initWithObjects:@"D1",@"D2",@"D3" ,nil];
        
        for(NSString *line in shiftArr) {
            CustomButton *lineButton = [CustomButton buttonWithType:UIButtonTypeCustom];
            [lineButton setFrame:CGRectMake(((i>2 ? i-3 : i)*35)+75, (i>2 ? 130 : 70), 28, 52)];
            [lineButton setBackgroundImage:[UIImage imageNamed:@"line-button-grey.png"] forState:UIControlStateNormal];
            [lineButton setBackgroundImage:[UIImage imageNamed:@"num-button.png"] forState:UIControlStateSelected];
            [lineButton addTarget:self action:@selector(cellSelected:) forControlEvents:UIControlEventTouchUpInside];
            [lineButton setAccessibilityLabel:@"offline"];
            [lineButton setTitle:line forState:UIControlStateNormal];
            [lineButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [lineButton setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
            lineButton.titleLabel.font=[UIFont systemFontOfSize:14.0f];
            [lineButton setTag:i+1];
            [eventsandPlayerButtons addObject:lineButton];
            [lineButton setHidden:TRUE];
            i++;
            
            [self.playerView setHidden:FALSE];
            [self.playerView setUserInteractionEnabled:TRUE];
            [self.playerView addSubview:lineButton];
            
            BOOL doesContainOffLine = [[globals.TAGGED_ATTS_DICT objectForKey:@"offline"] containsObject:[NSString stringWithFormat:@"line_f_%d",lineButton.tag]];
            [lineButton setSelected:doesContainOffLine];
            if (doesContainOffLine){
                if(![[taggedAttsDict allKeys] containsObject:@"shiftline"])
                {
                    NSMutableArray *attValues = [[NSMutableArray alloc]initWithObjects:lineButton, nil];
                    [taggedAttsDict setObject:attValues forKey:@"shiftline"];
                }else {
                    [[taggedAttsDict objectForKey:@"shiftline"] addObject:lineButton];
                }
            }
            
            
        }
        
        i=0;
        for(NSString *line in shiftArr) {
            CustomButton *lineButton = [CustomButton buttonWithType:UIButtonTypeCustom];
            [lineButton setFrame:CGRectMake((i>2 ? i-3 : i)*35+310, (i>2 ? 130 : 70), 28, 52)];
            [lineButton setBackgroundImage:[UIImage imageNamed:@"line-button-grey.png"] forState:UIControlStateNormal];
            [lineButton setBackgroundImage:[UIImage imageNamed:@"num-button.png"] forState:UIControlStateSelected];
            [lineButton addTarget:self action:@selector(cellSelected:) forControlEvents:UIControlEventTouchUpInside];
            [lineButton setAccessibilityLabel:@"defline"];
            [lineButton setTitle:line forState:UIControlStateNormal];
            [lineButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [lineButton setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
            lineButton.titleLabel.font=[UIFont systemFontOfSize:14.0f];
            [eventsandPlayerButtons addObject:lineButton];
            [lineButton setTag:i+1];
            [lineButton setHidden:TRUE];
            i++;
            
            BOOL doesContainDefLine = [[globals.TAGGED_ATTS_DICT objectForKey:@"defline"] containsObject:[NSString stringWithFormat:@"line_d_%d",lineButton.tag]];
            [lineButton setSelected:doesContainDefLine];
            if (doesContainDefLine){
                if(![[taggedAttsDict allKeys] containsObject:@"shiftline"])
                {
                    NSMutableArray *attValues = [[NSMutableArray alloc]initWithObjects:lineButton, nil];
                    [taggedAttsDict setObject:attValues forKey:@"shiftline"];
                }else {
                    [[taggedAttsDict objectForKey:@"shiftline"] addObject:lineButton];
                }
            }
            [self.playerView addSubview:lineButton];
        }
        
    }
}

//for hockey, period and zone
-(void)createPeriodTags
{
    [periodHalfLabel setHidden:FALSE];
    NSArray *tempPeriodsArr;
    if ([globals.WHICH_SPORT isEqualToString:@"hockey"]) {
        tempPeriodsArr = globals.ARRAY_OF_PERIODS;
    }else if([globals.WHICH_SPORT isEqualToString:@"football"]){
        [hockeyZoneLabel setHidden:TRUE];
        tempPeriodsArr = [[NSArray alloc]initWithObjects:@"1",@"2",@"3",@"4", nil];
    }
    for(NSString *prd in tempPeriodsArr)
    {
        int i = [tempPeriodsArr indexOfObject:prd];
        CustomButton *perButton = [CustomButton buttonWithType:UIButtonTypeCustom];
        [perButton setFrame:CGRectMake(370+(i*28), periodHalfLabel.frame.origin.y, 22, 23)];
        [perButton setBackgroundImage:[UIImage imageNamed:@"line-button-grey.png"] forState:UIControlStateNormal];
        [perButton setBackgroundImage:[UIImage imageNamed:@"num-button.png"] forState:UIControlStateSelected];
        [perButton setAccessibilityLabel:@"periods"];
        [perButton addTarget:self action:@selector(cellSelected:) forControlEvents:UIControlEventTouchUpInside];
        [perButton setTitle:prd forState:UIControlStateNormal];
        [perButton setTag:i];
        [perButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [perButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateSelected];
        perButton.titleLabel.font=[UIFont systemFontOfSize:14.0f];
        
        BOOL doesContainPeriod = [[globals.TAGGED_ATTS_DICT objectForKey:@"periods"] containsObject:[NSString stringWithFormat:@"%d",i]];
        [perButton setSelected:doesContainPeriod];
        if (doesContainPeriod){
            [taggedButtonArr addObject:perButton];
        }
        [self.linePeriodView addSubview:perButton];
        
    }
    if ([globals.WHICH_SPORT isEqualToString:@"hockey"]) {
        [hockeyZoneLabel setHidden:FALSE];
    for(NSString *zone in globals.ARRAY_OF_ZONES_HOCKEY)
    {
        int i = [globals.ARRAY_OF_ZONES_HOCKEY indexOfObject:zone];
        CustomButton *zoneButton = [CustomButton buttonWithType:UIButtonTypeCustom];
        [zoneButton setFrame:CGRectMake(565+(i*28), offLineandZoneLabel.frame.origin.y, 22, 23)];
        [zoneButton setBackgroundImage:[UIImage imageNamed:@"line-button-grey.png"] forState:UIControlStateNormal];
        [zoneButton setBackgroundImage:[UIImage imageNamed:@"num-button.png"] forState:UIControlStateSelected];
        [zoneButton setAccessibilityLabel:@"zone"];
        [zoneButton addTarget:self action:@selector(cellSelected:) forControlEvents:UIControlEventTouchUpInside];
        [zoneButton setTitle:zone forState:UIControlStateNormal];
        [zoneButton setTag:i];
        [zoneButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [zoneButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateSelected];
        zoneButton.titleLabel.font=[UIFont systemFontOfSize:14.0f];
        
        BOOL doesContainZone = [[globals.TAGGED_ATTS_DICT objectForKey:@"zone"] containsObject:zone];
        [zoneButton setSelected:doesContainZone];
        if (doesContainZone){
            [taggedButtonArr addObject:zoneButton];
        }
        
            [self.linePeriodView addSubview:zoneButton];
        }
        
    }
    
}
//buttons in shift/line filter tab for hockey
//down/distance filter for football
-(void)createStrengthandShiftTags{
    
    
    UILabel *shiftLineLabel =[[UILabel alloc]initWithFrame:CGRectMake(40, 25, 250, 30)];
    NSArray *shiftArr;
    UILabel *strLabel =[[UILabel alloc]initWithFrame:CGRectMake(40, 25, 150, 30)];
    if ([globals.WHICH_SPORT isEqualToString:@"hockey"]) {
        [shiftLineLabel setText:@"Line Shift Filtering"];
        [strLabel setText:@"PK/PP Filtering"];
         shiftArr = globals.ARRAY_OF_LINES;
    }else{
        [strLabel setText:@"Gain Yards Filtering"];
        [shiftLineLabel setText:@"Down Filtering"];
         shiftArr = [[NSArray alloc]initWithObjects:@"D1",@"D2",@"D3", nil];
    }
    
    [shiftLineLabel setFont:[UIFont systemFontOfSize:13.0f]];
    [shiftLineLabel setTextColor:[UIColor darkGrayColor]];
    [shiftLineLabel setBackgroundColor:[UIColor clearColor]];
    [self.playerView addSubview:shiftLineLabel];
    [shiftLineLabel setHidden:TRUE];
    [shiftButtons addObject:shiftLineLabel];
    
    [strLabel setFont:[UIFont systemFontOfSize:13.0f]];
    [strLabel setTextColor:[UIColor darkGrayColor]];
    [strLabel setBackgroundColor:[UIColor clearColor]];
    [self.eventsView addSubview:strLabel];
    [strLabel setHidden:TRUE];
    [shiftButtons addObject:strLabel];

    
    if ([globals.WHICH_SPORT isEqualToString:@"hockey"]) {
       
        UILabel *offLabel =[[UILabel alloc]initWithFrame:CGRectMake(10, 70, 50, 30)];
        
        [offLabel setText:@"OFF."];
        [offLabel setFont:[UIFont systemFontOfSize:17.0f]];
        [offLabel setTextColor:[UIColor darkGrayColor]];
        [offLabel setBackgroundColor:[UIColor clearColor]];
        [self.playerView addSubview:offLabel];
        [offLabel setHidden:TRUE];
        [shiftButtons addObject:offLabel];
        //[eventsandPlayerButtons addObject:offLabel];
        int i=0;
        
        for(NSString *line in shiftArr) {
            CustomButton *lineButton = [CustomButton buttonWithType:UIButtonTypeCustom];
            [lineButton setFrame:CGRectMake((i*35)+60, 70, 28, 52)];
            if ([globals.WHICH_SPORT isEqualToString:@"football"]) {
                [lineButton setFrame:CGRectMake(((i>2 ? i-3 : i)*35)+55, (i>2 ? 130 : 70), 28, 52)];
            }else if ([globals.WHICH_SPORT isEqualToString:@"hockey"]){
                [lineButton setFrame:CGRectMake((i*35)+55, 70, 28, 52)];
            }
            [lineButton setBackgroundImage:[UIImage imageNamed:@"line-button-grey.png"] forState:UIControlStateNormal];
            [lineButton setBackgroundImage:[UIImage imageNamed:@"num-button.png"] forState:UIControlStateSelected];
            [lineButton addTarget:self action:@selector(cellSelectedinShiftFilter:) forControlEvents:UIControlEventTouchUpInside];
            [lineButton setAccessibilityLabel:@"offline"];
            [lineButton setTitle:line forState:UIControlStateNormal];
            [lineButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [lineButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateSelected];
            lineButton.titleLabel.font=[UIFont systemFontOfSize:14.0f];
            [lineButton setTag:i+1];
            [shiftButtons addObject:lineButton];
            [lineButton setHidden:TRUE];
            i++;
            
            BOOL doesContainOffLine = [[globals.TAGGED_ATTS_DICT_SHIFT objectForKey:@"offline"] containsObject:[NSString stringWithFormat:@"line_f_%d",lineButton.tag]];
            [lineButton setSelected:doesContainOffLine];
            if (doesContainOffLine){
                if(![[taggedButtonDictShift allKeys] containsObject:@"shiftline"])
                {
                    NSMutableArray *attValues = [[NSMutableArray alloc]initWithObjects:lineButton, nil];
                    [taggedButtonDictShift setObject:attValues forKey:@"shiftline"];
                }else {
                    [[taggedButtonDictShift objectForKey:@"shiftline"] addObject:lineButton];
                }
            }
            
            [self.playerView addSubview:lineButton];
        }
        
        UILabel *defLabel =[[UILabel alloc]initWithFrame:CGRectMake(offLabel.frame.origin.x+200, 70, 50, 30)];
        [defLabel setText:@"DEF."];
        [defLabel setFont:[UIFont systemFontOfSize:17.0f]];
        [defLabel setTextColor:[UIColor darkGrayColor]];
        [defLabel setBackgroundColor:[UIColor clearColor]];
        [self.playerView addSubview:defLabel];
        [shiftButtons addObject:defLabel];
        //[eventsandPlayerButtons addObject:defLabel];
        [defLabel setHidden:TRUE];
        i=0;
        for(NSString *line in shiftArr) {
            CustomButton *lineButton = [CustomButton buttonWithType:UIButtonTypeCustom];
            
            if ([globals.WHICH_SPORT isEqualToString:@"football"]) {
                [lineButton setFrame:CGRectMake((i>2 ? i-3 : i)*35+310, (i>2 ? 130 : 70), 28, 52)];
            }else if ([globals.WHICH_SPORT isEqualToString:@"hockey"]){
                [lineButton setFrame:CGRectMake((i*35)+260, 55+15, 28, 52)];
            }
            [lineButton setBackgroundImage:[UIImage imageNamed:@"line-button-grey.png"] forState:UIControlStateNormal];
            [lineButton setBackgroundImage:[UIImage imageNamed:@"num-button.png"] forState:UIControlStateSelected];
            [lineButton addTarget:self action:@selector(cellSelectedinShiftFilter:) forControlEvents:UIControlEventTouchUpInside];
            [lineButton setAccessibilityLabel:@"defline"];
            [lineButton setTitle:line forState:UIControlStateNormal];
            [lineButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [lineButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateSelected];
            lineButton.titleLabel.font=[UIFont systemFontOfSize:14.0f];
            [shiftButtons addObject:lineButton];
            [lineButton setTag:i+1];
            [lineButton setHidden:TRUE];
            i++;
            
            BOOL doesContainDefLine = [[globals.TAGGED_ATTS_DICT_SHIFT objectForKey:@"defline"] containsObject:[NSString stringWithFormat:@"line_d_%d",lineButton.tag]];
            [lineButton setSelected:doesContainDefLine];
            if (doesContainDefLine){
                if(![[taggedButtonDictShift allKeys] containsObject:@"shiftline"])
                {
                    NSMutableArray *attValues = [[NSMutableArray alloc]initWithObjects:lineButton, nil];
                    [taggedButtonDictShift setObject:attValues forKey:@"shiftline"];
                }else {
                    [[taggedButtonDictShift objectForKey:@"shiftline"] addObject:lineButton];
                }
            }
            [self.playerView addSubview:lineButton];
        }
        
        //strength buttons for home team
        for (NSString *strength in globals.ARRAY_OF_STRENGTH) {
            int i = [globals.ARRAY_OF_STRENGTH indexOfObject:strength];
            CustomButton *strButton = [CustomButton buttonWithType:UIButtonTypeCustom];
            [strButton setFrame:CGRectMake(40+(i*35), 55+15, 28, 25)];
            [strButton setBackgroundImage:[UIImage imageNamed:@"line-button-grey.png"] forState:UIControlStateNormal];
            [strButton setBackgroundImage:[UIImage imageNamed:@"num-button.png"] forState:UIControlStateSelected];
            [strButton setAccessibilityLabel:@"homestr"];
            [strButton addTarget:self action:@selector(cellSelectedinShiftFilter:) forControlEvents:UIControlEventTouchUpInside];
            [strButton setTitle:strength forState:UIControlStateNormal];
            [strButton setTag:i+1];
            [strButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [strButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateSelected];
            strButton.titleLabel.font=[UIFont systemFontOfSize:14.0f];
            [strButton setHidden:TRUE];
            
            BOOL doesContainStrength = [[globals.TAGGED_ATTS_DICT_SHIFT objectForKey:@"homestr"] containsObject:strength];
            [strButton setSelected:doesContainStrength];
            if (doesContainStrength){
                if(![[taggedButtonDictShift allKeys] containsObject:@"strength"])
                {
                    NSMutableArray *attValues = [[NSMutableArray alloc]initWithObjects:strButton, nil];
                    [taggedButtonDictShift setObject:attValues forKey:@"strength"];
                }else {
                    [[taggedButtonDictShift objectForKey:@"strength"] addObject:strButton];
                }
            }
            [shiftButtons addObject:strButton];
            //[homeStrButtons addObject:strButton];
            [self.eventsView addSubview:strButton];
            //[strengthCoachPickButtons addObject:strButton];
        }
        
        
        //home team label
        UILabel *homeStrLabel =[[UILabel alloc]initWithFrame:CGRectMake(240-50, 55+15, 40, 30)];
        [homeStrLabel setText:@"H"];
        [homeStrLabel setFont:[UIFont systemFontOfSize:13.0f]];
        [homeStrLabel setTextColor:[UIColor darkGrayColor]];
        [homeStrLabel setBackgroundColor:[UIColor clearColor]];
        [self.eventsView addSubview:homeStrLabel];
        [homeStrLabel setHidden:TRUE];
        [shiftButtons addObject:homeStrLabel];
        //[strengthCoachPickButtons addObject:homeStrLabel];
        
        //away team label
        UILabel *awayStrLabel =[[UILabel alloc]initWithFrame:CGRectMake(240-50, 95+15, 40, 30)];
        [awayStrLabel setText:@"A"];
        [awayStrLabel setFont:[UIFont systemFontOfSize:13.0f]];
        [awayStrLabel setTextColor:[UIColor darkGrayColor]];
        [awayStrLabel setBackgroundColor:[UIColor clearColor]];
        [self.eventsView addSubview:awayStrLabel];
        [awayStrLabel setHidden:TRUE];
        [shiftButtons addObject:awayStrLabel];
        // [strengthCoachPickButtons addObject:awayStrLabel];
        CustomButton *allStrengthButton = [CustomButton buttonWithType:UIButtonTypeCustom];
        [allStrengthButton setFrame:CGRectMake(220, 55+15, 65, 65)];
        [allStrengthButton setBackgroundImage:[UIImage imageNamed:@"line-button-grey.png"] forState:UIControlStateNormal];
        [allStrengthButton setBackgroundImage:[UIImage imageNamed:@"num-button.png"] forState:UIControlStateSelected];
        [allStrengthButton setAccessibilityLabel:@"allstrength"];
        [allStrengthButton addTarget:self action:@selector(cellSelectedinShiftFilter:) forControlEvents:UIControlEventTouchUpInside];
        [allStrengthButton setTitle:@"All" forState:UIControlStateNormal];
        [allStrengthButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [allStrengthButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateSelected];
        allStrengthButton.titleLabel.font=[UIFont systemFontOfSize:14.0f];
        
        BOOL doesContainAllStrength = [[globals.TAGGED_ATTS_DICT_SHIFT objectForKey:@"allstrength"] containsObject:@"allstrength"];
        [allStrengthButton setSelected:doesContainAllStrength];
        if (doesContainAllStrength){
            if(![[taggedButtonDictShift allKeys] containsObject:@"allstrength"])
            {
                NSMutableArray *attValues = [[NSMutableArray alloc]initWithObjects:allStrengthButton, nil];
                [taggedButtonDictShift setObject:attValues forKey:@"allstrength"];
            }else {
                [[taggedButtonDictShift objectForKey:@"allstrength"] addObject:allStrengthButton];
            }
        }
        
        
        [shiftButtons addObject:allStrengthButton];
        [allStrengthButton setHidden:TRUE];
        [self.eventsView addSubview:allStrengthButton];

        
        //strength buttons for away team
        for (NSString *strength in globals.ARRAY_OF_STRENGTH) {
            int i = [globals.ARRAY_OF_STRENGTH indexOfObject:strength];
            CustomButton *strButton = [CustomButton buttonWithType:UIButtonTypeCustom];
            [strButton setFrame:CGRectMake(90+(i*35)-50, 95+15, 28, 25)];
            [strButton setBackgroundImage:[UIImage imageNamed:@"line-button-grey.png"] forState:UIControlStateNormal];
            [strButton setBackgroundImage:[UIImage imageNamed:@"num-button.png"] forState:UIControlStateSelected];
            [strButton setAccessibilityLabel:@"awaystr"];
            [strButton addTarget:self action:@selector(cellSelectedinShiftFilter:) forControlEvents:UIControlEventTouchUpInside];
            [strButton setTitle:strength forState:UIControlStateNormal];
            [strButton setTag:i+1];
            [strButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [strButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateSelected];
            strButton.titleLabel.font=[UIFont systemFontOfSize:14.0f];
            [strButton setHidden:TRUE];
            
            BOOL doesContainStrength = [[globals.TAGGED_ATTS_DICT_SHIFT objectForKey:@"awaystr"] containsObject:strength];
            [strButton setSelected:doesContainStrength];
            if (doesContainStrength){
                if(![[taggedButtonDictShift allKeys] containsObject:@"strength"])
                {
                    NSMutableArray *attValues = [[NSMutableArray alloc]initWithObjects:strButton, nil];
                    [taggedButtonDictShift setObject:attValues forKey:@"strength"];
                }else {
                    [[taggedButtonDictShift objectForKey:@"strength"] addObject:strButton];
                }
            }
        
            [shiftButtons addObject:strButton];
            //[homeStrButtons addObject:strButton];
            [self.eventsView addSubview:strButton];
            // [strengthCoachPickButtons addObject:strButton];
        }

    }else if([globals.WHICH_SPORT isEqualToString:@"football"]){
        UILabel *offStrLabel =[[UILabel alloc]initWithFrame:CGRectMake(5, 85, 30, 30)];
        [offStrLabel setText:@"+"];
        [offStrLabel setFont:[UIFont systemFontOfSize:28.0f]];
        [offStrLabel setTextColor:[UIColor greenColor]];
        [offStrLabel setBackgroundColor:[UIColor clearColor]];
        [self.eventsView addSubview:offStrLabel];
        [offStrLabel setHidden:FALSE];
        [shiftButtons addObject:offStrLabel];
        [self.eventsView addSubview:offStrLabel];
        
        UILabel *defStrLabel =[[UILabel alloc]initWithFrame:CGRectMake(10, 155, 30, 30)];
        [defStrLabel setText:@"-"];
        [defStrLabel setFont:[UIFont systemFontOfSize:28.0f]];
        [defStrLabel setTextColor:[UIColor redColor]];
        [defStrLabel setBackgroundColor:[UIColor clearColor]];
        [self.eventsView addSubview:defStrLabel];
        [defStrLabel setHidden:FALSE];
        [shiftButtons addObject:defStrLabel];
        [self.eventsView addSubview:defStrLabel];
        
        NSArray *distanceArray1 = [[NSArray alloc]initWithObjects:@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9", nil];
        for (NSString *distance in distanceArray1) {
            int i = [distanceArray1 indexOfObject:distance];
            CustomButton *offDistUpButton = [CustomButton buttonWithType:UIButtonTypeCustom];
            [offDistUpButton setFrame:CGRectMake(40+(i*30), 70, 25, 25)];
            [offDistUpButton setBackgroundImage:[UIImage imageNamed:@"line-button-grey.png"] forState:UIControlStateNormal];
            [offDistUpButton setBackgroundImage:[UIImage imageNamed:@"num-button.png"] forState:UIControlStateSelected];
            [offDistUpButton setAccessibilityLabel:@"posgain"];
            [offDistUpButton addTarget:self action:@selector(cellSelectedinShiftFilter:) forControlEvents:UIControlEventTouchUpInside];
            [offDistUpButton setTitle:distance forState:UIControlStateNormal];
            [offDistUpButton setTag:i+1];
            [offDistUpButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [offDistUpButton setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
            offDistUpButton.titleLabel.font=[UIFont systemFontOfSize:14.0f];
            [offDistUpButton setHidden:TRUE];
            
            BOOL doesContainDistance = [[globals.TAGGED_ATTS_DICT_SHIFT objectForKey:@"posgain"] containsObject:distance];
            [offDistUpButton setSelected:doesContainDistance];
            if (doesContainDistance){
                if(![[taggedButtonDictShift allKeys] containsObject:@"distance"])
                {
                    NSMutableArray *attValues = [[NSMutableArray alloc]initWithObjects:offDistUpButton, nil];
                    [taggedButtonDictShift setObject:attValues forKey:@"distance"];
                }else {
                    [[taggedButtonDictShift objectForKey:@"distance"] addObject:offDistUpButton];
                }
            }
            [shiftButtons addObject:offDistUpButton];
            [self.eventsView addSubview:offDistUpButton];
            
            CustomButton *defDistUpButton = [CustomButton buttonWithType:UIButtonTypeCustom];
            [defDistUpButton setFrame:CGRectMake(40+(i*30), 140, 25, 25)];
            [defDistUpButton setBackgroundImage:[UIImage imageNamed:@"line-button-grey.png"] forState:UIControlStateNormal];
            [defDistUpButton setBackgroundImage:[UIImage imageNamed:@"num-button.png"] forState:UIControlStateSelected];
            [defDistUpButton setAccessibilityLabel:@"neggain"];
            [defDistUpButton addTarget:self action:@selector(cellSelectedinShiftFilter:) forControlEvents:UIControlEventTouchUpInside];
            [defDistUpButton setTitle:distance forState:UIControlStateNormal];
            [defDistUpButton setTag:i+1];
            [defDistUpButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [defDistUpButton setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
            defDistUpButton.titleLabel.font=[UIFont systemFontOfSize:14.0f];
            [defDistUpButton setHidden:TRUE];
            
            doesContainDistance = [[globals.TAGGED_ATTS_DICT_SHIFT objectForKey:@"neggain"] containsObject:distance];
            [defDistUpButton setSelected:doesContainDistance];
            if (doesContainDistance){
                if(![[taggedButtonDictShift allKeys] containsObject:@"gain"])
                {
                    NSMutableArray *attValues = [[NSMutableArray alloc]initWithObjects:defDistUpButton, nil];
                    [taggedButtonDictShift setObject:attValues forKey:@"gain"];
                }else {
                    [[taggedButtonDictShift objectForKey:@"gain"] addObject:defDistUpButton];
                }
            }
            [shiftButtons addObject:defDistUpButton];
            [self.eventsView addSubview:defDistUpButton];
            
        }
        
        NSArray *distanceArray2 = [[NSArray alloc]initWithObjects:@"10s",@"20s",@"30s",@"40s",@"50s", nil];
        for (NSString *distance in distanceArray2) {
            int i = [distanceArray2 indexOfObject:distance];
            CustomButton *offDistDownButton = [CustomButton buttonWithType:UIButtonTypeCustom];
            [offDistDownButton setFrame:CGRectMake(40+(i*30), 100, 25, 25)];
            [offDistDownButton setBackgroundImage:[UIImage imageNamed:@"line-button-grey.png"] forState:UIControlStateNormal];
            [offDistDownButton setBackgroundImage:[UIImage imageNamed:@"num-button.png"] forState:UIControlStateSelected];
            [offDistDownButton setAccessibilityLabel:@"posgain"];
            [offDistDownButton addTarget:self action:@selector(cellSelectedinShiftFilter:) forControlEvents:UIControlEventTouchUpInside];
            [offDistDownButton setTitle:distance forState:UIControlStateNormal];
            [offDistDownButton setTag:(i+1)*10];
            [offDistDownButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [offDistDownButton setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
            offDistDownButton.titleLabel.font=[UIFont systemFontOfSize:14.0f];
            [offDistDownButton setHidden:TRUE];
            
            BOOL doesContainDistance = [[globals.TAGGED_ATTS_DICT_SHIFT objectForKey:@"posgain"] containsObject:[NSString stringWithFormat:@"%d",(i+1)*10]];
            [offDistDownButton setSelected:doesContainDistance];
            if (doesContainDistance){
                if(![[taggedButtonDictShift allKeys] containsObject:@"gain"])
                {
                    NSMutableArray *attValues = [[NSMutableArray alloc]initWithObjects:offDistDownButton, nil];
                    [taggedButtonDictShift setObject:attValues forKey:@"gain"];
                }else {
                    [[taggedButtonDictShift objectForKey:@"gain"] addObject:offDistDownButton];
                }
            }
            [shiftButtons addObject:offDistDownButton];
            [self.eventsView addSubview:offDistDownButton];
            
            
            CustomButton *defDistDownButton = [CustomButton buttonWithType:UIButtonTypeCustom];
            [defDistDownButton setFrame:CGRectMake(40+(i*30), 170, 25, 25)];
            [defDistDownButton setBackgroundImage:[UIImage imageNamed:@"line-button-grey.png"] forState:UIControlStateNormal];
            [defDistDownButton setBackgroundImage:[UIImage imageNamed:@"num-button.png"] forState:UIControlStateSelected];
            [defDistDownButton setAccessibilityLabel:@"neggain"];
            [defDistDownButton addTarget:self action:@selector(cellSelectedinShiftFilter:) forControlEvents:UIControlEventTouchUpInside];
            [defDistDownButton setTitle:distance forState:UIControlStateNormal];
            [defDistDownButton setTag:(i+1)*10];
            [defDistDownButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [defDistDownButton setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
            defDistDownButton.titleLabel.font=[UIFont systemFontOfSize:14.0f];
            [defDistDownButton setHidden:TRUE];
            
            UILabel *typeLabel=[[UILabel alloc] init];
            [typeLabel setFrame:CGRectMake(10, periodHalfLabel.frame.origin.y, 60, 30)];
            [typeLabel setText:@"TYPE:"];
            [typeLabel setFont:[UIFont systemFontOfSize:13.0f]];
            [typeLabel setTextColor:[UIColor darkGrayColor]];
            [typeLabel setBackgroundColor:[UIColor clearColor]];
            [self.linePeriodView addSubview:typeLabel];
            
            CustomButton *typeButtonRun = [CustomButton buttonWithType:UIButtonTypeCustom];
            [typeButtonRun setFrame:CGRectMake(80, typeLabel.frame.origin.y, 40, 25)];
            [typeButtonRun setBackgroundImage:[UIImage imageNamed:@"line-button-grey.png"] forState:UIControlStateNormal];
            [typeButtonRun setBackgroundImage:[UIImage imageNamed:@"num-button.png"] forState:UIControlStateSelected];
            [typeButtonRun setAccessibilityLabel:@"type"];
            [typeButtonRun addTarget:self action:@selector(cellSelectedinShiftFilter:) forControlEvents:UIControlEventTouchUpInside];
            [typeButtonRun setTitle:@"Run" forState:UIControlStateNormal];
            [typeButtonRun setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [typeButtonRun setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
            [shiftButtons addObject:typeButtonRun];
            typeButtonRun.titleLabel.font=[UIFont systemFontOfSize:14.0f];
            [linePeriodView addSubview:typeButtonRun];
            
            CustomButton *typeButtonPass = [CustomButton buttonWithType:UIButtonTypeCustom];
            [typeButtonPass setFrame:CGRectMake(125, typeLabel.frame.origin.y, 40, 25)];
            [typeButtonPass setBackgroundImage:[UIImage imageNamed:@"line-button-grey.png"] forState:UIControlStateNormal];
            [typeButtonPass setBackgroundImage:[UIImage imageNamed:@"num-button.png"] forState:UIControlStateSelected];
            [typeButtonPass setAccessibilityLabel:@"type"];
            [typeButtonPass addTarget:self action:@selector(cellSelectedinShiftFilter:) forControlEvents:UIControlEventTouchUpInside];
            [typeButtonPass setTitle:@"Pass" forState:UIControlStateNormal];
            [typeButtonPass setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [typeButtonPass setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
            typeButtonPass.titleLabel.font=[UIFont systemFontOfSize:14.0f];
            [shiftButtons addObject:typeButtonPass];
            [linePeriodView addSubview:typeButtonPass];
            
            CustomButton *typeButtonKick = [CustomButton buttonWithType:UIButtonTypeCustom];
            [typeButtonKick setFrame:CGRectMake(170, typeLabel.frame.origin.y, 40, 25)];
            [typeButtonKick setBackgroundImage:[UIImage imageNamed:@"line-button-grey.png"] forState:UIControlStateNormal];
            [typeButtonKick setBackgroundImage:[UIImage imageNamed:@"num-button.png"] forState:UIControlStateSelected];
            [typeButtonKick setAccessibilityLabel:@"type"];
            [typeButtonKick addTarget:self action:@selector(cellSelectedinShiftFilter:) forControlEvents:UIControlEventTouchUpInside];
            [typeButtonKick setTitle:@"Kick" forState:UIControlStateNormal];
            [typeButtonKick setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [typeButtonKick setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
            typeButtonKick.titleLabel.font=[UIFont systemFontOfSize:14.0f];
            [shiftButtons addObject:typeButtonKick];
            [linePeriodView addSubview:typeButtonKick];
            
            doesContainDistance = [[globals.TAGGED_ATTS_DICT_SHIFT objectForKey:@"neggain"] containsObject:[NSString stringWithFormat:@"%d",(i+1)*10]];
            [defDistDownButton setSelected:doesContainDistance];
            if (doesContainDistance){
                if(![[taggedButtonDictShift allKeys] containsObject:@"gain"])
                {
                    NSMutableArray *attValues = [[NSMutableArray alloc]initWithObjects:defDistDownButton, nil];
                    [taggedButtonDictShift setObject:attValues forKey:@"gain"];
                }else {
                    [[taggedButtonDictShift objectForKey:@"gain"] addObject:defDistDownButton];
                }
            }
            [shiftButtons addObject:defDistDownButton];
            [self.eventsView addSubview:defDistDownButton];
        
        }
    }
    
    // [strengthCoachPickButtons addObject:allStrengthButton];
    
    UILabel *coachPickLabel =[[UILabel alloc]initWithFrame:CGRectMake(350, 25, 150, 30)];
    [coachPickLabel setText:@"Coach Pick Filtering"];
    [coachPickLabel setFont:[UIFont systemFontOfSize:13.0f]];
    [coachPickLabel setTextColor:[UIColor darkGrayColor]];
    [coachPickLabel setBackgroundColor:[UIColor clearColor]];
    [self.eventsView addSubview:coachPickLabel];
    [coachPickLabel setHidden:TRUE];
    [shiftButtons addObject:coachPickLabel];
    

    CustomButton *coachPickButton = [CustomButton buttonWithType:UIButtonTypeCustom];
    [coachPickButton setFrame:CGRectMake(375, 55+15, 91, 65)];
    [coachPickButton setBackgroundImage:[UIImage imageNamed:@"line-button-grey.png"] forState:UIControlStateNormal];
    [coachPickButton setBackgroundImage:[UIImage imageNamed:@"num-button.png"] forState:UIControlStateSelected];
    [coachPickButton setAccessibilityLabel:@"coachpick"];
    [coachPickButton addTarget:self action:@selector(cellSelectedinShiftFilter:) forControlEvents:UIControlEventTouchUpInside];
    [coachPickButton setTitle:@"Coach Pick" forState:UIControlStateNormal];
    [coachPickButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [coachPickButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateSelected];
    coachPickButton.titleLabel.font=[UIFont systemFontOfSize:14.0f];
    
    BOOL doesContainCoachPick= [[globals.TAGGED_ATTS_DICT_SHIFT objectForKey:@"coachpick"]count] >0; //&& [[globals.TAGGED_ATTS_DICT_SHIFT objectForKey:@"coachpick"]containsObject:[NSNumber numberWithInt:1]];
    [coachPickButton setSelected:doesContainCoachPick];
    if (doesContainCoachPick){
        if(![[taggedButtonDictShift allKeys] containsObject:@"coachpick"])
        {
            NSMutableArray *attValues = [[NSMutableArray alloc]initWithObjects:coachPickButton, nil];
            [taggedButtonDictShift setObject:attValues forKey:@"coachpick"];
        }else {
            [[taggedButtonDictShift objectForKey:@"coachpick"] addObject:coachPickButton];
        }
    }
    
    [shiftButtons addObject:coachPickButton];
    [coachPickButton setHidden:TRUE];
    [self.eventsView addSubview:coachPickButton];
}


//we need to create different buttons for the event filter screen that are the same as the shift filter but go to a different function
-(void)footballTypeTagsEventFilter
{
    if([globals.WHICH_SPORT isEqualToString:@"football"])
    {
        
        UILabel *typeLabel=[[UILabel alloc] init];
        [typeLabel setFrame:CGRectMake(10, periodHalfLabel.frame.origin.y, 60, 30)];
        [typeLabel setText:@"TYPE:"];
        [typeLabel setFont:[UIFont systemFontOfSize:13.0f]];
        [typeLabel setTextColor:[UIColor darkGrayColor]];
        [typeLabel setBackgroundColor:[UIColor clearColor]];
        [self.linePeriodView addSubview:typeLabel];
        
        CustomButton *typeButtonRun = [CustomButton buttonWithType:UIButtonTypeCustom];
        [typeButtonRun setFrame:CGRectMake(80, typeLabel.frame.origin.y,40,  25)];
        [typeButtonRun setBackgroundImage:[UIImage imageNamed:@"line-button-grey.png"] forState:UIControlStateNormal];
        [typeButtonRun setBackgroundImage:[UIImage imageNamed:@"num-button.png"] forState:UIControlStateSelected];
        [typeButtonRun setAccessibilityLabel:@"type"];
        [typeButtonRun addTarget:self action:@selector(cellSelected:) forControlEvents:UIControlEventTouchUpInside];
        [typeButtonRun setTitle:@"Run" forState:UIControlStateNormal];
        [typeButtonRun setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [typeButtonRun setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
        typeButtonRun.titleLabel.font=[UIFont systemFontOfSize:14.0f];
        [eventsandPlayerButtons addObject:typeButtonRun];
        [linePeriodView addSubview:typeButtonRun];
        
        CustomButton *typeButtonPass = [CustomButton buttonWithType:UIButtonTypeCustom];
        [typeButtonPass setFrame:CGRectMake(125, typeLabel.frame.origin.y,40,  25)];
        [typeButtonPass setBackgroundImage:[UIImage imageNamed:@"line-button-grey.png"] forState:UIControlStateNormal];
        [typeButtonPass setBackgroundImage:[UIImage imageNamed:@"num-button.png"] forState:UIControlStateSelected];
        [typeButtonPass setAccessibilityLabel:@"type"];
        [typeButtonPass addTarget:self action:@selector(cellSelected:) forControlEvents:UIControlEventTouchUpInside];
        [typeButtonPass setTitle:@"Pass" forState:UIControlStateNormal];
        [typeButtonPass setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [typeButtonPass setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
        typeButtonPass.titleLabel.font=[UIFont systemFontOfSize:14.0f];
        [eventsandPlayerButtons addObject:typeButtonPass];
        [linePeriodView addSubview:typeButtonPass];
        
        CustomButton *typeButtonKick = [CustomButton buttonWithType:UIButtonTypeCustom];
        [typeButtonKick setFrame:CGRectMake(170, typeLabel.frame.origin.y, 40,  25)];
        [typeButtonKick setBackgroundImage:[UIImage imageNamed:@"line-button-grey.png"] forState:UIControlStateNormal];
        [typeButtonKick setBackgroundImage:[UIImage imageNamed:@"num-button.png"] forState:UIControlStateSelected];
        [typeButtonKick setAccessibilityLabel:@"type"];
        [typeButtonKick addTarget:self action:@selector(cellSelected:) forControlEvents:UIControlEventTouchUpInside];
        [typeButtonKick setTitle:@"Kick" forState:UIControlStateNormal];
        [typeButtonKick setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [typeButtonKick setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
        typeButtonKick.titleLabel.font=[UIFont systemFontOfSize:14.0f];
        
        [eventsandPlayerButtons addObject:typeButtonKick];
        
        [linePeriodView addSubview:typeButtonKick];
    }
}

- (NSString *)unselectButtonsInShift:(UIButton *)button
{
    NSString *att = button.accessibilityLabel;
    
    if([att isEqualToString:@"offline"]||[att isEqualToString:@"defline"]){
        //if user selects lines, then deselect all strength buttons and coach pick button and remove their information from the dictionary taggedAttsDictShift
        if ([taggedButtonDictShift objectForKey:@"strength"]) {
            for(CustomButton *button in [taggedButtonDictShift objectForKey:@"strength"])
            {
                [button setSelected:FALSE];
            }
            [[taggedButtonDictShift objectForKey:@"strength"] removeAllObjects];
            [taggedAttsDictShift removeObjectForKey:@"homestr"];
            [taggedAttsDictShift removeObjectForKey:@"awaystr"];
            //[taggedAttsDictShift removeObjectForKey:@"allstrength"];
        }
        
        if ([taggedButtonDictShift objectForKey:@"allstrength"]) {
            for(CustomButton *button in [taggedButtonDictShift objectForKey:@"allstrength"])
            {
                [button setSelected:FALSE];
            }
            [[taggedButtonDictShift objectForKey:@"allstrength"] removeAllObjects];
            [taggedAttsDictShift removeObjectForKey:@"allstrength"];
        }
        if ([taggedButtonDictShift objectForKey:@"coachpick"]) {
            for(CustomButton *button in [taggedButtonDictShift objectForKey:@"coachpick"])
            {
                [button setSelected:FALSE];
            }
            [[taggedButtonDictShift objectForKey:@"coachpick"] removeAllObjects];
            [taggedAttsDictShift removeObjectForKey:@"coachpick"];
        }
        
        if ([taggedAttsDictShift objectForKey:@"posgain"]){
            
            for(CustomButton *button in [taggedButtonDictShift objectForKey:@"gain"])
            {
                [button setSelected:FALSE];
            }
            
            [taggedAttsDictShift removeObjectForKey:@"posgain"];
        }
        
        if ([taggedAttsDictShift objectForKey:@"neggain"]){
            
            for(CustomButton *button in [taggedButtonDictShift objectForKey:@"gain"])
            {
                [button setSelected:FALSE];
            }
            
            [taggedAttsDictShift removeObjectForKey:@"neggain"];
        }
        
        if ([taggedAttsDictShift objectForKey:@"posgain"] || [taggedAttsDictShift objectForKey:@"neggain"]) {
            [[taggedButtonDictShift objectForKey:@"gain"] removeAllObjects];
        }

        
    }else if([att isEqualToString:@"allstrength"]){
        if ([taggedButtonDictShift objectForKey:@"strength"]) {
            for(CustomButton *button in [taggedButtonDictShift objectForKey:@"strength"])
            {
                [button setSelected:FALSE];
            }
            [[taggedButtonDictShift objectForKey:@"strength"] removeAllObjects];
            [taggedAttsDictShift removeObjectForKey:@"homestr"];
            [taggedAttsDictShift removeObjectForKey:@"awaystr"];
            //[taggedAttsDictShift removeObjectForKey:@"allstrength"];
        }
        
        if ([taggedButtonDictShift objectForKey:@"shiftline"]) {
            for(CustomButton *button in [taggedButtonDictShift objectForKey:@"shiftline"])
            {
                [button setSelected:FALSE];
            }
            [[taggedButtonDictShift objectForKey:@"shiftline"] removeAllObjects];
            [taggedAttsDictShift removeObjectForKey:@"offline"];
            [taggedAttsDictShift removeObjectForKey:@"defline"];
        }
        
        if ([taggedButtonDictShift objectForKey:@"coachpick"]) {
            for(CustomButton *button in [taggedButtonDictShift objectForKey:@"coachpick"])
            {
                [button setSelected:FALSE];
            }
            [[taggedButtonDictShift objectForKey:@"coachpick"] removeAllObjects];
            [[taggedAttsDictShift objectForKey:@"coachpick"] removeAllObjects];
        }
        
    }else if([att isEqualToString:@"homestr"] || [att isEqualToString:@"awaystr"]){
        //if user selects strength buttons, then deselect all line buttons and coach pick button and remove their information from the dictionary taggedAttsDictShift
        if ([taggedButtonDictShift objectForKey:@"shiftline"]) {
            for(CustomButton *button in [taggedButtonDictShift objectForKey:@"shiftline"])
            {
                [button setSelected:FALSE];
            }
            [[taggedButtonDictShift objectForKey:@"shiftline"] removeAllObjects];
            [taggedAttsDictShift removeObjectForKey:@"offline"];
            [taggedAttsDictShift removeObjectForKey:@"defline"];
        }
        if ([taggedButtonDictShift objectForKey:@"allstrength"]) {
            for(CustomButton *button in [taggedButtonDictShift objectForKey:@"allstrength"])
            {
                [button setSelected:FALSE];
            }
            [[taggedButtonDictShift objectForKey:@"allstrength"] removeAllObjects];
            [taggedAttsDictShift removeObjectForKey:@"allstrength"];
        }
        if ([taggedButtonDictShift objectForKey:@"coachpick"]) {
            for(CustomButton *button in [taggedButtonDictShift objectForKey:@"coachpick"])
            {
                [button setSelected:FALSE];
            }
            [[taggedButtonDictShift objectForKey:@"coachpick"] removeAllObjects];
            [taggedAttsDictShift removeObjectForKey:@"coachpick"];
        }
        
    }else if([att isEqualToString:@"coachpick"]){
        //if the user select coach pick button, deselect all strength buttons and line buttons and remove their information from the dictionary taggedAttsDictShift
        if ([taggedButtonDictShift objectForKey:@"strength"]) {
            for(CustomButton *button in [taggedButtonDictShift objectForKey:@"strength"])
            {
                [button setSelected:FALSE];
            }
            [[taggedButtonDictShift objectForKey:@"strength"] removeAllObjects];
            [taggedAttsDictShift removeObjectForKey:@"homestr"];
            [taggedAttsDictShift removeObjectForKey:@"awaystr"];
        }
        
        if ([taggedButtonDictShift objectForKey:@"allstrength"]) {
            for(CustomButton *button in [taggedButtonDictShift objectForKey:@"allstrength"])
            {
                [button setSelected:FALSE];
            }
            [[taggedButtonDictShift objectForKey:@"allstrength"] removeAllObjects];
            [taggedAttsDictShift removeObjectForKey:@"allstrength"];
        }
        
        
        if ([taggedButtonDictShift objectForKey:@"shiftline"]) {
            for(CustomButton *button in [taggedButtonDictShift objectForKey:@"shiftline"])
            {
                [button setSelected:FALSE];
            }
            [[taggedButtonDictShift objectForKey:@"shiftline"] removeAllObjects];
            [taggedAttsDictShift removeObjectForKey:@"offline"];
            [taggedAttsDictShift removeObjectForKey:@"defline"];
        }
        
        if ([taggedAttsDictShift objectForKey:@"posgain"]){
            
            for(CustomButton *button in [taggedButtonDictShift objectForKey:@"gain"])
            {
                [button setSelected:FALSE];
            }
            
            [taggedAttsDictShift removeObjectForKey:@"posgain"];
        }
        
        if ([taggedAttsDictShift objectForKey:@"neggain"]){
            
            for(CustomButton *button in [taggedButtonDictShift objectForKey:@"gain"])
            {
                [button setSelected:FALSE];
            }
            
            [taggedAttsDictShift removeObjectForKey:@"neggain"];
        }
        
        if ([taggedAttsDictShift objectForKey:@"posgain"] || [taggedAttsDictShift objectForKey:@"neggain"]) {
             [[taggedButtonDictShift objectForKey:@"gain"] removeAllObjects];
        }


    }else if ([att isEqualToString:@"posgain"] || [att isEqualToString:@"neggain"]) {
        
        if ([taggedButtonDictShift objectForKey:@"coachpick"]) {
            for(CustomButton *button in [taggedButtonDictShift objectForKey:@"coachpick"])
            {
                [button setSelected:FALSE];
            }
            [[taggedButtonDictShift objectForKey:@"coachpick"] removeAllObjects];
            [taggedAttsDictShift removeObjectForKey:@"coachpick"];
        }
        
        if ([taggedButtonDictShift objectForKey:@"shiftline"]) {
            for(CustomButton *button in [taggedButtonDictShift objectForKey:@"shiftline"])
            {
                [button setSelected:FALSE];
            }
            [[taggedButtonDictShift objectForKey:@"shiftline"] removeAllObjects];
            [taggedAttsDictShift removeObjectForKey:@"offline"];
            [taggedAttsDictShift removeObjectForKey:@"defline"];
        }
    }
    return att;
}

//Shift/line filtering
//line buttons and strength and coachpick are all seperate sections
-(void)cellSelectedinShiftFilter:(id)sender
{
    if (taggedButtonArr.count) {
        [self clearEventFilter];
    }
    
    if([globals.WHICH_SPORT isEqualToString:@"football"])
    {
        [self createShiftAttributesDictFootball:(UIButton*)sender];
    }else if([globals.WHICH_SPORT isEqualToString:@"hockey"])
    {
        [self createShiftAttributesDictHockey:(UIButton*)sender];
    }else if([globals.WHICH_SPORT isEqualToString:@"rugby"])
    {
        [self createShiftAttributesDictRugby:(UIButton*)sender];
    }else if([globals.WHICH_SPORT isEqualToString:@"soccer"])
    {
        [self createShiftAttributesDictSoccer:(UIButton*)sender];
    }
    
    [globals.TAGGED_ATTS_DICT_SHIFT setDictionary:taggedAttsDictShift];
    [self sortAllClipsBySelectingforShiftFiltering];
}

/// METHOD TO FILTER ATTRIBUTES IN SHIFT FILTERING

-(void)sortAllClipsBySelectingforShiftFiltering{
    displayArray = [self sortClipsBySelectingforShiftFiltering:[globals.CURRENT_EVENT_THUMBNAILS allValues]];
    //reload tags
    [numTagsLabel setText:[NSString stringWithFormat:@"%d Tags", displayArray.count]];
    [numTagsLabel setNeedsDisplay];
    
    [[superArgs objectForKey:@"controller"] receiveFilteredArray:displayArray];
    [displayArray removeAllObjects];

}
-(NSMutableArray*)sortClipsBySelectingforShiftFiltering:(NSArray*)tagsArr
{
    //we are going to get boolean values of whether or not tags fit the attributes requsted
    //lines add, events add, event/lines/periods/colours intersect
    NSMutableArray *tempAllTags = [tagsArr mutableCopy];
    allTagsArray = [tempAllTags mutableCopy];
    
    //first of all we are going to get rid of all periods and odd type tags in our big array -- don't want to deal with or display them
    for(NSDictionary *tag in tempAllTags){
        //"type" value: #default = 0; #stop line/zone = 2;#telestration = 4;#player end shift = 6;#period/half end = 8/18; #strength end  = 10
        if([[tag objectForKey:@"type"]integerValue]&1 || [[tag objectForKey:@"type"]integerValue] == 8 || [[tag objectForKey:@"type"]integerValue] == 18){
            [allTagsArray removeObject:tag];
        }
    }
    
    NSMutableArray *filteredArr = [[NSMutableArray alloc]init];
    [self.taggedAttsDictShift setDictionary:globals.TAGGED_ATTS_DICT_SHIFT];
    
    if(taggedAttsDictShift.count<1) //if there is nothing selected in the attributes dictionary, show all the clips (means user is done filtering)
    {
        filteredArr = [NSMutableArray arrayWithArray:allTagsArray];
    }else{
        for(NSDictionary *obj in allTagsArray)
        {
            //initialise all the boolean values that we are going to filter by
            //assume false at first
            BOOL doesContainOFFLines = FALSE;
            BOOL doesContainDEFLines = FALSE;
            BOOL doesContainGain = FALSE;
            BOOL doesContainStrength = FALSE;
            BOOL doesContainAllStrength = FALSE;
            BOOL doesContainType = FALSE;
            
            if ([globals.WHICH_SPORT isEqualToString:@"hockey"]) { // we only filter by offline, defline, strength in hockey
                
                //first of all check to see whether or not the lines exist
                //the first part of this bool statement checks to see if the attributes dict contains off or def lines
                //if it does AND the value for that line is equal to the name of the current object, then set to true.
                doesContainOFFLines = [[taggedAttsDictShift objectForKey:@"offline"]count]>0 && [[taggedAttsDictShift objectForKey:@"offline"] containsObject:[obj objectForKey:@"name"]] ;
                doesContainDEFLines = [[taggedAttsDictShift objectForKey:@"defline"]count]>0 && [[taggedAttsDictShift objectForKey:@"defline"] containsObject:[obj objectForKey:@"name"]] ;
                
                //now we ned to filter by strength
                //first need to check the "strength" attribute array in the tag is not empty
                if(![[obj objectForKey:@"strength"] isEqual:@""] && [[globals.TYPES_OF_TAGS objectAtIndex:2] containsObject:[obj objectForKey:@"name"]])
                {
                    
                    //First of all the array of strengths is found by taking the strength value of the current tag and parsing by the comma -- ex 5,6 becomes {5,6} as an array
                    NSArray *arrayOfStrengths = [[NSArray alloc] initWithArray:[[obj objectForKey:@"strength"]componentsSeparatedByString:@","]];
                    
                    //Do a check -- if we want all the strength and the two strength values aren't the same then set boolean to true
                    //we don't want to take into account values like 5,5 cause they aren't really strengths
                    if ([taggedAttsDictShift objectForKey:@"allstrength"] &&[[arrayOfStrengths objectAtIndex:0]integerValue]!=[[arrayOfStrengths objectAtIndex:1]integerValue] ) {
                        doesContainAllStrength = TRUE;
                    }else{
                        doesContainAllStrength = FALSE;
                    }
                    
                    if ([[taggedAttsDictShift objectForKey:@"homestr"]count]>0 && [[taggedAttsDictShift objectForKey:@"awaystr"]count]==0 ) {
                        //not away strength is selected, filtering with union set
                        doesContainStrength = [[taggedAttsDictShift objectForKey:@"homestr"]containsObject:[arrayOfStrengths objectAtIndex:0]];
                    }else if([[taggedAttsDictShift objectForKey:@"homestr"]count] == 0 && [[taggedAttsDictShift objectForKey:@"awaystr"]count] >0 ){
                        //not home strength is selected, filtering with union set
                        doesContainStrength = [[taggedAttsDictShift objectForKey:@"awaystr"]containsObject:[arrayOfStrengths objectAtIndex:1]];
                    }else if([[taggedAttsDictShift objectForKey:@"homestr"]count]> 0 && [[taggedAttsDictShift objectForKey:@"awaystr"]count] >0 ){
                        //both home and away strength are selected, filtering with intersection set
                        doesContainStrength = [[taggedAttsDictShift objectForKey:@"homestr"]containsObject:[arrayOfStrengths objectAtIndex:0]] && [[taggedAttsDictShift objectForKey:@"awaystr"]containsObject:[arrayOfStrengths objectAtIndex:1]];
                    }else{
                        doesContainStrength = FALSE;
                    }
                }else{
                    doesContainStrength = FALSE;
                    doesContainAllStrength = FALSE;
                }
            }else if([globals.WHICH_SPORT isEqualToString:@"football"]){
                
                if(![[taggedAttsDictShift objectForKey:@"offline"]count]>0 && ![[taggedAttsDictShift objectForKey:@"defline"]count]>0)
                {
                    doesContainOFFLines=![[taggedAttsDictShift objectForKey:@"offline"]count]>0;
                    doesContainDEFLines=![[taggedAttsDictShift objectForKey:@"defline"]count]>0;
                    
                }else{
                    doesContainOFFLines = [[taggedAttsDictShift objectForKey:@"offline"]count]>0 && [[taggedAttsDictShift objectForKey:@"offline"] firstObjectCommonWithArray:[obj objectForKey:@"line"]]!=nil;
                    doesContainDEFLines = [[taggedAttsDictShift objectForKey:@"defline"]count]>0 && [[taggedAttsDictShift objectForKey:@"defline"] firstObjectCommonWithArray:[obj objectForKey:@"line"]]!=nil;
                    
                }
                
                NSDictionary *jsonExtra ; // we need to turn our extra string into a json dictionary, will be contained in this variable
                if([[obj objectForKey:@"extra"] length] != 0) // check if there is anything in the extra param
                {
                    NSData *data=[[obj objectForKey:@"extra"] dataUsingEncoding:NSUTF8StringEncoding]; // convert extra param to data]
                    NSError *err;
                    jsonExtra = [[NSDictionary alloc]initWithDictionary:[NSJSONSerialization JSONObjectWithData:data options:NSUTF8StringEncoding error:&err] ]; //convert data to dictionary
                }
                if(!([[taggedAttsDictShift objectForKey:@"posgain"]count]>0 || [[taggedAttsDictShift objectForKey:@"neggain"]count]>0))
                {
                    doesContainGain = ![[taggedAttsDictShift objectForKey:@"posgain"]count]>0;
                    doesContainGain = ![[taggedAttsDictShift objectForKey:@"neggain"]count]>0;
                }
                //   //////NSLog(@"jsone -- %@",jsonExtra);
                
                if ( [jsonExtra count] && [[jsonExtra objectForKey:@"gain"]integerValue] > 0) {
                    int posGain = [[jsonExtra objectForKey:@"gain"] integerValue];
                    if (posGain > 9) {
                        posGain = posGain - posGain%10;
                    }
                    doesContainGain = (![[taggedAttsDictShift objectForKey:@"posgain"]count]>0  && ![[taggedAttsDictShift objectForKey:@"neggain"]count]>0)||[[taggedAttsDictShift objectForKey:@"posgain"] containsObject:[NSString stringWithFormat:@"%d",posGain]] ;
                }else if ([jsonExtra count] && [[jsonExtra objectForKey:@"gain"]integerValue] < 0) {
                    int negGain = abs([[jsonExtra objectForKey:@"gain"] integerValue]);
                    if (negGain > 9) {
                        negGain = negGain - negGain%10;
                    }
                    doesContainGain = (![[taggedAttsDictShift objectForKey:@"neggain"]count]>0 && ![[taggedAttsDictShift objectForKey:@"posgain"]count]>0) || [[taggedAttsDictShift objectForKey:@"neggain"] containsObject:[NSString stringWithFormat:@"%d",negGain]] ;
                }
                doesContainType = ![[taggedAttsDictShift objectForKey:@"type"]count]>0 || [[taggedAttsDictShift objectForKey:@"type"] containsObject:[jsonExtra objectForKey:@"type"]] ;
                
            }
            
            BOOL doesContainCoachPick;
            //if ([globals.WHICH_SPORT isEqualToString:@"football"]) {
                doesContainCoachPick= [[taggedAttsDictShift objectForKey:@"coachpick"]count] >0 && [[taggedAttsDictShift objectForKey:@"coachpick"]containsObject:[NSString stringWithFormat:@"%@",[obj objectForKey:@"coachpick"]]];
            //}else{
            //    doesContainCoachPick= ![[taggedAttsDictShift objectForKey:@"coachpick"]count] >0 && [[taggedAttsDictShift objectForKey:@"coachpick"]containsObject:[NSString stringWithFormat:@"%@",[obj objectForKey:@"coachpick"]]];
            //}
             
            if(![globals.WHICH_SPORT isEqualToString:@"football"])
            {
                if(doesContainOFFLines || doesContainDEFLines || doesContainAllStrength ||doesContainStrength|| doesContainCoachPick)
                {
                    [filteredArr addObject:obj];
                }
            }else{
                if((doesContainOFFLines || doesContainDEFLines) && doesContainGain && doesContainType && doesContainCoachPick)
                {
                    [filteredArr addObject:obj];
                }
            }
        }
    }
    
    return filteredArr;
}



//change bg to orange, if its a colour, change border only, if its a line, select all players in that line too
-(void)cellSelected:(id)sender
{
    if (taggedButtonDictShift.count) {
        [self clearShiftFilter];
    }
    
    CustomButton *button = (CustomButton*)sender;
    
    //for medical testing
    if([globals.WHICH_SPORT isEqualToString:@"soccer"]||[globals.WHICH_SPORT isEqualToString:@"rugby"]||[globals.WHICH_SPORT isEqualToString:@"medical"] || [globals.WHICH_SPORT isEqualToString:@""])
    {
        [self createEventsAttributesDictSoccer:button];
    }else if ([globals.WHICH_SPORT isEqualToString:@"hockey"])
    {
        [self createEventsAttributesDictHockey:button];
    }else if([globals.WHICH_SPORT isEqualToString:@"football"])
    {
        [self createEventsAttributesDictFootball:button];
    }
//    else if([globals.WHICH_SPORT isEqualToString:@"rugby"])
//    {
//        [self createEventsAttributesDictRugby:button];
//    }
    
    [globals.TAGGED_ATTS_DICT setDictionary:taggedAttsDict];
    [self sortAllClipsWithAttributes];
}


#pragma mark – UICollectionViewDelegateFlowLayout

//the big doozie, this was changed a lot when the new server changes came in
//we are now basically filtering all the duration tags by time, so if a tag happens at time 5 mins, we have to check by time which duration tags are going on at this time
-(void)sortAllClipsWithAttributes{
    displayArray = [self sortClipsWithAttributes:[globals.CURRENT_EVENT_THUMBNAILS allValues]];
    //reload tags
    
    [numTagsLabel setText:[NSString stringWithFormat:@"%d Tags", displayArray.count]];
    [numTagsLabel setNeedsDisplay];
    
    [[superArgs objectForKey:@"controller"] receiveFilteredArray:displayArray];
    [displayArray removeAllObjects];

}

-(NSMutableArray*)sortClipsWithAttributes:(NSArray *)tagsArr
{
    
    //we are going to get boolean values of whether or not tags fit the attributes requsted
    //lines add, events add, event/lines/periods/colours intersect
    
    
    NSMutableArray *tempAllTags = [tagsArr mutableCopy]; //get all the current tags
    allTagsArray = [tempAllTags mutableCopy];//mutable copy so we can do stuff to it without casting every single time
    
    //going to iterate through and get rid of all the odd tags and periods
    for(NSDictionary *tag in tempAllTags){
        //"type" value: #default = 0; #stop line/zone = 2;#telestration = 4;#player end shift = 6;#period/half end = 8/18; #strength end  = 10
        if(([[tag objectForKey:@"type"]integerValue]&1) || [[tag objectForKey:@"type"]integerValue]==18||[[tag objectForKey:@"type"]integerValue]==8){
            [allTagsArray removeObject:tag];
        }
    }
    
//    //if it is in list view, donot show telestration
//    if (!showTelestration){
//        for(NSDictionary *tag in tempAllTags){
//            if ([[tag objectForKey:@"type"]integerValue ] ==4) {
//                [allTagsArray removeObject:tag];
//            }
//        }
//    }
    
    NSMutableArray *filteredArr = [[NSMutableArray alloc]init];
    [taggedAttsDict setDictionary:globals.TAGGED_ATTS_DICT];
    
    if(taggedAttsDict.count<1) //if no attributes have been selected, show all the tags
    {
        filteredArr = [NSMutableArray arrayWithArray:allTagsArray];
    }else{
        
        NSArray *tempOffArr;
        if ([[taggedAttsDictShift objectForKey:@"offline"]count]>0 && [[taggedAttsDictShift objectForKey:@"offline"] containsObject:@"allDownOff"] ) {
        //For football, the all-offense-down button is selected
            tempOffArr = [[[NSArray alloc]initWithObjects:@"line_f_o_1",@"line_f_o_2",@"line_f_o_3", nil]copy];
        }else{
            tempOffArr =[[NSArray alloc]initWithArray:[taggedAttsDict objectForKey:@"offline"]];
        }
        
        NSArray *tempDefArr;
        if ([[taggedAttsDictShift objectForKey:@"defline"]count]>0 && [[taggedAttsDictShift objectForKey:@"defline"] containsObject:@"allDownDef"] ) {
        //For football, the all-defense-down button is selected
            tempDefArr = [[[NSArray alloc]initWithObjects:@"line_f_d_1",@"line_f_d_2",@"line_f_d_3", nil]copy];
        }else{
            tempDefArr =[[NSArray alloc]initWithArray:[taggedAttsDict objectForKey:@"defline"]];
        }
        
        for(NSDictionary *obj in allTagsArray)
        {
            //coachpick is filtered independently with the other attributes
            if ([[taggedAttsDict allKeys] containsObject:@"coachpick"]) {
                
                //check to see if coachpick is being filtered, and then if the current tag is coachpicked
                BOOL doesContainCoachPick= [[taggedAttsDict objectForKey:@"coachpick"]count] >0 && [[taggedAttsDict objectForKey:@"coachpick"]containsObject:[NSString stringWithFormat:@"%@",[obj objectForKey:@"coachpick"]]];
                
                //if its coach picked just add it to the array we want to display
                if(doesContainCoachPick)
                {
                    [filteredArr addObject:obj];
                }
            }else{
                BOOL doesContainEvent = !([[taggedAttsDict objectForKey:@"events"]count]>0) || [[taggedAttsDict objectForKey:@"events"] containsObject:[obj objectForKey:@"name"]] ;
                BOOL doesContainPlayers =  !([[taggedAttsDict objectForKey:@"players"]count] >0)||[[taggedAttsDict objectForKey:@"players"]firstObjectCommonWithArray:[obj objectForKey:@"player"]]!=nil;
                BOOL doesContainColour = !([[taggedAttsDict objectForKey:@"colours"]count] >0) || [[taggedAttsDict objectForKey:@"colours"]containsObject:[obj objectForKey:@"colour"]];
                
                //for hockey
                NSString *tagTime = [NSString stringWithFormat:@"%@",[obj objectForKey:@"time"]];
                BOOL doesContainOFFLines = [[taggedAttsDict objectForKey:@"offline"]count]<1;
                
                if(!doesContainOFFLines)
                {
                    if([[taggedAttsDict objectForKey:@"offline"]count]>0)
                    {
                        //first of all we need to grab the times for type we are filtering
                        //we have a temporary array - t - and we will add all the times at which the even type occurs
                        NSMutableArray *t = [[NSMutableArray alloc]initWithArray:[globals.DURATION_TYPE_TIMES objectForKey:@"2"]];
                        
                        //if we have server then we can also add the times at which the odd type happens -- this only happens when server is available
                        //because thats the only time we don't know the end time of the last tag, so its still open
                        //offline duration tags will always be closed because we know the total duration of the game
                        if(globals.HAS_MIN)
                        {
                            [t addObjectsFromArray:[globals.DURATION_TYPE_TIMES objectForKey:@"1"]];
                        }
                        
                        //sort t by time, makes our binary search faster
                        [t sortUsingComparator:^NSComparisonResult(NSString *str1, NSString *str2) {
                            return [str1 compare:str2 options:(NSNumericSearch)];
                        }];
                        NSInteger *sortedIndex = 0;
                        NSString *closestTagTime;
                        if (t.count > 1) {
                            //first do a binary search to find the index that this time would be inserted
                            int binSearchIndex =[t binarySearch:tagTime] ; // binsearch returns -1 if time not found
                            binSearchIndex = (int)binSearchIndex <0 ? 0:binSearchIndex; // make sure the binary search index is greater then 0
                            
                            //we are going to set the index to the returned index -1 because we want the time before this one (tells us which tags were open at this time)
                            sortedIndex=(int)binSearchIndex >t.count-1 ? t.count-1 : binSearchIndex-1; //make sure index doesn't go beyond the bounds of the array
                            sortedIndex=(int)sortedIndex <0 ? 0:sortedIndex; //make sure index isn't less then 0

                            closestTagTime = [t objectAtIndex:sortedIndex]; //based on our binary search, we get the closest tag time before ours (floor)
                            
                            //now take the global dictionary which relates times to which tags happen at those times, and find the dictionary of tags for our closest time
                            NSDictionary *timeDictionary = [[NSDictionary alloc]initWithDictionary:[globals.DURATION_TAGS_TIME objectForKey:closestTagTime]];
                            
                            //our boolean values are set based on whether or not our timedictionary contains whichever line was filtered
                            doesContainOFFLines =[[taggedAttsDict objectForKey:@"offline"] containsObject:[timeDictionary objectForKey:@"2"]];
                            //if there is no even type in the timedictionary, there might be an odd type
                            doesContainOFFLines= doesContainOFFLines ? TRUE : [[taggedAttsDict objectForKey:@"offline"] containsObject:[timeDictionary objectForKey:@"1"]];
                            
                        }else if(t.count==1){
                            closestTagTime = [t objectAtIndex:0];
                            NSDictionary *timeDictionary = [[NSDictionary alloc]initWithDictionary:[globals.DURATION_TAGS_TIME objectForKey:closestTagTime]];
                            
                            doesContainOFFLines =[[taggedAttsDict objectForKey:@"offline"] containsObject:[timeDictionary objectForKey:@"2"]];
                            doesContainOFFLines= doesContainOFFLines ? TRUE : [[taggedAttsDict objectForKey:@"offline"] containsObject:[timeDictionary objectForKey:@"1"]];
                        }else{
                            doesContainOFFLines=FALSE;
                        }
                    
                    }
                }
                
                BOOL doesContainDEFLines = [[taggedAttsDict objectForKey:@"defline"]count]<1;
                
                if(!doesContainDEFLines)
                {
                    if([[taggedAttsDict objectForKey:@"defline"]count]>0)
                    {
                        NSMutableArray *t = [[NSMutableArray alloc]initWithArray:[globals.DURATION_TYPE_TIMES objectForKey:@"6"]];
                        if(globals.HAS_MIN)
                        {
                            [t addObjectsFromArray:[globals.DURATION_TYPE_TIMES objectForKey:@"5"]];
                        }
                        [t sortUsingComparator:^NSComparisonResult(NSString *str1, NSString *str2) {
                            return [str1 compare:str2 options:(NSNumericSearch)];
                        }];
                        NSInteger *sortedIndex = 0;
                        NSString *closestTagTime;
                        if (t.count > 1) {
                            int binSearchIndex =[t binarySearch:tagTime] ; // binsearch returns -1 if time not found
                            binSearchIndex = (int)binSearchIndex <0 ? 0:binSearchIndex; // make sure the binary search index is greater then 0

                            sortedIndex=(int)binSearchIndex >t.count-1 ? t.count-1 : binSearchIndex-1;
                            sortedIndex=(int)sortedIndex <0 ? 0:sortedIndex; //make sure index isn't less then 0

                            closestTagTime = [t objectAtIndex:sortedIndex];
                            NSDictionary *timeDictionary = [[NSDictionary alloc]initWithDictionary:[globals.DURATION_TAGS_TIME objectForKey:closestTagTime]];

                            doesContainDEFLines =[[taggedAttsDict objectForKey:@"defline"] containsObject:[timeDictionary objectForKey:@"6"]];
                            doesContainDEFLines= doesContainDEFLines ? TRUE : [[taggedAttsDict objectForKey:@"defline"] containsObject:[timeDictionary objectForKey:@"5"]];
                        }else if(t.count==1){
                            closestTagTime = [t objectAtIndex:0];
                            NSDictionary *timeDictionary = [[NSDictionary alloc]initWithDictionary:[globals.DURATION_TAGS_TIME objectForKey:closestTagTime]];
                            
                            doesContainDEFLines =[[taggedAttsDict objectForKey:@"defline"] containsObject:[timeDictionary objectForKey:@"6"]];
                            doesContainDEFLines= doesContainDEFLines ? TRUE : [[taggedAttsDict objectForKey:@"defline"] containsObject:[timeDictionary objectForKey:@"5"]];
                        }else{
                            doesContainDEFLines=FALSE;
                        }

                    }
                }
                BOOL doesContainPeriod = [[taggedAttsDict objectForKey:@"periods"]count]<1 && [[taggedAttsDict objectForKey:@"half"]count]<1;
                if(!doesContainPeriod)
                {
                    if([[taggedAttsDict objectForKey:@"periods"]count]>0 || [[taggedAttsDict objectForKey:@"half"]count]>0)
                    {
                        NSMutableArray *t;
                        NSMutableArray *openEndStrings = [[NSMutableArray alloc] init]; //will use this array for open and end types of different sports -- soccer will be 17,18 hockey will be 7,8
                        if([globals.WHICH_SPORT isEqualToString:@"hockey"])
                        {
                            [openEndStrings addObject:@"7"];
                            [openEndStrings addObject:@"8"];
                        }else if([globals.WHICH_SPORT isEqualToString:@"soccer"] || [globals.WHICH_SPORT isEqualToString:@"rugby"])
                        {
                            [openEndStrings addObject:@"17"];
                            [openEndStrings addObject:@"18"];
                        }
                        
                        t = [[NSMutableArray alloc]initWithArray:[globals.DURATION_TYPE_TIMES objectForKey:[openEndStrings  objectAtIndex:1]]];
                        if(globals.HAS_MIN)
                        {
                            [t addObjectsFromArray:[globals.DURATION_TYPE_TIMES objectForKey:[openEndStrings objectAtIndex:0]]];
                        }

                        //sorting
                        [t sortUsingComparator:^NSComparisonResult(NSString *str1, NSString *str2) {
                            return [str1 compare:str2 options:(NSNumericSearch)];
                        }];
                        NSString *closestTagTime;
                        NSInteger *sortedIndex = 0;
                        
                        if (t.count > 1)
                        {
                            int binSearchIndex =[t binarySearch:tagTime] ; // binsearch returns -1 if time not found
                            binSearchIndex = (int)binSearchIndex <0 ? 0:binSearchIndex; // make sure the binary search index is greater then 0

                            sortedIndex=(int)binSearchIndex >t.count-1 ? t.count-1 : binSearchIndex-1;
                            sortedIndex=(int)sortedIndex <0 ? 0:sortedIndex; //make sure index isn't less then 0

                            closestTagTime = [t objectAtIndex:sortedIndex];
                        }else if(t.count == 1){
                            closestTagTime = [t objectAtIndex:0];
                        }
                        NSDictionary *timeDictionary = [[NSDictionary alloc]initWithDictionary:[globals.DURATION_TAGS_TIME objectForKey:closestTagTime]];
                        NSString *comparingAttribute = [globals.WHICH_SPORT isEqualToString:@"hockey"] ? @"periods" : @"half";
                        doesContainPeriod =[[taggedAttsDict objectForKey:comparingAttribute] containsObject:[timeDictionary objectForKey:[openEndStrings objectAtIndex:1]]];
                        doesContainPeriod= doesContainPeriod ? TRUE : [[taggedAttsDict objectForKey:comparingAttribute] containsObject:[timeDictionary objectForKey:[openEndStrings objectAtIndex:0]]];

                    }
                }
                
                BOOL doesContainType = FALSE;
                
                if ([globals.WHICH_SPORT isEqualToString:@"football"]) {
                    if ([obj objectForKey:@"period"] && [[obj objectForKey:@"period"] isKindOfClass:[NSArray class]]) {
                        NSArray *temArr = [[NSArray alloc]initWithObjects:[[obj objectForKey:@"period"]objectAtIndex:0], nil];
                        doesContainPeriod = !([[taggedAttsDict objectForKey:@"periods"]count] >0 )|| [[taggedAttsDict objectForKey:@"periods"]firstObjectCommonWithArray:temArr]!=nil;
                        
                        NSDictionary *jsonExtra ; // we need to turn our extra string into a json dictionary, will be contained in this variable
                        if([[obj objectForKey:@"extra"] length] != 0) // check if there is anything in the extra param
                        {
                            NSData *data=[[obj objectForKey:@"extra"] dataUsingEncoding:NSUTF8StringEncoding]; // convert extra param to data]
                            NSError *err;
                            jsonExtra = [[NSDictionary alloc]initWithDictionary:[NSJSONSerialization JSONObjectWithData:data options:NSUTF8StringEncoding error:&err] ]; //convert data to dictionary
                        }
                        doesContainType = ![[taggedAttsDict objectForKey:@"type"]count]>0 || [[taggedAttsDict objectForKey:@"type"] containsObject:[jsonExtra objectForKey:@"type"]] ;
                        if(doesContainType)
                        {
                            //  //////NSLog(@"boo");
                        }
                    }
                    
                }else{
                    doesContainType = TRUE;
                }
                
                BOOL doesContainZone = [[taggedAttsDict objectForKey:@"zone"]count]<1;
                if ([globals.WHICH_SPORT isEqualToString:@"soccer"] || [globals.WHICH_SPORT isEqualToString:@"rugby"]) {
                    if(!doesContainZone)
                    {
                        if([[taggedAttsDict objectForKey:@"zone"]count]>0)
                        {
                            NSMutableArray *t;
                            NSMutableArray *openEndStrings = [[NSMutableArray alloc] init]; //will use this array for open and end types of different sports -- soccer will be 17,18 hockey will be 7,8
                                [openEndStrings addObject:@"15"];
                                [openEndStrings addObject:@"16"];
                            
                            t = [[NSMutableArray alloc]initWithArray:[globals.DURATION_TYPE_TIMES objectForKey:[openEndStrings  objectAtIndex:1]]];
                            if(globals.HAS_MIN)
                            {
                                [t addObjectsFromArray:[globals.DURATION_TYPE_TIMES objectForKey:[openEndStrings objectAtIndex:0]]];
                            }
                            
                            //sorting
                            [t sortUsingComparator:^NSComparisonResult(NSString *str1, NSString *str2) {
                                return [str1 compare:str2 options:(NSNumericSearch)];
                            }];
                            NSString *closestTagTime;
                            NSInteger *sortedIndex = 0;
                            
                            if (t.count > 1)
                            {
                                int binSearchIndex =[t binarySearch:tagTime] ; // binsearch returns -1 if time not found
                                binSearchIndex =(int) binSearchIndex <0 ? 0:binSearchIndex; // make sure the binary search index is greater then 0

                                sortedIndex=(int)binSearchIndex >t.count-1 ? t.count-1 : binSearchIndex-1;
                                sortedIndex=(int)sortedIndex <0 ? 0:sortedIndex; //make sure index isn't less then 0

                                closestTagTime = [t objectAtIndex:sortedIndex];
                            }else if(t.count == 1){
                                closestTagTime = [t objectAtIndex:0];
                            }
                            NSDictionary *timeDictionary = [[NSDictionary alloc]initWithDictionary:[globals.DURATION_TAGS_TIME objectForKey:closestTagTime]];
                            doesContainZone =[[taggedAttsDict objectForKey:@"zone"] containsObject:[timeDictionary objectForKey:[openEndStrings objectAtIndex:1]]];
                            doesContainZone = doesContainZone ? TRUE : [[taggedAttsDict objectForKey:@"zone"] containsObject:[timeDictionary objectForKey:[openEndStrings objectAtIndex:0]]];
                            
                        }
                    }

                }else if ([globals.WHICH_SPORT isEqualToString:@"hockey"]){
                    //for hockey
                    doesContainZone = ![[taggedAttsDict objectForKey:@"zone"]count]>0 || [[taggedAttsDict objectForKey:@"zone"] containsObject:[obj objectForKey:@"zone"]];
                }else{
                    doesContainZone = TRUE;
                }
                
//                BOOL doesContainHalf = ![[taggedAttsDict objectForKey:@"half"]count]>0 || [[taggedAttsDict objectForKey:@"half"] containsObject:[obj objectForKey:@"period"]];
                
                if(doesContainEvent && doesContainOFFLines && doesContainDEFLines && doesContainPeriod && doesContainPlayers && doesContainColour && doesContainZone && doesContainType)
                {
                    [filteredArr addObject:obj];
                }
            }
        }
    }
    return filteredArr;
}



- (void)eventsFilter:(id)sender {
    eventFilterTitleButton.selected = TRUE;
    shiftFilterTitleButton.selected = FALSE;
    
    if (globals.IS_TAG_TYPES_UPDATED) {
        [self createEventTags];
        [self createColourTags];
        if([globals.WHICH_SPORT isEqualToString:@"soccer"] || [globals.WHICH_SPORT isEqualToString:@"rugby"])
        {
            [self createSoccerPlayerTags];
        }else if([globals.WHICH_SPORT isEqualToString:@"hockey"]){
            [self createPlayerTags];
        }
        globals.IS_TAG_TYPES_UPDATED = FALSE;
    }

    //clear all the selection in SHIFT/LINE FILTERING
    if (taggedButtonDictShift.count ) {
        [self clearShiftFilter];
    }
    
    if (taggedAttsDictShift.count) {
        [taggedAttsDictShift removeAllObjects];
        [globals.TAGGED_ATTS_DICT_SHIFT removeAllObjects];
    }

    //if press the "EVENT FILTERING" button whiling filtering events (taggedAttsDict.count !=0), do not change anything;Else (taggedAttsDict.count == 0),repopulate all the tags
    if (taggedAttsDict.count == 0 ) {
        NSMutableArray *tempAllTags = [[globals.CURRENT_EVENT_THUMBNAILS allValues]mutableCopy];
        allTagsArray = [tempAllTags mutableCopy];
        for(NSDictionary *tag in tempAllTags){
            //"type" value: #default = 0; #stop line/zone = 2;#telestration = 4;#player end shift = 6;#period/half end = 8; #strength end  = 10
            if([[tag objectForKey:@"type"] intValue]==8 || [[tag objectForKey:@"type"] intValue]==18 || [[tag objectForKey:@"type"]integerValue]==3 || ([[tag objectForKey:@"type"]integerValue]&1)){
                [allTagsArray removeObject:tag];
            }
        }
        
        [[superArgs objectForKey:@"controller"] receiveFilteredArray:[[NSMutableArray alloc]initWithArray:allTagsArray]];
        
    }
    
    [eventFilterTitleButton setBackgroundImage:[UIImage imageNamed:@"event_filter_selected.png"] forState:UIControlStateNormal];
    if ([globals.WHICH_SPORT isEqualToString:@"hockey"]) {
        [shiftFilterTitleButton setBackgroundImage:[UIImage imageNamed:@"shiftline_filter_unselected.png"] forState:UIControlStateNormal];
    }else if([globals.WHICH_SPORT isEqualToString:@"football"]){
        [shiftFilterTitleButton setBackgroundImage:[UIImage imageNamed:@"shiftdown_filter_unselected.png"] forState:UIControlStateNormal];
    }
    
    [self.eventsView setHidden:FALSE];
    [self.linePeriodView setHidden:FALSE];
    [self.usersView setHidden:FALSE];
    [self.eventsView setUserInteractionEnabled:TRUE];
    [self.linePeriodView setUserInteractionEnabled:TRUE];
    [self.linePeriodView setUserInteractionEnabled:TRUE];
    [horzDivider setHidden:FALSE];
    [shiftlineHorzDivider setHidden:TRUE];
    for(UIView *pButton in eventsandPlayerButtons){
        [pButton setHidden:FALSE];
        
    }
    [strengthDivider setHidden:TRUE];
    for(UIView *button in shiftButtons){
        if(![eventsandPlayerButtons containsObject:button])
        {
            [button setHidden:TRUE];
        }
    }
    [shiftlineHorzDivider setHidden:TRUE];
    //[self.playerView setScrollEnabled:TRUE];
    if (globals.TYPES_OF_TAGS.count > 0) {
        if(ceil((float)[[globals.TYPES_OF_TAGS objectAtIndex:0] count]/ROWS_IN_EVENTS) <5){
            [self.eventsView setContentSize:CGSizeMake(self.eventsView.frame.size.width, 200)];
        }else{
            [self.eventsView setContentSize:CGSizeMake(self.eventsView.frame.size.width+ ceil((float)[[globals.TYPES_OF_TAGS objectAtIndex:0] count]/ROWS_IN_EVENTS)*123, 200)];
        }
        if(ceil(globals.ARRAY_OF_HOCKEY_PLAYERS.count/ROWS_IN_PLAYERS) <7){
            [self.playerView setContentSize:CGSizeMake(self.playerView.frame.size.width, 200)];
        }else{
            [self.playerView setContentSize:CGSizeMake(self.playerView.frame.size.width+ (ceil(globals.ARRAY_OF_HOCKEY_PLAYERS.count/ROWS_IN_PLAYERS)-5)*83, 200)];
        }

    }
        
}


- (void)shiftLineFilter:(id)sender {
    
    eventFilterTitleButton.selected = FALSE;
    shiftFilterTitleButton.selected = TRUE;
    //clear event filter
    if (taggedButtonArr.count) {
        [self clearEventFilter];
    }
    if (taggedAttsDict.count) {
        [taggedAttsDict removeAllObjects];
        [globals.TAGGED_ATTS_DICT removeAllObjects];
    }
    //if press the "SHIFT/LINE FILTERING" button whiling filtering shift/line (taggedAttsDictShift.count !=0), do not change anything;Else (taggedAttsDictShift.count == 0),repopulate all the tags
    if (taggedAttsDictShift.count == 0) {
        NSMutableArray *tempAllTags = [[globals.CURRENT_EVENT_THUMBNAILS allValues]mutableCopy];
        allTagsArray = [tempAllTags mutableCopy];
        for(NSDictionary *tag in tempAllTags){
            //"type" value: #default = 0; #stop line/zone = 2;#telestration = 4;#player end shift = 6;#period/half end = 8; #strength end  = 10
            if([[tag objectForKey:@"type"] intValue]==8|| [[tag objectForKey:@"type"] intValue]==18|| [[tag objectForKey:@"type"]integerValue]==3 ||([[tag objectForKey:@"type"]integerValue]&1)){
                [allTagsArray removeObject:tag];
            }
        }
        
//        NSMutableArray *tempArr = [displayArray mutableCopy];
//        if (!showTelestration){
//            for(NSDictionary *tag in tempArr){
//                if ([[tag objectForKey:@"type"]integerValue ] ==4) {
//                    [displayArray removeObject:tag];
//                }
//            }
//        }
        [[superArgs objectForKey:@"controller"] receiveFilteredArray:[[NSMutableArray alloc]initWithArray:allTagsArray]];
    }
    
    [horzDivider setHidden:TRUE];
    [eventFilterTitleButton setBackgroundImage:[UIImage imageNamed:@"event_filter_unselected.png"] forState:UIControlStateNormal];
    if ([globals.WHICH_SPORT isEqualToString:@"hockey"]) {
        [shiftFilterTitleButton setBackgroundImage:[UIImage imageNamed:@"shiftline_filter_selected.png"] forState:UIControlStateNormal];
    }else if([globals.WHICH_SPORT isEqualToString:@"football"]){
        [shiftFilterTitleButton setBackgroundImage:[UIImage imageNamed:@"shiftdown_filter_selected.png"] forState:UIControlStateNormal];
        [horzDivider setHidden:FALSE];
    }
    
    if(![globals.WHICH_SPORT isEqualToString:@"football"])
    {
        [self.linePeriodView setHidden:TRUE];
        [self.usersView setHidden:TRUE];
        [self.linePeriodView setUserInteractionEnabled:FALSE];
        [self.linePeriodView setUserInteractionEnabled:FALSE];
    }
    
    
    [shiftlineHorzDivider setHidden:FALSE];
    for(UIView *pButton in eventsandPlayerButtons){
        if(![shiftButtons containsObject:pButton])
        {
            [pButton setHidden:TRUE];
        }
    }
    [strengthDivider setHidden:FALSE];
    // for(UIView *view in strengthCoachPickButtons){
    //     [view setHidden:FALSE];
    // }
    for(UIView *button in shiftButtons){
        [button setHidden:FALSE];
    }
    [shiftlineHorzDivider setHidden:FALSE];
    //[self.playerView setScrollEnabled:FALSE];
    [self.eventsView setContentSize:CGSizeMake(self.eventsView.frame.size.width, 200)];
    [self.playerView setContentSize:CGSizeMake(self.playerView.frame.size.width, 200)];
    
}


- (void)swipeFilter:(id)sender {
    
    CustomButton *button = (CustomButton*)sender;
    if([button isEqual:eventFilterTitleButton] || [button isEqual:filterTitleSoccer]){
        //[button setBackgroundImage:[UIImage imageNamed:@"event_filter_selected.png"] forState:UIControlStateNormal];
        [eventFilterTitleButton setBackgroundImage:[UIImage imageNamed:@"event_filter_selected.png"] forState:UIControlStateNormal];
        [shiftFilterTitleButton setBackgroundImage:[UIImage imageNamed:@"shiftline_filter_unselected.png"] forState:UIControlStateNormal];
        //[self.eventsView setHidden:FALSE];
        [self.linePeriodView setHidden:FALSE];
        [self.usersView setHidden:FALSE];
        //[self.eventsView setUserInteractionEnabled:TRUE];
        [self.linePeriodView setUserInteractionEnabled:TRUE];
        [self.linePeriodView setUserInteractionEnabled:TRUE];
        [horzDivider setHidden:FALSE];
        [shiftlineHorzDivider setHidden:TRUE];
        for(UIView *pButton in eventsandPlayerButtons){
            [pButton setHidden:FALSE];
        }
        [strengthDivider setHidden:TRUE];
        //for(UIView *view in strengthCoachPickButtons){
        //    [view setHidden:TRUE];
        // }
        for(UIView *button in shiftButtons){
            [button setHidden:TRUE];
        }
        [shiftlineHorzDivider setHidden:TRUE];
        // [self.playerView setScrollEnabled:TRUE];
        
        if(ceil((float)[[globals.TYPES_OF_TAGS objectAtIndex:0] count]/ROWS_IN_EVENTS) <5){
            [self.eventsView setContentSize:CGSizeMake(self.eventsView.frame.size.width, 200)];
        }else{
            [self.eventsView setContentSize:CGSizeMake((ceil((float)[[globals.TYPES_OF_TAGS objectAtIndex:0] count]/ROWS_IN_EVENTS))*123, 200)];
        }
        if(ceil(globals.ARRAY_OF_HOCKEY_PLAYERS.count/ROWS_IN_PLAYERS) <7){
            [self.playerView setContentSize:CGSizeMake(self.playerView.frame.size.width, 200)];
        }else{
            [self.playerView setContentSize:CGSizeMake(self.playerView.frame.size.width+ (ceil(globals.ARRAY_OF_HOCKEY_PLAYERS.count/ROWS_IN_PLAYERS)-5)*83, 200)];
        }
        
    }else{
        [eventFilterTitleButton setBackgroundImage:[UIImage imageNamed:@"event_filter_unselected.png"] forState:UIControlStateNormal];
        [shiftFilterTitleButton setBackgroundImage:[UIImage imageNamed:@"shiftline_filter_selected.png"] forState:UIControlStateNormal];
        //[self.eventsView setHidden:TRUE];
        [self.linePeriodView setHidden:TRUE];
        [self.usersView setHidden:TRUE];
        //[self.eventsView setUserInteractionEnabled:FALSE];
        [self.linePeriodView setUserInteractionEnabled:FALSE];
        [self.linePeriodView setUserInteractionEnabled:FALSE];
        [horzDivider setHidden:TRUE];
        [shiftlineHorzDivider setHidden:FALSE];
        for(UIView *pButton in eventsandPlayerButtons){
            [pButton setHidden:TRUE];
        }
        [strengthDivider setHidden:FALSE];
        // for(UIView *view in strengthCoachPickButtons){
        //     [view setHidden:FALSE];
        // }
        for(UIView *button in shiftButtons){
            [button setHidden:FALSE];
        }
        [shiftlineHorzDivider setHidden:FALSE];
        //[self.playerView setScrollEnabled:FALSE];
        [self.eventsView setContentSize:CGSizeMake(self.eventsView.frame.size.width, 200)];
        [self.playerView setContentSize:CGSizeMake(self.playerView.frame.size.width, 200)];
    }
    [[superArgs objectForKey:@"controller"] slideFilterBox];
    [self changeFilterTitleImage];
    /*if (self.view.frame.origin.y >450) {
     [eventFilterTitleButton setBackgroundImage:[UIImage imageNamed:@"eventfilter.png"] forState:UIControlStateNormal];
     [shiftFilterTitleButton setBackgroundImage:[UIImage imageNamed:@"shiftlinefilter.png"] forState:UIControlStateNormal];
     
     }*/
    //  [eventFilterTitleButton setBackgroundImage:[UIImage imageNamed:@"eventfilter.png"] forState:UIControlStateNormal];
    //  [shiftFilterTitleButton setBackgroundImage:[UIImage imageNamed:@"shiftlinefilter.png"] forState:UIControlStateNormal];
    //   [[superArgs objectForKey:@"controller"] slideFilterBox];
    // //
}
-(void)changeFilterTitleImage{
    if (self.view.frame.origin.y >500) {
        [eventFilterTitleButton setBackgroundImage:[UIImage imageNamed:@"event_filter_unselected.png"] forState:UIControlStateNormal];
        [shiftFilterTitleButton setBackgroundImage:[UIImage imageNamed:@"shiftline_filter_unselected.png"] forState:UIControlStateNormal];
        //[filterTitleSoccer setBackgroundImage:[UIImage imageNamed:@"event_filter_unselected.png"] forState:UIControlStateNormal];
    }
}








//remodelling filtering for each sport ////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////

//logic that's used to create the attributes dictionary for football
-(void)createEventsAttributesDictFootball: (UIButton *)button
{
    BOOL isButtonSelected = button.isSelected ? FALSE : TRUE; // is the button already selected? if it is then set it to not selected
    [button setSelected:isButtonSelected];
    NSString *att=button.accessibilityLabel; //the attribute of the button that was selected is equal to its accessibility value (set earlier)
    NSMutableArray *attValues; //an array containing all of the attributes that the user want to filter by
    
    
    
    if(isButtonSelected) //If the button is set to selected then we need to add the filter to our array of filter attributes.
    {
        //if we hit a tag colour, change its alpha value so user sees its selected
        if([button.accessibilityLabel isEqualToString:@"colours"])
        {
            [button setAlpha:1.0f];
            [taggedButtonArr addObject:button];
        }
        
        if(![[taggedAttsDict allKeys] containsObject:att]) // if the attributes dictionary doesn't have anything in it for this attribute, we initialise it
        {
            if([att isEqualToString:@"periods"]){ // filter by quarters
                attValues = [[NSMutableArray alloc]initWithObjects:[NSString stringWithFormat:@"%d",button.tag], nil];
                [taggedAttsDict setObject:attValues forKey:att];
            }else if([att isEqualToString:@"offline"]){ //filter by downs -- this is offensive downs
                NSMutableArray *attValues;
                attValues = [[NSMutableArray alloc]initWithObjects:[NSString stringWithFormat:@"line_f_o_%d",button.tag], nil];
                
                [taggedAttsDict setObject:attValues forKey:att];
                
            }else if([att isEqualToString:@"defline"]){ // filter by defensive downs
                NSMutableArray *attValues;
                attValues = [[NSMutableArray alloc]initWithObjects:[NSString stringWithFormat:@"line_f_d_%d",button.tag], nil];
                
                [taggedAttsDict setObject:attValues forKey:att];
            }else{
                NSMutableArray *attValues = [[NSMutableArray alloc]initWithObjects:button.titleLabel.text, nil];
                [taggedAttsDict setObject:attValues forKey:att];
            }
            [taggedButtonArr addObject:button]; //we are going to add the selected buttons to an array so that we can deselect all of them easily
        }else {//if the dictionary already has stuff in it for this attribute we just add the value or remove it without initialising anything
            
            if([att isEqualToString:@"periods"]){
                [[taggedAttsDict objectForKey:att] addObject:[NSString stringWithFormat:@"%d",button.tag]];
            }else if([att isEqualToString:@"offline"]){
                
                if ([[taggedAttsDict objectForKey:att] containsObject:@"allDownOff"]) {
                    [[taggedAttsDict objectForKey:att] removeObject:@"allDownOff"];
                    for(UIButton *button in [taggedButtonDictShift objectForKey:@"shiftline"]){
                        if ( [button.accessibilityLabel isEqualToString:@"offline"]) {
                            button.selected = FALSE;
                            [[taggedButtonDictShift objectForKey:@"shiftline"] removeObject:button];
                            break;
                        }
                    }
                }
                
                [[taggedAttsDict objectForKey:att] addObject:[NSString stringWithFormat:@"line_f_o_%d",button.tag]];
                
                
            }else if([att isEqualToString:@"defline"]){
                if ([globals.WHICH_SPORT isEqualToString:@"hockey"]) {
                    [[taggedAttsDict objectForKey:att] addObject:[NSString stringWithFormat:@"line_d_%d",button.tag]];
                }else if([globals.WHICH_SPORT isEqualToString:@"football"]){
                    
                    if ([[taggedAttsDict objectForKey:att] containsObject:@"allDownOff"]) {
                        [[taggedAttsDict objectForKey:att] removeObject:@"allDownOff"];
                        for(UIButton *button in [taggedButtonDictShift objectForKey:@"shiftline"]){
                            if ([button.accessibilityLabel isEqualToString:@"defline"]) {
                                button.selected = FALSE;
                                [[taggedButtonDictShift objectForKey:@"shiftline"] removeObject:button];
                                break;
                            }
                        }
                    }
                    [[taggedAttsDict objectForKey:att] addObject:[NSString stringWithFormat:@"line_f_d_%d",button.tag]];
                    
                }
                
            }else{
                [[taggedAttsDict objectForKey:att] addObject:button.titleLabel.text];
            }
            [taggedButtonArr addObject:button];
            
        }
    }else{ // if the button is already selected then we have to remove the object .. if(isButtonSelected)
        [taggedButtonArr removeObject:button];
        if([button.accessibilityLabel isEqualToString:@"colours"])
        {
            [button setAlpha:0.1f];
            //[selectedButtonsforSoccer removeObject:button];
        }
        NSString *att = button.accessibilityLabel;
        
        if(!([globals.WHICH_SPORT isEqualToString:@"hockey"]||[globals.WHICH_SPORT isEqualToString:@"football"]) && ([att isEqualToString:@"periods"]||[att isEqualToString:@"offline"]||[att isEqualToString:@"defline"] || [att isEqualToString:@"players"] || [att isEqualToString:@"events"] || [att isEqualToString:@"zone"] || [att isEqualToString:@"half"] || [att isEqualToString:@"coachpick"]))
        {
            if([att isEqualToString:@"coachpick"]){
                [[taggedAttsDict objectForKey:att] removeObject:[NSString stringWithFormat:@"%d",1]];
            }else if([att isEqualToString:@"half"]){
                [[taggedAttsDict objectForKey:att] removeObject:[NSString stringWithFormat:@"%d",button.tag]];
                //[selectedButtonsforSoccer removeObject:button];
            }else{
                [[taggedAttsDict objectForKey:att] removeObject:button.titleLabel.text];
                //[selectedButtonsforSoccer removeObject:button];
            }
        }else{
            if([att isEqualToString:@"periods"]){
                [[taggedAttsDict objectForKey:att] removeObject:[NSString stringWithFormat:@"%d",button.tag]];
            }else if([att isEqualToString:@"offline"]){
                if ([globals.WHICH_SPORT isEqualToString:@"hockey"]) {
                    [[taggedAttsDict objectForKey:att] removeObject:[NSString stringWithFormat:@"line_f_%d",button.tag]];
                }else if([globals.WHICH_SPORT isEqualToString:@"football"]){
                    [[taggedAttsDict objectForKey:att] removeObject:[NSString stringWithFormat:@"line_f_o_%d",button.tag]];
                    
                }
                
            }
            else if([att isEqualToString:@"defline"]){
                if ([globals.WHICH_SPORT isEqualToString:@"hockey"]) {
                    [[taggedAttsDict objectForKey:att] removeObject:[NSString stringWithFormat:@"line_d_%d",button.tag]];
                }else if([globals.WHICH_SPORT isEqualToString:@"football"]){
                    [[taggedAttsDict objectForKey:att] removeObject:[NSString stringWithFormat:@"line_f_d_%d",button.tag]];
                    
                }
                
            }else{
                [[taggedAttsDict objectForKey:att] removeObject:button.titleLabel.text];
            }
        }
        if([[taggedAttsDict objectForKey:att]count]<1)
        {
            [taggedAttsDict removeObjectForKey:att];
        }
    }
    
    [globals.TAGGED_ATTS_DICT setDictionary:taggedAttsDict];
    [self sortAllClipsWithAttributes];
    
}
/////////////////////////////-(void)createEventsAttributesDictFootball: (UIButton *)button


//logic that's used to create the attributes dictionary for Hockey
-(void)createEventsAttributesDictHockey: (UIButton *)button
{
    BOOL isButtonSelected = button.isSelected ? FALSE : TRUE;
    [button setSelected:isButtonSelected];
    NSString *att=button.accessibilityLabel; //the attribute of the button that was selected is equal to its accessibility value (set earlier)
    
    if(isButtonSelected)//when the button is turned on
    {
        if([button.accessibilityLabel isEqualToString:@"colours"])
        {
            [button setAlpha:1.0f];
            [taggedButtonArr addObject:button];
        }
        
        //initialise array if it doesn't exist as an attribute
        if(![[taggedAttsDict allKeys] containsObject:att])
        {
            if([att isEqualToString:@"periods"]){
                NSMutableArray *attValues = [[NSMutableArray alloc]initWithObjects:[NSString stringWithFormat:@"%d",button.tag], nil];
                [taggedAttsDict setObject:attValues forKey:att];
            }else if([att isEqualToString:@"offline"]){
                NSMutableArray *attValues;
                attValues = [[NSMutableArray alloc]initWithObjects:[NSString stringWithFormat:@"line_f_%d",button.tag], nil];
                [taggedAttsDict setObject:attValues forKey:att];
                
            }else if([att isEqualToString:@"defline"]){
                NSMutableArray *attValues;
                
                attValues = [[NSMutableArray alloc]initWithObjects:[NSString stringWithFormat:@"line_d_%d",button.tag], nil];
                [taggedAttsDict setObject:attValues forKey:att];
            }else{
                NSMutableArray *attValues = [[NSMutableArray alloc]initWithObjects:button.titleLabel.text, nil];
                [taggedAttsDict setObject:attValues forKey:att];
            }
            [taggedButtonArr addObject:button];
        }else{
            
            if([att isEqualToString:@"periods"]){
                [[taggedAttsDict objectForKey:att] addObject:[NSString stringWithFormat:@"%d",button.tag]];
            }else if([att isEqualToString:@"offline"]){
                [[taggedAttsDict objectForKey:att] addObject:[NSString stringWithFormat:@"line_f_%d",button.tag]];
                
            }else if([att isEqualToString:@"defline"]){
                
                [[taggedAttsDict objectForKey:att] addObject:[NSString stringWithFormat:@"line_d_%d",button.tag]];
                
            }else{
                [[taggedAttsDict objectForKey:att] addObject:button.titleLabel.text];
            }
            [taggedButtonArr addObject:button];
        }
        
    }else{
        [taggedButtonArr removeObject:button];
        if([button.accessibilityLabel isEqualToString:@"colours"])
        {
            [button setAlpha:0.1f];
        }
        NSString *att = button.accessibilityLabel;
        
        if([att isEqualToString:@"periods"]){
            [[taggedAttsDict objectForKey:att] removeObject:[NSString stringWithFormat:@"%d",button.tag]];
        }else if([att isEqualToString:@"offline"]){
            [[taggedAttsDict objectForKey:att] removeObject:[NSString stringWithFormat:@"line_f_%d",button.tag]];
            
        }
        else if([att isEqualToString:@"defline"]){
            [[taggedAttsDict objectForKey:att] removeObject:[NSString stringWithFormat:@"line_d_%d",button.tag]];
            
        }else{
            [[taggedAttsDict objectForKey:att] removeObject:button.titleLabel.text];
        }
    }
    if([[taggedAttsDict objectForKey:att]count]<1)
    {
        [taggedAttsDict removeObjectForKey:att];
    }
    
    [globals.TAGGED_ATTS_DICT setDictionary:taggedAttsDict];
    [self sortAllClipsWithAttributes];
}
/////////////-(void)createEventsAttributesDictHockey: (UIButton *)button

//logic that's used to create the attributes dictionary for Soccer
-(void)createEventsAttributesDictSoccer: (UIButton *)button
{
    BOOL isButtonSelected = button.isSelected ? FALSE : TRUE;
    [button setSelected:isButtonSelected];
    NSString *att=button.accessibilityLabel; //the attribute of the button that was selected is equal to its accessibility value (set earlier)
    
    if(isButtonSelected) //if i just selected the button
    {
        if ([att isEqualToString:@"coachpick"]) {
            [taggedAttsDict removeAllObjects];
            for(CustomButton *button in taggedButtonArr){
                if([button.accessibilityLabel isEqualToString:@"colours"])
                {
                    [button setAlpha:0.1f];
                }else{
                    [button setSelected:FALSE];
                }
            }
            [taggedButtonArr removeAllObjects];
        }else{
            if ([[taggedAttsDict allKeys] containsObject:@"coachpick"]) {
                [taggedAttsDict removeObjectForKey:@"coachpick"];
                [coachPickButtonSoccer setSelected:FALSE];
            }
            
            if([button.accessibilityLabel isEqualToString:@"colours"])
            {
                [button setAlpha:1.0f];
                
                //for soccer
                if (!taggedButtonArr) {
                    taggedButtonArr =[[NSMutableArray alloc]initWithArray:[[NSArray alloc] initWithObjects:button, nil]];
                }else{
                    [taggedButtonArr addObject:button];
                }
            }
        }
        
        if(![[taggedAttsDict allKeys] containsObject:att])
        {
                if ([att isEqualToString:@"coachpick"]) {
                    NSMutableArray *attValues = [[NSMutableArray alloc]initWithObjects:[NSString stringWithFormat:@"%d",1], nil];
                    [taggedAttsDict setObject:attValues forKey:att];
                }else if([att isEqualToString:@"half"]){
                    NSMutableArray *attValues = [[NSMutableArray alloc]initWithObjects:[NSString stringWithFormat:@"%d",button.tag], nil];
                    [taggedAttsDict setObject:attValues forKey:att];
                    if (!taggedButtonArr) {
                        taggedButtonArr =[[NSMutableArray alloc]initWithArray:[[NSArray alloc] initWithObjects:button, nil]];
                    }else{
                        [taggedButtonArr addObject:button];
                    }
                }else{
                    NSMutableArray *attValues = [[NSMutableArray alloc]initWithObjects:button.titleLabel.text, nil];
                    [taggedAttsDict setObject:attValues forKey:att];
                    
                    if (!taggedButtonArr) {
                        taggedButtonArr =[[NSMutableArray alloc]initWithArray:[[NSArray alloc] initWithObjects:button, nil]];
                    }else{
                        [taggedButtonArr addObject:button];
                    }
                }
            
        }else{
            
         
                if ([att isEqualToString:@"coachpick"]) {
                    [[taggedAttsDict objectForKey:att] addObject:[NSString stringWithFormat:@"%d",1]];
                }else if([att isEqualToString:@"half"]){
                    [[taggedAttsDict objectForKey:att] addObject:[NSString stringWithFormat:@"%d",button.tag]];
                    [taggedButtonArr addObject:button];
                }else{
                    [[taggedAttsDict objectForKey:att] addObject:button.titleLabel.text];
                    [taggedButtonArr addObject:button];
                }
            }
        
    }else{
        [taggedButtonArr removeObject:button];
        if([button.accessibilityLabel isEqualToString:@"colours"])
        {
            [button setAlpha:0.1f];
            //[selectedButtonsforSoccer removeObject:button];
        }
        NSString *att = button.accessibilityLabel;
        
     
            if([att isEqualToString:@"coachpick"]){
                [[taggedAttsDict objectForKey:att] removeObject:[NSString stringWithFormat:@"%d",1]];
            }else if([att isEqualToString:@"half"]){
                [[taggedAttsDict objectForKey:att] removeObject:[NSString stringWithFormat:@"%d",button.tag]];
                //[selectedButtonsforSoccer removeObject:button];
            }else{
                [[taggedAttsDict objectForKey:att] removeObject:button.titleLabel.text];
                //[selectedButtonsforSoccer removeObject:button];
            }
        
        if([[taggedAttsDict objectForKey:att]count]<1)
        {
            [taggedAttsDict removeObjectForKey:att];
        }
    }
    
    [globals.TAGGED_ATTS_DICT setDictionary:taggedAttsDict];
    [self sortAllClipsWithAttributes];
    
}
////////////////////-(void)createEventsAttributesDictSoccer: (UIButton *)button


-(void)createEventsAttributesDictRugby: (UIButton *)button
//logic that's used to create the attributes dictionary for Rugby -- for now same as soccer
{
    BOOL isButtonSelected = button.isSelected ? FALSE : TRUE;
    [button setSelected:isButtonSelected];
    NSString *att=button.accessibilityLabel; //the attribute of the button that was selected is equal to its accessibility value (set earlier)
    
    if(isButtonSelected) //if i just selected the button
    {
        if ([att isEqualToString:@"coachpick"]) {
            [taggedAttsDict removeAllObjects];
            for(CustomButton *button in taggedButtonArr){
                if([button.accessibilityLabel isEqualToString:@"colours"])
                {
                    [button setAlpha:0.1f];
                }else{
                    [button setSelected:FALSE];
                }
            }
            [taggedButtonArr removeAllObjects];
        }else{
            if ([[taggedAttsDict allKeys] containsObject:@"coachpick"]) {
                [taggedAttsDict removeObjectForKey:@"coachpick"];
                [coachPickButtonSoccer setSelected:FALSE];
            }
            
            if([button.accessibilityLabel isEqualToString:@"colours"])
            {
                [button setAlpha:1.0f];
                
                //for soccer
                if (!taggedButtonArr) {
                    taggedButtonArr =[[NSMutableArray alloc]initWithArray:[[NSArray alloc] initWithObjects:button, nil]];
                }else{
                    [taggedButtonArr addObject:button];
                }
            }
        }
        
        if(![[taggedAttsDict allKeys] containsObject:att])
        {
            if(([att isEqualToString:@"periods"]||[att isEqualToString:@"offline"]||[att isEqualToString:@"defline"] || [att isEqualToString:@"players"] || [att isEqualToString:@"events"] || [att isEqualToString:@"zone"] || [att isEqualToString:@"half"] || [att isEqualToString:@"coachpick"]))
            {
                if ([att isEqualToString:@"coachpick"]) {
                    NSMutableArray *attValues = [[NSMutableArray alloc]initWithObjects:[NSString stringWithFormat:@"%d",1], nil];
                    [taggedAttsDict setObject:attValues forKey:att];
                }else if([att isEqualToString:@"half"]){
                    NSMutableArray *attValues = [[NSMutableArray alloc]initWithObjects:[NSString stringWithFormat:@"%d",button.tag], nil];
                    [taggedAttsDict setObject:attValues forKey:att];
                    if (!taggedButtonArr) {
                        taggedButtonArr =[[NSMutableArray alloc]initWithArray:[[NSArray alloc] initWithObjects:button, nil]];
                    }else{
                        [taggedButtonArr addObject:button];
                    }
                }else{
                    NSMutableArray *attValues = [[NSMutableArray alloc]initWithObjects:button.titleLabel.text, nil];
                    [taggedAttsDict setObject:attValues forKey:att];
                    
                    if (!taggedButtonArr) {
                        taggedButtonArr =[[NSMutableArray alloc]initWithArray:[[NSArray alloc] initWithObjects:button, nil]];
                    }else{
                        [taggedButtonArr addObject:button];
                    }
                }
            }
        }else{
            
            if(([att isEqualToString:@"periods"]||[att isEqualToString:@"offline"]||[att isEqualToString:@"defline"] || [att isEqualToString:@"players"] || [att isEqualToString:@"events"] || [att isEqualToString:@"zone"] || [att isEqualToString:@"half"] || [att isEqualToString:@"coachpick"]))
            {
                if ([att isEqualToString:@"coachpick"]) {
                    [[taggedAttsDict objectForKey:att] addObject:[NSString stringWithFormat:@"%d",1]];
                }else if([att isEqualToString:@"half"]){
                    [[taggedAttsDict objectForKey:att] addObject:[NSString stringWithFormat:@"%d",button.tag]];
                    [taggedButtonArr addObject:button];
                }else{
                    [[taggedAttsDict objectForKey:att] addObject:button.titleLabel.text];
                    [taggedButtonArr addObject:button];
                }
            }
        }
    }else{
        [taggedButtonArr removeObject:button];
        if([button.accessibilityLabel isEqualToString:@"colours"])
        {
            [button setAlpha:0.1f];
            //[selectedButtonsforSoccer removeObject:button];
        }
        NSString *att = button.accessibilityLabel;
        
        if(([att isEqualToString:@"periods"]||[att isEqualToString:@"offline"]||[att isEqualToString:@"defline"] || [att isEqualToString:@"players"] || [att isEqualToString:@"events"] || [att isEqualToString:@"zone"] || [att isEqualToString:@"half"] || [att isEqualToString:@"coachpick"]))
        {
            if([att isEqualToString:@"coachpick"]){
                [[taggedAttsDict objectForKey:att] removeObject:[NSString stringWithFormat:@"%d",1]];
            }else if([att isEqualToString:@"half"]){
                [[taggedAttsDict objectForKey:att] removeObject:[NSString stringWithFormat:@"%d",button.tag]];
                //[selectedButtonsforSoccer removeObject:button];
            }else{
                [[taggedAttsDict objectForKey:att] removeObject:button.titleLabel.text];
                //[selectedButtonsforSoccer removeObject:button];
            }
        }
        if([[taggedAttsDict objectForKey:att]count]<1)
        {
            [taggedAttsDict removeObjectForKey:att];
        }
    }
    
}
//////////////-(void)createEventsAttributesDictRugby: (UIButton *)button


//logic that's used to create the attributes dictionary for football
-(void)createShiftAttributesDictFootball: (UIButton *)button
{
    BOOL isButtonSelected = button.isSelected ? FALSE : TRUE;
    [button setSelected:isButtonSelected];
    if(isButtonSelected)
    {
        NSString *att = button.accessibilityLabel;
        [self unselectButtonsInShift:button];
        
        if(![[taggedAttsDictShift allKeys] containsObject:att])
        {
            
            
            NSMutableArray *buttonObj = [[NSMutableArray alloc]initWithObjects:button, nil];
            
            if([att isEqualToString:@"type"]){
                NSMutableArray *attValues;
                attValues = [[NSMutableArray alloc]initWithObjects:button.titleLabel.text, nil];
                
                [taggedAttsDictShift setObject:attValues forKey:att];
                if (![[taggedButtonDictShift allKeys]containsObject:@"shiftline"]) {
                    [taggedButtonDictShift setObject:buttonObj forKey:@"shiftline"];
                }else{
                    [[taggedButtonDictShift objectForKey:@"shiftline"] addObject:button];
                }
            }
            
            
            if([att isEqualToString:@"offline"]){
                NSMutableArray *attValues;
                attValues = [[NSMutableArray alloc]initWithObjects:[NSString stringWithFormat:@"line_f_o_%d",button.tag], nil];
                
                
                [taggedAttsDictShift setObject:attValues forKey:att];
                if (![[taggedButtonDictShift allKeys]containsObject:@"shiftline"]) {
                    [taggedButtonDictShift setObject:buttonObj forKey:@"shiftline"];
                }else{
                    [[taggedButtonDictShift objectForKey:@"shiftline"] addObject:button];
                }
                // [shiftLineButtons addObject:button];
            }else if([att isEqualToString:@"defline"]){
                NSMutableArray *attValues;
                attValues = [[NSMutableArray alloc]initWithObjects:[NSString stringWithFormat:@"line_f_d_%d",button.tag], nil];
                
                [taggedAttsDictShift setObject:attValues forKey:att];
                if (![[taggedButtonDictShift allKeys]containsObject:@"shiftline"]) {
                    [taggedButtonDictShift setObject:buttonObj forKey:@"shiftline"];
                }else{
                    [[taggedButtonDictShift objectForKey:@"shiftline"] addObject:button];
                }
            }else if([att isEqualToString:@"coachpick"]){
                NSMutableArray *attValues = [[NSMutableArray alloc]initWithObjects:[NSString stringWithFormat:@"%d",1], nil];
                [taggedAttsDictShift setObject:attValues forKey:att];
                if (![[taggedButtonDictShift allKeys]containsObject:@"coachpick"]) {
                    [taggedButtonDictShift setObject:buttonObj forKey:@"coachpick"];
                }else{
                    [[taggedButtonDictShift objectForKey:@"coachpick"] addObject:button];
                }
            }else if([att isEqualToString:@"allstrength"]){
                NSMutableArray *attValues = [[NSMutableArray alloc]initWithObjects:att, nil];
                [taggedAttsDictShift setObject:attValues forKey:att];
                if (![[taggedButtonDictShift allKeys]containsObject:@"allstrength"]) {
                    [taggedButtonDictShift setObject:buttonObj forKey:@"allstrength"];
                }else{
                    [[taggedButtonDictShift objectForKey:@"allstrength"] addObject:button];
                }
            }else if([att isEqualToString:@"homestr"] || [att isEqualToString:@"awaystr"]){
                NSMutableArray *attValues = [[NSMutableArray alloc]initWithObjects:button.titleLabel.text, nil];
                [taggedAttsDictShift setObject:attValues forKey:att];
                if (![[taggedButtonDictShift allKeys]containsObject:@"strength"]) {
                    [taggedButtonDictShift setObject:buttonObj forKey:@"strength"];
                }else{
                    [[taggedButtonDictShift objectForKey:@"strength"] addObject:button];
                }
            }else if([att isEqualToString:@"posgain"] || [att isEqualToString:@"neggain"]){
                NSMutableArray *attValues = [[NSMutableArray alloc]initWithObjects:[NSString stringWithFormat:@"%d",button.tag], nil];
                [taggedAttsDictShift setObject:attValues forKey:att];
                if (![[taggedButtonDictShift allKeys]containsObject:@"gain"]) {
                    [taggedButtonDictShift setObject:buttonObj forKey:@"gain"];
                }else{
                    [[taggedButtonDictShift objectForKey:@"gain"] addObject:button];
                }
                
            }
        }else{
            
            if([att isEqualToString:@"offline"]){
                
                if ([[taggedAttsDictShift objectForKey:att] containsObject:@"allDownOff"]) {
                    [[taggedAttsDictShift objectForKey:att] removeObject:@"allDownOff"];
                    for(UIButton *button in [taggedButtonDictShift objectForKey:@"shiftline"]){
                        if ([button.accessibilityLabel isEqualToString:@"offline"]) {
                            button.selected = FALSE;
                            [[taggedButtonDictShift objectForKey:@"shiftline"] removeObject:button];
                            break;
                        }
                    }
                }
                
                [[taggedAttsDictShift objectForKey:att] addObject:[NSString stringWithFormat:@"line_f_o_%d",button.tag]];
                
                
                
                
                [[taggedButtonDictShift objectForKey:@"shiftline"] addObject:button];
            }else if([att isEqualToString:@"defline"]){
                
                
                if ([[taggedAttsDictShift objectForKey:att] containsObject:@"allDownDef"]) {
                    [[taggedAttsDictShift objectForKey:att] removeObject:@"allDownDef"];
                    for(UIButton *button in [taggedButtonDictShift objectForKey:@"shiftline"]){
                        if ([button.accessibilityLabel isEqualToString:@"defline"]) {
                            button.selected = FALSE;
                            [[taggedButtonDictShift objectForKey:@"shiftline"] removeObject:button];
                            break;
                        }
                    }
                }
                
                [[taggedAttsDictShift objectForKey:att] addObject:[NSString stringWithFormat:@"line_f_d_%d",button.tag]];
                
                
                
                [[taggedButtonDictShift objectForKey:@"shiftline"] addObject:button];
            }else if([att isEqualToString:@"coachpick"]){
                [[taggedAttsDictShift objectForKey:att] addObject:[NSString stringWithFormat:@"%d",1]];
                [[taggedButtonDictShift objectForKey:@"coachpick"] addObject:button];
            }else if([att isEqualToString:@"allstrength"]){
                [[taggedAttsDictShift objectForKey:att] addObject:att];
                [[taggedButtonDictShift objectForKey:@"allstrength"] addObject:button];
            }else if([att isEqualToString:@"homestr"] || [att isEqualToString:@"awaystr"]){
                [[taggedAttsDictShift objectForKey:att] addObject:button.titleLabel.text];
                [[taggedButtonDictShift objectForKey:@"strength"] addObject:button];
            }else if([att isEqualToString:@"posgain"] || [att isEqualToString:@"neggain"]){
                [[taggedAttsDictShift objectForKey:att] addObject:[NSString stringWithFormat:@"%d",button.tag]];
                [[taggedButtonDictShift objectForKey:@"gain"] addObject:button];
                
            }
            
        }
    }else{
        NSString *att = button.accessibilityLabel;
        
        
        if([att isEqualToString:@"type"])
        {
            [[taggedAttsDictShift objectForKey:att] removeObject:button.titleLabel.text];
        }
        
        
        if([att isEqualToString:@"offline"]){
            
            [[taggedAttsDictShift objectForKey:att] removeObject:[NSString stringWithFormat:@"line_f_o_%d",button.tag]];
            
            
            
            
            [[taggedButtonDictShift objectForKey:@"shiftline"] removeObject:button];
        }else if([att isEqualToString:@"defline"]){
            [[taggedAttsDictShift objectForKey:att] removeObject:[NSString stringWithFormat:@"line_f_d_%d",button.tag]];
            
            
            [[taggedButtonDictShift objectForKey:@"shiftline"] removeObject:button];
        }else if([att isEqualToString:@"coachpick"]){
            [[taggedAttsDictShift objectForKey:att] removeObject:[NSString stringWithFormat:@"%d",1]];
            [[taggedButtonDictShift objectForKey:@"coachpick"] removeObject:button];
        }else if([att isEqualToString:@"allstrength"]){
            [[taggedAttsDictShift objectForKey:att] removeObject:att];
            [[taggedButtonDictShift objectForKey:@"allstrength"] removeObject:button];
        }else if([att isEqualToString:@"homestr"] || [att isEqualToString:@"awaystr"]){
            [[taggedAttsDictShift objectForKey:att] removeObject:button.titleLabel.text];
            [[taggedButtonDictShift objectForKey:@"strength"] removeObject:button];
        }else if([att isEqualToString:@"posgain"] || [att isEqualToString:@"neggain"]){
            [[taggedAttsDictShift objectForKey:att] removeObject:[NSString stringWithFormat:@"%d",button.tag]];
            [[taggedButtonDictShift objectForKey:@"gain"] removeObject:button];
        }
        
        if([[taggedAttsDictShift objectForKey:att]count]<1)
        {
            [taggedAttsDictShift removeObjectForKey:att];
        }
    }
    
    [globals.TAGGED_ATTS_DICT_SHIFT setDictionary:taggedAttsDictShift];
    [self sortAllClipsBySelectingforShiftFiltering];
    
}
////-(void)createShiftAttributesDictFootball: (UIButton *)button

//logic that's used to create the attributes dictionary for Hockey
-(void)createShiftAttributesDictHockey: (UIButton *)button
{
    BOOL isButtonSelected = button.isSelected ? FALSE : TRUE;
    [button setSelected:isButtonSelected];
    if(isButtonSelected)
    {
        NSString *att;
        att = button.accessibilityLabel;
        //unselect all the other buttons which is not in the same section of the current selected button
        [self unselectButtonsInShift:button];
        if(![[taggedAttsDictShift allKeys] containsObject:att])
        {
            NSMutableArray *buttonObj = [[NSMutableArray alloc]initWithObjects:button, nil];
            
                if([att isEqualToString:@"offline"]){
                    NSMutableArray *attValues;
                    attValues = [[NSMutableArray alloc]initWithObjects:[NSString stringWithFormat:@"line_f_%d",button.tag], nil];
                    [taggedAttsDictShift setObject:attValues forKey:att];
                    if (![[taggedButtonDictShift allKeys]containsObject:@"shiftline"]) {
                        [taggedButtonDictShift setObject:buttonObj forKey:@"shiftline"];
                    }else{
                        [[taggedButtonDictShift objectForKey:@"shiftline"] addObject:button];
                    }
                }else if([att isEqualToString:@"defline"]){
                    NSMutableArray *attValues;
                    attValues = [[NSMutableArray alloc]initWithObjects:[NSString stringWithFormat:@"line_d_%d",button.tag], nil];
                    
                    [taggedAttsDictShift setObject:attValues forKey:att];
                    if (![[taggedButtonDictShift allKeys]containsObject:@"shiftline"]) {
                        [taggedButtonDictShift setObject:buttonObj forKey:@"shiftline"];
                    }else{
                        [[taggedButtonDictShift objectForKey:@"shiftline"] addObject:button];
                    }
                }else if([att isEqualToString:@"coachpick"]){
                    NSMutableArray *attValues = [[NSMutableArray alloc]initWithObjects:[NSString stringWithFormat:@"%d",1], nil];
                    [taggedAttsDictShift setObject:attValues forKey:att];
                    if (![[taggedButtonDictShift allKeys]containsObject:@"coachpick"]) {
                        [taggedButtonDictShift setObject:buttonObj forKey:@"coachpick"];
                    }else{
                        [[taggedButtonDictShift objectForKey:@"coachpick"] addObject:button];
                    }
                }else if([att isEqualToString:@"allstrength"]){
                    NSMutableArray *attValues = [[NSMutableArray alloc]initWithObjects:att, nil];
                    [taggedAttsDictShift setObject:attValues forKey:att];
                    if (![[taggedButtonDictShift allKeys]containsObject:@"allstrength"]) {
                        [taggedButtonDictShift setObject:buttonObj forKey:@"allstrength"];
                    }else{
                        [[taggedButtonDictShift objectForKey:@"allstrength"] addObject:button];
                    }
                }else if([att isEqualToString:@"homestr"] || [att isEqualToString:@"awaystr"]){
                    NSMutableArray *attValues = [[NSMutableArray alloc]initWithObjects:button.titleLabel.text, nil];
                    [taggedAttsDictShift setObject:attValues forKey:att];
                    if (![[taggedButtonDictShift allKeys]containsObject:@"strength"]) {
                        [taggedButtonDictShift setObject:buttonObj forKey:@"strength"];
                    }else{
                        [[taggedButtonDictShift objectForKey:@"strength"] addObject:button];
                    }
                }
               
        }else{
            
            if([att isEqualToString:@"offline"]){
                
                [[taggedAttsDictShift objectForKey:att] addObject:[NSString stringWithFormat:@"line_f_%d",button.tag]];
                
                [[taggedButtonDictShift objectForKey:@"shiftline"] addObject:button];
            }else if([att isEqualToString:@"defline"]){
                [[taggedAttsDictShift objectForKey:att] addObject:[NSString stringWithFormat:@"line_d_%d",button.tag]];
                
                [[taggedButtonDictShift objectForKey:@"shiftline"] addObject:button];
            }else if([att isEqualToString:@"coachpick"]){
                [[taggedAttsDictShift objectForKey:att] addObject:[NSString stringWithFormat:@"%d",1]];
                [[taggedButtonDictShift objectForKey:@"coachpick"] addObject:button];
            }else if([att isEqualToString:@"allstrength"]){
                [[taggedAttsDictShift objectForKey:att] addObject:att];
                [[taggedButtonDictShift objectForKey:@"allstrength"] addObject:button];
            }else if([att isEqualToString:@"homestr"] || [att isEqualToString:@"awaystr"]){
                [[taggedAttsDictShift objectForKey:att] addObject:button.titleLabel.text];
                [[taggedButtonDictShift objectForKey:@"strength"] addObject:button];
            }else if([att isEqualToString:@"posgain"] || [att isEqualToString:@"neggain"]){
                [[taggedAttsDictShift objectForKey:att] addObject:[NSString stringWithFormat:@"%d",button.tag]];
                [[taggedButtonDictShift objectForKey:@"distance"] addObject:button];
            }
        }
    }else{
        NSString *att = button.accessibilityLabel;
        
        if([att isEqualToString:@"offline"]){
            [[taggedAttsDictShift objectForKey:att] removeObject:[NSString stringWithFormat:@"line_f_%d",button.tag]];
            [[taggedButtonDictShift objectForKey:@"shiftline"] removeObject:button];
        }else if([att isEqualToString:@"defline"]){
            
            [[taggedAttsDictShift objectForKey:att] removeObject:[NSString stringWithFormat:@"line_d_%d",button.tag]];
            [[taggedButtonDictShift objectForKey:@"shiftline"] removeObject:button];
        }else if([att isEqualToString:@"coachpick"]){
            [[taggedAttsDictShift objectForKey:att] removeObject:[NSString stringWithFormat:@"%d",1]];
            [[taggedButtonDictShift objectForKey:@"coachpick"] removeObject:button];
        }else if([att isEqualToString:@"allstrength"]){
            [[taggedAttsDictShift objectForKey:att] removeObject:att];
            [[taggedButtonDictShift objectForKey:@"allstrength"] removeObject:button];
        }else if([att isEqualToString:@"homestr"] || [att isEqualToString:@"awaystr"]){
            [[taggedAttsDictShift objectForKey:att] removeObject:button.titleLabel.text];
            [[taggedButtonDictShift objectForKey:@"strength"] removeObject:button];
        }
        
        if([[taggedAttsDictShift objectForKey:att]count]<1)
        {
            [taggedAttsDictShift removeObjectForKey:att];
        }
    }
    
    [globals.TAGGED_ATTS_DICT_SHIFT setDictionary:taggedAttsDictShift];
    [self sortAllClipsBySelectingforShiftFiltering];
    
}

//logic that's used to create the attributes dictionary for soccer
-(void)createShiftAttributesDictSoccer: (UIButton *)button
{
    BOOL isButtonSelected = button.isSelected ? FALSE : TRUE;
    [button setSelected:isButtonSelected];
    if(isButtonSelected)
    {
        NSString *att;
        att = button.accessibilityLabel;
        [self unselectButtonsInShift:button];
        if(![[taggedAttsDictShift allKeys] containsObject:att])
        {
            if([att isEqualToString:@"offline"]||[att isEqualToString:@"defline"]||[att isEqualToString:@"homestr"] || [att isEqualToString:@"awaystr"]||[att isEqualToString:@"allstrength"]||[att isEqualToString:@"coachpick"])
            {
                NSMutableArray *attValues = [[NSMutableArray alloc]initWithObjects:[NSString stringWithFormat:@"%d",button.tag], nil];
                [taggedAttsDictShift setObject:attValues forKey:att];
            }
        }else{
            
            if(([att isEqualToString:@"offline"]||[att isEqualToString:@"defline"]||[att isEqualToString:@"homestr"] || [att isEqualToString:@"awaystr"]||[att isEqualToString:@"allstrength"]||[att isEqualToString:@"coachpick"]))
            {
                
                [[taggedAttsDictShift objectForKey:att] addObject:[NSString stringWithFormat:@"%d",button.tag]];
            }
            
        }
    }
}
////-(void)createShiftAttributesDictSoccer: (UIButton *)button

//logic that's used to create the attributes dictionary for rugby
-(void)createShiftAttributesDictRugby: (UIButton *)button
{
    BOOL isButtonSelected = button.isSelected ? FALSE : TRUE;
    [button setSelected:isButtonSelected];
    if(isButtonSelected)
    {
        NSString *att;
        att = button.accessibilityLabel;
        [self unselectButtonsInShift:button];
        if(![[taggedAttsDictShift allKeys] containsObject:att])
        {
            if([att isEqualToString:@"offline"]||[att isEqualToString:@"defline"]||[att isEqualToString:@"homestr"] || [att isEqualToString:@"awaystr"]||[att isEqualToString:@"allstrength"]||[att isEqualToString:@"coachpick"])
            {
                NSMutableArray *attValues = [[NSMutableArray alloc]initWithObjects:[NSString stringWithFormat:@"%d",button.tag], nil];
                [taggedAttsDictShift setObject:attValues forKey:att];
            }
        }else{
            
            if(([att isEqualToString:@"offline"]||[att isEqualToString:@"defline"]||[att isEqualToString:@"homestr"] || [att isEqualToString:@"awaystr"]||[att isEqualToString:@"allstrength"]||[att isEqualToString:@"coachpick"]))
            {
                
                [[taggedAttsDictShift objectForKey:att] addObject:[NSString stringWithFormat:@"%d",button.tag]];
            }
            
        }
    }
}
////-(void)createShiftAttributesDictrugby: (UIButton *)button


@end
