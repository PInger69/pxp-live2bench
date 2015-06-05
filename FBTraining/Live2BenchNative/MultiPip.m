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
    
    id                  observerCloseFullScreen;
    id                  observerOpenFullScreen;
    NSDictionary        * smallScreenFramesParts;
    NSDictionary        * fullScreenFramesParts;
    
    
    NSMutableArray      * _allPips;
    NSInteger           feedCount;
    CGRect              rect;
}



@synthesize context = _context;

-(id)initWithFrame:(CGRect)frame
{

    self =[super initWithFrame:frame];
    if (self) {
        rect        = frame;
        _allPips    = [[NSMutableArray alloc]init];
       
        float pWidth    = frame.size.width  * 0.5;
        float pHeight   = frame.size.height * 0.5;
        
        Pip * pip1 = [[Pip alloc]initWithFrame:CGRectMake(0,            0, pWidth, pHeight)];
        Pip * pip2 = [[Pip alloc]initWithFrame:CGRectMake(pWidth,       0, pWidth, pHeight)];
        Pip * pip3 = [[Pip alloc]initWithFrame:CGRectMake(0,      pHeight, pWidth, pHeight)];
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
    
    NSInteger n = (feedCount > 4)?4: feedCount;
   
    
    if (n == 1) {
       [((Pip *)[_allPips objectAtIndex:0]) playWithFeed:(Feed *)[listOfFeeds objectAtIndex:0]];
       [((Pip *)[_allPips objectAtIndex:1]) playWithFeed:(Feed *)[listOfFeeds objectAtIndex:0]];
       [((Pip *)[_allPips objectAtIndex:2]) playWithFeed:(Feed *)[listOfFeeds objectAtIndex:0]];
       [((Pip *)[_allPips objectAtIndex:3]) playWithFeed:(Feed *)[listOfFeeds objectAtIndex:0]];
    
    } else if (n ==2) {
        [((Pip *)[_allPips objectAtIndex:0]) playWithFeed:(Feed *)[listOfFeeds objectAtIndex:0]];
        [((Pip *)[_allPips objectAtIndex:1]) playWithFeed:(Feed *)[listOfFeeds objectAtIndex:1]];
        [((Pip *)[_allPips objectAtIndex:2]) playWithFeed:(Feed *)[listOfFeeds objectAtIndex:1]];
        [((Pip *)[_allPips objectAtIndex:3]) playWithFeed:(Feed *)[listOfFeeds objectAtIndex:0]];
    
    } else if (n ==3) {
        [((Pip *)[_allPips objectAtIndex:0]) playWithFeed:(Feed *)[listOfFeeds objectAtIndex:0]];
        [((Pip *)[_allPips objectAtIndex:1]) playWithFeed:(Feed *)[listOfFeeds objectAtIndex:1]];
        [((Pip *)[_allPips objectAtIndex:2]) playWithFeed:(Feed *)[listOfFeeds objectAtIndex:3]];
        [((Pip *)[_allPips objectAtIndex:3]) playWithFeed:(Feed *)[listOfFeeds objectAtIndex:0]];
        
    } else if (n ==4) {
        [((Pip *)[_allPips objectAtIndex:0]) playWithFeed:(Feed *)[listOfFeeds objectAtIndex:0]];
        [((Pip *)[_allPips objectAtIndex:1]) playWithFeed:(Feed *)[listOfFeeds objectAtIndex:1]];
        [((Pip *)[_allPips objectAtIndex:2]) playWithFeed:(Feed *)[listOfFeeds objectAtIndex:3]];
        [((Pip *)[_allPips objectAtIndex:3]) playWithFeed:(Feed *)[listOfFeeds objectAtIndex:4]];
        
    }
    
//    for (int i =0; i< n; i++) {
//        Pip * pip   = [_allPips objectAtIndex:i];
//        Feed * feed =   [listOfFeeds objectAtIndex:i];
//        [pip playWithFeed:feed];
//    }
//    
//    
//    NSInteger leftToMake = 4 - n;
//    
//    for (NSInteger ii =leftToMake; ii > 0; ii--) {
//        Pip * pip   = [_allPips objectAtIndex:n++];
//        Feed * feed =   [listOfFeeds objectAtIndex:ii];
//        [pip playWithFeed:feed];
//    }
    
}


-(void)seekTo:(CMTime) time
{
//    NSInteger n = (feedCount > 4)?4: feedCount;
//    for (int i =0; i< n; i++) {
//        Pip * pip   = [_allPips objectAtIndex:i];
//        [pip seekTo:time];
//    }
    for (Pip * p in _allPips) {
        [p seekTo:time];
    }
    
}

//
-(void)pause
{
    for (Pip * p in _allPips) {
        [p pause];
    }

}

//
-(void)live
{
    for (Pip * p in _allPips) {
        [p live];
    }
    
}
-(void)play
{
    for (Pip * p in _allPips) {
        [p play];
    }
}

-(void)playRate:(float)rate
{
    for (Pip * p in _allPips) {
        [p playRate:rate];
    }
}

-(void)fullScreen
{
    if (self.superview){

        [UIView beginAnimations:@"scaleAnimation" context:nil];
        [UIView setAnimationDuration:0.22];
        
            float pWidth    = self.superview.frame.size.width  * 0.5;
            float pHeight   = self.superview.frame.size.height * 0.5;
            ((Pip*)_allPips[0]).frame               = CGRectMake(0,            0, pWidth, pHeight);
            ((Pip*)_allPips[0]).avPlayerLayer.frame = CGRectMake(0,            0, pWidth, pHeight);
        
            ((Pip*)_allPips[1]).frame               = CGRectMake(pWidth,       0, pWidth, pHeight);
            ((Pip*)_allPips[1]).avPlayerLayer.frame = CGRectMake(0,       0, pWidth, pHeight);
        
            ((Pip*)_allPips[2]).frame               = CGRectMake(0,      pHeight, pWidth, pHeight);
            ((Pip*)_allPips[2]).avPlayerLayer.frame = CGRectMake(0,      0, pWidth, pHeight);
        
            ((Pip*)_allPips[3]).frame               = CGRectMake(pWidth, pHeight, pWidth, pHeight);
            ((Pip*)_allPips[3]).avPlayerLayer.frame = CGRectMake(0, 0, pWidth, pHeight);
        
        [UIView commitAnimations];

    }
}

-(void)normalScreen
{
    [UIView beginAnimations:@"scaleAnimation" context:nil];
    [UIView setAnimationDuration:0.22];

        float pWidth    = rect.size.width  * 0.5;
        float pHeight   = rect.size.height * 0.5;
        ((Pip*)_allPips[0]).frame               = CGRectMake(0,            0, pWidth, pHeight);
        ((Pip*)_allPips[0]).avPlayerLayer.frame = CGRectMake(0,            0, pWidth, pHeight);
    
        ((Pip*)_allPips[1]).frame               = CGRectMake(pWidth,       0, pWidth, pHeight);
        ((Pip*)_allPips[1]).avPlayerLayer.frame = CGRectMake(0,       0, pWidth, pHeight);
    
        ((Pip*)_allPips[2]).frame               = CGRectMake(0,      pHeight, pWidth, pHeight);
        ((Pip*)_allPips[2]).avPlayerLayer.frame = CGRectMake(0,      0, pWidth, pHeight);
    
        ((Pip*)_allPips[3]).frame               = CGRectMake(pWidth, pHeight, pWidth, pHeight);
        ((Pip*)_allPips[3]).avPlayerLayer.frame = CGRectMake(0, 0, pWidth, pHeight);
    [UIView commitAnimations];
}


@end
