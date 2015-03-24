//
//  SocialSharingManager.h
//  Live2BenchNative
//
//  Created by dev on 2015-03-13.
//  Copyright (c) 2015 DEV. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SocialSharingProtocol.h"

@interface SocialSharingManager : NSObject

+(instancetype) commonManager;
-(instancetype)initWithSocialOptions: (NSArray *) socialSharingOptions;

-(NSArray *) arrayOfIcons;
-(NSArray *) arrayOfSelectedIcons;
-(NSArray *) arrayOfSocialOptions;

-(void)shareItems:(NSArray *)itemsToShare forSocialObject: (NSString *) socialObject inViewController: (UIViewController *) viewController withProgressFrame: (CGRect) progressFrame;
-(void) linkSocialObject: (NSString *)socialObject inViewController: (UIViewController *)viewController;


@end
