//
//  RicoPreRollOperation.m
//  Live2BenchNative
//
//  Created by dev on 2015-11-30.
//  Copyright © 2015 DEV. All rights reserved.
//

#import "RicoPreRollOperation.h"

@interface RicoPreRollOperation ()
@property (weak,nonatomic) AVPlayer * player;
@property (assign,nonatomic) float rate;

@end


@implementation RicoPreRollOperation  
{
    BOOL _finished;
    
}



- (instancetype)initWithAVPlayer:(AVPlayer*)aPlayer prerollAtRate:(float)aRate
{
    self = [super init];
    if (self) {
        _player = aPlayer;
        _rate = aRate;
        _finished = NO;
    }
    return self;
}


-(void)main
{
    __block RicoPreRollOperation* weakself = self;
    
    [_player prerollAtRate:_rate completionHandler:^(BOOL finished) {
        
        if (weakself.completionHandler != nil) {
            weakself.completionHandler(finished);
        }
        NSLog(@"Preroll finishe  success %@",(finished)?@"yes":@"no");
        [self setFinished:YES];
    }];
    
}


- (void)setFinished:(BOOL)isFinished
{
    [self willChangeValueForKey:@"isFinished"];
    _finished = isFinished;
    [self didChangeValueForKey:@"isFinished"];
}

-(BOOL)finished
{
    return _finished;
}

-(void)cancel
{
    [self setFinished:YES];
    self.player = nil;
    [super cancel];
}


@end
