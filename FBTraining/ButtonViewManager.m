//
//  ButtonViewManager.m
//  MultipleButtonsWithPopovers
//
//  Created by dev on 2015-01-26.
//  Copyright (c) 2015 Avoca Technologies. All rights reserved.
//

#import "ButtonViewManager.h"
#import "PopoverViewController.h"

@interface ButtonViewManager () <PopoverDelegate>

@property (nonatomic, strong) UIPopoverController *popover;
@property (strong, nonatomic) NSMutableArray *selectedPlayers;
@property (strong, nonatomic) NSMutableArray *players;
@property (strong, nonatomic) NSMutableDictionary *dataMutableDictionary;
@property (strong, nonatomic) UILabel *label;
@property (strong, nonatomic) UIView *viewContainingAllViews;
@property (strong, nonatomic) NSMutableArray *theButtons;

@end


@implementation ButtonViewManager


@synthesize dataDictionary = _dataDictionary;


-(instancetype)initWithDataDictionary: (NSDictionary *)dataDictionary andPlistDictionary: (NSDictionary *)plistDictionary{
    self = [super init];
    if (self){
        self.selectable = YES;
        self.theButtons = [[NSMutableArray alloc] init];
        self.viewContainingAllViews = [[UIView alloc] init];
        //self.viewContainingAllViews.backgroundColor = [UIColor whiteColor];
        
        self.players = [[NSMutableArray alloc]init];
        self.selectedPlayers = [[NSMutableArray alloc]init];
        self.dataMutableDictionary = [[NSMutableDictionary alloc] init];
        self.dataDictionary = dataDictionary;
        self.name = plistDictionary[@"Name"];
        self.label = [[UILabel alloc]init];
        self.label.text = self.name;
        
        // The -1 accounts for the fact that the data dictionary has a selected index object
        if (dataDictionary) {
            for (int i = 0; i < ([dataDictionary count] - 1); ++i){
                UIButton *addingButton = [[UIButton alloc]init] ;
                [addingButton setTitle:[NSString stringWithFormat:@"%i", (i+1)] forState:UIControlStateNormal];
                [addingButton setTitleColor:PRIMARY_APP_COLOR forState:UIControlStateNormal];
                [addingButton.layer setBorderWidth:1.0f];
                [addingButton.layer setBorderColor:PRIMARY_APP_COLOR.CGColor];
                
                
                addingButton.backgroundColor = [UIColor whiteColor];
                addingButton.tintColor = PRIMARY_APP_COLOR;
                [addingButton setNeedsDisplay];
                [self.theButtons addObject:addingButton];
                [self.viewContainingAllViews addSubview:addingButton];
                [addingButton addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchUpOutside];
                [addingButton addTarget:self action:@selector(buttonIsHeld:) forControlEvents:UIControlEventTouchDown];
                //[addingButton addTarget:self action:@selector(buttonIsHeld:) forControlEvents:UIControlEvent];
            }
        }
        NSDictionary *frameDictionary = plistDictionary[@"Position"];
        NSNumber *xPosition = (NSNumber *) frameDictionary[@"xPosition"];
        NSNumber *yPosition = (NSNumber *) frameDictionary[@"yPosition"];
        NSNumber *width = (NSNumber *) frameDictionary[@"width"];
        NSNumber *height = (NSNumber *) frameDictionary[@"height"];
        CGRect theFrame = CGRectMake([xPosition floatValue], [yPosition floatValue], [width floatValue], [height floatValue]);
        self.frame = theFrame;
        NSNumber *selectedIndex = (NSNumber *)dataDictionary[@"SelectedIndex"];
        UIButton *selectedButton = self.theButtons[[selectedIndex intValue]];
        selectedButton.backgroundColor = PRIMARY_APP_COLOR;
        [selectedButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }
    return self;
}



#pragma mark - Custom Property Methods
-(void) setSelectable:(BOOL)selectable{
    _selectable = selectable;
    for (UIButton *theButton in self.theButtons){
        theButton.backgroundColor = [UIColor whiteColor];
        [theButton setTitleColor:PRIMARY_APP_COLOR forState:UIControlStateNormal];
    }

}

-(void)setFrame:(CGRect)frame{
    CGRect newFrame = CGRectMake(frame.origin.x, frame.origin.y, (frame.size.width + 10) *[self.theButtons count] - 10, frame.size.height);
    _frame = newFrame;
    self.viewContainingAllViews.frame = newFrame;
    for (int i = 0; i < [self.theButtons count]; ++i){
        
        UIButton *currentButton = self.theButtons[i];
        currentButton.frame = CGRectMake((i * frame.size.width + i*10) , 0, frame.size.width, frame.size.height);
    }
    
    self.label = [[UILabel alloc]initWithFrame:CGRectMake(frame.origin.x , frame.origin.y - 30, 80, 30)];
    self.label.text = self.name;
}
-(void)setParentView:(UIView *)parentView{
    _parentView = parentView;
    [self.parentView addSubview:self.viewContainingAllViews];
    [self.parentView addSubview:self.label];
}

- (void)setDataDictionary:(NSDictionary *)dataDictionary
{
    _dataDictionary = dataDictionary;
    _dataMutableDictionary = [NSMutableDictionary dictionaryWithDictionary:dataDictionary];
    
    for (int i = 0; i < _dataMutableDictionary.count; i++) {
        
        [self.players addObject: [[NSMutableArray alloc]init]];
        [self.selectedPlayers addObject: [[NSMutableArray alloc]init]];
        
        
        NSDictionary *eachButtonDictionary =[_dataMutableDictionary objectForKey:[NSNumber numberWithInt: i + 1]];
        
        for(int j = 0; j < eachButtonDictionary.count; ++j) {
            
            NSDictionary *eachPlayerDictionary = eachButtonDictionary[[NSNumber numberWithInt: j + 1]];
            [self.players[i] addObject:[ eachPlayerDictionary objectForKey:@"Name"]];
            [self.selectedPlayers[i] addObject:[eachPlayerDictionary objectForKey:@"Value"]];
            
        }
    }
    
}


-(NSDictionary *) dataDictionary{
    
    for (int i = 0; i < [_dataMutableDictionary count]; ++i){
        NSMutableDictionary *eachButtonsDataDictionary = [NSMutableDictionary dictionaryWithDictionary:[_dataMutableDictionary objectForKey:[NSNumber numberWithInt:i + 1] ]];;
        
        for (int j = 0; j < eachButtonsDataDictionary.count; ++j){
            NSMutableDictionary *lowerLevelDictionary = [NSMutableDictionary dictionaryWithDictionary:[eachButtonsDataDictionary objectForKey:[NSNumber numberWithInt: j + 1] ]];
            
            lowerLevelDictionary[@"Value"] = self.selectedPlayers[i][j];
            eachButtonsDataDictionary[[NSNumber numberWithInt:j+1]] = lowerLevelDictionary;
        }
        
        _dataMutableDictionary[[NSNumber numberWithInt:i+1]] = eachButtonsDataDictionary;
    }
    
    _dataDictionary = [_dataMutableDictionary copy];
    return _dataDictionary;
}


#pragma mark - Button target methods

-(void)buttonIsHeld: (UIButton *)sender{
    
        if( [sender.backgroundColor isEqual: PRIMARY_APP_COLOR]){

                sender.backgroundColor = [UIColor whiteColor];
                [sender setTitleColor:PRIMARY_APP_COLOR forState:UIControlStateNormal];
                
            
        }else{
            for (UIButton *theButton in self.theButtons){
                theButton.backgroundColor = [UIColor whiteColor];
                [theButton setTitleColor:PRIMARY_APP_COLOR forState:UIControlStateNormal];
                
            }
            sender.backgroundColor = PRIMARY_APP_COLOR;
            [sender setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        }
    
}

- (void)buttonPressed:(UIButton *)sender
{
    
    /**
     *  Should identify the certain button and pop different view later
     */
    
    //NSInteger *indentifier = sender.titleLabel;
    
    if (self.popover) {
        [self.popover dismissPopoverAnimated:NO];
    }
    
    
    if(self.selectable){
        
        
        int buttonIndex = (int)[self.theButtons indexOfObject:sender];
        CGSize popSize = CGSizeMake(300, 200);
        //sender.backgroundColor = PRIMARY_APP_COLOR;
        //[sender setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        if( [self.players[buttonIndex] count] >= 1){
            PopoverViewController *popoverContent = [[PopoverViewController alloc] initWithArray:self.players[buttonIndex] andSelectInfo:self.selectedPlayers[buttonIndex] andFrame:CGRectMake(0, 0, popSize.width, popSize.height) withGap: self.gap];
            
            popoverContent.theButtonViewManager = self;
            popoverContent.view.backgroundColor = [UIColor whiteColor];
            popoverContent.view.frame = CGRectMake(10, 10, 180, 180);
            popoverContent.view.layer.borderColor = PRIMARY_APP_COLOR.CGColor;
            popoverContent.view.layer.borderWidth = 1.2f;
            popoverContent.view.layer.cornerRadius = 10;
            popoverContent.view.layer.masksToBounds = YES;
            
            self.popover = [[UIPopoverController alloc] initWithContentViewController:popoverContent];
            
            [self.popover setPopoverLayoutMargins: UIEdgeInsetsMake(10, 0, 0, 0)];
            
            [self.popover setPopoverContentSize:popSize animated:YES];
            
            self.popover.backgroundColor = PRIMARY_APP_COLOR;
            //self.popover.popoverBackgroundViewClass = [UIPopoverBackgroundView class];
            self.popover.passthroughViews = [NSArray arrayWithObject:self.viewContainingAllViews];
            
            [self.popover presentPopoverFromRect: sender.frame inView:self.viewContainingAllViews permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
        }
    }else{
        sender.backgroundColor = [UIColor whiteColor];
        [sender setTitleColor:PRIMARY_APP_COLOR forState:UIControlStateNormal];
    }
    
    
}


#pragma mark - Notifications
-(void)sendNotificationWithButton: (UIButton *) sender{
    
    //NSNotification *postingNotification = [NSNotification notificationWithName:notificationName object:self];
    //[[NSNotificationCenter defaultCenter]postNotification:postingNotification];
}

-(void)notificationAction: (id) notificationValue{
    for (UIButton *theButton in self.theButtons){
        theButton.backgroundColor = [UIColor whiteColor];
        [theButton setTitleColor:PRIMARY_APP_COLOR forState:UIControlStateNormal];
    }
    int index = (int)notificationValue;
    UIButton *theButtonSelected = (UIButton *)self.theButtons[index];
    theButtonSelected.backgroundColor = [UIColor whiteColor];
    [theButtonSelected setTitleColor:PRIMARY_APP_COLOR forState:UIControlStateNormal];
}

-(void)removeFromSuperview{
    for (UIButton *aButton in self.theButtons){
        [aButton removeFromSuperview];
    }
    [self.label removeFromSuperview];
}

-(void)sendNotificationWithName:(NSString *)notificationName
{
    // for protocol
}

@end

