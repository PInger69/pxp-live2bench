//
//  SeekButton.m
//  QuickTest
//
//  Created by dev on 6/16/2014.
//  Copyright (c) 2014 dev. All rights reserved.
//

#import "SeekButton.h"
#import "NumberedSeekerButton.h"


#pragma clang diagnostic ignored "-Warc-performSelector-leaks"




#define FORWARD @"forward"
#define BACKWARD @"backward"
#define LITTLE_ICON_DIMENSIONS      30 //the image is really 33x36
#define LARGE_ICON_DIMENSIONS       50 // this image is really 46x51
#define NORMAL_MARGIN               5
#define LARGE_MARGIN                10
#define WIDTH                       40
#define HEIGHT                      145
#define FULL_WIDTH                  70
#define FULL_HEIGHT                 250
#define DEFAULT_INDEX               2   // This is what the app graphics and speed start at

/**
 *  This class will manage all the seeking buttons in the project.
 *  all buttons will have the same velocity in their declared direction.
 *
 *  Usage:
 *  SeekButton * seeker = [SeekButton makeForwardAt:CGPointMake(50, 100)];
 *  [seeker onPressSeekPerformSelector:@selector(seekerMethod:) addTarget:self]; // seekerMethod is where you adjust video seek speed
 *  [self.view addSubview:seeker];
 */

@implementation SeekButton
{
    NumberedSeekerButton *mainButton;
    NSMutableArray *buttonList;
    UIView *backPlate;
    UILongPressGestureRecognizer *longPressGesture;
    NSString *direction;
    BOOL isFullScreen;
    SEL onSeekSelector;
    id seekingTarget;
    float   velocity;
}

@synthesize speed = _speed;

static int              currentForwardButtonIndex;
static int              currentBackwardButtonIndex;
static NSArray          * listOfSpeeds;
static NSMutableArray   * allSeekButtonsForward;
static NSMutableArray   * allSeekButtonsBackward;

+(void)initializeStatics
{
    allSeekButtonsForward 				= [[NSMutableArray alloc]init];
    allSeekButtonsBackward               = [[NSMutableArray alloc]init];
    
    listOfSpeeds                = @[ // in seconds
                                    [NSNumber numberWithFloat:0.1f],
                                    [NSNumber numberWithFloat:0.25f],
                                    [NSNumber numberWithFloat:1.00f],
                                    [NSNumber numberWithFloat:5.00f],
                                    [NSNumber numberWithFloat:10.00f],
                                    [NSNumber numberWithFloat:15.00f],
                                    [NSNumber numberWithFloat:20.00f]
                                    ];
    currentForwardButtonIndex = currentBackwardButtonIndex = (DEFAULT_INDEX >listOfSpeeds.count-1)? listOfSpeeds.count-1:DEFAULT_INDEX;
    
    
}


/**
 *  This updates all the main button images that are made by the Class methods
 */
+(void)updateAll:( NSString *)direct
{
    if ([direct isEqualToString:FORWARD] ) {
        for(SeekButton* eachButton in allSeekButtonsForward) {
            [eachButton setMainButtonImageIndex:currentForwardButtonIndex];
            [eachButton hideSeekControlView:nil];
        }
    } else if ([direct isEqualToString:BACKWARD]) {
        for(SeekButton* eachButton in allSeekButtonsBackward) {
            [eachButton setMainButtonImageIndex:currentBackwardButtonIndex];
            [eachButton hideSeekControlView:nil];
        }
        
    } else {
        for(SeekButton* eachButtonF in allSeekButtonsForward) {
            [eachButtonF setMainButtonImageIndex:currentForwardButtonIndex];
            [eachButtonF hideSeekControlView:nil];
        }
        for(SeekButton* eachButtonB in allSeekButtonsBackward) {
            [eachButtonB setMainButtonImageIndex:currentBackwardButtonIndex];
            [eachButtonB hideSeekControlView:nil];
        }
    }
}


+(id)makeForwardAt:(CGPoint)pt
{
    if (!allSeekButtonsForward) [SeekButton initializeStatics];
    
    float newHeight = ((LITTLE_ICON_DIMENSIONS+ NORMAL_MARGIN) * (listOfSpeeds.count+1))+ NORMAL_MARGIN;
    float newWidth = LITTLE_ICON_DIMENSIONS + NORMAL_MARGIN*2;
    
    CGRect buttonSizing = CGRectMake(pt.x, pt.y - newHeight + NORMAL_MARGIN*2 + LITTLE_ICON_DIMENSIONS ,newWidth,newHeight);
    SeekButton *mySeeker = [[SeekButton alloc]initWithFrame:buttonSizing direction:FORWARD isFullScreen:NO];
    return mySeeker;
}

+(id)makeBackwardAt:(CGPoint)pt
{
    if (!allSeekButtonsBackward) [SeekButton initializeStatics];
    
    float newHeight = ((LITTLE_ICON_DIMENSIONS+ NORMAL_MARGIN) * (listOfSpeeds.count+1))+ NORMAL_MARGIN;
    float newWidth = LITTLE_ICON_DIMENSIONS + NORMAL_MARGIN*2;
    
    CGRect buttonSizing = CGRectMake(pt.x , pt.y - newHeight  + NORMAL_MARGIN*2 + LITTLE_ICON_DIMENSIONS ,newWidth,newHeight); // this positions the graphic by main Button top left
    SeekButton *mySeeker = [[SeekButton alloc]initWithFrame:buttonSizing direction:BACKWARD isFullScreen:NO];
    return mySeeker;
}

+(id)makeFullScreenForwardAt:(CGPoint)pt
{
    if (!allSeekButtonsForward) [SeekButton initializeStatics];
    
    float newHeight = ((LARGE_ICON_DIMENSIONS+ LARGE_MARGIN) * (listOfSpeeds.count+1))+ LARGE_MARGIN;
    float newWidth = LARGE_ICON_DIMENSIONS + LARGE_MARGIN*2;
    
    CGRect buttonSizing = CGRectMake(pt.x, pt.y - newHeight+LARGE_MARGIN*2+ LARGE_ICON_DIMENSIONS, newWidth,newHeight); // this positions the graphic by main Button top left
    SeekButton *mySeeker = [[SeekButton alloc]initWithFrame:buttonSizing direction:FORWARD isFullScreen:YES];
    return mySeeker;
}

+(id)makeFullScreenBackwardAt:(CGPoint)pt
{
    if (!allSeekButtonsBackward) [SeekButton initializeStatics];
    
    float newHeight = ((LARGE_ICON_DIMENSIONS+ LARGE_MARGIN) * (listOfSpeeds.count+1))+ LARGE_MARGIN;
    float newWidth = LARGE_ICON_DIMENSIONS + LARGE_MARGIN*2;
    
    CGRect buttonSizing = CGRectMake(pt.x, pt.y - newHeight+LARGE_MARGIN*2+ LARGE_ICON_DIMENSIONS , newWidth,newHeight);// this positions the graphic by main Button top left
    SeekButton *mySeeker = [[SeekButton alloc]initWithFrame:buttonSizing direction:BACKWARD isFullScreen:YES];
    return mySeeker;
}


/**
 *  This is used by the class to construct the buttons needed. With out the use of modifying
 *
 *  @param frame  based off the Class method pt and static rect size
 *  @param dir    this lets the instance know what images to use as well as the speeds
 *  @param isFull this is for full screen or not
 *
 *  @return customized instance of the seeker button
 */
-(id)initWithFrame:(CGRect)frame direction:(NSString *) dir isFullScreen:(BOOL) isFull
{
    self = [super initWithFrame:frame];
    if (self) {
        if (!allSeekButtonsForward) [SeekButton initializeStatics];
        buttonList = [[NSMutableArray alloc]init];
        
        direction           = dir;
        isFullScreen        = isFull;
        float iconSize      = (isFullScreen)? LARGE_ICON_DIMENSIONS : LITTLE_ICON_DIMENSIONS;
        float margin        = (isFullScreen)? LARGE_MARGIN : NORMAL_MARGIN;
        
        
        for (id object in listOfSpeeds) {
            NumberedSeekerButton * btn ;
            CGRect r = CGRectMake(0, 0, iconSize, iconSize);
            if (isFullScreen){
                btn = ([direction isEqualToString:FORWARD])? [[NumberedSeekerButton alloc]initForwardLargeWithFrame:r] : [[NumberedSeekerButton alloc]initBackwardLargeWithFrame:r];
            } else {
                btn = ([direction isEqualToString:FORWARD])? [[NumberedSeekerButton alloc]initForwardNormalWithFrame:r] : [[NumberedSeekerButton alloc]initBackwardNormalWithFrame:r];
            }
            [btn setTextNumber:[object floatValue]];
            [buttonList addObject:btn];
        }
        
        // Backplace
        backPlate                   = [[UIView alloc]initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        backPlate.backgroundColor   = [UIColor colorWithRed:(195/255.0) green:(207/255.0) blue:(216/255.0) alpha:0.3];
        backPlate.hidden            = YES;
        [self addSubview:backPlate];
        
        // set up button size based of full screen or not
        
        CGRect r = CGRectMake(margin, (frame.size.height - (iconSize + margin)) , iconSize, iconSize);
        if (isFullScreen){
            mainButton = ([direction isEqualToString:FORWARD])? [[NumberedSeekerButton alloc]initForwardLargeWithFrame:r] : [[NumberedSeekerButton alloc]initBackwardLargeWithFrame:r];
        } else {
            mainButton = ([direction isEqualToString:FORWARD])? [[NumberedSeekerButton alloc]initForwardNormalWithFrame:r] : [[NumberedSeekerButton alloc]initBackwardNormalWithFrame:r];
        }
        [self addSubview:mainButton];
        
        for (int i=0; i<buttonList.count; i++) {
            NumberedSeekerButton * button = ((NumberedSeekerButton*)buttonList[i]);
            button.frame = CGRectMake(margin, (frame.size.height - (iconSize + margin)) - (iconSize + margin)  * (i+1), iconSize, iconSize);
            [self addSubview:button];
        }
        
        // set up all other buttons
        
        for (int i=0; i<buttonList.count; i++) {
            NumberedSeekerButton * button = ((NumberedSeekerButton*)buttonList[i]);
            [button addTarget:self action:@selector(onPressSeekButton:) forControlEvents:UIControlEventTouchUpInside];
            [button addTarget:self action:@selector(hideSeekControlView:) forControlEvents:UIControlEventTouchDragInside];
            button.hidden = YES;
            button.tag = i;
        }
        
        // set up the main button
        [mainButton addTarget:self action:@selector(onPressSeekButton:) forControlEvents:UIControlEventTouchUpInside];
        mainButton.tag = -1;
        longPressGesture = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(onLongPressSeekControl:)];
        longPressGesture.minimumPressDuration = 0.5; //seconds
        longPressGesture.delegate = self;
        [mainButton addGestureRecognizer:longPressGesture];
        
        
        if ([dir isEqualToString:FORWARD] ) {
            [mainButton setTextNumber:[listOfSpeeds[currentForwardButtonIndex]floatValue]];
            velocity = [listOfSpeeds[currentForwardButtonIndex] floatValue];
            [allSeekButtonsForward addObject:self]; // add to static list for update
        } else if ([dir isEqualToString:BACKWARD]) {
            [mainButton setTextNumber:[listOfSpeeds[currentBackwardButtonIndex]floatValue]];
            velocity = [listOfSpeeds[currentBackwardButtonIndex] floatValue];
            [allSeekButtonsBackward addObject:self]; // add to static list for update
        }
        
        
        
        
    }
    return self;
}


/**
 *  This is the default method. Please do not use.
 *
 *  @param frame only the "x" and "y" will be used
 *
 *  @return instance made from the class method
 */
- (id)initWithFrame:(CGRect)frame
{
    self = [SeekButton makeForwardAt:CGPointMake(frame.origin.x, frame.origin.y)];
    NSLog(@"MADE A NORMAL FORWARD SEEK BUTTON!"); // Please use Class methods to make the buttons
    return self;
}


/**
 *  When a star is pressed run this selector
 *
 *  @param sel    method to be run
 *  @param target object that contains the method
 */
-(void)onPressSeekPerformSelector:(SEL)sel addTarget:(id)target
{
    seekingTarget = target;
    onSeekSelector = sel;
}


/**
 *  This is to update the image to the correct image in the Class Dict
 *
 *  @param index of image ot retrieve from the class dictionary
 */
-(void)setMainButtonImageIndex:(int)index
{
    [ mainButton setTextNumber:[listOfSpeeds[index]  floatValue]];
    return;
}


/**
 *  This hides the back plate and all the setting buttons
 *
 *  @param sender used (nil)
 */
-(void)hideSeekControlView:(id)sender{
    backPlate.hidden = YES;
    for (NumberedSeekerButton * btn in buttonList) {
        btn.hidden = YES;
    }
}


/**
 *  On a press that is .5 seconds, it will reveal all the setting buttons and backplate
 *
 *  @param gestureRecognizer from the main button
 */
- (void)onLongPressSeekControl:(UILongPressGestureRecognizer *)gestureRecognizer
{
    backPlate.hidden = NO;
    for (NumberedSeekerButton * btn in buttonList) {
        btn.hidden = NO;
    }
}


/**
 *  This is run for each button in the seeker
 *
 *  @param sender the button pressed
 */
-(void)onPressSeekButton:(id)sender{
    NumberedSeekerButton *button = (NumberedSeekerButton*)sender;
    
    if (button.tag > -1) {
        if ([direction isEqualToString:FORWARD] ) {
            currentForwardButtonIndex = button.tag; //  "-1" is the tag for the main button
            velocity = [listOfSpeeds[currentForwardButtonIndex] floatValue];
        } else if ([direction isEqualToString:BACKWARD]) {
            currentBackwardButtonIndex = button.tag; //  "-1" is the tag for the main button
            velocity = [listOfSpeeds[currentBackwardButtonIndex] floatValue];
        }
    }
    
    if (onSeekSelector) [seekingTarget performSelector:onSeekSelector withObject:self];
    
    [SeekButton updateAll:direction]; //updates all instance graphics
}

/**
 *  This is a quick way to tell if the buttons are open.
 *  The main purpouse of this method is to adjust the hitArea by what is seen
 *
 *  @return if open or not
 */
-(BOOL)isOpen
{
    return !backPlate.hidden; //If you can't see the plate then its close :)
}

// Getter and Setter
-(float) speed
{
    return ([direction  isEqual: FORWARD])?velocity:-velocity;
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    if (self.isOpen) {
        return YES;
    } else if (point.x >= 0 && point.x <=70 && point.y >= 420 && point.y <= 490) {
        return YES;
    } else {
        return NO;
    }
    
}


@end

