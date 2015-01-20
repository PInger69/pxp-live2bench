//
//  ActionList.m
//  Live2BenchNative
//
//  Created by dev on 2015-01-16.
//  Copyright (c) 2015 DEV. All rights reserved.
//

#import "ActionList.h"

#define ACTION_ITEM     @"actionItem"
#define START_BLOCK     @"startItem"
#define FINISH_BLOCK    @"finishItem"

static void * actionContext = &actionContext;

@implementation ActionList
{
    NSMutableArray * _alist;
    void(^finishList)(void);
    BOOL _running;
}

@synthesize paused  = _paused;


-(id)init
{
    self = [super init];
    if (self){
        _alist      = [[NSMutableArray alloc]init];
        _paused     = NO;
        _running    = NO;
    }
    return self;
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (context == &actionContext) {
        NSDictionary *      itemPack                = [_alist firstObject];
        id <ActionListItem> item                    = [itemPack objectForKey: ACTION_ITEM];
        if ([itemPack objectForKey: FINISH_BLOCK]) {
            void * (^onEndBlock)(BOOL succsess)     = [itemPack objectForKey: FINISH_BLOCK];
            onEndBlock(item.isSuccess);
        }
        [self finish];
    }
}

-(void)start
{
    if (![_alist count]) return;
    _running = YES;
    [self run];
}

-(void)clear
{
    if (![_alist count]) return;
    
    if (_running) {
        NSDictionary *      itemPack     = [_alist firstObject];
        id <ActionListItem> item         = [itemPack objectForKey:ACTION_ITEM];
        [((NSObject*)item) removeObserver:self forKeyPath:NSStringFromSelector(@selector(isFinished)) context:&actionContext];
        _running = NO;
    }
    finishList = nil;
    [_alist removeAllObjects];
}

/**
 *  Runs first item in the block and adds observer
 */
-(void)run
{
    NSDictionary *      itemPack     = [_alist firstObject];
    id <ActionListItem> item         = [itemPack objectForKey:ACTION_ITEM];
    
    if ([itemPack objectForKey:START_BLOCK]) {
        void * (^onStartBlock)()    = [itemPack objectForKey:START_BLOCK];
        onStartBlock();
    }
    
    [((NSObject*)item) addObserver:self forKeyPath:NSStringFromSelector(@selector(isFinished)) options:0 context:&actionContext];
    [item start];
}

/**
 *  When and Item is finished run next item or pause
 */
-(void)finish
{
    if(_paused) return ;
    
    if (![_alist count]){
        if (finishList) finishList();
        _running = NO;
    } else {
        [self next];
    }
}


/**
 *  Removes first item. Then checks when finished before running the next item
 */
-(void)next
{
    // Removes old objext
    NSDictionary *      itemPack     = [_alist firstObject];
    id <ActionListItem> item         = [itemPack objectForKey:ACTION_ITEM];
    [((NSObject*)item) removeObserver:self forKeyPath:NSStringFromSelector(@selector(isFinished)) context:&actionContext];
    [_alist removeObjectAtIndex:0];
    
    // Is list empty?... run complete if else run next item
    if (![_alist count]){
        if (finishList) finishList();
        _running = NO;
    } else {
        [self run];
    }
}





-(void)addItem:(id<ActionListItem>)item
{
    item.isFinished = NO;
    [_alist addObject:@{ACTION_ITEM:item}];
}

-(void)addItem:(id<ActionListItem>)item onItemFinish:(void (^)(BOOL succsess))onFinish
{
    item.isFinished = NO;
    [_alist addObject:@{ACTION_ITEM:item,FINISH_BLOCK:onFinish}];
}

-(void)addItem:(id<ActionListItem>)item   onItemStart:(void (^)())onStart onItemFinish:(void (^)(BOOL succsess))onFinish
{
    item.isFinished = NO;
    [_alist addObject:@{ACTION_ITEM:item, FINISH_BLOCK:onFinish, START_BLOCK:onStart}];
}


-(void)addItem:(id<ActionListItem>)item onItemStart:(void (^)())onStart
{
    item.isFinished = NO;
    [_alist addObject:@{ACTION_ITEM:item, START_BLOCK:onStart}];
}


-(void)onFinishList:(void(^)(void))finBlock
{
    finishList = finBlock;
}

-(BOOL)paused
{
    return _paused;
}

-(void)setPaused:(BOOL)paused
{
    if (paused == _paused) return;
    [self willChangeValueForKey:@"paused"];
    _paused = paused;
    [self didChangeValueForKey:@"paused"];
    
    if (!_paused && [_alist count]){
        [self next];
    }
}


@end



