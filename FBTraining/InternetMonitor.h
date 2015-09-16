//
//  InternetMonitor.h
//  Live2BenchNative
//
//  Created by andrei on 2015-09-02.
//  Copyright © 2015 DEV. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface InternetMonitor : NSObject

@property (atomic,assign) BOOL hasWifi;
@property (atomic,assign) BOOL hasInternet;

@end
