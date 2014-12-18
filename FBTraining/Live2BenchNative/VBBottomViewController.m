//
//  VBBottomViewController.m
//  Live2BenchNative
//
//  Created by DEV on 2013-05-31.
//  Copyright (c) 2013 DEV. All rights reserved.
//

#import "VBBottomViewController.h"

@interface VBBottomViewController ()

@end

@implementation VBBottomViewController

@synthesize leftView;
@synthesize middleView;
@synthesize rightView;
@synthesize tagNames =_tagNames;
@synthesize playerDrawer=_playerDrawer;
@synthesize arrow=_arrow;
//@synthesize rightArrow=_rightArrow;
//@synthesize playerDrawerRight=_playerDrawerRight;
@synthesize moviePlayer=_moviePlayer;
@synthesize oldName,uController;
@synthesize allPlayersView;
@synthesize rotationView;
@synthesize dragDropObjects;
@synthesize dragDropViews;
@synthesize originalPosition;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil controller:(FirstViewController *)fv
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    firstViewController = fv;
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    rotationButtonArr = [[NSMutableArray alloc]init];
    rightRotationButtonArr = [[NSMutableArray alloc]init];
    dragDropObjects = [[NSMutableArray alloc]init];
    globals= [Globals instance];
    [self initLayout];
    
    updateControlInfoTimer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                              target:self
                                                            selector:@selector(updateControlInfo)
                                                            userInfo:nil
                                                             repeats:YES];
    
    NSMutableArray *RotationOne = [[NSMutableArray alloc]init];
    NSMutableArray *RotationTwo = [[NSMutableArray alloc]init];
    NSMutableArray *RotationThree = [[NSMutableArray alloc]init];
    NSMutableArray *RotationFour = [[NSMutableArray alloc]init];
    arrayOfRotations = [[NSMutableArray alloc]initWithObjects:RotationOne,RotationTwo,RotationThree,RotationFour, nil];
    appQueue = [[AppQueue alloc]init];
    uController = [[UtilitiesController alloc]init];
    rotationButtonWasSelected = nil;
    dragDropViews = [[NSArray alloc]initWithObjects:allPlayersView,rotationView, nil];
//    dragDropManager = [[DragDropManager alloc]initWithDragSubjects:dragDropObjects andDropAreas:dragDropViews];
//    UILongPressGestureRecognizer *uiTapGestureRecognizer = [[UILongPressGestureRecognizer alloc]initWithTarget:dragDropManager action:@selector(dragging:)];
//    [self.view addGestureRecognizer:uiTapGestureRecognizer];
}
//TODO: create a timer that highlights Rotations, period, strength
//TODO: put Rotation buttons in a global array to access later on in the code


-(void)viewWillAppear:(BOOL)animated{
    
}
//timer that highlights Rotations, period, strength
-(void)updateControlInfo{
    
    //if there is no live game, stop the timer
    if (!globals.LIVE_TIMER_ON || ![globals.WHICH_SPORT isEqualToString:@"hockey"]) {
        return;
    }
    //highlight the button of the current forward Rotation
    
    if(globals.CURRENT_ROTATION>=0){
        ////NSLog(@"updateControlInfo current_f_Rotation: %d, rotationButtonWasSelected: %@,[rotationButtonArr objectAtIndex:globals.CURRENT_F_Rotation-1]: %@ ",globals.CURRENT_F_Rotation,rotationButtonWasSelected,[rotationButtonArr objectAtIndex:globals.CURRENT_F_Rotation-1]);
        if (![rotationButtonWasSelected isEqual:[rotationButtonArr objectAtIndex:globals.CURRENT_ROTATION-1]]) {
            if (rotationButtonWasSelected) {
                rotationButtonWasSelected.selected = FALSE;
            }
            [[rotationButtonArr objectAtIndex:globals.CURRENT_ROTATION-1] setSelected:TRUE];
            rotationButtonWasSelected = [rotationButtonArr objectAtIndex:globals.CURRENT_ROTATION-1];
            //update player box in bottom view according to the Rotation changing
            CustomButton *button = (CustomButton*)[rotationButtonArr objectAtIndex:globals.CURRENT_ROTATION-1];
//            if (self.arrow.alpha == 1.0) {
//                
//                [UIView animateWithDuration:0.2
//                                 animations:^{
//                                     [self.arrow setAlpha:1.0f];
//                                     [self.arrow setFrame:CGRectMake(button.center.x-15, self.arrow.frame.origin.y, self.arrow.frame.size.width, self.arrow.frame.size.height)];
//                                 }
//                                 completion:^(BOOL finished){ }];
//                [allPlayersView setBackgroundColor:[UIColor colorWithRed:224/255.0f green:229/255.0f blue:240/255.0f alpha:1.0f]];
//                [allPlayersView setFrame:CGRectMake(35,button.frame.origin.y+button.frame.size.height+10,300,160)];
//                
////                self.playerDrawer = [[PlayerCollectionViewController alloc] initWithNibName:@"PlayerCollectionViewController" bundle:nil];
////                [self.playerDrawer.view setBackgroundColor:[UIColor colorWithRed:224/255.0f green:229/255.0f blue:240/255.0f alpha:1.0f]];
////                [self.playerDrawer.view setFrame:CGRectMake(35,button.frame.origin.y+button.frame.size.height+10,300,160)];
////                
////                [self.view addSubview:self.playerDrawer.view];
//                
//                [self.arrow setAlpha:1.0f];
//                [allPlayersView setAlpha:1.0f];
//                
//            }
            
        }
        
    }else {
        if(globals.HAS_MIN)
        {
            // NSLog(@"update control infor, if(globals.has_min) current_f_Rotation: %d ",globals.CURRENT_F_Rotation);
            //reset the lefteRotationButtonWasSelected when restart a new event, otherwise it will keep using the value in the previous event
            rotationButtonWasSelected = nil;
            [[rotationButtonArr objectAtIndex:0] sendActionsForControlEvents:UIControlEventTouchUpInside];
        }
    }

}

-(void)initLayout
{
    [self populateTagNames];
    
    
    //Rotation buttons
    for(int i=0;i<3;i++)
    {
        ////TODO: optimise button creation
        //left buttons
        CustomButton *rotationButton = [CustomButton  buttonWithType:UIButtonTypeCustom];
        [rotationButton setFrame:CGRectMake((i*50)+75, 5, 40, 40)];
        [rotationButton setBackgroundImage:[UIImage imageNamed:@"line-button-grey.png"] forState:UIControlStateNormal];
        [rotationButton setBackgroundImage:[UIImage imageNamed:@"num-button.png"] forState:UIControlStateSelected];
        [rotationButton setTitle:[NSString stringWithFormat:@"%d",(i+1)] forState:UIControlStateNormal];
        [rotationButton addTarget:self action:@selector(buttonSelected:) forControlEvents:UIControlEventTouchUpInside];
        [rotationButton addTarget:self action:@selector(buttonSwiped:) forControlEvents:UIControlEventTouchDragOutside];
        [rotationButton.titleLabel setShadowOffset:CGSizeMake(0, 0)];
        [rotationButton setTag:i];
        //highlight the button of the current forward Rotation
        //[rotationButton setSelected:globals.CURRENT_F_Rotation == (i+1)];
        
        [rotationButton setAccessibilityLabel:@"left"];
        [rotationButton.layer setShadowColor:[[UIColor blackColor] CGColor]];
        [rotationButton.layer setShadowOpacity:0.5f];
        [rotationButton.layer setShadowRadius:1.0f];
        [rotationButton.layer setShadowOffset:CGSizeMake(-1, 1)];
        [rotationButton setContentMode:UIViewContentModeScaleAspectFit];
        [rotationButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [self.view addSubview:rotationButton];
        [rotationButtonArr addObject:rotationButton];
        
    }
    for(int i=3;i<6;i++)
    {
        //right buttons
        CustomButton *rotationButton = [CustomButton  buttonWithType:UIButtonTypeCustom];
        [rotationButton setFrame:CGRectMake(((i-3)*50)+800, 5, 40, 40)];
        [rotationButton setBackgroundImage:[UIImage imageNamed:@"line-button-grey.png"] forState:UIControlStateNormal];
        [rotationButton setBackgroundImage:[UIImage imageNamed:@"num-button.png"] forState:UIControlStateSelected];
        [rotationButton setTitle:[NSString stringWithFormat:@"%d",(i+1)] forState:UIControlStateNormal];
        [rotationButton addTarget:self action:@selector(buttonSelected:) forControlEvents:UIControlEventTouchUpInside];
        [rotationButton addTarget:self action:@selector(buttonSwiped:) forControlEvents:UIControlEventTouchDragOutside];
        [rotationButton setTag:i];
        ////highlight the button of the current defense Rotation
        //[rightRotationButton setSelected:globals.CURRENT_D_Rotation == (i+1)];
        [rotationButton setAccessibilityLabel:@"right"];
        [rotationButton.layer setShadowColor:[[UIColor blackColor] CGColor]];
        [rotationButton.layer setShadowOpacity:0.5f];
        [rotationButton.layer setShadowRadius:1.0f];
        [rotationButton.layer setShadowOffset:CGSizeMake(-1, 1)];
        [rotationButton setContentMode:UIViewContentModeScaleAspectFit];
        [rotationButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [self.view addSubview:rotationButton];
        [rotationButtonArr addObject:rotationButton];
    }
   
    rotationView= [[UIView alloc]initWithFrame:CGRectMake(420, 10, 175, 120)];
    [rotationView setBackgroundColor:[UIColor colorWithRed:224/255.0f green:229/255.0f blue:240/255.0f alpha:1.0f]];
    [self.view addSubview:rotationView];
   
    self.arrow = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"ortri.png"]];
    [self.arrow setFrame:CGRectMake(80, 45, 25, 15)];
    [self.arrow setContentMode:UIViewContentModeScaleAspectFit];
    [self.arrow setAlpha:0.0f];
    [self.view addSubview:self.arrow];
    
    allPlayersView= [[UIView alloc]initWithFrame:CGRectMake(75,55,240,120)];
    [allPlayersView setBackgroundColor:[UIColor colorWithRed:224/255.0f green:229/255.0f blue:240/255.0f alpha:1.0f]];
    [allPlayersView setAlpha:0.0];
    [self.view addSubview:allPlayersView];
    
    
    for(NSString *playerNumber in globals.ARRAY_OF_VB_PLAYERS){
        
        int j = [globals.ARRAY_OF_VB_PLAYERS indexOfObject: playerNumber ];
        
        int rowNum = ceil(j/4);
        
        int colNum = (j+1)%4>0 ? (j+1)%4 : 4;
        
        UIButton* cell =[CustomButton buttonWithType:UIButtonTypeCustom];
        [cell setFrame:CGRectMake((colNum * 56)-37, (rowNum*55)+10, 35, 35)];
        cell.backgroundColor = [UIColor whiteColor];
        [cell setBackgroundImage:[UIImage imageNamed:@"num-button"] forState:UIControlStateSelected];
        [cell setBackgroundImage:[UIImage imageNamed:@"line-button-grey.png"] forState:UIControlStateNormal];
        //[cell addTarget:self action:@selector(didSelectItemAtIndexPath:) forControlEvents:UIControlEventTouchUpInside];
        [cell addTarget:self action:@selector(buttonMoveStart:) forControlEvents:UIControlEventTouchDown];
        [cell addTarget:self action:@selector(buttonMoved:withEvent:) forControlEvents:UIControlEventTouchDragInside];
        [cell addTarget:self action:@selector(buttonMoved:withEvent:) forControlEvents:UIControlEventTouchDragOutside];
        [cell addTarget:self action:@selector(buttonMoveEnd:withEvent:) forControlEvents:UIControlEventTouchUpInside];
        [cell addTarget:self action:@selector(buttonMoveEnd:withEvent:) forControlEvents:UIControlEventTouchUpOutside];
        [cell setTitle:playerNumber forState:UIControlStateNormal];
        [cell setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [cell setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
        [cell setAccessibilityLabel:@"player"];
        [cell.layer setShadowColor:[[UIColor blackColor] CGColor]];
        [cell.layer setShadowOpacity:0.5f];
        [cell.layer setShadowRadius:1.0f];
        [cell.layer setShadowOffset:CGSizeMake(-1, 1)];
        [cell setContentMode:UIViewContentModeScaleAspectFit];
        [allPlayersView addSubview:cell];
        [dragDropObjects addObject:cell];
    }
    
       
    for(NSString *playerNumber in globals.ARRAY_OF_VB_ROTATION_PLAYERS){
        
        int k = [globals.ARRAY_OF_VB_ROTATION_PLAYERS indexOfObject: playerNumber ];
        
        int rowNum = ceil(k/3);
        
        NSArray *colArr = [[NSArray alloc]initWithObjects:@"1",@"2",@"3",@"3",@"2",@"1", nil];
        
        UIButton* cell =[CustomButton buttonWithType:UIButtonTypeCustom];
        [cell setFrame:CGRectMake((([[colArr objectAtIndex:k]integerValue]-1) * 50)+20, (rowNum*50)+15, 35, 35)];
        cell.backgroundColor = [UIColor clearColor];
        [cell setBackgroundImage:[UIImage imageNamed:@"num-button"] forState:UIControlStateSelected];
        [cell setBackgroundImage:[UIImage imageNamed:@"line-button-grey.png"] forState:UIControlStateNormal];
        //[cell addTarget:self action:@selector(didSelectItemAtIndexPath:) forControlEvents:UIControlEventTouchUpInside];
        [cell addTarget:self action:@selector(buttonMoveStart:) forControlEvents:UIControlEventTouchDown];
        [cell addTarget:self action:@selector(buttonMoved:withEvent:) forControlEvents:UIControlEventTouchDragInside];
        [cell addTarget:self action:@selector(buttonMoved:withEvent:) forControlEvents:UIControlEventTouchDragOutside];
        [cell addTarget:self action:@selector(buttonMoveEnd:withEvent:) forControlEvents:UIControlEventTouchUpInside];
        [cell addTarget:self action:@selector(buttonMoveEnd:withEvent:) forControlEvents:UIControlEventTouchUpOutside];
        [cell setTitle:playerNumber forState:UIControlStateNormal];
        [cell setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [cell setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
        [cell setAccessibilityLabel:@"player"];
        [cell.layer setShadowColor:[[UIColor blackColor] CGColor]];
        [cell.layer setShadowOpacity:0.5f];
        [cell.layer setShadowRadius:1.0f];
        [cell.layer setShadowOffset:CGSizeMake(-1, 1)];
        [cell setContentMode:UIViewContentModeScaleAspectFit];
        [rotationView addSubview:cell];
        [dragDropObjects addObject:cell];
    }

}

-(void)buttonMoveStart:(id)sender{
    CustomButton *button = (CustomButton*)sender;
    originalPosition = button.frame.origin;
}

-(void)buttonMoved:(id)sender withEvent:(UIEvent*)event{
    CustomButton *button = (CustomButton*)sender;
    UITouch *touch = [[event allTouches]anyObject];
    CGPoint previousPoint = [touch previousLocationInView:button.superview];
    CGPoint point = [touch locationInView:button.superview];
    CGPoint center = button.center;
    NSLog(@"previousPoint %@, current point %@ center %@, button frame %@ button original %@",NSStringFromCGPoint(previousPoint),NSStringFromCGPoint(point),NSStringFromCGPoint(center),NSStringFromCGPoint(button.frame.origin),NSStringFromCGPoint(originalPosition));
    center.x += point.x - previousPoint.x;
    center.y += point.y - previousPoint.y;
    button.center = center;
    
}

-(float)distanceOfTwoPoints:(CGPoint) p1  point2:(CGPoint)p2{
    CGFloat xDist = (p2.x - p1.x);
    CGFloat yDist = (p2.y - p1.y);
    CGFloat distance = sqrt((xDist * xDist) + (yDist * yDist));
    return distance;
}

-(void)buttonMoveEnd:(id)sender withEvent:(UIEvent*)event{
    CustomButton *button = (CustomButton*)sender;
    UITouch *touch = [[event allTouches]anyObject];
    CGPoint touchPoint = [touch locationInView:rotationView];
    
    if ([button.superview isEqual:rotationView]) {
        if (![rotationView pointInside:touchPoint withEvent:nil]) {
            [button setFrame:CGRectMake(originalPosition.x, originalPosition.y, button.frame.size.width, button.frame.size.height)];
        }
    }else{
        if ([rotationView pointInside:touchPoint withEvent:nil]) {
            [button removeFromSuperview];
            for (CustomButton *rButton in rotationButtonArr) {
                if (rButton.frame.origin.x < touchPoint.x && rButton.frame.origin.x + rButton.frame.size.width > touchPoint.x && rButton.frame.origin.y < touchPoint.y && rButton.frame.origin.y + rButton.frame.size.height > touchPoint.y) {
                    [rotationView addSubview:button];
                    button.backgroundColor = [UIColor clearColor];
                    button.frame = CGRectMake(rButton.frame.origin.x,rButton.frame.origin.y, button.frame.size.width, button.frame.size.width);
                    [rButton removeFromSuperview];
                    return;
                }
            }
        }else{
            CGPoint touchPoint = [touch locationInView:allPlayersView];
            if (![allPlayersView pointInside:touchPoint withEvent:nil]) {
                [button setFrame:CGRectMake(originalPosition.x, originalPosition.y, button.frame.size.width, button.frame.size.height)];
            }
        }
            
        }
}

- (void)buttonSelected:(id)sender{
    CustomButton *button = (CustomButton*)sender;
    
    if (button.selected) {
        button.selected = FALSE;
        [self.arrow setAlpha:0.0];
        [allPlayersView setAlpha:0.0];
        return;
    }
    
    [self.arrow setAlpha:1.0f];
    [self.arrow setFrame:CGRectMake(button.center.x-15, self.arrow.frame.origin.y, self.arrow.frame.size.width, self.arrow.frame.size.height)];
    [allPlayersView setBackgroundColor:[UIColor colorWithRed:224/255.0f green:229/255.0f blue:240/255.0f alpha:1.0f]];
    if (button.frame.origin.x < 800) {
        [allPlayersView setFrame:CGRectMake(button.frame.origin.x,button.frame.origin.y+button.frame.size.height+10,240,120)];
    }else{
        [allPlayersView setFrame:CGRectMake(button.frame.origin.x - 200,button.frame.origin.y+button.frame.size.height+10,240,120)];
    }
    [allPlayersView setAlpha:1.0f];

    
    NSString *name;
    NSString *tagTime;
    
    if (globals.CURRENT_ROTATION == -1 ) {
        tagTime = @"0.0";
    }else{
        tagTime= [NSString stringWithFormat:@"%f",firstViewController.moviePlayer.currentPlaybackTime];
    }
    
    name =[@"rotation" stringByAppendingString:button.titleLabel.text];
//    [self.arrow setAlpha:0.0f];
//    [allPlayersView setAlpha:0.0f];
    
    if ([rotationButtonWasSelected isEqual:button]) {
        return;
    }
    
    if (rotationButtonWasSelected) {
        rotationButtonWasSelected.selected = FALSE;
    }
    button.selected = TRUE;
    rotationButtonWasSelected = button;
    globals.CURRENT_ROTATION = button.tag +1;
    //NSLog(@"buttonSelected: current_f_Rotation: %d ",globals.CURRENT_F_Rotation);
    
    globals.DID_CREATE_NEW_TAG = TRUE;
    
    //    dict = [[NSDictionary alloc]initWithObjectsAndKeys:globals.EVENT_NAME,@"event",name,@"name",[globals.ACCOUNT_INFO objectForKey:@"hid"],@"user",tagTime,@"tagtime",[globals.ACCOUNT_INFO objectForKey:@"tagColour"],@"colour",name,@"Rotation", @"1",@"type", nil];//,nil];
    
    //TEMPORARY BUG FIX BY CHANGING USER INFO
    dict = [[NSDictionary alloc]initWithObjectsAndKeys:globals.EVENT_NAME,@"event",name,@"name",@"123",@"user",tagTime,@"tagtime",[globals.ACCOUNT_INFO objectForKey:@"tagColour"],@"colour",name,@"rotation", @"1",@"type", nil];//,nil];
    //NSLog(@"Rotation dict %@",dict);
    [self sendTagInfo:dict];
    
}

- (void)buttonSwiped:(id)sender
{
    CustomButton *button = (CustomButton*)sender;
    NSString *name;
        
//    [UIView animateWithDuration:0.2
//                     animations:^{
                         [self.arrow setAlpha:1.0f];
                         [self.arrow setFrame:CGRectMake(button.center.x-15, self.arrow.frame.origin.y, self.arrow.frame.size.width, self.arrow.frame.size.height)];
//                     }
//                     completion:^(BOOL finished){ }];
//    
    //self.playerDrawer = [[ContentViewController alloc] initWithNibName:@"ContentViewController" bundle:nil index:button.tag side:@"Forward"];
    [allPlayersView setBackgroundColor:[UIColor colorWithRed:224/255.0f green:229/255.0f blue:240/255.0f alpha:1.0f]];
    if (button.frame.origin.x < 800) {
        [allPlayersView setFrame:CGRectMake(button.frame.origin.x,button.frame.origin.y+button.frame.size.height+10,240,120)];
    }else{
        [allPlayersView setFrame:CGRectMake(button.frame.origin.x - 200,button.frame.origin.y+button.frame.size.height+10,240,120)];
    }
    [allPlayersView setAlpha:1.0f];
    
    if ([rotationButtonWasSelected isEqual:button]) {
        return;
    }
    
    
    
    name =[@"rotation"stringByAppendingString:button.titleLabel.text];
    
    if (rotationButtonWasSelected) {
        rotationButtonWasSelected.selected = FALSE;
    }
    button.selected = TRUE;
    rotationButtonWasSelected = button;
    globals.CURRENT_ROTATION = button.tag +1;
    
    globals.DID_CREATE_NEW_TAG = TRUE;
    
    NSString *tagTime = [NSString stringWithFormat:@"%f",firstViewController.moviePlayer.currentPlaybackTime];
    
    dict = [[NSDictionary alloc]initWithObjectsAndKeys:globals.EVENT_NAME,@"event",name,@"name",[globals.ACCOUNT_INFO objectForKey:@"hid"],@"user",tagTime,@"tagtime",[globals.ACCOUNT_INFO objectForKey:@"tagColour"],@"colour",name,@"rotation", @"1",@"type", nil];//,nil];
    
    [self sendTagInfo:dict];
}

-(void)sendTagInfo:(NSDictionary *)newDict{
    
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:newDict options:0 error:&error];
    NSString *jsonString;
    if (! jsonData) {
        
    } else {
        jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        jsonString = [jsonString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    }
    NSString *url = [NSString stringWithFormat:@"%@/min/ajax/tagset/%@",globals.URL,jsonString];
    
    NSArray *objects = [[NSArray alloc]initWithObjects:[NSValue valueWithPointer:@selector(nullFunction)],self, nil];
    NSArray *keys = [[NSArray alloc]initWithObjects:@"callback",@"controller", nil];
    NSDictionary *instObj = [NSDictionary dictionaryWithObjects:objects forKeys:keys];
    [appQueue enqueue:url dict:instObj];
    
}

-(void) nullFunction{
    
}


- (void)updateArray:(NSMutableArray*)arr index:(int)i
{
    [arrayOfRotations replaceObjectAtIndex:i withObject:arr];
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
    // Dispose of any resources that can be recreated.
}

-(void)viewWillDisappear:(BOOL)animated{
    [self.arrow setAlpha:0.0f];
    [self.playerDrawer.view setAlpha:0.0f];
}
    
@end
