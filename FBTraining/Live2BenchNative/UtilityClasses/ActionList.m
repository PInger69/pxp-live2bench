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
    NSDictionary * currentActionItem;
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
    if (context == &actionContext && [[change objectForKey:@"new"]boolValue]) {
//        NSDictionary *      itemPack                = [_alist firstObject];
        id <ActionListItem> item                    = [currentActionItem objectForKey: ACTION_ITEM];
        if ([currentActionItem objectForKey: FINISH_BLOCK]) {
            void * (^onEndBlock)(BOOL succsess)     = [currentActionItem objectForKey: FINISH_BLOCK];
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
    currentActionItem                 = [_alist firstObject];
    id <ActionListItem> item         = [currentActionItem objectForKey:ACTION_ITEM];
    [_alist removeObjectAtIndex:0];
    if ([currentActionItem objectForKey:START_BLOCK]) {
        void * (^onStartBlock)()    = [currentActionItem objectForKey:START_BLOCK];
        onStartBlock();
    }
    
    [((NSObject*)item) addObserver:self forKeyPath:NSStringFromSelector(@selector(isFinished)) options:NSKeyValueObservingOptionNew context:&actionContext];
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
    // Removes old object observer

    id <ActionListItem> item         = [currentActionItem objectForKey:ACTION_ITEM];
    [((NSObject*)item) removeObserver:self forKeyPath:NSStringFromSelector(@selector(isFinished)) context:&actionContext];

    
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



-(void)unShiftItem:(id<ActionListItem>)item
{
    item.isFinished = NO;
    [_alist insertObject:@{ACTION_ITEM:item} atIndex:0];
}

-(void)unShiftItem:(id<ActionListItem>)item onItemFinish:(void (^)(BOOL succsess))onFinish
{
    item.isFinished = NO;
    [_alist insertObject:@{ACTION_ITEM:item,FINISH_BLOCK:onFinish} atIndex:0];
}

-(void)unShiftItem:(id<ActionListItem>)item   onItemStart:(void (^)())onStart onItemFinish:(void (^)(BOOL succsess))onFinish
{
    item.isFinished = NO;
    [_alist insertObject:@{ACTION_ITEM:item, FINISH_BLOCK:onFinish, START_BLOCK:onStart} atIndex:0];
}

-(void)unShiftItem:(id<ActionListItem>)item onItemStart:(void (^)())onStart
{
    item.isFinished = NO;
    [_alist insertObject:@{ACTION_ITEM:item, START_BLOCK:onStart} atIndex:0];
}

-(void)addStack:(NSArray*)items
{
    [_alist addObjectsFromArray:items];
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


-(NSString*)description
{
    NSString* txt = [NSString stringWithFormat:@"Count of items in Action List: %lu",(unsigned long)[_alist count]];
    
    
    return txt;
}

@end







// Utility Classes




@implementation DelayAction
{
    int t;
}

@synthesize isFinished = _isFinished;
@synthesize isSuccess = _isSuccess;
@synthesize delegate = _delegate;

-(id)initWithTime:(int)time
{
    self = [super init];
    if (self){
        t = time;
    }
    return self;
}

-(void)start
{
    [self performSelector:@selector(onFinishWait) withObject:self afterDelay:t];
}

-(void)onFinishWait
{
    self.isFinished = YES;
}




@end















