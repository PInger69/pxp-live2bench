//
//  ExportPlayersSync.m
//  Live2BenchNative
//
//  Created by Si Te Feng on 7/29/14.
//  Copyright (c) 2014 DEV. All rights reserved.
//

#import "ExportPlayersSync.h"
#import "Globals.h"


@implementation ExportPlayersSync


- (instancetype)init
{
    self = [super init];
    
    if(self)
    {
        self.exportType = @"csv"; //CSV by default
        self.resultString = @"No Data Available";
        globals = [Globals instance];
        
        NSDictionary* allThumbnails = globals.CURRENT_EVENT_THUMBNAILS;
        
        NSArray* allThumbnailKeys = [allThumbnails allKeys];
        
        for(NSString* tagId in allThumbnailKeys)
        {
            NSDictionary* tagDict = [allThumbnails objectForKey:tagId];
            NSArray* tagDictKeys = [tagDict allKeys];
            
            NSArray* players = nil; //An Array of player Dicts
            
            if([tagDictKeys containsObject:@"player"])
            {
                players = [tagDict objectForKey:@"player"];
            }
            
            NSLog(@"Players: %@", players);
            
        }

        
    }
    
    return self;
}



- (void)startConvertingAsynchronously
{
    NSMutableString* playerDataString = [@"" mutableCopy];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, NULL),
    ^{
        
        [playerDataString appendString:@"Football.Practice.PracticeDate\tFootball.OffPlayersOnField\tFootball.DefPlayersOnField\tFootball.Practice.PracticePeriodType\n"];
        
        //Getting the Date and Time
        NSString* eventTime = [globals.HUMAN_READABLE_EVENT_NAME substringToIndex:19];//10
        //2014-07-26 21:10:11
        NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSDate* eventDate = [formatter dateFromString:eventTime];
        NSDateFormatter* csvDateFormatter = [[NSDateFormatter alloc] init];
        [csvDateFormatter setDateFormat:@"MM/dd/yyyy  hh:mm:ss a"];
        // 7/27/2014  12:00:00 AM
        NSString* exportCSVDateString = [csvDateFormatter stringFromDate:eventDate];
        
        NSLog(@"ExportString: %@", exportCSVDateString);
        
        for(int i =0 ;i<10; i++)
        {
            [playerDataString appendFormat:@"%@\t", exportCSVDateString];
        
            NSString* OffString = @"09;85;87;18;88;25";
            
            [playerDataString appendFormat:@"%@\t", OffString];
            
            NSString* DefString = @"09;88;87;81;16;43";
            [playerDataString appendFormat:@"%@\t", DefString];
        
            NSString* periodName = [NSString stringWithFormat:@"P%d", arc4random()%24+1];
            
            [playerDataString appendFormat:@"%@\n", periodName];
        }
        
        self.resultString = [playerDataString copy];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate exportPlayersSync:self didFinishLoadingWithString:self.resultString];
        });
        
    });
    
    
}


















@end
