//
//  FacebookShare.h
//  Live2BenchNative
//
//  Created by dev on 2015-03-16.
//  Copyright (c) 2015 DEV. All rights reserved.
//
#import "SocialSharingProtocol.h"
#import <Foundation/Foundation.h>

@interface FacebookShare : NSObject <SocialSharingProtocol>

@property (strong, readonly, nonatomic) UIImage *icon;
@property (strong, readonly, nonatomic) UIImage *selectedIcon;
@property (strong, nonatomic) NSString *name;
//@property (strong, nonatomic) UIViewController *viewController;
@property (assign, nonatomic) BOOL enabled;
@property (assign, nonatomic) BOOL isLoggedIn;
@property (assign, nonatomic) int tasksToComplete;
@property (assign, nonatomic) int tasksCompleted;

-(void) linkInViewController: (UIViewController *)viewController;
-(void)shareItems: (NSArray *) itemsToShare inViewController: (UIViewController *) viewController;
//-(void)cancel;


@end
