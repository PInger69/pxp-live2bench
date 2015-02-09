//
//  EncoderManagerActionPack.m
//  Live2BenchNative
//
//  Created by dev on 2015-01-21.
//  Copyright (c) 2015 DEV. All rights reserved.
//

#import "EncoderManagerActionPack.h"




@implementation CheckForACloudAction
{
    EncoderManager * encoderMangager;
}
@synthesize isFinished  = _isFinished;
@synthesize isSuccess   = _isSuccess;

-(id)initWithEncoderManager:(EncoderManager*)aEncoderManager
{
    self = [super init];
    if (self) {
        encoderMangager = aEncoderManager;
    }
    return self;
}




-(void)start {
    NSURL * checkURL                        = [NSURL URLWithString:   @"http://myplayxplay.net/max/ping/ajax"  ];
    NSURLRequest * urlRequest               = [NSURLRequest requestWithURL:checkURL cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60];
    NSURLConnection * connnect              = [NSURLConnection connectionWithRequest:urlRequest delegate:self];
    [connnect start];
}


- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    self.isSuccess          = YES;
    self.isFinished         = YES;
    encoderMangager.hasMAX  = YES;
}


-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    self.isSuccess  = NO;
    self.isFinished = YES;
    encoderMangager.hasMAX  = NO;
}

-(id <ActionListItem>)reset
{   _isSuccess  = NO;
    _isFinished = NO;
    return self;
}

@end

@implementation CheckWiFiAction
{
    
    EncoderManager * encoderMangager;
}
@synthesize isFinished  = _isFinished;
@synthesize isSuccess   = _isSuccess;

-(id)initWithEncoderManager:(EncoderManager*)aEncoderManager
{
    self = [super init];
    if (self) {
        encoderMangager = aEncoderManager;
    }
    return self;
}

-(void)start {
    self.isSuccess = encoderMangager.hasWiFi;
    self.isFinished = YES;
}

-(id <ActionListItem>)reset
{   _isSuccess  = NO;
    _isFinished = NO;
    return self;
}
@end

@implementation CheckMasterEncoderAction
{
    EncoderManager * encoderManager;
    
}
@synthesize isFinished  = _isFinished;
@synthesize isSuccess   = _isSuccess;



-(id)initWithEncoderManager:(EncoderManager*)aEncoderManager
{
    self = [super init];
    if (self) {
        encoderManager = aEncoderManager;
    }
    
    return self;
    
}

-(void)start
{
    if (encoderManager.masterEncoder) {
        self.isFinished = YES;
    } else {
        
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(found) name:NOTIF_EM_FOUND_MASTER object:nil];
    }
}


-(void)found
{
    self.isSuccess = YES;
    
    [[NSNotificationCenter defaultCenter]removeObserver:self name:NOTIF_EM_FOUND_MASTER object:nil];
    self.isFinished = YES;
}

-(id <ActionListItem>)reset
{   _isSuccess  = NO;
    _isFinished = NO;
    return self;
}

-(void)dealloc
{
    
    [[NSNotificationCenter defaultCenter]removeObserver:self name:NOTIF_EM_FOUND_MASTER object:nil];
}

@end

@implementation LogoutAction
{
    EncoderManager * encoderManager;
    
}
@synthesize isFinished  = _isFinished;
@synthesize isSuccess   = _isSuccess;



-(id)initWithEncoderManager:(EncoderManager*)aEncoderManager
{
    self = [super init];
    if (self) {
        encoderManager = aEncoderManager;
    }
    
    return self;
    
}

-(void)start
{
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(found:) name:NOTIF_USER_LOGGED_OUT object:nil];
    [encoderManager logoutOfCloud];
}


-(void)found:(NSNotification*)note
{
    self.isSuccess = [[note.userInfo objectForKey:@"success"]boolValue];
    
    [[NSNotificationCenter defaultCenter]removeObserver:self name:NOTIF_USER_LOGGED_OUT object:nil];
    self.isFinished = YES;
}

-(id <ActionListItem>)reset
{   _isSuccess  = NO;
    _isFinished = NO;
    return self;
}

-(void)dealloc
{
    
    [[NSNotificationCenter defaultCenter]removeObserver:self name:NOTIF_USER_LOGGED_OUT object:nil];
}

@end


@implementation CloudTagNamesToUserCenter

@synthesize isFinished  = _isFinished;
@synthesize isSuccess   = _isSuccess;

-(void)start
{
    
}

-(id <ActionListItem>)reset
{   _isSuccess  = NO;
    _isFinished = NO;
    return self;
}

@end