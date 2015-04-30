//
//  SocialSharingProtocol.h
//  Live2BenchNative
//
//  Created by dev on 2015-03-13.
//  Copyright (c) 2015 DEV. All rights reserved.
//

#ifndef Live2BenchNative_SocialSharingProtocol_h
#define Live2BenchNative_SocialSharingProtocol_h

@protocol SocialSharingProtocol <NSObject>

@property (strong, readonly, nonatomic) UIImage *icon;
@property (strong, readonly, nonatomic) UIImage *selectedIcon;
@property (strong, nonatomic) NSString *name;
//@property (strong, nonatomic) UIViewController *viewController;
@property (assign, nonatomic) BOOL enabled;
@property (assign, nonatomic) BOOL isLoggedIn;
@property (assign, nonatomic) int tasksToComplete;
@property (assign, nonatomic) int tasksCompleted;


-(void)shareItems: (NSArray *) itemsToShare inViewController: (UIViewController *) viewController;
//-(void)cancel;

@optional
-(void) linkInViewController: (UIViewController *)viewController;

@end

#endif
