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

-(id)initWithFrame:(CGRect)frame playerList:(NSArray*)playerList{
    self = [super init];
    self.view.frame = frame;
    
    _scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    [_scrollView setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
    _scrollView.showsVerticalScrollIndicator = true;
    [self.view addSubview:_scrollView];
    
    //_bottomViewController = bottomViewController;
    _cellList =  [[NSMutableArray alloc]init];
    _playerList = [playerList sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"doubleValue" ascending:YES]]];
    [self createCells:_playerList];
    

    return self;
}

-(id)initWithPlayerList:(NSArray*)playerList{
    return [self initWithFrame:CGRectZero playerList:playerList];
}

-(void)assignFrame:(CGRect)frame{
    self.view.frame = frame;
}

- (id)initWithIndex:(NSInteger)i side:(NSString*)whichSide
{
    self = [super init];
    if (self) {
    }
    return self;
}

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

-(NSArray*)getSelectedPlayers{
    NSMutableArray *players = [[NSMutableArray alloc]init];
    for (BorderButton *button in _cellList) {
        if (button.selected) {
            [players addObject:button.titleLabel.text];
        }
    }
    return [players copy];
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
    }else if (!button.selected){
        button.selected = true;
    }
}


-(void)viewDidLayoutSubviews{
    [_scrollView setContentSize:CGSizeMake(self.view.frame.size.width,ceilf((_playerList.count/3)*50)+15)];
}

@end
