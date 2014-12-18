//
//  ClipImageDownloader.m
//  Live2BenchNative
//
//  Created by Si Te Feng on 6/11/14.
//  Copyright (c) 2014 DEV. All rights reserved.
//

#import "ClipImageDownloader.h"
#import "Globals.h"


@implementation ClipImageDownloader
{
    Globals*  globals;
}


- (instancetype)init
{
    self = [super init];
   
    if(self)
    {
        globals = [Globals instance];
        
        
    }
    
    return self;
}


- (BOOL)redownloadImageFromtheServer:(NSDictionary*)dict{
    NSFileManager *fileManager= [NSFileManager defaultManager];
    //if thumbnail folder not exist, create a new one
    if(![fileManager fileExistsAtPath:globals.THUMBNAILS_PATH])
    {
        NSError *cError;
        [fileManager createDirectoryAtPath:globals.THUMBNAILS_PATH withIntermediateDirectories:TRUE attributes:nil error:&cError];
    }
    
    NSURL *jurl = [[NSURL alloc]initWithString:[[dict objectForKey:@"url"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    NSString *imageName = [[dict objectForKey:@"url"] lastPathComponent];
    //thumbnail data
    NSData *imgData= [NSData dataWithContentsOfURL:jurl options:0 error:nil];
    
    //image file path for current image
    NSString *filePath = [globals.THUMBNAILS_PATH stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@",imageName]];
    
    NSData *imgTData;
    NSString *teleImageFilePath;
    //save telesteration thumb
    if([[dict objectForKey:@"type"]intValue]==4)
    {
        //tele image datat
        imgTData= [NSData dataWithContentsOfURL:[NSURL URLWithString:[[dict objectForKey:@"teleurl"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]] options:0 error:nil];
        NSString *teleImageName = [[dict objectForKey:@"teleurl"] lastPathComponent];
        //image file path for telestration
        teleImageFilePath = [globals.THUMBNAILS_PATH stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@",teleImageName]];
        
    }
    
    if (([[dict objectForKey:@"type"]intValue]!=4 && imgData != nil )||([[dict objectForKey:@"type"]intValue]==4 && imgData != nil && imgTData != nil) ) {
        
        [imgData writeToFile:filePath atomically:YES];
        
        if ([[dict objectForKey:@"type"]intValue]==4) {
            [imgTData writeToFile:teleImageFilePath atomically:YES ];
        }
        
        if (!globals.DOWNLOADED_THUMBNAILS_SET){
            globals.DOWNLOADED_THUMBNAILS_SET = [NSMutableArray arrayWithObject:[dict objectForKey:@"id"]];
        } else {
            [globals.DOWNLOADED_THUMBNAILS_SET addObject:[dict objectForKey:@"id"]];
        }
        
        return TRUE;
    }else{
        return FALSE;
    }
    
}


@end
