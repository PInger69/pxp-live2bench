//
//  StreamViewVideoKit.m
//  Live2BenchNative
//
//  Created by dev on 2016-04-04.
//  Copyright © 2016 DEV. All rights reserved.
//

#import "StreamViewVideoKit.h"


@interface StreamViewVideoKit ()
//@property (nonatomic, retain) VKPlayerController *player;
@end



@implementation StreamViewVideoKit

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.view = self;
        [self setBackgroundColor:[UIColor greenColor]];
//        self.player = [[VKPlayerController alloc]initWithURLString:@""];
//        [self.view addSubview:self.player];
    }
    return self;
}


- (instancetype)init
{
    self = [super init];
    if (self) {
        self.view = self;
        [self setBackgroundColor:[UIColor greenColor]];
    }
    return self;
}
-(void)url:(NSString*)urlPath
{

}

-(void)refresh
{

}

-(void)clear
{

}

@end
