//
//  PlayerCollectionViewController.m
//  Live2BenchNative
//
//  Created by dev on 13-02-28.
//  Copyright (c) 2013 DEV. All rights reserved.
//

#define ROWS_IN_EVENTS                3

#import "PlayerCollectionViewController.h"

@interface PlayerCollectionViewController ()

@end

@implementation PlayerCollectionViewController

@synthesize zoneDidSelected,zoneButtonWasSelected;

- (id)init
{
    self = [super init];
    if (self) {
        // Custom initialization
    }
    return self;
}



- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupView];
//    globals = [Globals instance];
//    if ([globals.WHICH_SPORT isEqualToString:@"hockey"]) {
//        displayData = [[NSMutableArray alloc] initWithArray:[NSArray arrayWithObjects:@"OZ",@"NZ",@"DZ", nil]];//globals.TEAM_SETUP];
//        [displayData addObjectsFromArray:globals.TEAM_SETUP];
//    }else if ([globals.WHICH_SPORT isEqualToString:@"soccer"] || [globals.WHICH_SPORT isEqualToString:@"rugby"]|| [globals.WHICH_SPORT isEqualToString:@"football"]){
//        displayData = [[NSMutableArray alloc] initWithArray:globals.TEAM_SETUP];
//    }else{
//        //not soccer or rguby or hockey
//    }
    ////////NSLog(@"playercollectionview viewdidload globals.TEAM_SETUP: %@",globals.TEAM_SETUP);
     ////////NSLog(@"playercollection view team setup %@",globals.TEAM_SETUP);
     playersDidSelected = [[NSMutableArray alloc]init];
     zoneDidSelected = @"";
    [self createCells];
    [self.view setBackgroundColor:[UIColor whiteColor]];

    // Do any additional setup after loading the view from its nib.
}

-(void)setupView
{
    scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    [scrollView setAutoresizingMask:UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth];
    [scrollView setDelegate:self];
    [self.view addSubview:scrollView];
}

-(void)createCells
{
    for(int i=0; i<displayData.count; i++)
    {
        
        if(!playerButtons)
        {
            playerButtons=[[NSMutableArray alloc]init];
        }
        NSIndexPath *pathForCell = [NSIndexPath indexPathForRow:i inSection:0];
        CustomButton *thisCell = [self cellForItemAtIndexPath:pathForCell];
        
        int colNum = ceil(i/ROWS_IN_EVENTS);
        
        int rowNum = (i+1)%ROWS_IN_EVENTS>0 ? (i+1)%ROWS_IN_EVENTS : ROWS_IN_EVENTS;
    
        [thisCell setFrame:CGRectMake((colNum * 50)+10, (rowNum*40)-30, 35, 30)];
        [scrollView addSubview:thisCell];
        [playerButtons addObject:thisCell];
    }

    //set the content width large enough to scroll the scrolling view
    [scrollView setContentSize:CGSizeMake (50*ceil(displayData.count/3) + 60, 120)];
    [scrollView setAlwaysBounceHorizontal:TRUE];
    [scrollView setPagingEnabled:FALSE];

}

-(void)clearCellSelections
{
    for(BorderButton *button in playerButtons)
    {
        if(button.selected)
        {
            [button sendActionsForControlEvents:UIControlEventTouchUpInside];
        }
    }
    zoneButtonWasSelected = nil;
    zoneDidSelected = @"";
    [playersDidSelected removeAllObjects];
}

- (CustomButton*)cellForItemAtIndexPath:(NSIndexPath *)indexPath {
//    
    //create the cell, use the player for the given indexpath
    
    BorderButton *cell = [BorderButton buttonWithType:UIButtonTypeCustom];
//
////    [cell setBackgroundImage:[UIImage imageNamed:@"line-button.png"] forState:UIControlStateSelected];
////
////    [cell setBackgroundImage:[UIImage imageNamed:@"line-button-grey.png"] forState:UIControlStateNormal];
//    
//    if ([indexPath indexAtPosition:1] <3 && [globals.WHICH_SPORT isEqualToString:@"hockey"]) {
//        NSString *zone = [displayData objectAtIndex:[indexPath indexAtPosition:1]];
////        UILabel *zoneLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, cell.frame.size.width, cell.frame.size.height)];
////        [zoneLabel setTextAlignment:NSTextAlignmentCenter];
////        [zoneLabel setTextColor:[UIColor darkGrayColor]];
////        [zoneLabel setBackgroundColor:[UIColor clearColor]];
////        [zoneLabel setAccessibilityLabel:@"title"];
////        [zoneLabel setFont:[UIFont boldSystemFontOfSize:18.0]];
////        [zoneLabel setText:zone];
////        [cell addSubview:zoneLabel];
//        [cell setAccessibilityLabel:@"zone"];
////        [cell.layer setBorderColor:PRIMARY_APP_COLOR.CGColor];
////        [cell.layer setBorderWidth:1.0];
//        [cell setTitle:zone forState:UIControlStateNormal];
//        [cell addTarget:self action:@selector(didSelectCell:) forControlEvents:UIControlEventTouchUpInside];
//    //}else if ([globals.WHICH_SPORT isEqualToString:@"soccer"] || [globals.WHICH_SPORT isEqualToString:@"rugby"]){
//    }else{
//        NSString *playerNumber = [[[displayData objectAtIndex:[indexPath indexAtPosition:1]] objectForKey:@"jersey"] stringValue];
////        UILabel *playerLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, cell.frame.size.width, cell.frame.size.height)];
////        [playerLabel setTextAlignment:NSTextAlignmentCenter];
////        [playerLabel setTextColor:[UIColor darkGrayColor]];
////        [playerLabel setBackgroundColor:[UIColor clearColor]];
////        [playerLabel setAccessibilityLabel:@"title"];
////        [playerLabel setText:playerNumber];
////        [cell addSubview:playerLabel];
//        [cell setAccessibilityLabel:playerNumber];
//        [cell setTitle:playerNumber forState:UIControlStateNormal];
//        [cell addTarget:self action:@selector(didSelectCell:) forControlEvents:UIControlEventTouchUpInside];
//        [cell setTag:[playerNumber intValue]];
//
////    }else {
////        //If it isnt hockey, soccer or rugby
//    }
//    //No shadows = better performance
//    /*[cell.layer setShadowColor:[[UIColor blackColor] CGColor]];
//    [cell.layer setShadowOpacity:0.5f];
//    [cell.layer setShadowRadius:1.0f];
//    [cell.layer setShadowOffset:CGSizeMake(-1, 1)];*/
//    
//    [cell setContentMode:UIViewContentModeScaleAspectFit];
    return cell;
}

#pragma mark - UICollectionViewDelegate
- (void)didSelectCell:(id)sender
{
    //UICollectionViewCell *cell = [self.playerCollectionView cellForItemAtIndexPath:indexPath];
    BorderButton *button = (BorderButton *)sender;
      NSString *playerNumber = [NSString stringWithFormat:@"%ld",(long)button.tag];
    if(!button.selected)
    {
        if ([button.accessibilityLabel isEqualToString:@"zone"]) {
            if (zoneButtonWasSelected) {
                zoneButtonWasSelected.selected = FALSE;
            }
            zoneButtonWasSelected = button;
            zoneDidSelected = button.titleLabel.text;
        }else{
            if (![playersDidSelected containsObject:playerNumber]) {
                [playersDidSelected addObject:playerNumber];
            }
        }
          [button  setSelected:TRUE];
    }else{
        if ([button.accessibilityLabel isEqualToString:@"zone"]) {
            zoneButtonWasSelected = nil;
            zoneDidSelected = @"";
        }else{
            [playersDidSelected removeObject:playerNumber];
        }
        [button  setSelected:FALSE];
        
    }
}



- (NSString*)tagAtIndexPath:(NSIndexPath *)indexPath
{
    if ([indexPath indexAtPosition:1] <3) {
        return [displayData objectAtIndex:indexPath.row];
    }else{
        return [[[displayData objectAtIndex:indexPath.row]objectForKey:@"jersey"] stringValue];
    }
}

-(NSMutableDictionary*)getAllSelectedPlayers{
//    NSMutableArray *tempArr = [playersDidSelected mutableCopy];
//    NSString *tempStr = [zoneDidSelected mutableCopy];
//    NSMutableDictionary *selectedData = [[NSMutableDictionary alloc]init];
//    if ([globals.WHICH_SPORT isEqualToString:@"hockey"]) {
//        [selectedData setObject:tempArr forKey:@"players"];
//        [selectedData setObject:tempStr forKey:@"zone"];
//    }else if([globals.WHICH_SPORT isEqualToString:@"soccer"] || [globals.WHICH_SPORT isEqualToString:@"rugby"] || [globals.WHICH_SPORT isEqualToString:@"football"]){
//        [selectedData setObject:tempArr forKey:@"players"];
//    }else {
//        
//    }
//    
//    [playersDidSelected removeAllObjects];
//    zoneDidSelected = @"";
//    return selectedData;
    return nil;
}




- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    // Dispose of any resources that can be recreated.
}

@end
