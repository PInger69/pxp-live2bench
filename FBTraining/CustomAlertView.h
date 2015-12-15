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


@interface CustomAlertView : UIAlertView

@property (assign, nonatomic) AlertType type;

+(void)staticInit;
+(void)dismissAll;
+(void)addAlert:(UIAlertView*)alert;
+(void)removeAll;
+(void)removeAlert:(UIAlertView*)alert;
+(BOOL)alertMessageExists:(NSString*)alertMsg;
+(void)removeAlertWithMessage:(NSString*)message;
+(NSMutableArray*)supressedTitles;


-(CustomAlertView*)alertType:(AlertType)type;
-(BOOL)display;

-(CustomAlertView*)showView;
-(void)viewFinished;
@end
