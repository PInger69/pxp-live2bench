//
//  InternetMonitor.m
//  Live2BenchNative
//
//  Created by andrei on 2015-09-02.
//  Copyright © 2015 DEV. All rights reserved.
//

#import "InternetMonitor.h"

@implementation InternetMonitor

@synthesize hasInternet;
@synthesize hasWifi;

-(id)init{
    self = [super init];
    if(self){
        
        [NSTimer scheduledTimerWithTimeInterval:10.0
                                         target:self
                                       selector:@selector(checkInternet)
                                       userInfo:nil
                                        repeats:YES];
        
    }
    return self;
}


-(void)checkInternet{
    
//    BOOL newHasInternet = [Utility hasInternet];
    
    __block InternetMonitor * weakself = self;
    [Utility hasInternetOnComplete:^(BOOL succsess) {
        weakself.hasInternet = succsess;
        
        
    }];
    
    BOOL newHasWifi = [Utility hasWiFi];
    
    if(newHasWifi != hasWifi && !newHasWifi){
        
        [[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_LOST_WIFI object:nil];
        [[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_STATUS_LABEL_CHANGED object:nil userInfo:@{@"text":@"No Wifi"}];
        
    }
    

    hasWifi = newHasWifi;
    
}


@end
