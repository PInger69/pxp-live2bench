//
//  PxpPreference.m
//  Live2BenchNative
//
//  Created by dev on 2015-12-15.
//  Copyright © 2015 DEV. All rights reserved.
//

#import "PxpPreference.h"

@implementation PxpPreference

static NSDictionary * _preference;

+(void)initialize
{
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"PxpPreference" ofType:@"plist"];
    _preference  = [NSDictionary dictionaryWithContentsOfFile:plistPath];
}

+(NSDictionary*)dictionary
{
    return _preference;

}


@end
