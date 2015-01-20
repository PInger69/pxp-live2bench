//
//  MultiPip.m
//  Live2BenchNative
//
//  Created by dev on 2015-01-20.
//  Copyright (c) 2015 DEV. All rights reserved.
//

#import "MultiPip.h"
#import "Pip.h"

@implementation MultiPip
{
    NSMutableArray * _allPips;
    NSInteger feedCount;
}

-(id)initWithFrame:(CGRect)frame
{
    self =[super initWithFrame:frame];
    if (self) {
        _allPips = [[NSMutableArray alloc]init];
       
        float pWidth    = frame.size.width  * 0.5;
        float pHeight   = frame.size.height * 0.5;
        
        Pip * pip1 = [[Pip alloc]initWithFrame:CGRectMake(0,            0, pWidth, pHeight)];
        Pip * pip2 = [[Pip alloc]initWithFrame:CGRectMake(pWidth,       0, pWidth, pHeight)];
        Pip * pip3 = [[Pip alloc]initWithFrame:CGRectMake(pHeight,      0, pWidth, pHeight)];
        Pip * pip4 = [[Pip alloc]initWithFrame:CGRectMake(pWidth, pHeight, pWidth, pHeight)];
       
        [_allPips addObject:pip1];
        [_allPips addObject:pip2];
        [_allPips addObject:pip3];
        [_allPips addObject:pip4];
        

        [self addSubview:pip1];
        [self addSubview:pip2];
        [self addSubview:pip3];
        [self addSubview:pip4];
    }
    return self;
}


-(void)makePips:(NSArray*)listOfFeeds
{
    feedCount = [listOfFeeds count];
    
    int n = (feedCount > 4)?4: feedCount;
    
    for (int i =0; i< n; i++) {
        Pip * pip   = [_allPips objectAtIndex:i];
        Feed * feed =   [listOfFeeds objectAtIndex:i];
        [pip playWithFeed:feed];
    }
}


-(void)seekTo:(CMTime) time
{
 

    int n = (feedCount > 4)?4: feedCount;
    
    for (int i =0; i< n; i++) {
        Pip * pip   = [_allPips objectAtIndex:i];
        [pip seekTo:time];
    }
}

//
//
//
//-(void)clearPips
//{
//
//
//}




@end
