//
//  ToastObserver.m
//  ToastView
//
//  Created by dev on 2015-01-21.
//  Copyright (c) 2015 Avoca Technologies. All rights reserved.
//

#import "ToastObserver.h"
#import "UIKit/UIKit.h"
#import "Utility.h"
#import "ToastObserverSettingViewController.h"

@interface ToastObserver ()

// This property is only required for the object to have a reference to
// the view within all its methods
@property (nonatomic, strong) UIView *animatingView;

// The mutable array queueOfNotifications stores the Notifications before
// they are processed and put on the screen
@property (nonatomic, strong) NSMutableArray *queueOfNotifications;


@end


static NSUInteger allowedToastType        = 0;

@implementation ToastObserver

-(instancetype)init{
    self = [super init];
    if(self){
        // By adding the ToastObserver as an observer in the Notification Center, any Notifications that are posted with the name ToastObserver
        // will be recognized by the Toast Observer
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationNoticed:) name:NOTIF_TOAST object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(settingsChanged:)     name:NOTIF_TOAST_SETTING_CHANGED object:nil];
        
        self.toastType = ARNone | ARFileDownloadComplete | ARTagSynchronized | ARTagCreated;
        allowedToastType = NSUIntegerMax;
        // Refer to ToastObserver.h for an explanation of these following properties:
        self.enabled    = YES;
        self.easeTime   = 0.2;
        self.delayTime  = 1.5;
        self.queueOfNotifications = [NSMutableArray new];
    }
    return self;
}

+(void)allowedTypes:(NSInteger)type
{
    allowedToastType = type;
}

- (void)settingsChanged: (NSNotification *)note {
    NSDictionary *toastSettings = note.userInfo;
    
    self.toastType = ARNone;
    if ([toastSettings[TOAST_DOWNLOAD_COMPLETE] boolValue]) self.toastType |= ARFileDownloadComplete;
    if ([toastSettings[TOAST_TAG_SYNCHRONIZED] boolValue]) self.toastType |= ARTagSynchronized;
    if ([toastSettings[TOAST_TAG_RECEIVED] boolValue]) self.toastType |= ARTagCreated;
    
    allowedToastType = 0;
    if ([toastSettings[TOAST_DOWNLOAD_COMPLETE] boolValue]) allowedToastType |= ARFileDownloadComplete;
    if ([toastSettings[TOAST_TAG_SYNCHRONIZED] boolValue])  allowedToastType |= ARTagSynchronized;
    if ([toastSettings[TOAST_TAG_RECEIVED] boolValue])      allowedToastType |= ARTagCreated;
}

-(void)setEnabled:(BOOL)enabled{
    _enabled = enabled;
    if (!enabled) {
        [self.queueOfNotifications removeAllObjects];
    }
}

// The Notification must have the name @"ToastView"
// As well its user info must be of format:
// @{ @"Name": <(str)name>, @"Colour": < UIColor >}
-(void) notificationNoticed: (NSNotification *)receivedNotification{
      dispatch_async(dispatch_get_main_queue(), ^{
            NSUInteger mask = (NSUInteger )receivedNotification.userInfo[@"type"];
              if (allowedToastType & mask) {
                [self.queueOfNotifications addObject:receivedNotification];
                if([self.queueOfNotifications count] >0) {
                    [self animateView];
                }
            }
      });
}

-(void)animateView{
    // These lines of code created the view to be presented:
    // By accessing the first notification in the queue the userInfo dictionary can be passed
    // to the toast view

    // remove the first item and present it
    NSNotification *currentNotification = [self.queueOfNotifications firstObject];
    [self.queueOfNotifications removeObjectAtIndex:0];
    
    //Creating of the ToastView
    UIView *presentingView = [[UIView alloc] init];
    presentingView.layer.borderColor = PRIMARY_APP_COLOR.CGColor;
    presentingView.backgroundColor = [UIColor whiteColor];
    presentingView.layer.borderWidth = 1.0f;
    
    // These lines are to create the label and add it onto the view
    UILabel *label          = [[UILabel alloc] initWithFrame:CGRectMake(50, 0, 150, 50)];
    label.textAlignment     = NSTextAlignmentCenter;
    label.textColor         = [UIColor blackColor];
    label.text              = [[currentNotification.userInfo objectForKey:@"msg"] stringByRemovingPercentEncoding];
    [presentingView addSubview:label];
    
    double entireAnimationTime  = ((self.easeTime * 2) + self.delayTime);
    double relativeEaseTime     = self.easeTime/entireAnimationTime;
    double relativeDelayEndTime     = (self.delayTime/entireAnimationTime)+relativeEaseTime;
    
    // These lines are to create a subview which is on the left of the infoView
    // and set its color to be the same as the color of the trigger button
    UIView *smallView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
    smallView.backgroundColor = [Utility colorWithHexString: currentNotification.userInfo[@"colour"] ];;
    [presentingView addSubview:smallView];
    
    CGRect originalFrame = CGRectMake(20, self.parentView.bounds.size.height, 200, 50);
    presentingView.frame = originalFrame;
  
    // By keeping a reference to the view in this manner, dequeueTheArray can later remove the
    // view from its superview (the view controller)
    self.animatingView = presentingView;
    [self.parentView addSubview:self.animatingView];
    
    CGRect theNewFrame = self.animatingView.frame;
    theNewFrame.origin.y = self.parentView.bounds.size.height - 70;
   
    [UIView animateKeyframesWithDuration: self.easeTime+self.delayTime+self.easeTime delay:0.0 options:nil animations:^{
        [UIView addKeyframeWithRelativeStartTime:0.0 relativeDuration:relativeEaseTime animations:^{
            presentingView.frame = theNewFrame;
        }];
        
        [UIView addKeyframeWithRelativeStartTime: relativeDelayEndTime relativeDuration:relativeEaseTime animations:^{
            presentingView.frame = originalFrame;
        }];
        
    }completion:^(BOOL finished) {
        if([self.queueOfNotifications count] >0) {
              dispatch_async(dispatch_get_main_queue(), ^{
                  [self animateView];
              });
        }
    }];
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end

