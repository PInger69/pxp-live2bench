//
//  RicoPlayerMonitor.h
//  Live2BenchNative
//
//  Created by dev on 2016-05-04.
//  Copyright © 2016 DEV. All rights reserved.
//

#import <Foundation/Foundation.h>
@class RicoPlayer;
@interface RicoPlayerMonitor : NSObject

@property (nonatomic,strong) NSMutableArray * log;

- (instancetype)initWithPlayer:(RicoPlayer*)player;

-(void)start;
-(void)stop;


-(void)update:(RicoPlayer*)player;
-(void)reset;


@end
