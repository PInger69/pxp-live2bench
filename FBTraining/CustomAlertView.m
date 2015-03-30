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
static AlertType allowedTypes;


+(void)staticInit {
    alertPool       = [[NSMutableArray alloc]init];
    allowedTypes    = AlertAll;
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

+(void)removeAlert:(UIAlertView*)alert
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
//        [alertPool addObject:self];
        if (![alertPool containsObject:self])    [alertPool addObject:self];
    }
    return self;

}

- (id)initWithTitle:(NSString *)title message:(NSString *)message delegate:(id /*<UIAlertViewDelegate>*/)delegate cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitles:(NSString *)otherButtonTitles, ... NS_REQUIRES_NIL_TERMINATION
{
    if (!alertPool) [CustomAlertView staticInit];
    self = [super initWithTitle:title message:message delegate:delegate cancelButtonTitle:cancelButtonTitle otherButtonTitles:otherButtonTitles, nil];
    if (self) {
        self.type = AlertNone;
//        [alertPool addObject:self];
            if (![alertPool containsObject:self])    [alertPool addObject:self];
    }
    return self;
}

-(void)show
{
   // if (allowedTypes & self.type) {
     [super show];   
   // }
}

-(CustomAlertView*)alertType:(AlertType)type
{
    self.type = type;
    return self;
}



@end
