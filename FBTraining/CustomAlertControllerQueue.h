//
//  CustomAlertControllerQueue.h
//  Live2BenchNative
//
//  Created by dev on 2015-12-21.
//  Copyright © 2015 DEV. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef NS_OPTIONS (NSInteger,AlertType){
    AlertNone       = 0,
    //    AlertImportant  = 1<<0,
    //    AlertMinor      = 1<<1,
    //    AlertCritical   = 1<<2,
    //    AlertAll        = 4255
    AlertImportant      = 1<<0,
    AlertNotification   = 1<<1,
    AlertEncoder        = 1<<2,
    AlertDevice         = 1<<3,
    AlertIndecisive     = 1<<4,
    AlertAll            = 31
};

@interface CustomAlertControllerQueue : NSObject


+(CustomAlertControllerQueue*)getInstance;


@property (nonatomic ,strong) NSMutableArray * alertQueue;
@property (nonatomic ,strong) NSMutableArray * suppressedTitles;
@property (nonatomic ,assign) AlertType     allowedTypes;


-(BOOL)presentViewController:(UIViewController*)alertVC inController:(UIViewController*)presentingVC animated:(BOOL)animated style:(AlertType)type completion:(void(^)(void) )completion;
-(void)dismissViewController:(UIViewController*)alertVC animated:(BOOL)animated completion:(void(^)(void) )completion;




@end
