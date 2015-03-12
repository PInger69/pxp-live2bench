//
//  UserSettings.h
//  Live2BenchNative
//
//  Created by dev on 8/27/2014.
//  Copyright (c) 2014 DEV. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserSettings : NSObject


+(void)init;
+(id)getSettingFor:(NSString*)pName;
+(void)setSettingFor:(NSString*)pName value:(id)value;

@end
