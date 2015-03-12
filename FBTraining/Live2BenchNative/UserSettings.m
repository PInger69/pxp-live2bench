//
//  UserSettings.m
//  Live2BenchNative
//
//  Created by dev on 8/27/2014.
//  Copyright (c) 2014 DEV. All rights reserved.
//
/**
 *  This Class is a global class that reads and writes to plist files that well keep track of the
 *  changes that the used wants to make to the app. e.g. no alerts or notifications
 */
#import "UserSettings.h"


static NSString * plist;
static NSMutableDictionary * settings;
@implementation UserSettings


+(void)init{

    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString * path = [[NSString alloc]initWithString:documentsDirectory];
    plist = [path stringByAppendingPathComponent:@"userSettings.plist"];
    
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:plist]) {
        settings = [[NSMutableDictionary alloc]initWithContentsOfFile:plist];
    }else{
        settings = [[NSMutableDictionary alloc]init];
    }
}

+(void)writeToPlist
{
    if (!settings) {
        [UserSettings init];
    }
    BOOL isDirect;
    if(![[NSFileManager defaultManager] fileExistsAtPath:plist isDirectory:&isDirect])
    {
        [[NSFileManager defaultManager] createFileAtPath:plist contents:nil attributes:nil];
    }
    [settings writeToFile:plist atomically:YES];
 
}


+(id)getSettingFor:(NSString*)pName
{
    if (!settings) {
        [UserSettings init];
    }
    return [settings objectForKey:pName];
}


+(void)setSettingFor:(NSString*)pName value:(id)value
{
    if (!settings) {
        [UserSettings init];
    }
    [settings setObject:value forKey:pName];
    [UserSettings writeToPlist];
}



@end
