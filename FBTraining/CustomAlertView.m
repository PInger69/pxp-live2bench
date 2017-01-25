//
//  CustomAlertView.m
//  Live2BenchNative
//
//  Created by dev on 8/22/2014.
//  Copyright (c) 2014 DEV. All rights reserved.
//

#import "CustomAlertView.h"
#import "AlertsSettingViewController.h"

static NSMutableArray * alertPool;
static NSMutableArray * _currentViews;
static NSMutableArray * _supressedTitles;


@implementation CustomAlertView

static AlertType    allowedTypes;


+(void)staticInit {
    if (alertPool) return;
    alertPool           = [[NSMutableArray alloc]init];
    _currentViews       = [[NSMutableArray alloc]init];
    _supressedTitles    = [[NSMutableArray alloc]init];
    // all enabled by default
    allowedTypes = AlertImportant | AlertNotification | AlertEncoder | AlertDevice | AlertIndecisive;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(alertsSettingChanged:) name:NOTIF_ALERTS_SETTING_CHANGED object:nil];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"" object:nil userInfo:@{}];
    
}

+(NSMutableArray*)supressedTitles
{

    return _supressedTitles;
}

+ (void)alertsSettingChanged:(NSNotification *)note {
    NSDictionary *alertSettings = note.userInfo;
    
    allowedTypes = AlertImportant;
    
    if ([alertSettings[ALERT_NOTIFICATION] boolValue]) allowedTypes |= AlertNotification;
    if ([alertSettings[ALERT_ENCODER] boolValue]) allowedTypes |= AlertEncoder;
    if ([alertSettings[ALERT_DEVICE] boolValue]) allowedTypes |= AlertDevice;
    if ([alertSettings[ALERT_INDECISIVE] boolValue]) allowedTypes |= AlertIndecisive;
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
   
    for (NSInteger i=[alertPool count]; i>0;i--){
        UIAlertView * check = [alertPool objectAtIndex:i];
        if ([check.message isEqualToString:message]){
            [alertPool removeObject:check];
        }
    }
}



+(BOOL)alertMessageExists:(NSString*)alertMsg
{
    BOOL alertExists = NO;
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
    UIAlertView * alertTint = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"TintTest",nil) message:NSLocalizedString(@"was Change?",nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"Close",nil) otherButtonTitles:NSLocalizedString(@"ok",nil), nil];
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
    if ((allowedTypes & self.type) && ![_supressedTitles containsObject:self.title]) {
        //[super show];
        [self showView];
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

// Add new alert view to alert view arrays
-(CustomAlertView*)showView{
    if (![_currentViews containsObject:self]) {
        [_currentViews addObject:self];
        if (_currentViews.count == 1) {
            [self actuallyShowView];
            return self;
        }
    }
    return nil;
}

// Actually show the alert on screen (Needed to avoid complecations in other places)
-(void)actuallyShowView{
  
    NSLog(@"Is Depricated %s",__FUNCTION__);

    if (![_currentViews containsObject:self]) {
        [_currentViews addObject:self];
        if (_currentViews.count == 1) {
//            [self actuallyShowView];
  [super show]; 
        }
    }
}


-(void)show
{
    
    if (![_currentViews containsObject:self]) {
        [_currentViews addObject:self];
        if (_currentViews.count == 1) {
            [super show];
            
        }
    }

}


// The current alert is now done, so remove it from the alert view arrays, and if there is any more alert views in the array, display it
-(void)viewFinished{
    [_currentViews removeObjectAtIndex:0] ;
    if (_currentViews.count != 0) {
        CustomAlertView *toBeDisplayer = [_currentViews objectAtIndex:0];
        [toBeDisplayer actuallyShowView];
    }
}

-(void)dismissWithClickedButtonIndex:(NSInteger)buttonIndex animated:(BOOL)animated
{
    
    
    [super dismissWithClickedButtonIndex:buttonIndex animated:animated];
    
//    if (_currentViews indexOfObject:<#(nonnull id)#>)[_currentViews removeObjectAtIndex:0] ;
    if (_currentViews.count != 0) {
        CustomAlertView *toBeDisplayer = [_currentViews objectAtIndex:0];
        [toBeDisplayer actuallyShowView];
    }
    
}

@end
