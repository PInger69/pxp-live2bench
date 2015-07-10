//
//  AppDelegateActionPack.m
//  Live2BenchNative
//
//  Created by dev on 2015-01-23.
//  Copyright (c) 2015 DEV. All rights reserved.
//

#import "AppDelegateActionPack.h"

@implementation RequestUserInfoAction
{
    AppDelegate *appDelegate;
}

@synthesize isFinished  = _isFinished;
@synthesize isSuccess   = _isSuccess;
@synthesize delegate = _delegate;

- (instancetype)initWithAppDelegate:(AppDelegate*)appDel
{
    self = [super init];
    if (self) {
        appDelegate = appDel;
    }
    return self;
}


-(void)start
{
    [appDelegate.tabBarController presentViewController:appDelegate.loginController animated:YES completion:nil];
    [appDelegate.loginController addObserver:self forKeyPath:NSStringFromSelector(@selector(success)) options:NSKeyValueObservingOptionNew context:NULL];
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:NSStringFromSelector(@selector(success))]) {
        self.isSuccess  = YES;
        self.isFinished = YES;
        [appDelegate.loginController removeObserver:self  forKeyPath:NSStringFromSelector(@selector(success))];
    }
}


-(void)dealloc
{
    [appDelegate.loginController removeObserver:self  forKeyPath:NSStringFromSelector(@selector(success))];
}

-(id <ActionListItem>)reset
{

    _isSuccess  = NO;
    _isFinished = NO;
    return self;
}

@end


@implementation RequestEulaAction
{
    AppDelegate *appDelegate;
}

@synthesize isFinished  = _isFinished;
@synthesize isSuccess   = _isSuccess;
@synthesize delegate = _delegate;

- (instancetype)initWithAppDelegate:(AppDelegate*)appDel
{
    self = [super init];
    if (self) {
        appDelegate = appDel;
    }
    return self;
}
-(void)start
{
    [appDelegate.eulaViewController onCompleteAccept:^{
        [appDelegate.loginController dismissViewControllerAnimated:YES completion:nil];
    }];
    [appDelegate.loginController presentViewController:appDelegate.eulaViewController animated:YES completion:nil];
    [appDelegate.eulaViewController addObserver:self forKeyPath:NSStringFromSelector(@selector(accepted)) options:NSKeyValueObservingOptionNew context:NULL];
    
}


-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:NSStringFromSelector(@selector(accepted))]) {
        [appDelegate.eulaViewController removeObserver:self  forKeyPath:NSStringFromSelector(@selector(accepted))];
        self.isSuccess  = YES;
        self.isFinished = YES;
    }
}

-(void)dealloc
{
    [appDelegate.eulaViewController removeObserver:self  forKeyPath:NSStringFromSelector(@selector(accepted))];
}

-(id <ActionListItem>)reset
{   _isSuccess  = NO;
    _isFinished = NO;
    return self;
}


@end