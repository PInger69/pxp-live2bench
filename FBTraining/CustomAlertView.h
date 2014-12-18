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

typedef enum : NSUInteger {
    AlertNone       = 0,
    AlertImportant  = 1<<1,
    AlertMinor      = 1<<2,
    AlertCritical   = 1<<3,
    AlertAll        = 4294967295
    
} AlertType;


@interface CustomAlertView : UIAlertView

@property (assign, nonatomic) AlertType type;

+(void)dismissAll;
+(void)addAlert:(UIAlertView*)alert;
+(void)removeAll;
+(void)removeAlert:(UIAlertView*)alert;
+(BOOL)alertMessageExists:(NSString*)alertMsg;
+(void)removeAlertWithMessage:(NSString*)message;
@end
