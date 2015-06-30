//
//  Live2BenchTagUIViewController.m
//  Live2BenchNative
//
//  Created by dev on 2014-12-10.
//  Copyright (c) 2014 DEV. All rights reserved.
//

#import "Live2BenchTagUIViewController.h"

#import "UserCenter.h"
//#import "Globals.h"


#pragma mark - Tray
@interface Tray : UIView
{
    NSString            * swipeSide;
    NSMutableDictionary * swipeControlDict;
}
- (id)initWithSide:(NSString*)side buttonList:(NSMutableArray*)aButtonList;;
@end

@implementation Tray
{
    BOOL            maximized;
    NSMutableArray  * buttonList;
}



- (id)initWithSide:(NSString*)side buttonList:(NSMutableArray*)aButtonList;
{
    self = [super init];
    swipeSide = side;
    if (self) {
        UISwipeGestureRecognizer *oneFingerSwipeLeft = [[UISwipeGestureRecognizer alloc]
                                                        initWithTarget:self
                                                        action:@selector(oneFingerSwipeLeft:)];
        [oneFingerSwipeLeft setDirection:UISwipeGestureRecognizerDirectionLeft];
        [oneFingerSwipeLeft setCancelsTouchesInView:YES];
//        [self addGestureRecognizer:oneFingerSwipeLeft];
        
        //register right swipe
        UISwipeGestureRecognizer *oneFingerSwipeRight = [[UISwipeGestureRecognizer alloc]
                                                         initWithTarget:self
                                                         action:@selector(oneFingerSwipeRight:)] ;
        [oneFingerSwipeRight setDirection:UISwipeGestureRecognizerDirectionRight];
        [oneFingerSwipeLeft setCancelsTouchesInView:YES];
//        [self addGestureRecognizer:oneFingerSwipeRight];
        
        //key "left" represents the tag name buttons on the left side, and key value equals to 0 means, the buttons are not swiped out, 1 means, the buttons are swiped out; same for the right  buttons
        swipeControlDict = [[NSMutableDictionary alloc]initWithObjects:[NSArray arrayWithObjects:@"0",@"0", nil] forKeys:[NSArray arrayWithObjects:@"left",@"right", nil]];
        

    }
    return self;
}


- (void)oneFingerSwipeLeft:(UITapGestureRecognizer *)recognizer
{
    
    //remember x and y are reversed in fullscreen
    CGPoint tempCenter = self.center;
    [UIView animateWithDuration:0.3
                     animations:^{
                         if ([swipeSide isEqualToString:@"left"]) {
                             //if left buttons have already swiped out,then swipe back to left
                             if ([[swipeControlDict objectForKey:@"left"]integerValue]) {
                                 [self setCenter:CGPointMake(tempCenter.x-self.frame.size.width/2, tempCenter.y)];
                                 for(BorderButton *button in self.subviews)
                                 {
                                     [button setContentEdgeInsets:UIEdgeInsetsMake(3, 3+self.frame.size.width/2, 3, 3)];
                                     [button changeBackgroundColor:[UIColor clearColor] :1.0];
                                 }
                                 [swipeControlDict setValue:@"0" forKey:@"left"];
                             }
                             
                         }else{
                             //if right buttons have not been swiped out, then swipe out to left
                             if (![[swipeControlDict objectForKey:@"right"]integerValue]) {
                                 [self setCenter:CGPointMake(tempCenter.x-self.frame.size.width/2, tempCenter.y)];
                                 for(BorderButton *button in self.subviews)
                                 {
                                     [button setContentEdgeInsets:UIEdgeInsetsMake(3, 3, 3, 3)];
                                     [button changeBackgroundColor:[UIColor whiteColor] :0.8];
                                 }
                                 [swipeControlDict setValue:@"1" forKey:@"right"];
                             }
                         }
                     }completion:^(BOOL finished){[self setUserInteractionEnabled:TRUE];
                         
                     }];
}


- (void)oneFingerSwipeRight:(UITapGestureRecognizer *)recognizer
{
    
    //remember x and y are reversed in fullscreen check to see if the current touched view is on the left side(-15.5) or on the right side (930.5).
    //if it is on the left side and it's current position is 81.5 meaning that it is swiped out, set it back to 81.5. if it is on the right side and its current
    //position is less then 930.5 meaning the right side has not been swiped in, we set the position to its default position(don't move)
    
    //NOTE: use view.center.y because the ys and xs are reversed in fullscreen (fs is always in portrait)
    CGPoint tempCenter = self.center;
    
    [UIView animateWithDuration:0.3
                     animations:^{
                         if ([swipeSide isEqualToString:@"left"]) {
                             //if left buttons have not been swiped out, swipe out to right
                             if (![[swipeControlDict objectForKey:@"left"]integerValue]) {
                                 [self setCenter:CGPointMake(tempCenter.x+self.frame.size.width/2, tempCenter.y)];
                                 for(BorderButton *button in self.subviews)
                                 {
                                     [button setContentEdgeInsets:UIEdgeInsetsMake(3, 3, 3, 3)];
                                     [button changeBackgroundColor:[UIColor whiteColor] :0.8];
                                 }
                                 [swipeControlDict setValue:@"1" forKey:@"left"];
                                 //////NSLog(@"overlay:%@",NSStringFromCGRect(self.view.frame));
                                 
                             }
                             
                         }else{
                             //if right buttons have been swiped out, swipe back to right
                             if ([[swipeControlDict objectForKey:@"right"]integerValue]) {
                                 [self setCenter:CGPointMake(tempCenter.x+self.frame.size.width/2, tempCenter.y)];
                                 for(BorderButton *button in self.subviews)
                                 {
                                     [button setContentEdgeInsets:UIEdgeInsetsMake(3, 3, 3, 3+self.frame.size.width/2)];
                                     [button changeBackgroundColor:[UIColor clearColor] :1.0];
                                 }
                                 [swipeControlDict setValue:@"0" forKey:@"right"];
                             }
                         }
                     }completion:^(BOOL finished){[self setUserInteractionEnabled:TRUE];
                     }];
    
    
}



@end















/*
 This class manages the creation of the side tags as well as displays them

 
 */
#pragma mark - Live2BenchTagUIViewController



@implementation Live2BenchTagUIViewController
{
    UIView * placementView;
    id fullScreenObserver;
    Tray   * _leftTray;
    Tray   * _rightTray;

}

@synthesize currentEvent                = _currentEvent;
@synthesize enabled                     = _enabled;
@synthesize hidden                      = _hidden;
@synthesize buttonSize                  = _buttonSize;
@synthesize gap                         = _gap;
@synthesize topOffset                   = _topOffset;
@synthesize state                       = _state;
@synthesize fullScreenViewController    = _fullScreenViewController;
@synthesize buttonState;

-(id)initWithView:(UIView*)view
{
    self = [super init];
    if (self) {

        tagButtonsLeft      = [[NSMutableArray alloc]init];
        tagButtonsRight     = [[NSMutableArray alloc]init];
        buttons             = [[NSMutableDictionary alloc]init];
        placementView       = view;
        tagCount            = 0;
        _topOffset          = 100.0f; // space from top of the screen
        _buttonSize         = CGSizeMake( 124.0f, 30.0f );
        _gap                = 2;
        _enabled            = NO;
        _state              = STATE_SMALLSCREEN;
        _leftTray           = [[Tray alloc]initWithSide:@"left" buttonList:tagButtonsLeft];
        _rightTray          = [[Tray alloc]initWithSide:@"right" buttonList:tagButtonsRight];
    }

    return self;
}

// this builds the tags from the supplied data
-(void)inputTagData:(NSArray*)listOfDicts
{
 
    [self clear]; // clear if any is present
    
    NSMutableArray * left  = [[NSMutableArray alloc]init];
    NSMutableArray * right = [[NSMutableArray alloc]init];
    
    for (NSDictionary * btnData in listOfDicts) {
         // Builds the button and adds it to the view
         //[placementView addSubview:[self _buildButton:btnData]];
        if ([[btnData objectForKey:@"position"]isEqualToString:@"left"]) {
            [left addObject:btnData];
        } else {
            [right addObject:btnData];
        }

     }
    
   
    NSArray *sortedLeft = [left sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
        NSNumber * first   = [(NSDictionary *)a objectForKey:@"order"];
        NSNumber * second  = [(NSDictionary *)b objectForKey:@"order"];
        NSComparisonResult result =  [first compare:second];
        
        
        return result;
    }];

    NSArray *sortedRight = [right sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
        NSNumber * first   = [(NSDictionary *)a objectForKey:@"order"];
        NSNumber * second  = [(NSDictionary *)b objectForKey:@"order"];
        NSComparisonResult result =  [first compare:second];
        
        
        return result;
    }];
    
    for (NSDictionary * dc in sortedLeft) {
        [self _buildButton:dc];
    }
    
    for (NSDictionary * dc in sortedRight) {
        [self _buildButton:dc];
    }
    

    self.enabled = _enabled; // sets the fade after build base off last setting of enabled
    

    
    [_leftTray setFrame:CGRectMake(0,
                                   _topOffset,
                                   _buttonSize.width,
                                   CGRectGetMaxY(((UIButton*)[tagButtonsLeft lastObject]).frame ))];
    
    [_rightTray setFrame:CGRectMake(1024 - _buttonSize.width,
                                    _topOffset,
                                    _buttonSize.width,
                                    CGRectGetMaxY(((UIButton*)[tagButtonsRight lastObject]).frame ))];
    
    [placementView addSubview:_leftTray];
    [placementView addSubview:_rightTray];
}



-(void)addActionToAllTagButtons:(SEL)sel addTarget:(id)target forControlEvents:(UIControlEvents)controlEvent
{
    for (NSMutableArray * list in @[tagButtonsLeft,tagButtonsRight]) {
        for (BorderButton * btn in list) {
            [btn addTarget:target action:sel forControlEvents:controlEvent];
        }
    }
}


-(void)clear
{
    tagCount = 0;
    for (NSMutableArray * list in @[tagButtonsLeft,tagButtonsRight]) {
        for (BorderButton * btn in list) {
            [btn removeFromSuperview];
        }
        [list removeAllObjects];
    }
    [buttons removeAllObjects];
}


/*-(BorderButton *)_buildButton:(NSDictionary*)dict
{
    BorderButton * btn = [BorderButton buttonWithType:UIButtonTypeCustom];
    [btn setTitle:[dict objectForKey:@"name"] forState:UIControlStateNormal];
    [btn setTag:tagCount++];
    
    [buttons setObject:btn forKey:[dict objectForKey:@"name"]];
    
    if( [[dict objectForKey:@"side"] isEqualToString:@"left"]  || [[dict objectForKey:@"position"] isEqualToString:@"left"]){

        [btn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
        [btn setAccessibilityValue:@"left"];
        
        [btn setFrame:CGRectMake(0,
                                 ( [tagButtonsLeft count] * (_buttonSize.height + _gap) ) + 0,
                                 _buttonSize.width,
                                 _buttonSize.height) ];
        
        [tagButtonsLeft addObject:btn];
        [_leftTray addSubview:btn];
        // TODO DEPREICATED START
//        if (![[Globals instance].LEFT_TAG_BUTTONS_NAME containsObject:[dict objectForKey:@"name"]]) {
//            [[Globals instance].LEFT_TAG_BUTTONS_NAME addObject:[dict objectForKey:@"name"]];
//        }
        // TODO DEPREICATED END
        
    } else { /// Right Tags
        
        [btn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
        [btn setAccessibilityValue:@"right"];
//        self.view.bounds.size.width - _buttonSize.width
        [btn setFrame:CGRectMake(0,
                                 ( [tagButtonsRight count] * (_buttonSize.height + _gap) ) + 0,
                                 _buttonSize.width,
                                 _buttonSize.height) ];
        
        [tagButtonsRight addObject:btn];
        [_rightTray addSubview:btn];
        // TODO DEPREICATED START
//        if (![[Globals instance].RIGHT_TAG_BUTTONS_NAME containsObject:[dict objectForKey:@"name"]]) {
//            [[Globals instance].RIGHT_TAG_BUTTONS_NAME addObject:[dict objectForKey:@"name"]];
//        }
        // TODO DEPREICATED END
    
    }
    
    //This check is to make the filler buttons blank
    
    if ([[dict objectForKey:@"name"] isEqualToString:@"--"] || [[dict objectForKey:@"name"] isEqualToString:@"-"]) {
        btn.hidden = YES;
    }
    
    return btn;
}*/

-(SideTagButton *)_buildButton:(NSDictionary*)dict
{
    SideTagButton * btn = [SideTagButton buttonWithType:UIButtonTypeCustom];
    [btn setTitle:[dict objectForKey:@"name"] forState:UIControlStateNormal];
    [btn setTag:tagCount++];
    
    [buttons setObject:btn forKey:[dict objectForKey:@"name"]];
    
    if( [[dict objectForKey:@"side"] isEqualToString:@"left"]  || [[dict objectForKey:@"position"] isEqualToString:@"left"]){
        
        [btn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
        [btn setAccessibilityValue:@"left"];
        
        [btn setFrame:CGRectMake(0,
                                 ( [tagButtonsLeft count] * (_buttonSize.height + _gap) ) + 0,
                                 _buttonSize.width,
                                 _buttonSize.height) ];
        
        [tagButtonsLeft addObject:btn];
        [_leftTray addSubview:btn];
        // TODO DEPREICATED START
        //        if (![[Globals instance].LEFT_TAG_BUTTONS_NAME containsObject:[dict objectForKey:@"name"]]) {
        //            [[Globals instance].LEFT_TAG_BUTTONS_NAME addObject:[dict objectForKey:@"name"]];
        //        }
        // TODO DEPREICATED END
        
    } else { /// Right Tags
        
        [btn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
        [btn setAccessibilityValue:@"right"];
        //        self.view.bounds.size.width - _buttonSize.width
        [btn setFrame:CGRectMake(0,
                                 ( [tagButtonsRight count] * (_buttonSize.height + _gap) ) + 0,
                                 _buttonSize.width,
                                 _buttonSize.height) ];
        
        [tagButtonsRight addObject:btn];
        [_rightTray addSubview:btn];
        // TODO DEPREICATED START
        //        if (![[Globals instance].RIGHT_TAG_BUTTONS_NAME containsObject:[dict objectForKey:@"name"]]) {
        //            [[Globals instance].RIGHT_TAG_BUTTONS_NAME addObject:[dict objectForKey:@"name"]];
        //        }
        // TODO DEPREICATED END
        
    }
    
    //This check is to make the filler buttons blank
    
    if ([[dict objectForKey:@"name"] isEqualToString:@"--"] || [[dict objectForKey:@"name"] isEqualToString:@"-"]) {
        btn.hidden = YES;
    }
    
    return btn;
}

/*-(BorderButton*)getButtonByName:(NSString*)btnName
{

    return [buttons objectForKey:btnName];

}*/
-(SideTagButton*) getButtonByName:(NSString*)btnName
{
    return [buttons objectForKey:btnName];
}

#pragma mark - Observers



#pragma mark - Full Screen Controlls

-(void)minimize
{
    if (![_state isEqualToString:STATE_FULLSCREEN]) return;
}

-(void)maximize
{
    if (![_state isEqualToString:STATE_FULLSCREEN]) return;
}

-(void)close
{
    if (![_state isEqualToString:STATE_FULLSCREEN]) return;
}
-(void)open
{
    if (![_state isEqualToString:STATE_FULLSCREEN]) return;
}





#pragma mark - Getters and Setters
/////////////////////////////////////////////////// getter and setters

/*-(void)setEnabled:(BOOL)enabled
{
    [self willChangeValueForKey:@"enabled"];
    _enabled = enabled;

    
    CGFloat     alpha       = (_enabled)?   1.0f:0.2f;
    BOOL        interEnable = (_enabled)?   TRUE:FALSE;
    
    for (NSMutableArray * list in @[tagButtonsLeft,tagButtonsRight]) {
        for (BorderButton * btn in list) {
            [btn setAlpha:alpha];
            [btn setUserInteractionEnabled:interEnable];
        }
    }
   
    [self didChangeValueForKey:@"enabled"];
        
}*/


-(BOOL)enabled
{
    return _enabled;
}



/*-(void)setHidden:(BOOL)hidden
{
    [self willChangeValueForKey:@"hidden"];
    _enabled = hidden;
    
     for (NSMutableArray * list in @[tagButtonsLeft,tagButtonsRight]) {
        for (BorderButton * btn in list) {
            [btn setHidden:_enabled];
        }
    }
    
    [self didChangeValueForKey:@"hidden"];
}

-(BOOL)hidden
{
    return _hidden;
}*/

-(void)setButtonState:(SideTagButtonModes)mode{
//    if (self.buttonState == SideTagButtonModeToggle && mode == SideTagButtonModeRegular)
//    {
//        [self closeAllOpenTagButtons];
//    }
//    
    
    for (NSMutableArray * list in @[tagButtonsLeft,tagButtonsRight]) {
        for (SideTagButton * btn in list) {
            [btn setMode:mode];
        }
    }
//    self.buttonState = mode;
}

                       
-(void)setState:(NSString *)state
{

    if (state == _state || (!_fullScreenViewController && [state isEqualToString:STATE_FULLSCREEN])) return;
    
    [self willChangeValueForKey:@"state"];
    if ([state isEqualToString:STATE_FULLSCREEN]){

    } else if ([state isEqualToString:STATE_SMALLSCREEN]){

        
        
    }
    _state = state;
    [self didChangeValueForKey:@"state"];
}

-(NSString *)state
{
    return _state;
}


-(void)setFullScreenViewController:(FullScreenViewController *)fullScreenViewController
{
    // removes observer if one is attached... just preventing future memory leaks
    if (_fullScreenViewController) {
//        [_fullScreenViewController removeObserver:self forKeyPath:@"enable" context:fullScreenContext];
    }
   
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(_fullScreen) name:NOTIF_FULLSCREEN     object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(_fullScreen) name:NOTIF_SMALLSCREEN    object:nil];
     _fullScreenViewController = fullScreenViewController;
    
    // add observers
//   [_fullScreenViewController addObserver:self forKeyPath:@"enable" options:NSKeyValueObservingOptionNew context:fullScreenContext];
}

-(FullScreenViewController *)fullScreenViewController
{
    return _fullScreenViewController;
}

-(void)_fullScreen
{

    if (_fullScreenViewController.enable) {
        [_fullScreenViewController.view addSubview:_leftTray];
        //[_leftTray setCenter:CGPointMake(_leftTray.center.x/2, _leftTray.center.y)];
        [_fullScreenViewController.view addSubview:_rightTray];
        //[_rightTray setCenter:CGPointMake(_rightTray.center.x/2, _rightTray.center.y)];
    } else {
        [placementView addSubview:_leftTray];
        [placementView addSubview:_rightTray];
    }
}

-(void)allToggleOnOpenTags:(Event *)event
{
    if ([event.name isEqualToString:_currentEvent.name]) {
        return;
    }
    
    _currentEvent = event;
    NSMutableArray *eventTags = event.tags;
    
    NSArray * tempList = [tagButtonsLeft arrayByAddingObjectsFromArray:tagButtonsRight];
    

    for (SideTagButton * btn1 in tempList) {
        btn1.isOpen = NO;
    }

    for (Tag * tag in eventTags) {
        for (SideTagButton * btn2 in tempList) {
            // if the tag is open and has a duration Id and is from this divice
            if (tag.name == btn2.titleLabel.text && tag.type == TagTypeOpenDuration && tag.deviceID == [[[UIDevice currentDevice] identifierForVendor]UUIDString]){
                btn2.isOpen = YES;
                btn2.durationID = tag.durationID;
            }
            
            
        }
    }
    


}

// add the observer to the current event so when we receive the open duration tag all the buttons would be enable again
-(void)onEventChange:(Event*)event
{
    if (_currentEvent) {
        [[NSNotificationCenter defaultCenter]removeObserver:self name:NOTIF_TAG_RECEIVED object:_currentEvent];
    }
    
    if (!event){
        _currentEvent = nil;
    }else{
        _currentEvent = event;
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(enableButton:) name:NOTIF_TAG_RECEIVED object:_currentEvent];
    }
}

// diable user interaction for all the side button until we receive the open duration tag from the server
-(void)disEnableButton
{
    NSArray * tempList = [tagButtonsLeft arrayByAddingObjectsFromArray:tagButtonsRight];
    for (SideTagButton * btn1 in tempList){
        if (btn1.mode == SideTagButtonModeToggle) {
            btn1.userInteractionEnabled = false;
        }
    }
    
}

// enable all the buttons again
-(void)enableButton:(NSNotification*)note
{
     NSArray * tempList = [tagButtonsLeft arrayByAddingObjectsFromArray:tagButtonsRight];
    for (SideTagButton * btn1 in tempList){
        if (btn1.mode == SideTagButtonModeToggle) {
            btn1.userInteractionEnabled = true;
        }
    }
}



/*-(void)unHighlightButton:(SideTagButton *)button
{
    NSArray * tempList = [tagButtonsLeft arrayByAddingObjectsFromArray:tagButtonsRight];
    for (SideTagButton * btn1 in tempList){
        if ([btn1.titleLabel.text isEqualToString:button.titleLabel.text]) {
            btn1.highlighted = false;
        }
    }
}*/

-(void)closeAllOpenTagButtons
{
    NSArray * tempList = [tagButtonsLeft arrayByAddingObjectsFromArray:tagButtonsRight];
    for (SideTagButton * btn1 in tempList){
        if (btn1.isOpen) {
            [btn1 sendActionsForControlEvents:UIControlEventTouchUpInside];
        }
    }

}



@end
