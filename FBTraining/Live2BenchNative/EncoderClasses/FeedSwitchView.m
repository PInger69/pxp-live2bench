//
//  FeedSwitchView.m
//  Live2BenchNative
//
//  Created by dev on 10/28/2014.
//  Copyright (c) 2014 DEV. All rights reserved.
//

#import "FeedSwitchView.h"
#define FEEDS @"feeds"
#define PRIMARY_COLOR   [UIColor yellowColor]
#define SECONDARY_COLOR [UIColor blueColor]
#define DESELECT_COLOR  [UIColor darkGrayColor]

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
}

@synthesize primaryPosition     = _primaryPosition;
@synthesize secondaryPosition   = _secondaryPosition;
@synthesize buttonArray         = _buttonArray;

-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _buttonArray         = [[NSMutableArray alloc]init];
        _primaryPosition     = 0;
        _secondaryPosition   = -1;
        //[[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(onEncoderCountChange:) name:NOTIF_ENCODER_COUNT_CHANGE object:encoderManager];
        _buttonSize          = CGSizeMake(frame.size.width, frame.size.height);
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
        _secondaryPosition  = 0;
        _buttonToFeedDict   = [[NSMutableDictionary alloc]init];
        _buttonSize         = CGSizeMake(frame.size.width, frame.size.height);
//        //        _videoPlayer        = videoPlayer;
//        //        _pips               = _videoPlayer.pips;
//        _buttonArray        = [[NSMutableArray alloc]init];
//        self.layer.borderColor = [[UIColor whiteColor]CGColor];
//        self.layer.borderWidth = 1;
//        
//        
//        
//        Pip * item = videoPlayer;
//        [item addObserver:self forKeyPath:@"avPlayer" options:(NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld) context:primaryContext];
//        //        for (id object in _pips) {
//        //            Pip * item = object;
//        //            [item addObserver:self forKeyPath:@"avPlayer" options:0 context:secondaryContext];
//        //        }
//        
//        [self addObserver:_encoderManager forKeyPath:FEEDS options:0 context:nil];
        
//        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(onEncoderCountChange:) name:NOTIF_ENCODER_FEED_HAVE_CHANGED object:encoderManager];

    }
    return self;
}


-(void)onEncoderCountChange:(NSNotification*)note
{
    [self buildButtonsWithData:[_encoderManager.feeds copy]];
}





/**
 *  This method will clear all buttons and build new ones based of the data sent in
 *
 *  @param list array of dicts e.g  @{@"name":FEED,@"name":FEED,@"name":FEED},
 */
-(void)buildButtonsWithData:(NSDictionary*)aList
{
    
    NSLog(@"Feed switch error on encoder change count");

    // Clean up previous buttons
    [_buttonArray makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [_buttonArray removeAllObjects];
    [_buttonToFeedDict removeAllObjects];
    
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
        
        button.layer.borderColor = [DESELECT_COLOR CGColor];
        
        if (i == _secondaryPosition && i != _primaryPosition){
            [button setTitleColor:SECONDARY_COLOR forState:UIControlStateNormal];
            button.layer.borderColor = [SECONDARY_COLOR CGColor];
        } else if (i == _primaryPosition){
            [button setTitleColor:PRIMARY_COLOR forState:UIControlStateNormal];
            button.layer.borderColor = [PRIMARY_COLOR CGColor];
        }
        
        
        [_buttonToFeedDict setObject:feed forKey:theKey]; // this dict is to keep the feeds when the button is pressed it will call the feeds based on it self
        [_buttonArray addObject: button];
        [self addSubview:button];
   
    }
    [self setFrame:CGRectMake(myXY.x, myXY.y, buttonWidth*count, buttonHeight)];
    
}

-(UIButton*)makeButton:(NSString*)aName key:(NSString*)aKey
{
    UIButton * button =  [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 10, 10)];
    [button setTitle:aName forState:UIControlStateNormal];
    [button setAccessibilityValue:aKey];
    [button setTitleColor:DESELECT_COLOR forState:UIControlStateNormal];
    button.layer.borderWidth = 1;
    return button;
}

-(Feed*)feedFromKey:(NSString*)key
{
    return [_buttonToFeedDict objectForKey:key];
}

// Primary is alway HQ and a secondary is all LQ
-(void)onButtonPress:(id)sender
{
    UIButton * button = sender;
    NSUInteger tagPic = button.tag;
    
    [_buttonArray enumerateObjectsUsingBlock:^(UIButton *obj, NSUInteger idx, BOOL *stop) {
        [obj setTitleColor:DESELECT_COLOR forState:UIControlStateNormal];
        obj.layer.borderColor = [DESELECT_COLOR CGColor];
    }];
    
    if ( tagPic != _secondaryPosition && tagPic != _primaryPosition){
        self.secondaryPosition  = tagPic;
//        _alternativeFeeds            = button.accessibilityValue;// to be solved
    } else if (tagPic == _secondaryPosition && tagPic != _primaryPosition) {
        self.primaryPosition    = tagPic;
        _primaryFeed            = button.accessibilityValue;//This is to save the primarty feed selection on ecoder changes
    } else if (tagPic != _secondaryPosition && tagPic == _primaryPosition) {
        self.primaryPosition    = tagPic;
        _primaryFeed            = button.accessibilityValue;
    }

    [self colorize: [_buttonArray objectAtIndex:_secondaryPosition] color:SECONDARY_COLOR];
    [self colorize: [_buttonArray objectAtIndex:_primaryPosition] color:PRIMARY_COLOR];
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
     button.layer.borderColor = [col CGColor];
}

@end
