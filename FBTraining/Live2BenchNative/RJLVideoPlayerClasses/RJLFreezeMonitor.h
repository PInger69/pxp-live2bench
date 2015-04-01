//
//  RJLFreezeMonitor.h
//  Live2BenchNative
//
//  Created by dev on 2015-03-20.
//  Copyright (c) 2015 DEV. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PxpVideoPlayerProtocol.h"


@interface RJLFreezeMonitor : NSObject

@property (nonatomic,assign) BOOL enabled;

- (instancetype)initWithPlayer:(UIViewController <PxpVideoPlayerProtocol>*)aPlayer;

-(void)stop;

-(void)start;

@end
