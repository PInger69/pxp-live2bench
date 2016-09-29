//
//  DeviceLog.m
//  Live2BenchNative
//
//  Created by dev on 2016-09-12.
//  Copyright © 2016 DEV. All rights reserved.
//

#import "DeviceLog.h"

static NSString * logName = @"deviceLog.txt";
@implementation DeviceLog


- (instancetype)init
{
    self = [super init];
    if (self) {
        NSError *error;
        NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        self.path = [[NSString alloc]initWithString:documentsDirectory];
        self.path = [self.path stringByAppendingPathComponent:logName];
//
//        
        if (![[NSFileManager defaultManager] fileExistsAtPath:self.path]) {
            // if no log then make a blank one
            [@"" writeToFile:self.path atomically:YES encoding:NSUTF16StringEncoding error:&error];
        }
//
//        
//        
        


    }
    return self;
}

-(void)clearLog
{
    NSError *error;
    [@"" writeToFile:self.path atomically:YES encoding:NSUTF16StringEncoding error:&error];
}


-(void)appendToLog:(NSString*)text
{
    NSError* error = nil;
    NSString* contents = [NSString stringWithContentsOfFile:self.path
                                                   encoding:NSUTF16StringEncoding
                                                      error:&error];
    if(error) { // If error object was instantiated, handle it.
        NSLog(@"ERROR while loading from file: %@", error);
        // …
    }
    
    
    contents = [contents stringByAppendingFormat:@"%@\n",text];
//    contents = [contents stringByAppendingString:text];
    [contents writeToFile:self.path atomically:YES
                 encoding:NSUnicodeStringEncoding
                    error:&error];
}






@end
