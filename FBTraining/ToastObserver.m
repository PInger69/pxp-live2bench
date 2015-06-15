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
#import "Tag.h"

#import "ToastObserverSettingViewController.h"

@interface ToastObserver ()

// This property is only required for the object to have a reference to
// the view within all its methods
@property (nonatomic, strong) UIView *animatingView;

// The mutable array queueOfNotifications stores the Notifications before
// they are processed and put on the screen
@property (nonatomic, strong) NSMutableArray *queueOfNotifications;


@end



@implementation ToastObserver


-(instancetype)init{
    self = [super init];
    if(self){
        // By adding the ToastObserver as an observer in the Notification Center, any Notifications that are posted with the name ToastObserver
        // will be recognized by the Toast Observer
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationNoticed:) name:NOTIF_TAG_RECEIVED object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(synchronizedTags:) name:@"NOTIF_TAGS_SYNCHRONIZED" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fileDownloadComplete:) name:@"NOTIF_FILE_DOWNLOAD_COMPLETE" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(settingsChanged:) name:NOTIF_TOAST_SETTING_CHANGED object:nil];
        
        self.toastType = ARNone | ARFileDownloadComplete | ARTagSynchronized | ARTagCreated;
        
        // Refer to ToastObserver.h for an explanation of these following properties:
        self.enabled = YES;
        self.easeTime = 0.5;
        self.delayTime = 1.5;
        self.queueOfNotifications = [[NSMutableArray alloc] init];
    }
    return self;
}

-(void)synchronizedTags:(NSNotification *)note {
    if (self.toastType & ARTagSynchronized) {
        [self.queueOfNotifications addObject:note];
        // If there is only 1 Notification in the queue, animateView is called
        // Otherwise the other 2 methods ( dequeueTheArray and animateView)
        //will keep track of the queue
        if([self.queueOfNotifications count] == 1){
            [self animateView];
        }
    }
}

-(void)fileDownloadComplete:(NSNotification *)note {
    if (self.toastType & ARFileDownloadComplete) {
        // Each NSNotification is first added to the queue
        [self.queueOfNotifications addObject:note];
        // If there is only 1 Notification in the queue, animateView is called
        // Otherwise the other 2 methods ( dequeueTheArray and animateView)
        //will keep track of the queue
        if([self.queueOfNotifications count] == 1){
            [self animateView];
        }
    }
}

- (void)settingsChanged: (NSNotification *)note {
    NSDictionary *toastSettings = note.userInfo;
    
    self.toastType = ARNone;
    if ([toastSettings[TOAST_DOWNLOAD_COMPLETE] boolValue]) self.toastType |= ARFileDownloadComplete;
    if ([toastSettings[TOAST_TAG_SYNCHRONIZED] boolValue]) self.toastType |= ARTagSynchronized;
    if ([toastSettings[TOAST_TAG_RECEIVED] boolValue]) self.toastType |= ARTagCreated;
}

-(void)setEnabled:(BOOL)enabled{
    _enabled = enabled;
    
    if (!enabled) {
        [self.queueOfNotifications removeAllObjects];
    }
    
}

-(void) notificationNoticed: (NSNotification *)receivedNotification{
    
    // This is the check to make sure Toast observer should be on, if
    // ToastObserver is disabled then this code will not execute, and hence
    // the other methods can no longer be called
    if (self.toastType & ARTagCreated) {
        // Each NSNotification is first added to the queue
        [self.queueOfNotifications addObject:receivedNotification];
        // If there is only 1 Notification in the queue, animateView is called
        // Otherwise the other 2 methods ( dequeueTheArray and animateView)
        //will keep track of the queue
        if([self.queueOfNotifications count] == 1) {
            [self animateView];
        }
    }
}


-(void) dequeueTheArray
{
    // This condition is here because [self animateView] cannot be called
    // when there is no more objects in the array
    if([self.queueOfNotifications count] == 1){
        [self.animatingView removeFromSuperview];
        [self.queueOfNotifications removeObjectAtIndex:0];
    }
    
    // When this code executes, the view is removed from its superview ,
    // the first object in the line is taken out, and then the next Notification
    // in line is animated. This process, will repeat itself, until there is only one
    // Notification is left in the queue.
    if([self.queueOfNotifications count] > 1){
        [self.animatingView removeFromSuperview];
        [self.queueOfNotifications removeObjectAtIndex:0];
        [self animateView];
    }
}

-(void)animateView{
    // These lines of code created the view to be presented:
    // By accessing the first notification in the queue the userInfo dictionary can be passed
    // to the toast view
    NSNotification *currentNotification = (self.queueOfNotifications[0]);
    
    if (currentNotification.object) {
        Tag *tag = (Tag *) currentNotification.userInfo[@"tag"];
        //Creating of the ToastView
        UIView *presentingView = [[UIView alloc] init];
        presentingView.layer.borderColor = PRIMARY_APP_COLOR.CGColor;
        presentingView.backgroundColor = [UIColor whiteColor];
        presentingView.layer.borderWidth = 1.0f;
        
        // These lines are to create the label and add it onto the view
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(50, 0, 150, 50)];
        // This line set the text to be alignmented at the center of the lable
        label.textAlignment = NSTextAlignmentCenter;
        [presentingView addSubview:label];
        
        // These lines are to set the text for the label and the text color
        label.text = [tag.name stringByRemovingPercentEncoding];
        label.textColor = [UIColor blackColor];
        
        // These lines are to create a subview which is on the left of the infoView
        // and set its color to be the same as the color of the trigger button
        UIView *smallView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
        smallView.backgroundColor = [Utility colorWithHexString: tag.colour ];
        [presentingView addSubview:smallView];
        
        CGRect originalFrame = CGRectMake(20, self.parentView.bounds.size.height, 200, 50);
        presentingView.frame = originalFrame;
        // By keeping a reference to the view in this manner, dequeueTheArray can later remove the
        // view from its superview (the view controller)
        self.animatingView = presentingView;
        [self.parentView addSubview:self.animatingView];
        
        // This frame is the new frame, the place where the view will
        // show up on the screen
        CGRect theNewFrame = self.animatingView.frame;
        theNewFrame.origin.y = self.parentView.bounds.size.height - 70;
        
        double entireAnimationTime = ((self.easeTime * 2) + self.delayTime);
        double relativeEaseTime = self.easeTime/entireAnimationTime;
        
        [UIView animateKeyframesWithDuration: entireAnimationTime delay:0.0 options:nil animations:^{
            [UIView addKeyframeWithRelativeStartTime:0.0 relativeDuration:relativeEaseTime animations:^{
                presentingView.frame = theNewFrame;
            }];
            
            [UIView addKeyframeWithRelativeStartTime: 1 - relativeEaseTime relativeDuration:relativeEaseTime animations:^{
                presentingView.frame = originalFrame;
            }];
        }completion:NULL];
        
        
        
        // This line passes control to dequeueTheArray, which is most likely to pass control back to animateView, and that will create a
        // cycle of methods that occur until the queue is empty.
        [self performSelector: @selector(dequeueTheArray) withObject:self afterDelay: entireAnimationTime + 0.5];
        return;
    }
    
    if (currentNotification.userInfo) {
        //Creating of the ToastView
        UIView *presentingView = [[UIView alloc] init];
        presentingView.layer.borderColor = PRIMARY_APP_COLOR.CGColor;
        presentingView.backgroundColor = [UIColor whiteColor];
        presentingView.layer.borderWidth = 1.0f;
        
        // These lines are to create the label and add it onto the view
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(50, 0, 150, 50)];
        // This line set the text to be alignmented at the center of the lable
        label.textAlignment = NSTextAlignmentCenter;
        [presentingView addSubview:label];
        
        // These lines are to set the text for the label and the text color
        label.text = [[currentNotification.userInfo objectForKey:@"name"] stringByRemovingPercentEncoding];
        label.textColor = [UIColor blackColor];
        
        // These lines are to create a subview which is on the left of the infoView
        // and set its color to be the same as the color of the trigger button
        UIView *smallView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
        smallView.backgroundColor = [Utility colorWithHexString: [currentNotification.userInfo objectForKey:@"colour"]];
        [presentingView addSubview:smallView];
        
        CGRect originalFrame = CGRectMake(20, self.parentView.bounds.size.height, 200, 50);
        presentingView.frame = originalFrame;
        // By keeping a reference to the view in this manner, dequeueTheArray can later remove the
        // view from its superview (the view controller)
        self.animatingView = presentingView;
        [self.parentView addSubview:self.animatingView];
        
        // This frame is the new frame, the place where the view will
        // show up on the screen
        CGRect theNewFrame = self.animatingView.frame;
        theNewFrame.origin.y = self.parentView.bounds.size.height - 70;
        
        double entireAnimationTime = ((self.easeTime * 2) + self.delayTime);
        double relativeEaseTime = self.easeTime/entireAnimationTime;
        
        [UIView animateKeyframesWithDuration: entireAnimationTime delay:0.0 options:nil animations:^{
            [UIView addKeyframeWithRelativeStartTime:0.0 relativeDuration:relativeEaseTime animations:^{
                presentingView.frame = theNewFrame;
            }];
            
            [UIView addKeyframeWithRelativeStartTime: 1 - relativeEaseTime relativeDuration:relativeEaseTime animations:^{
                presentingView.frame = originalFrame;
            }];
        }completion:NULL];
        
        
        
        // This line passes control to dequeueTheArray, which is most likely to pass control back to animateView, and that will create a
        // cycle of methods that occur until the queue is empty.
        [self performSelector: @selector(dequeueTheArray) withObject:self afterDelay: entireAnimationTime + 0.5];
    }
}


-(void)dealloc
{
    // This method needs to be overridden inorder for this object
    // to add itself to NSNotificationCenter as an observer
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end

