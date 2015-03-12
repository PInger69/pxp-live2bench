//
//  JPGlobal.h
//  JumpPad
//
//  Created by Si Te Feng on 2014-05-14.
//  Copyright (c) 2014 Si Te Feng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


@interface JPReorderHelper : NSObject


+ (instancetype)instance;






+ (NSString*)monthStringWithInt: (int)month;
+ (NSString*)ratingStringWithIndex: (NSInteger)index;
+ (NSString*)schoolYearStringWithInteger: (NSUInteger)year;

+ (NSString*)paragraphStringWithName: (NSString*)name;
+ (void)openURL: (NSURL*)url;


UIImage* imageFromView(UIView *view);







@end
