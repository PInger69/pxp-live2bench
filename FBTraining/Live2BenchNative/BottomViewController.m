//
//  BottomViewController.m
//  Live2BenchNative
//
//  Created by DEV on 2013-01-24.
//  Copyright (c) 2013 DEV. All rights reserved.
//

#import "BottomViewController.h"

@interface BottomViewController ()

@end

@implementation BottomViewController

@synthesize leftView;
@synthesize middleView;
@synthesize rightView;
@synthesize tagNames =_tagNames;
@synthesize playerDrawerLeft=_playerDrawerLeft;
@synthesize leftArrow=_leftArrow;
@synthesize rightArrow=_rightArrow;
@synthesize playerDrawerRight=_playerDrawerRight;
@synthesize periodLabel=_periodLabel;
@synthesize periodSegmentedControl=_periodSegmentedControl;
@synthesize homeSegControl=_homeSegControl;
@synthesize awaySegControl =_awaySegControl;
@synthesize moviePlayer=_moviePlayer;
@synthesize oldName;


- (id)initWithController:(Live2BenchViewController *)l2b
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
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(updateControlInfo) name:@"EventInformationUpdated" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(updateControlInfo) name:@"UpdateBottomViewControInfo" object:nil];
    
    [self setupView];
    
    leftLineButtonArr = [[NSMutableArray alloc]init];
    rightLineButtonArr = [[NSMutableArray alloc]init];
//    updateControlInfoTimer = [NSTimer scheduledTimerWithTimeInterval:1.0
//                                                         target:self
//                                                       selector:@selector(updateControlInfo)
//                                                       userInfo:nil
//                                                        repeats:YES];
//     globals= [Globals instance];
    [self initLayout];
    
   
    NSMutableArray *lineOne = [[NSMutableArray alloc]init];
    NSMutableArray *lineTwo = [[NSMutableArray alloc]init];
    NSMutableArray *lineThree = [[NSMutableArray alloc]init];
    NSMutableArray *lineFour = [[NSMutableArray alloc]init];
    arrayOfLines = [[NSMutableArray alloc]initWithObjects:lineOne,lineTwo,lineThree,lineFour, nil];
    leftLineButtonWasSelected = nil;
    rightLineButtonWasSelected =nil;
    [self updateControlInfo];
    
}
//TODO: create a timer that highlights lines, period, strength
//TODO: put line buttons in a global array to access later on in the code

-(void)setupView
{
    self.periodSegmentedControl = [[UISegmentedControl alloc] initWithItems:@[@"1",@"2",@"3",@"OT",@"PS"]];
    self.homeSegControl = [[UISegmentedControl alloc] initWithItems:@[@"3",@"4",@"5",@"6"]];
    self.awaySegControl = [[UISegmentedControl alloc] initWithItems:@[@"3",@"4",@"5",@"6"]];
    
    UIView *segmentControlView = [[UIView alloc] initWithFrame:CGRectMake((self.view.frame.size.width - (self.periodSegmentedControl.numberOfSegments)*50.0f)/2, 0.0f, (self.periodSegmentedControl.numberOfSegments)*50.0f, self.view.frame.size.height)];
    segmentControlView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    
    self.periodLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 80.0f, 30.0f)];
    [self.periodLabel setText:@"PERIOD"];
    [self.periodLabel setFont:[UIFont systemFontOfSize:17.0f]];
    [self.periodLabel setBackgroundColor:[UIColor clearColor]];
    [segmentControlView addSubview:self.periodLabel];
    
//    [self.periodSegmentedControl setSegmentedControlStyle:UISegmentedControlStyleBar];
    [self.periodSegmentedControl setFrame:CGRectMake(self.periodLabel.frame.origin.x, CGRectGetMaxY(self.periodLabel.frame) + 5.0f, self.periodSegmentedControl.numberOfSegments*50.0f, 30.0f)];
    [self.periodSegmentedControl setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin];
    [self.periodSegmentedControl addTarget:self action:@selector(halfValueChanged:) forControlEvents:UIControlEventValueChanged];
    [segmentControlView addSubview:self.periodSegmentedControl];
    
    strengthHomeLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.periodLabel.frame.origin.x, CGRectGetMaxY(self.periodSegmentedControl.frame) + 30.0f, 100.0f, 30.0f)];
    [strengthHomeLabel setText:@"STRENGTH"];
    [strengthHomeLabel setFont:[UIFont systemFontOfSize:17.0f]];
    [strengthHomeLabel setBackgroundColor:[UIColor clearColor]];
    [segmentControlView addSubview:strengthHomeLabel];
    
//    [self.homeSegControl setSegmentedControlStyle:UISegmentedControlStyleBar];
    [self.homeSegControl setFrame:CGRectMake(strengthHomeLabel.frame.origin.x, CGRectGetMaxY(strengthHomeLabel.frame) + 5.0f, self.homeSegControl.numberOfSegments*50.0f, 30.0f)];
    [self.homeSegControl setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin];
    [self.homeSegControl addTarget:self action:@selector(segmentValueChanged:) forControlEvents:UIControlEventValueChanged];
    [segmentControlView addSubview:self.homeSegControl];
    
//    [self.awaySegControl setSegmentedControlStyle:UISegmentedControlStyleBar];
    [self.awaySegControl setFrame:CGRectMake(strengthHomeLabel.frame.origin.x, CGRectGetMaxY(self.homeSegControl.frame) + 15.0f, self.awaySegControl.numberOfSegments*50.0f, 30.0f)];
    [self.awaySegControl setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin];
    [self.awaySegControl addTarget:self action:@selector(segmentValueChanged:) forControlEvents:UIControlEventValueChanged];
    [segmentControlView addSubview:self.awaySegControl];
    
    [self.view addSubview:segmentControlView];
    
    leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, segmentControlView.frame.origin.x, self.view.frame.size.height)];
    [leftView setAutoresizingMask:UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
    rightView = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(segmentControlView.frame), 0, leftView.frame.size.width, leftView.frame.size.height)];
    [rightView setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
    [self.view addSubview:leftView];
    [self.view addSubview:rightView];
}

-(void)viewWillAppear:(BOOL)animated{
    
}
//timer that highlights lines, period, strength
-(void)updateControlInfo{
//
//    if (![globals.WHICH_SPORT isEqualToString:@"hockey"]) {
//        return;
//    }
//    //highlight current period, globals.CURRENT_PERIOD is the int value of segment control index
//    if (globals.CURRENT_PERIOD>=0) {
//       [self.periodSegmentedControl setSelectedSegmentIndex:globals.CURRENT_PERIOD];
//    }else {
//         if(globals.HAS_MIN)
//         {
//           [self.periodSegmentedControl setSelectedSegmentIndex:0];
//           [self.periodSegmentedControl sendActionsForControlEvents:UIControlEventValueChanged];
//         }
//    }
//    
//    if(globals.CURRENT_STRENGTH)
//    {
//         NSArray *arrayOfStrength = [globals.CURRENT_STRENGTH componentsSeparatedByString:@","];
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
//        if (homeValue==awayValue) {
//            strengthHomeLabel.backgroundColor =[UIColor colorWithRed:224/255.0f green:229/255.0f blue:240/255.0f alpha:1.0f];
//            strengthAwayLabel.backgroundColor = [UIColor colorWithRed:224/255.0f green:229/255.0f blue:240/255.0f alpha:1.0f];
//        }else if(homeValue > awayValue){
//            strengthHomeLabel.backgroundColor = [UIColor greenColor];
//            strengthAwayLabel.backgroundColor = [UIColor redColor];
//        }else{
//            strengthHomeLabel.backgroundColor = [UIColor redColor];
//            strengthAwayLabel.backgroundColor = [UIColor greenColor];
//        }
//    }else{
//        //set the selected segment index for both home and away, then send action to value changed function once;
//        [self.homeSegControl setSelectedSegmentIndex:2];
//        [self.awaySegControl setSelectedSegmentIndex:2];
//        [self.homeSegControl sendActionsForControlEvents:UIControlEventValueChanged];
//        //[self.awaySegControl sendActionsForControlEvents:UIControlEventValueChanged];
//    }
//    
//    //highlight the button of the current forward line
//    
//    if(globals.CURRENT_F_LINE>=0){
//        ////NSLog(@"updateControlInfo current_f_line: %d, leftLineButtonWasSelected: %@,[leftLineButtonArr objectAtIndex:globals.CURRENT_F_LINE-1]: %@ ",globals.CURRENT_F_LINE,leftLineButtonWasSelected,[leftLineButtonArr objectAtIndex:globals.CURRENT_F_LINE-1]);
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
//                
//                [UIView animateWithDuration:0.2
//                                 animations:^{
//                                     [self.leftArrow setAlpha:1.0f];
//                                     [self.leftArrow setFrame:CGRectMake(button.center.x-15, self.leftArrow.frame.origin.y, self.leftArrow.frame.size.width, self.leftArrow.frame.size.height)];
//                                 }
//                                 completion:^(BOOL finished){ }];
//                
//                self.playerDrawerLeft = [[ContentViewController alloc] initWithIndex:button.tag side:@"Forward"];
//                [self.playerDrawerLeft.view setBackgroundColor:[UIColor colorWithRed:224/255.0f green:229/255.0f blue:240/255.0f alpha:1.0f]];
//                [self.playerDrawerLeft.view setFrame:CGRectMake(35,button.frame.origin.y+button.frame.size.height+10,300,160)];
//                
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
//        if(globals.HAS_MIN)
//        {
//            // NSLog(@"update control infor, if(globals.has_min) current_f_line: %d ",globals.CURRENT_F_LINE);
//            //reset the leftelineButtonWasSelected when restart a new event, otherwise it will keep using the value in the previous event
//            leftLineButtonWasSelected = nil;
//            [[leftLineButtonArr objectAtIndex:0] sendActionsForControlEvents:UIControlEventTouchUpInside];
//        }
//    }
//    ////highlight the button of the current defense line
//    if(globals.CURRENT_D_LINE>= 0){
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
//                self.playerDrawerLeft = [[ContentViewController alloc] initWithIndex:button.tag side:@"Defense"];
//                [self.playerDrawerRight.view setBackgroundColor:[UIColor colorWithRed:224/255.0f green:229/255.0f blue:240/255.0f alpha:1.0f]];
//                [self.playerDrawerRight.view setFrame:CGRectMake(-5,button.frame.origin.y+button.frame.size.height+10,300,160)];
//                
//                [self.rightView addSubview:self.playerDrawerRight.view];
//                
//                [self.rightArrow setAlpha:1.0f];
//                [self.playerDrawerRight.view setAlpha:1.0f];
//            }
//            
//        }
//    }else{
//        if(globals.HAS_MIN)
//        {
//         //NSLog(@"update control infor, if(globals.has_min) current_d_line: %d ",globals.CURRENT_D_LINE);
//             //reset the leftelineButtonWasSelected when restart a new event, otherwise it will keep using the value in the previous event
//            rightLineButtonWasSelected = nil;   
//            [[rightLineButtonArr objectAtIndex:0] sendActionsForControlEvents:UIControlEventTouchUpInside];
//        }
//    }
//    
}

-(void)initLayout
{
    [self populateTagNames];
    
    
    //left line buttons
    for(int i=0;i<4;i++)
    {
        ////TODO: optimise button creation
        //left buttons
        CustomButton *leftLineButton = [CustomButton  buttonWithType:UIButtonTypeCustom];
        [leftLineButton setFrame:CGRectMake((i*50)+35, 5, 40, 40)];
        [leftLineButton setBackgroundImage:[UIImage imageNamed:@"line-button-grey.png"] forState:UIControlStateNormal];
        [leftLineButton setBackgroundImage:[UIImage imageNamed:@"num-button.png"] forState:UIControlStateSelected];
        [leftLineButton setTitle:[NSString stringWithFormat:@"%d",(i+1)] forState:UIControlStateNormal];
        [leftLineButton addTarget:self action:@selector(buttonSelected:) forControlEvents:UIControlEventTouchUpInside];
        [leftLineButton addTarget:self action:@selector(buttonSwiped:) forControlEvents:UIControlEventTouchDragOutside];
        //[leftLineButton.titleLabel setShadowOffset:CGSizeMake(0, 0)];
        [leftLineButton setTag:i];
        //highlight the button of the current forward line
        //[leftLineButton setSelected:globals.CURRENT_F_LINE == (i+1)];

        [leftLineButton setAccessibilityLabel:@"left"];
        
        //No shadows = better performance
        /*[leftLineButton.layer setShadowColor:[[UIColor blackColor] CGColor]];
        [leftLineButton.layer setShadowOpacity:0.5f];
        [leftLineButton.layer setShadowRadius:1.0f];
        [leftLineButton.layer setShadowOffset:CGSizeMake(-1, 1)];*/
        
        [leftLineButton setContentMode:UIViewContentModeScaleAspectFit];
        [leftLineButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [self.leftView addSubview:leftLineButton];
        if(i==0)
        {
            self.leftArrow = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"ortri.png"]];
            [self.leftArrow setFrame:CGRectMake(leftLineButton.center.x-15, leftLineButton.frame.size.height+5, 25, 15)];
            [self.leftArrow setContentMode:UIViewContentModeScaleAspectFit];
            [self.leftArrow setAlpha:0.0f];
            [self.leftView addSubview:self.leftArrow];
        }
        
        //right buttons
        CustomButton *rightLineButton = [CustomButton  buttonWithType:UIButtonTypeCustom];
        [rightLineButton setFrame:CGRectMake((i*50)+105, 5, 40, 40)];
        [rightLineButton setBackgroundImage:[UIImage imageNamed:@"line-button-grey.png"] forState:UIControlStateNormal];
        [rightLineButton setBackgroundImage:[UIImage imageNamed:@"num-button.png"] forState:UIControlStateSelected];
        [rightLineButton setTitle:[NSString stringWithFormat:@"%d",(i+1)] forState:UIControlStateNormal];
        [rightLineButton addTarget:self action:@selector(buttonSelected:) forControlEvents:UIControlEventTouchUpInside];
        [rightLineButton addTarget:self action:@selector(buttonSwiped:) forControlEvents:UIControlEventTouchDragOutside];
        [rightLineButton setTag:i];
        ////highlight the button of the current defense line
        //[rightLineButton setSelected:globals.CURRENT_D_LINE == (i+1)];
        /*[rightLineButton setAccessibilityLabel:@"right"];
         
         //No shadows = better performance
        [rightLineButton.layer setShadowColor:[[UIColor blackColor] CGColor]];
        [rightLineButton.layer setShadowOpacity:0.5f];
        [rightLineButton.layer setShadowRadius:1.0f];
        [rightLineButton.layer setShadowOffset:CGSizeMake(-1, 1)];*/
        
        [rightLineButton setContentMode:UIViewContentModeScaleAspectFit];
        [rightLineButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [self.rightView addSubview:rightLineButton];
        
        //we only show triangle if they select a gbutton
        if(i==0)
        {
            self.rightArrow = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"ortri.png"]];
            [self.rightArrow setFrame:CGRectMake(leftLineButton.center.x-15, leftLineButton.frame.size.height+5, 25, 15)];
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
//    
    strengthHomeLabel = [[UILabel alloc]initWithFrame:CGRectMake(595,self.homeSegControl.frame.origin.y  , 30, 30)];
    [strengthHomeLabel setText:@"H"];
    [strengthHomeLabel setTextAlignment:NSTextAlignmentCenter];
    [strengthHomeLabel setBackgroundColor:[UIColor colorWithRed:224/255.0f green:229/255.0f blue:240/255.0f alpha:1.0f]];
    [self.view addSubview:strengthHomeLabel];
    
    strengthAwayLabel = [[UILabel alloc]initWithFrame:CGRectMake(595,self.awaySegControl.frame.origin.y , 30, 30)];
    [strengthAwayLabel setText:@"A"];
    [strengthAwayLabel setTextAlignment:NSTextAlignmentCenter];
    [strengthAwayLabel setBackgroundColor:[UIColor colorWithRed:224/255.0f green:229/255.0f blue:240/255.0f alpha:1.0f]];
    [self.view addSubview:strengthAwayLabel];
    
    UILabel *offenseLabel = [[UILabel alloc]initWithFrame:CGRectMake(220,5, 50, 50)];
    [offenseLabel setText:@"O."];
    [offenseLabel setFont:[UIFont systemFontOfSize:20.f]];
    [offenseLabel setTextAlignment:NSTextAlignmentCenter];
    [offenseLabel setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:offenseLabel];
    
    UILabel *defenseLabel = [[UILabel alloc]initWithFrame:CGRectMake(750,5, 50, 50)];
    [defenseLabel setText:@"D."];
    [defenseLabel setFont:[UIFont systemFontOfSize:20.f]];
    [defenseLabel setTextAlignment:NSTextAlignmentCenter];
    [defenseLabel setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:defenseLabel];
}

- (void)buttonSelected:(id)sender{
    CustomButton *button = (CustomButton*)sender;
    NSString *name;
//    NSString *tagTime;

    if([button.accessibilityLabel isEqualToString:@"left"])
    {
        
//        if (globals.CURRENT_F_LINE == -1 ) {
//            tagTime = @"0.0";
//        }else{
//            //tagTime= [NSString stringWithFormat:@"%f",firstViewController.moviePlayer.currentPlaybackTime];
//            tagTime= [NSString stringWithFormat:@"%f",[live2BenchViewController.videoPlayer currentTimeInSeconds]];
//        }
        
       name =[[@"line_" stringByAppendingString:@"f_"] stringByAppendingString:button.titleLabel.text];
        [self.leftArrow setAlpha:0.0f];
        [self.playerDrawerLeft.view setAlpha:0.0f];
        
        if ([leftLineButtonWasSelected isEqual:button]) {
            return;
        }
        
        if (leftLineButtonWasSelected) {
            leftLineButtonWasSelected.selected = FALSE;
        }
        button.selected = TRUE;
        leftLineButtonWasSelected = button;
//        globals.CURRENT_F_LINE = button.tag +1;
         ////NSLog(@"buttonSelected: current_f_line: %d ",globals.CURRENT_F_LINE
        
        
    }else {
//        if (globals.CURRENT_D_LINE == -1) {
//            tagTime = @"0.0";
//        }else{
//            //tagTime= [NSString stringWithFormat:@"%f",live2BenchViewController.moviePlayer.currentPlaybackTime];
//            tagTime= [NSString stringWithFormat:@"%f",[live2BenchViewController.videoPlayer currentTimeInSeconds]];
//        }
        
        name =[[@"line_" stringByAppendingString:@"d_"] stringByAppendingString:button.titleLabel.text];
        [self.rightArrow setAlpha:0.0f];
        [self.playerDrawerRight.view setAlpha:0.0f];
        
        if ([rightLineButtonWasSelected isEqual:button]) {
            return;
        }
        
        if (rightLineButtonWasSelected) {
            rightLineButtonWasSelected.selected = FALSE;
        }
        button.selected = TRUE;
        rightLineButtonWasSelected = button;
//        globals.CURRENT_D_LINE = button.tag +1;
        
    }
    
   
//    globals.DID_CREATE_NEW_TAG = TRUE;
    
//    dict = [[NSDictionary alloc]initWithObjectsAndKeys:globals.EVENT_NAME,@"event",name,@"name",[globals.ACCOUNT_INFO objectForKey:@"hid"],@"user",tagTime,@"tagtime",[globals.ACCOUNT_INFO objectForKey:@"tagColour"],@"colour",name,@"line", @"1",@"type", nil];//,nil];
    
    //current absolute time in seconds
//    double currentSystemTime = CACurrentMediaTime();
    //TEMPORARY BUG FIX BY CHANGING USER INFO
//    dict = [[NSDictionary alloc]initWithObjectsAndKeys:globals.EVENT_NAME,@"event",name,@"name",@"123",@"user",[NSString stringWithFormat:@"%f",currentSystemTime],@"requesttime",tagTime,@"tagtime",[globals.ACCOUNT_INFO objectForKey:@"tagColour"],@"colour",name,@"line", @"1",@"type", nil];//,nil];
//
//    [self sendTagInfo:dict];
    
}

- (void)buttonSwiped:(id)sender
{
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
         [self.playerDrawerLeft.view setBackgroundColor:[UIColor colorWithRed:224/255.0f green:229/255.0f blue:240/255.0f alpha:1.0f]];
        [self.playerDrawerLeft.view setFrame:CGRectMake(35,button.frame.origin.y+button.frame.size.height+10,300,160)];

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
        
        

          self.playerDrawerLeft = [[ContentViewController alloc] initWithIndex:button.tag side:@"Defense"];
        [self.playerDrawerRight.view setBackgroundColor:[UIColor colorWithRed:224/255.0f green:229/255.0f blue:240/255.0f alpha:1.0f]];
        [self.playerDrawerRight.view setFrame:CGRectMake(-5,button.frame.origin.y+button.frame.size.height+10,300,160)];
      
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
//        globals.DID_CREATE_NEW_TAG = TRUE;
    
        //NSString *tagTime = [NSString stringWithFormat:@"%f",live2BenchViewController.moviePlayer.currentPlaybackTime];
//        NSString *tagTime= [NSString stringWithFormat:@"%f",[live2BenchViewController.videoPlayer currentTimeInSeconds]];
    //current absolute time in seconds
//    double currentSystemTime = CACurrentMediaTime();
//       dict = [[NSDictionary alloc]initWithObjectsAndKeys:globals.EVENT_NAME,@"event",name,@"name",[NSString stringWithFormat:@"%f",currentSystemTime],@"requesttime",[globals.ACCOUNT_INFO objectForKey:@"hid"],@"user",tagTime,@"tagtime",[globals.ACCOUNT_INFO objectForKey:@"tagColour"],@"colour",name,@"line", @"1",@"type", nil];//,nil];
//        
//        [self sendTagInfo:dict];
}

-(void)sendTagInfo:(NSDictionary *)newDict{
    
//    NSError *error;
//    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:newDict options:0 error:&error];
//    NSString *jsonString;
//    if (! jsonData) {
//        
//    } else {
//        jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
//        jsonString = [jsonString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
//    }
//    NSString *url = [NSString stringWithFormat:@"%@/min/ajax/tagset/%@",globals.URL,jsonString];
//    
//    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
//    
//    [[NSURLConnection alloc] initWithRequest:urlRequest delegate:self];
//    
//    //    NSArray *objects = [[NSArray alloc]initWithObjects:[NSValue valueWithPointer:@selector(nullFunction)],self, nil];
//    //    NSArray *keys = [[NSArray alloc]initWithObjects:@"callback",@"controller", nil];
//    //    NSDictionary *instObj = [NSDictionary dictionaryWithObjects:objects forKeys:keys];
//    //    [globals.APP_QUEUE enqueue:url dict:instObj];
    
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
//        float tagTime = [[thumbInfoSubDict objectForKey:@"starttime"] floatValue];
//        NSString *tagName = [thumbInfoSubDict objectForKey:@"name"];
//        UIColor *tagColour =[uController colorWithHexString:[thumbInfoSubDict objectForKey:@"colour"]];
//        
////        [live2BenchViewController markTagAtTime:tagTime colour:tagColour tagID:[thumbInfoSubDict objectForKey:@"id"]];
//        
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
//
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
- (IBAction)segmentValueChanged:(id)sender {
    
    //get the integer values of the current strengths (we need to compare)
//    int homeValue = [[globals.ARRAY_OF_POSS_PLAYERS objectAtIndex:self.homeSegControl.selectedSegmentIndex] intValue];
//    int awayValue = [[globals.ARRAY_OF_POSS_PLAYERS objectAtIndex:self.awaySegControl.selectedSegmentIndex] intValue];
//    
//    //if i have more players the the other team then the H view is green, other wise it is red
//    if (homeValue==awayValue) {
//        strengthHomeLabel.backgroundColor =[UIColor colorWithRed:224/255.0f green:229/255.0f blue:240/255.0f alpha:1.0f];
//        strengthAwayLabel.backgroundColor = [UIColor colorWithRed:224/255.0f green:229/255.0f blue:240/255.0f alpha:1.0f];
//    }else if(homeValue > awayValue){
//        strengthHomeLabel.backgroundColor = [UIColor greenColor];
//        strengthAwayLabel.backgroundColor = [UIColor redColor];
//    }else{
//        strengthHomeLabel.backgroundColor = [UIColor redColor];
//        strengthAwayLabel.backgroundColor = [UIColor greenColor];
//    }
//    
//    NSString *tagTime;
//    if (!globals.CURRENT_STRENGTH) {
//        tagTime = @"0.0";
//    }else{
//        tagTime= [live2BenchViewController getCurrentTimeforNewTag];
//    }
//
//    NSString *name = [NSString stringWithFormat:@"%d VS %d",homeValue,awayValue];
//    //current absolute time in seconds
//    double currentSystemTime = CACurrentMediaTime();
//    dict= [[NSDictionary alloc]initWithObjectsAndKeys:globals.EVENT_NAME,@"event",[NSString stringWithFormat:@"%f",currentSystemTime],@"requesttime",[NSString stringWithFormat:@"%d,%d",homeValue,awayValue],@"strength",name,@"name",@"123",@"user",tagTime,@"tagtime",[globals.ACCOUNT_INFO objectForKey:@"tagColour"],@"colour",@"9",@"type",nil];
//    [self sendTagInfo:dict];
//    globals.CURRENT_STRENGTH=[NSString stringWithFormat:@"%d,%d",homeValue,awayValue];
}
//select or change period button
- (IBAction)periodSegmentValueChanged:(id)sender {
//    NSString *tagTime;
//    if (globals.CURRENT_PERIOD == -1) {
//        tagTime = @"0.0";
//    }else{
//        tagTime= [live2BenchViewController getCurrentTimeforNewTag];
//    }
//    //current absolute time in seconds
//    double currentSystemTime = CACurrentMediaTime();
//    
//    //TEMPORARY BUG FIX BY CHANGING USER INFO
//    dict= [[NSDictionary alloc]initWithObjectsAndKeys:globals.EVENT_NAME,@"event",[NSString stringWithFormat:@"%f",currentSystemTime],@"requesttime",[NSString stringWithFormat:@"%d",[self.periodSegmentedControl selectedSegmentIndex]],@"name",[NSString stringWithFormat:@"%d",[self.periodSegmentedControl selectedSegmentIndex]],@"period",@"123",@"user",tagTime,@"tagtime",[globals.ACCOUNT_INFO objectForKey:@"tagColour"],@"colour",@"7",@"type",nil];
//    [self sendTagInfo:dict];
//    globals.CURRENT_PERIOD = [self.periodSegmentedControl selectedSegmentIndex];
}

-(void)viewWillDisappear:(BOOL)animated{
    [self.leftArrow setAlpha:0.0f];
    [self.playerDrawerLeft.view setAlpha:0.0f];
    [self.rightArrow setAlpha:0.0f];
    [self.playerDrawerRight.view setAlpha:0.0f];
}
@end
