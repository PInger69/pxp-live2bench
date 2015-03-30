//
//  CustomAlertView.h
//  Live2BenchNative
//
//  Created by dev on 8/22/2014.
//  Copyright (c) 2014 DEV. All rights reserved.
//

#import <UIKit/UIKit.h>
/**
 *  This class is meant to manage all the UI alerts taht are sent in the app so that we know where they all are
 */


typedef NS_OPTIONS (NSInteger,AlertType){
    AlertNone       = 0,
    AlertImportant  = 1<<0,
    AlertMinor      = 1<<1,
    AlertCritical   = 1<<2,
    AlertAll        = 4255
};


@interface CustomAlertView : UIAlertView

@property (assign, nonatomic) AlertType type;

+(void)staticInit;
+(void)dismissAll;
+(void)addAlert:(UIAlertView*)alert;
+(void)removeAll;
+(void)removeAlert:(UIAlertView*)alert;
+(BOOL)alertMessageExists:(NSString*)alertMsg;
+(void)removeAlertWithMessage:(NSString*)message;

-(CustomAlertView*)alertType:(AlertType)type;

@end
