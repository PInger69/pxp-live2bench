//
//  StreamViewVideoKit.m
//  Live2BenchNative
//
//  Created by dev on 2016-04-04.
//  Copyright © 2016 DEV. All rights reserved.
//

#import "StreamViewVideoKit.h"
#import "VKPlayerViewController.h"

@interface StreamViewVideoKit ()
@property (nonatomic,strong) UIView * player;
@property (nonatomic,strong) VKPlayerController *playerC;
@end



@implementation StreamViewVideoKit

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.view = self;
        [self setBackgroundColor:[UIColor blueColor]];
    }
    return self;
}


- (instancetype)init
{
    self = [super init];
    if (self) {
        self.view = self;
        [self setBackgroundColor:[UIColor blueColor]];
    }
    return self;
}
-(void)url:(NSString*)urlPath
{
    NSDictionary *options = @{ @"rtsp_transport":@"tcp"};
 
    if (self.playerC) {
        [self.playerC stop];
        [self.playerC.view removeFromSuperview];
    }
    
    
    //@"rtsp://172.18.2.102:8900/pxpstr"
    self.playerC =  [[VKPlayerController alloc]initWithURLString:urlPath];
    self.playerC.decoderOptions = options;
    
    [self.playerC.view setFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    [self.view addSubview:self.playerC.view];
    self.playerC.controlStyle = kVKPlayerControlStyleNone;
    [self.playerC play];
    [self.playerC setMute:YES];
    
}

-(void)refresh
{

}

-(void)clear
{
    [self.playerC stop];
}

@end
