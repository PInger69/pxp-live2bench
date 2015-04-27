//
//  CustomAlertView.m
//  Live2BenchNative
//
//  Created by dev on 8/22/2014.
//  Copyright (c) 2014 DEV. All rights reserved.
//

#import "CustomAlertView.h"

static NSMutableArray * alertPool;



@implementation CustomAlertView

static AlertType    allowedTypes;


+(void)staticInit {
    if (alertPool) return;
    alertPool           = [[NSMutableArray alloc]init];
<<<<<<< HEAD
    allowedTypes        = AlertNone;
    //typeChangeObserver  =  [[NSNotificationCenter defaultCenter]addObserverForName:@"alertTest" object:nil queue:nil usingBlock:^(NSNotification *note) {
                            // take the value from dict
                            // change "allowedTypes" to the value sent
    //                        NSLog(@"Alert Test!!!!!!!");
     //                   }];
=======
    allowedTypes        = AlertImportant;

>>>>>>> 002cc8652ee3b8dc46452d479cffa50a208552d5
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_REQUEST_SETTINGS object:nil userInfo:@{@"name":@"Alerts", @"block":^(NSArray *settingOptions, NSArray *onOrOff){
        for (int i = 0; i < [settingOptions count]; i++) {
            if ([((NSNumber *)onOrOff[i]) integerValue] == 1) {
                if ([settingOptions[i] isEqualToString:@"Notification Alerts"]){
                    allowedTypes = allowedTypes | AlertNotification;
                } else if ([settingOptions[i] isEqualToString:@"Encoder Alerts"]){
                    allowedTypes = allowedTypes | AlertEncoder;
                } else if ([settingOptions[i] isEqualToString:@"Device Alerts"]){
                    allowedTypes = allowedTypes | AlertDevice;
                } else {
                    allowedTypes = allowedTypes | AlertIndecisive;
                }
            }
        }
    }}];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(allowedTypesChanged:) name:@"Setting - Alerts" object:nil];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"" object:nil userInfo:@{}];
}

+(void)allowedTypesChanged:(NSNotification *)note {
    if ([note.userInfo[@"Name"] isEqualToString:@"Notification Alerts"]) {
        if (![note.userInfo[@"Value"] boolValue]) {
            allowedTypes = allowedTypes & (~AlertNotification);
        } else {
            allowedTypes = allowedTypes | AlertNotification;
        }
    } else if ([note.userInfo[@"Name"] isEqualToString:@"Encoder Alerts"]){
        if (![note.userInfo[@"Value"] boolValue]) {
            allowedTypes = allowedTypes & (~AlertEncoder);
        } else {
            allowedTypes = allowedTypes | AlertEncoder;
        }
    } else if ([note.userInfo[@"Name"] isEqualToString:@"Device Alerts"]){
        if (![note.userInfo[@"Value"] boolValue]) {
            allowedTypes = allowedTypes & (~AlertDevice);
        } else {
            allowedTypes = allowedTypes | AlertDevice;
        }
    } else {
        if (![note.userInfo[@"Value"] boolValue]) {
            allowedTypes = allowedTypes & (~AlertIndecisive);
        } else {
            allowedTypes = allowedTypes | AlertIndecisive;
        }
    }
}

+(void)dismissAll
{
    if (!alertPool) [CustomAlertView staticInit];
    if (alertPool.count > 0) {
        NSMutableArray *tempArr = [alertPool mutableCopy];
        for(UIAlertView *view in tempArr){
            [view dismissWithClickedButtonIndex:0 animated:NO];
            [alertPool removeObject:view];
        }
    }
}

+(void)addAlert:(UIAlertView*)alert
{
    if (!alertPool) [CustomAlertView staticInit];
    if (![alertPool containsObject:self])    [alertPool addObject:alert];
}

+(void)removeAll
{
    if (!alertPool) [CustomAlertView staticInit];
    [alertPool removeAllObjects];
}

+ (void)removeAlert:(UIAlertView*)alert
{
    if (!alertPool) [CustomAlertView staticInit];
    [alertPool removeObject:alert];
}



+(void)removeAlertWithMessage:(NSString*)message
{
    if (!alertPool) [CustomAlertView staticInit];
   
    for (int i=[alertPool count]; i>0;i--){
        UIAlertView * check = [alertPool objectAtIndex:i];
        if ([check.message isEqualToString:message]){
            [alertPool removeObject:check];
        }
    }
}



+(BOOL)alertMessageExists:(NSString*)alertMsg
{
    BOOL *alertExists = NO;
    for (UIAlertView *alert in alertPool){
        if ([alert.message isEqualToString:alertMsg]){
            alertExists = YES;
            break;
        }
    }
    return alertExists;
}

/**
 *  This is for debugging only
 */
+(void)tintAlertTest
{
    UIAlertView * alertTint = [[UIAlertView alloc] initWithTitle:@"TintTest" message:@"was Change?" delegate:nil cancelButtonTitle:@"Close" otherButtonTitles:@"ok", nil];
    [alertTint show];
}

-(id)init{
    if (!alertPool) [CustomAlertView staticInit];
    self = [super init];
    if (self) {
        if (![alertPool containsObject:self])    [alertPool addObject:self];
    }
    return self;
}

- (id)initWithTitle:(NSString *)title message:(NSString *)message delegate:(id /*<UIAlertViewDelegate>*/)delegate cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitles:(NSString *)otherButtonTitles, ... NS_REQUIRES_NIL_TERMINATION
{
    if (!alertPool) [CustomAlertView staticInit];
    self = [super initWithTitle:title message:message delegate:delegate cancelButtonTitle:cancelButtonTitle otherButtonTitles:otherButtonTitles, nil];
    if (self) {
        self.type = AlertAll;
//        [alertPool addObject:self];
        if (![alertPool containsObject:self])    [alertPool addObject:self];
    }
    return self;
}

//-(void)show
//{
//    if (allowedTypes & self.type) {
//        [super show];
//    }
//}

-(BOOL)display
{
    if (allowedTypes & self.type) {
        [super show];
        return YES;
    } else {
        return NO;
    }
}

-(CustomAlertView*)alertType:(AlertType)type
{
    self.type = type;
    return self;
}



@end
