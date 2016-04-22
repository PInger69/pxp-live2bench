//
//  FakeEncoderBitrate.m
//  Live2BenchNative
//
//  Created by dev on 2016-04-18.
//  Copyright © 2016 DEV. All rights reserved.
//

#import "FakeEncoderBitrate.h"


@implementation FakeEncoderBitrate
{
    NSTimer                 * statusTimer;
    NSTimeInterval          statusInterval;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        statusInterval      = 2;
        statusTimer         = [NSTimer scheduledTimerWithTimeInterval:statusInterval target:self selector:@selector(statusLoop) userInfo:nil repeats:YES];
    }
    return self;
}


-(void)statusLoop
{
    NSLog(@"Tick");
    self.bitrate = 3.0 + (arc4random()%5);
}


-(void)dealloc
{
    [statusTimer invalidate];
}


// filler crap
-(void)resetEventAfterRemovingFeed:(Event *)event{}
-(void)clearQueueAndCurrent{}
-(void) writeToPlist{}
-(void)issueCommand:(NSString *)methodName priority:(int)priority timeoutInSec:(float)time tagData:(NSMutableDictionary*)tData  timeStamp:(NSNumber *)aTimeStamp onComplete:(void(^)(NSDictionary*userInfo))onComplete{}
-(void)issueCommand:(NSString *)methodName priority:(int)priority timeoutInSec:(float)time tagData:(NSMutableDictionary*)tData  timeStamp:(NSNumber *)aTimeStamp{}
-(Event*)getEventByName:(NSString*)eventName
{
    return nil;
}
-(void)runOperation:(EncoderOperation*)operation
{

}

-(id <EncoderProtocol>)makePrimary
{
    return self;
}
-(id <EncoderProtocol>)removeFromPrimary
{
    return self;
}


@end
