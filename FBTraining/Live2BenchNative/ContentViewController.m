//
//  ContentViewController.m
//  Live2BenchNative
//
//  Created by DEV on 2013-01-25.
//  Copyright (c) 2013 DEV. All rights reserved.
//

#import "ContentViewController.h"

@interface ContentViewController (){
    UIScrollView *_scrollView;
    //NSArray *_playerList;
    NSMutableArray *_cellList;
}

@end

@implementation ContentViewController
@synthesize scrollView = _scrollView;
@synthesize playerList = _playerList;
//@synthesize collectionView=_collectionView;
//@synthesize gameItems=_gameItems;
//@synthesize selectedNumbers =_selectedNumbers;
//@synthesize currentLine;
//@synthesize playerMap;

-(id)initWithFrame:(CGRect)frame playerList:(NSArray*)playerList{
    self = [super init];
    self.view.frame = frame;
    
    _scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    [_scrollView setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
    _scrollView.showsVerticalScrollIndicator = true;
    [self.view addSubview:_scrollView];
    
    //_bottomViewController = bottomViewController;
    _cellList =  [[NSMutableArray alloc]init];
    _playerList = playerList;
    [self createCells:_playerList];
    

    return self;
}

- (id)initWithIndex:(NSInteger)i side:(NSString*)whichSide
{
////    if(!globals)
////    {
////        globals = [Globals instance];
////    }
//    
//    self = [super init];
//    if (self) {
//        
//        NSMutableArray* linef1 = [[NSMutableArray alloc]init];
//        NSMutableArray* linef2 = [[NSMutableArray alloc]init];
//        NSMutableArray* linef3 = [[NSMutableArray alloc]init];
//        NSMutableArray* linef4 = [[NSMutableArray alloc]init];
//        NSMutableArray* lined1 = [[NSMutableArray alloc]init];
//        NSMutableArray* lined2 = [[NSMutableArray alloc]init];
//        NSMutableArray* lined3 = [[NSMutableArray alloc]init];
//        NSMutableArray* lined4 = [[NSMutableArray alloc]init];
//        ////////NSLog(@"contentviewcontroller team setup %@",globals.TEAM_SETUP);
//        //NSArray *objects = [[NSArray alloc]initWithObjects:lined1,lined2,lined3,lined4,linef4,linef3,linef2,linef1, nil];
////        NSArray *keys = [[NSArray alloc]initWithObjects:@"line_f_1",@"line_f_2",@"line_f_3",@"line_f_4",@"line_d_1",@"line_d_2",@"line_d_3",@"line_d_4", nil];
////        for(NSDictionary *dict in globals.TEAM_SETUP){
////            // if (!globals.ARRAY_OF_HOCKEY_PLAYERS) {
////            //    globals.ARRAY_OF_HOCKEY_PLAYERS = [[NSMutableArray alloc]initWithObjects:[NSString //stringWithFormat:@"%@",[dict objectForKey:@"jersey"]], nil];
////            // }else{
////            if (![globals.ARRAY_OF_HOCKEY_PLAYERS containsObject:[NSString stringWithFormat:@"%@",[dict objectForKey:@"jersey"]]]) {
////                [globals.ARRAY_OF_HOCKEY_PLAYERS addObject:[NSString stringWithFormat:@"%@",[dict objectForKey:@"jersey"]]];
////                //}
////            }
////            
////            if ([[dict objectForKey:@"line"] rangeOfString:@"OL"].location != NSNotFound) {
////                if ([[dict objectForKey:@"line"] rangeOfString:@"1"].location != NSNotFound) {
////                    [linef1 addObject:[NSString stringWithFormat:@"%@",[dict objectForKey:@"jersey"]]];
////                }else if([[dict objectForKey:@"line"] rangeOfString:@"2"].location != NSNotFound){
////                    [linef2 addObject:[NSString stringWithFormat:@"%@",[dict objectForKey:@"jersey"]]];
////                }else if([[dict objectForKey:@"line"] rangeOfString:@"3"].location != NSNotFound){
////                    [linef3 addObject:[NSString stringWithFormat:@"%@",[dict objectForKey:@"jersey"]]];
////                }else if([[dict objectForKey:@"line"] rangeOfString:@"4"].location != NSNotFound){
////                    [linef4 addObject:[NSString stringWithFormat:@"%@",[dict objectForKey:@"jersey"]]];
////                }
////                
////            }else if([[dict objectForKey:@"line"] rangeOfString:@"DL"].location != NSNotFound){
////                if ([[dict objectForKey:@"line"] rangeOfString:@"1"].location != NSNotFound) {
////                    [lined1 addObject:[NSString stringWithFormat:@"%@",[dict objectForKey:@"jersey"]]];
////                }else if([[dict objectForKey:@"line"] rangeOfString:@"2"].location != NSNotFound){
////                    [lined2 addObject:[NSString stringWithFormat:@"%@",[dict objectForKey:@"jersey"]]];
////                }else if([[dict objectForKey:@"line"] rangeOfString:@"3"].location != NSNotFound){
////                    [lined3 addObject:[NSString stringWithFormat:@"%@",[dict objectForKey:@"jersey"]]];
////                }else if([[dict objectForKey:@"line"] rangeOfString:@"4"].location != NSNotFound){
////                    [lined4 addObject:[NSString stringWithFormat:@"%@",[dict objectForKey:@"jersey"]]];
////                }
////            }
////        }
////        globals.GLOBAL_TEAM_PLAYERS = [[NSMutableDictionary alloc]init]; //WithObjects:objects forKeys:keys];
////        [globals.GLOBAL_TEAM_PLAYERS setObject:linef1 forKey:@"line_f_1"];
////        [globals.GLOBAL_TEAM_PLAYERS setObject:linef2 forKey:@"line_f_2"];
////        [globals.GLOBAL_TEAM_PLAYERS setObject:linef3 forKey:@"line_f_3"];
////        [globals.GLOBAL_TEAM_PLAYERS setObject:linef4 forKey:@"line_f_4"];
////        [globals.GLOBAL_TEAM_PLAYERS setObject:lined1 forKey:@"line_d_1"];
////        [globals.GLOBAL_TEAM_PLAYERS setObject:lined2 forKey:@"line_d_2"];
////        [globals.GLOBAL_TEAM_PLAYERS setObject:lined3 forKey:@"line_d_3"];
////        [globals.GLOBAL_TEAM_PLAYERS setObject:lined4 forKey:@"line_d_4"];
////        
////        
//        //set number of players the user is allowed to select per line
//        numberOfPlayersAllowed = [whichSide isEqualToString:@"Defense"] ? 2 : 3;
//        
//        //we are going to initialise a dictionary of all players and select the current line
//        self.gameItems =[[NSMutableDictionary alloc]init];
//        [self.gameItems setObject:globals.ARRAY_OF_HOCKEY_PLAYERS forKey:@"Players"];
//        for(NSString *line in keys)
//        {
//            NSMutableDictionary *currentPlayers = [[NSMutableDictionary alloc]init];
//            [currentPlayers setObject:[globals.GLOBAL_TEAM_PLAYERS objectForKey:line] forKey:line];
//            if(![self.gameItems objectForKey:@"Forward"])
//            {
//                NSMutableArray *forwards = [[NSMutableArray alloc] init];
//                [self.gameItems setObject:forwards forKey:@"Forward"];
//                
//            }
//            if(![self.gameItems objectForKey:@"Defense"])
//            {
//                NSMutableArray *defense = [[NSMutableArray alloc] init];
//                [self.gameItems setObject:defense forKey:@"Defense"];
//                
//            }
//            if([line rangeOfString:@"d"].location == NSNotFound )
//            {
//                //is forward line
//                [[self.gameItems objectForKey:@"Forward" ] addObject:currentPlayers];
//                
//            }else{
//                [[self.gameItems objectForKey:@"Defense" ] addObject:currentPlayers];
//            }
//        }
//        self.currentLine = [[NSMutableArray alloc]init];
//        currentIndex = i;
//        self.currentLine = [[NSMutableArray alloc]initWithArray:[[[[self.gameItems objectForKey:whichSide] objectAtIndex:i] allValues] objectAtIndex:0]];
//        self.playerMap = [[NSMutableDictionary alloc]init];
//        return self;// Custom initialization
//    }
    return self;
}

/*- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section
{
    return [[self.gameItems objectForKey:@"Players"] count];
}*/

//- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
//    
//} 

/*- (NSInteger)numberOfSectionsInCollectionView: (UICollectionView *)collectionView {
    return 1;
}*/

-(void)createCells:(NSArray*)playerLists{
    //create the cell, use the player for the given indexpath
    
    for(NSString *playerNumber in playerLists){
        
        NSInteger i = [playerLists indexOfObject: playerNumber];
        NSInteger rowNum = ceil(i/5);
        NSInteger colNum = (i+1)%5>0 ? (i+1)%5 : 5;
        
        BorderButton* cell =[BorderButton buttonWithType:UIButtonTypeCustom];
        [cell setFrame:CGRectMake((colNum * 56)-37, (rowNum*40)+10, 40, 25)];
        [cell setBackgroundColor:[UIColor clearColor]];
        [cell setTitle:playerNumber forState:UIControlStateNormal];
        [cell setTitleColor:PRIMARY_APP_COLOR forState:UIControlStateNormal];
        [cell setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
        [cell addTarget:self action:@selector(selectCell:) forControlEvents:UIControlEventTouchUpInside];
        [_scrollView addSubview:cell];
        [_cellList addObject:cell];
    }
}

-(void)selectPlayers:(NSArray*)selectPlayers{
    [self unHighlightAllButtons];
    if (selectPlayers.count != 0){
        for (NSString *jersey in selectPlayers) {
            for (BorderButton *cell in _cellList) {
                if ([cell.titleLabel.text isEqualToString:jersey]) {
                    cell.selected = true;
                }
            }
        
        }
    }
}

-(void)unHighlightAllButtons{
    for (BorderButton *cell in _cellList) {
        cell.selected = false;
    }
}

-(void)selectCell:(id)sender{
    BorderButton *button = sender;
    if (button.selected) {
        button.selected = false;
    }else if (button.selected){
        button.selected = true;
    }
}

//-(void)createCells
//{
    //create the cell, use the player for the given indexpath
//    for(NSString *playerNumber in globals.ARRAY_OF_HOCKEY_PLAYERS)
//    {
//        int i = [globals.ARRAY_OF_HOCKEY_PLAYERS indexOfObject: playerNumber ];
//       
//        int rowNum = ceil(i/5);
//        
//        int colNum = (i+1)%5>0 ? (i+1)%5 : 5;
//        
//        BorderButton* cell =[BorderButton buttonWithType:UIButtonTypeCustom];
//           [cell setFrame:CGRectMake((colNum * 56)-37, (rowNum*40)+10, 40, 25)];
//    cell.backgroundColor = [UIColor clearColor];
//  
//    //[cell setBackgroundImage:[UIImage imageNamed:@"num-button"] forState:UIControlStateSelected];
//    
//    //[cell setBackgroundImage:[UIImage imageNamed:@"line-button-grey.png"] forState:UIControlStateNormal];
//
//    
//    //NSString *playerNumber = [[self.gameItems objectForKey:@"Players"] objectAtIndex:i];
//   // [self.playerMap setObject:[NSNumber numberWithInt:i ] forKey:playerNumber];
//
//        
//    [cell addTarget:self action:@selector(didSelectItemAtIndexPath:) forControlEvents:UIControlEventTouchUpInside];
//    [cell setTitle:playerNumber forState:UIControlStateNormal];
////        [cell setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
////        [cell setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
//    [cell setAccessibilityLabel:@"player"];
//        
//    //No shadows = better performance
//    /*[cell.layer setShadowColor:[[UIColor blackColor] CGColor]];
//    [cell.layer setShadowOpacity:0.5f];
//    [cell.layer setShadowRadius:1.0f];
//    [cell.layer setShadowOffset:CGSizeMake(-1, 1)];*/
//        
//    [cell setContentMode:UIViewContentModeScaleAspectFit];
//    
//    if([self.currentLine containsObject:playerNumber])
//    {
//        [cell setSelected:TRUE];
//        CGPoint bottomOffset = CGPointMake(0,scrollView.contentSize.height - scrollView.bounds.size.height);
//        [scrollView setContentOffset:bottomOffset animated:YES];
//    }
//    [scrollView addSubview:cell];
//    }
//}

#pragma mark - UICollectionViewDelegate
/*- (void) didSelectItemAtIndexPath:(id)sender
{
    BorderButton *button = (BorderButton*)sender;
    
    BOOL isButtonSelected = button.isSelected ? FALSE : TRUE;
    [button setSelected:isButtonSelected];
    if(isButtonSelected)
    {
//        //if user tries to add more then 3 players to a line, they get an alert and the 4th player is not selected
//        if((self.currentLine.count+1)>numberOfPlayersAllowed)
//        {
//            UIAlertView *alert = [[UIAlertView alloc]
//                                  initWithTitle: @"myplayXplay"
//                                  message: @"Only 3 players per line."
//                                  delegate: nil
//                                  cancelButtonTitle:@"OK"
//                                  otherButtonTitles:nil];
//            [alert show];
//            [button setSelected:FALSE];
//            
//        }else{
        
            //temporarily add the player to the current line
            [self.currentLine addObject:button.titleLabel.text];
//        }
    }else{
        [self.currentLine  removeObject:button.titleLabel.text];
    }
    
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    UICollectionViewCell *cell = [self.collectionView cellForItemAtIndexPath:indexPath];
    
    [self.currentLine removeObject:cell.accessibilityLabel];
}





- (void)viewWillDisappear:(BOOL)animated
{
    for(UIView *vw in scrollView.subviews)
    {
        [vw removeFromSuperview];
    }

}*/


/*- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [_scrollView setContentSize:CGSizeMake(self.view.frame.size.width,self.view.frame.size.height*2) ];
                                           //ceilf((_playerList.count/3)*50)+15)
}*/

-(void)viewDidLayoutSubviews{
    [_scrollView setContentSize:CGSizeMake(self.view.frame.size.width,ceilf((_playerList.count/3)*50)+15)];
}

/*- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Do any additional setup after loading the view from its nib.
    scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    [scrollView setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
    [self.view addSubview:scrollView];
}

 

- (void)didReceiveMemoryWarning
{
//    globals.DID_RECEIVE_MEMORY_WARNING = TRUE;
    [super didReceiveMemoryWarning];
    if ([self.view window] == nil) self.view = nil;


    // Dispose of any resources that can be recreated.
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return nil; // to supress warning
}*/


@end
