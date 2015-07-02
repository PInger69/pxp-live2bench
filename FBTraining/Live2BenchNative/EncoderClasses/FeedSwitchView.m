//
//  FeedSwitchView.m
//  Live2BenchNative
//
//  Created by dev on 10/28/2014.
//  Copyright (c) 2014 DEV. All rights reserved.
//

#import "FeedSwitchView.h"

#define FEEDS @"feeds"
#define PRIMARY_COLOR   PRIMARY_APP_COLOR
#define SECONDARY_COLOR [UIColor darkGrayColor]
#define DESELECT_COLOR  [UIColor lightGrayColor]

/**
 *   This class is just the View it will show a set of buttons and
 */



@implementation FeedSwitchView
{
    EncoderManager      * _encoderManager;
    NSString            * _primaryFeed;
    NSMutableArray      * _alternativeFeeds; // array for strings
    NSMutableDictionary * _buttonToFeedDict;
    CGSize              _buttonSize;
    BOOL                _secondarySelected;
    Event               * currentEvent;
}

@synthesize primaryPosition     = _primaryPosition;
@synthesize secondaryPosition   = _secondaryPosition;
@synthesize buttonArray         = _buttonArray;
@synthesize buttonDict          = _buttonDict;


-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _buttonArray        = [[NSMutableArray alloc]init];
        _primaryPosition    = 0;
        _secondaryPosition  = -1;
        _buttonToFeedDict   = [[NSMutableDictionary alloc]init];
        _buttonDict         = [[NSMutableDictionary alloc]init];
        _buttonSize         = CGSizeMake(frame.size.width, frame.size.height);
        _secondarySelected  = NO;

        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(onMovmentCheck:)       name:NOTIF_MOTION_ALARM object:nil];
        
//        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(onEventChange:)       name:NOTIF_EVENT_CHANGE object:nil];
        
        
    }
    return self;
}



-(id)initWithFrame:(CGRect)frame encoderManager:(EncoderManager*)encoderManager
{
    self = [super initWithFrame:frame];
    if (self) {
        _encoderManager     = encoderManager;
        _buttonArray        = [[NSMutableArray alloc]init];
        _primaryPosition    = 0;
        _secondaryPosition  = -1;
        _buttonToFeedDict   = [[NSMutableDictionary alloc]init];
        _buttonDict         = [[NSMutableDictionary alloc]init];
        _buttonSize         = CGSizeMake(frame.size.width, frame.size.height);
        _secondarySelected  = NO;
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(onEncoderCountChange:) name:NOTIF_ENCODER_COUNT_CHANGE object:nil];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(onEncoderCountChange:) name:NOTIF_ENCODER_FEED_HAVE_CHANGED object:nil];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(onMovmentCheck:)       name:NOTIF_MOTION_ALARM object:nil];

        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(onEventChange:)       name:NOTIF_EVENT_CHANGE object:nil];
        

    }
    return self;
}

-(instancetype) initWithFrame:(CGRect)frame andClipData: (NSDictionary *) clipData{
    self = [super initWithFrame:frame];
    if (self) {
        //_encoderManager     = encoderManager;
        _buttonArray        = [[NSMutableArray alloc]init];
        _primaryPosition    = 0;
        _secondaryPosition  = -1;
        _buttonToFeedDict   = [[NSMutableDictionary alloc]init];
        _buttonDict         = [[NSMutableDictionary alloc]init];
        _buttonSize         = CGSizeMake(frame.size.width, frame.size.height);
        _secondarySelected  = NO;
    }
    return self;
}


-(void)watchCurrentEvent:(Event*)aEvent
{
    [self clear];
    currentEvent = aEvent;
    [self buildButtonsWithData:aEvent.feeds];
}


-(void)onMovmentCheck:(NSNotification*)note
{

    NSDictionary * data = note.userInfo;
    NSArray      * alarms = [data objectForKey:@"alarms"];
    NSArray      * feedsOnEnc = [data objectForKey:@"feeds"];
    
    for (NSString * btnName1 in feedsOnEnc) {
        UIButton * btn1 = [_buttonDict objectForKey:btnName1];
        [btn1 setBackgroundColor:[UIColor clearColor]];
    }
    
    if ([alarms count]>0) {
        for (NSString * btnName2 in alarms) {
            UIButton * btn2 = [_buttonDict objectForKey:btnName2];
            [btn2 setBackgroundColor:[UIColor redColor]];
        }
        
    }
}


//-(void)onEventChange:(NSNotification*)note
//{
//    [self clear];
//    [self buildButtonsWithData:currentEvent.feeds];
//    
//}


/**
 *  This method will clear all buttons and build new ones based of the data sent in
 *
 *  @param list array of dicts e.g  @{@"name":FEED,@"name":FEED,@"name":FEED},
 */
-(void)buildButtonsWithData:(NSDictionary*)aList
{
    if ([aList isKindOfClass:[NSArray class]]){
        return; // messy clean up later
    }

    if ([aList count]>1) self.hidden = NO;

    // Clean up previous buttons
    [_buttonArray makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [_buttonArray removeAllObjects];
    [_buttonToFeedDict removeAllObjects];
    [_buttonDict removeAllObjects];
    NSArray * list      = [aList allKeys];
    CGPoint myXY        = self.frame.origin;
    NSUInteger count    = list.count;

    float buttonWidth   = _buttonSize.width;
    float buttonHeight  = _buttonSize.height;
    
    
    
    for (int i=0; i<count; i++) {
        NSString        * theKey    = [list objectAtIndex:i];
        Feed            * feed      = [aList objectForKey:theKey];
        UIButton        * button    = [self makeButton:theKey key:theKey];
        
        [button setFrame:CGRectMake(buttonWidth * i, 0, buttonWidth, buttonHeight)];
        [button addTarget:self action:@selector(onButtonPress:) forControlEvents:UIControlEventTouchUpInside];
        [button setTag:i];
        
//        button.layer.borderColor = [DESELECT_COLOR CGColor];
        
        if (i == _secondaryPosition && i != _primaryPosition){
            [button setTitleColor:SECONDARY_COLOR forState:UIControlStateNormal];
//            button.layer.borderColor = [SECONDARY_COLOR CGColor];
        } else if (i == _primaryPosition){
            [button setTitleColor:PRIMARY_COLOR forState:UIControlStateNormal];
//            button.layer.borderColor = [PRIMARY_COLOR CGColor];
        }
        
        [_buttonDict setObject:button forKey:theKey];
        [_buttonToFeedDict setObject:feed forKey:theKey]; // this dict is to keep the feeds when the button is pressed it will call the feeds based on it self
        [_buttonArray addObject: button];
        [self addSubview:button];
   
    }
    [self setFrame:CGRectMake(myXY.x, myXY.y, buttonWidth*count, buttonHeight)];
    if (_buttonArray.count <= 1) {
        self.hidden = YES;
    }
}

-(UIButton*)makeButton:(NSString*)aName key:(NSString*)aKey
{
    UIButton * button =  [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 10, 10)];
    [button setTitle:aName forState:UIControlStateNormal];
    [button setAccessibilityValue:aKey];
    [button setTitleColor:DESELECT_COLOR forState:UIControlStateNormal];
    button.layer.borderColor = [PRIMARY_COLOR CGColor];
    button.layer.borderWidth = 1;
    return button;
}

-(Feed*)feedFromKey:(NSString*)key
{
    Feed * theFeed = [_buttonToFeedDict objectForKey:key];
    return theFeed;
}

// Primary is alway HQ and a secondary is all LQ
-(void)onButtonPress:(id)sender
{
    UIButton * button = sender;
    NSUInteger tagPic = button.tag;

    if (tagPic == _primaryPosition) return;
    
    [_buttonArray enumerateObjectsUsingBlock:^(UIButton *obj, NSUInteger idx, BOOL *stop) {
        [obj setTitleColor:DESELECT_COLOR forState:UIControlStateNormal];
//        obj.layer.borderColor = [DESELECT_COLOR CGColor];
        
    }];
    
    [self colorize: [_buttonArray objectAtIndex:_primaryPosition] color:PRIMARY_COLOR];
    
    
    if ( tagPic != _secondaryPosition && tagPic != _primaryPosition){
        _secondarySelected = YES;
        self.secondaryPosition  = tagPic;
        [self colorize: [_buttonArray objectAtIndex:_secondaryPosition] color:SECONDARY_COLOR];
       
    } else if (tagPic == _secondaryPosition && !_secondarySelected) {
        _secondarySelected = YES;
        self.secondaryPosition = _secondaryPosition;
        [self colorize: [_buttonArray objectAtIndex:_secondaryPosition] color:SECONDARY_COLOR];
    } else if (tagPic == _secondaryPosition && _secondarySelected) {
        _secondarySelected = NO;
        self.secondaryPosition = _secondaryPosition;
    }
    
    
    
    
//    if ( tagPic != _secondaryPosition && tagPic != _primaryPosition){
//        self.secondaryPosition  = tagPic;
////        _alternativeFeeds            = button.accessibilityValue;// to be solved
//    } else if (tagPic == _secondaryPosition && tagPic != _primaryPosition) {
//        self.primaryPosition    = tagPic;
//        _primaryFeed            = button.accessibilityValue;//This is to save the primarty feed selection on ecoder changes
//    } else if (tagPic != _secondaryPosition && tagPic == _primaryPosition) {
//        self.primaryPosition    = tagPic;
//        _primaryFeed            = button.accessibilityValue;
//    }

//    [self colorize: [_buttonArray objectAtIndex:_secondaryPosition] color:SECONDARY_COLOR];

    _primaryFeed = ((UIButton*)[_buttonArray objectAtIndex:_primaryPosition]).accessibilityValue;
}

-(void)swap
{
    if (_secondaryPosition == _primaryPosition) return;
   
    NSUInteger temp     = _primaryPosition;
    _primaryPosition    = _secondaryPosition;
    _secondaryPosition  = temp;
    
    [self colorize: [_buttonArray objectAtIndex:_secondaryPosition] color:SECONDARY_COLOR];
    [self colorize: [_buttonArray objectAtIndex:_primaryPosition] color:PRIMARY_COLOR];
}

-(void)colorize:(UIButton*)button color:(UIColor*)col
{
    [button setTitleColor:col  forState:UIControlStateNormal];
//     button.layer.borderColor = [col CGColor];
}

-(Feed*)primaryFeed
{
    if (![_buttonArray count]){
        return nil;
    }
    
    NSString * key      = ((UIButton*)[_buttonArray objectAtIndex:_primaryPosition]).accessibilityValue;
    return [self feedFromKey:key];
}

-(Feed*)secondaryFeed
{
    if (![_buttonArray count]){
        return nil;
    }

    NSString * key = ((UIButton*)[_buttonArray objectAtIndex:_secondaryPosition]).accessibilityValue;
    return [self feedFromKey:key];
}


/**
 *  Deselect buttons
 *
 *  @param index if you pass -1 it will deselect all
 */
-(void)deselectByIndex:(NSInteger)index
{
    
    if (index < 0){
        [_buttonArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            UIButton *butt = (UIButton *)obj;
            [butt setTitleColor:DESELECT_COLOR forState:UIControlStateNormal];
        }];
        return;
    }
    
    UIButton *obj =[_buttonArray objectAtIndex:index];
   [obj setTitleColor:DESELECT_COLOR forState:UIControlStateNormal];
//    obj.layer.borderColor = [DESELECT_COLOR CGColor];
}

-(BOOL)secondarySelected
{
    return _secondarySelected;
}



/**
 *  The removes all buttons
 */
-(void)clear
{
    [_buttonArray makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [_buttonArray removeAllObjects];
    [_buttonToFeedDict removeAllObjects];
    
    _primaryFeed    = nil;
  

}


-(void)setPrimaryPositionByName:(NSString*)btnName
{
    if([_buttonDict objectForKey:btnName]){
        UIButton * btn = [_buttonDict objectForKey:btnName];
        _primaryPosition = btn.tag;
        [self colorize: btn color:PRIMARY_COLOR];
    }
}




@end
