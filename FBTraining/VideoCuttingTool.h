//
//  VideoCuttingTool.h
//  Live2BenchNative
//
//  Created by dev on 2015-03-27.
//  Copyright (c) 2015 DEV. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VideoCuttingTool : NSObject

-(NSData *)createClipAtTime: (float) time withLength: (float) length fromVideoFilePath: (NSString *) videoFilePath;

@end
