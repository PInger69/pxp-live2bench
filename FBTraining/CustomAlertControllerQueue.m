//
//  CustomAlertControllerQueue.m
//  Live2BenchNative
//
//  Created by dev on 2015-12-21.
//  Copyright © 2015 DEV. All rights reserved.
//

#import "CustomAlertControllerQueue.h"

@implementation CustomAlertControllerQueue
static CustomAlertControllerQueue * _instance;

+(CustomAlertControllerQueue*)getInstance
{
    if (!_instance){
        _instance = [[CustomAlertControllerQueue alloc]init];
    }
    
    return _instance;

}


- (instancetype)init
{
    self = [super init];
    if (self) {
        self.alertQueue         = [NSMutableArray new];
        self.suppressedTitles   = [NSMutableArray new];
        self.allowedTypes       = AlertAll;// & ~(AlertIndecisive);
    }
    return self;
}


-(BOOL)presentViewController:(UIViewController*)alertVC inController:(UIViewController*)presentingVC animated:(BOOL)animated style:(AlertType)type completion:(void(^)(void) )completion
{
    if ((self.allowedTypes & type) == 0) {
     return NO;
    }
    

    
    if ([self.suppressedTitles containsObject:alertVC.title]){
        return NO;
    }
    
    [self.alertQueue addObject:@{
                                 @"alertVC":alertVC,
                                 @"presentingVC":presentingVC,
                                 @"animated":@(animated)
//                                 @"completion":completion == nil)?[NSNull null]:completion
                                 }];
    [self presentAny];
    return YES;
}





-(void)dismissViewController:(UIViewController*)alertVC animated:(BOOL)animated completion:(void(^)(void) )completion
{
    if (alertVC.presentingViewController != nil) {
        __weak CustomAlertControllerQueue * weakself = self;
        [alertVC dismissViewControllerAnimated:animated completion:^{
            
            if (completion) completion();
            [weakself presentAny];
        }];
    
    } else {
        if (completion)completion();
        [self presentAny];
    }
    
    

}

-(void)presentAny
{
    if ([self.alertQueue count] >0) {
        
        UIAlertController* alertVC      = self.alertQueue[0][@"alertVC"];
        UIViewController* presentingVC = self.alertQueue[0][@"presentingVC"];
  
        
        if (presentingVC.presentedViewController != nil)return;
        void (^block)() = self.alertQueue[0][@"completion"];
        [presentingVC presentViewController:alertVC animated:[self.alertQueue[0][@"animated"]boolValue] completion:block];
        [self.alertQueue removeObjectAtIndex:0];
    }

}


@end
