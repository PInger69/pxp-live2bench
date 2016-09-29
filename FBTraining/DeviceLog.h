//
//  DeviceLog.h
//  Live2BenchNative
//
//  Created by dev on 2016-09-12.
//  Copyright © 2016 DEV. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DeviceLog : NSObject
@property (nonatomic,strong) NSString * path;

-(void)appendToLog:(NSString*)text;
-(void)clearLog;
@end
