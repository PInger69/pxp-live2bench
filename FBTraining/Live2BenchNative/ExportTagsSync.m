//
//  ExportTagsSync.m
//  Live2BenchNative
//
//  Created by Si Te Feng on 7/22/14.
//  Copyright (c) 2014 DEV. All rights reserved.
//

#import "ExportTagsSync.h"
#import "JPStyle.h"

@interface ExportTagsSync()

@property (nonatomic, strong) NSData* fileData;

@end

@implementation ExportTagsSync
- (id)initWithGlobalsCurrentEventThumbnails:(NSDictionary*)dict
{
    self = [self initWithGlobalsCurrentEventThumbnails:dict withType:JPExportTagTypeSportsCode];
    return self;
}

- (id)initWithGlobalsCurrentEventThumbnails:(NSDictionary *)dict withType:(JPExportTagType)type
{
    self = [super init];
    
    self.thumbDict = dict;
    self.type = type;
    
    return self;
}


- (id)initWithStatsDict: (NSDictionary*)dict
{
    self= [super init];
    
    self.statsDicts = dict;
    self.type = JPExportTagTypeCSV;
    
    return self;
}


- (void)startConvertingAsynchronously
{
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, NULL), ^{
        
        if(self.type == JPExportTagTypeSportsCode)
        {
            [self loadXMLStringWithTypeSportsCode];
        }
        else if(self.type == JPExportTagTypeLive2Bench)
        {
            [self loadXMLStringWithTypeLive2Bench];
        }
        else if(self.type == JPExportTagTypeCSV)
        {
            [self loadXMLStringWithTypeCSV];
        }

        dispatch_async(dispatch_get_main_queue(), ^{
            [self finishedLoadingXMLString];
            
        });
        
    });
    
}




- (void)finishedLoadingXMLString
{
    NSLog(@"CSV: %@", _xmlString);
    
    self.fileData = [_xmlString dataUsingEncoding:NSUTF8StringEncoding];
    
    [self.delegate exportTagSync:self didFinishConvertingWithFileData:self.fileData];
    
}



#pragma mark - Convenience Methods

- (void)loadXMLStringWithTypeCSV
{
    _xmlString = [NSMutableString string];
    
    CGFloat interval = (self.duration.y - self.duration.x) / 16;
    CGFloat startTime = self.duration.x;
    
    [_xmlString appendString:@"Event,"];
    
    for(int i=0; i<16; i++)
    {
        [_xmlString appendString:[NSString stringWithFormat:@"%.0fm,", startTime+interval/2.0 + interval*i]];
    }
    
    [_xmlString appendString:@"Total\n"];
    
    NSArray* statsKeys = [self.statsDicts allKeys];
    
    for(NSString* key in statsKeys)
    {
        NSDictionary* timesDict = [self.statsDicts objectForKey:key];
        NSArray* timesKeys = [timesDict allKeys];
        [_xmlString appendString:[NSString stringWithFormat:@"%@,",key]];
        
        int totalCount = 0;
        
        for(int i=0; i<16;i++)
        {
            CGFloat currStartTime = startTime + i*interval;
            CGFloat currEndTime   = currStartTime + interval;
            NSString* timeKeyString = @"";
            
            for(NSString* timeKey in timesKeys)
            {
                NSArray* tags = [timesDict objectForKey:timeKey];
                
                for(NSDictionary* tag in tags)
                {
                    float tagTimeInMin = [[tag objectForKey:@"time"] floatValue]/60.0f;
                    
                    if(tagTimeInMin < currEndTime && tagTimeInMin > currStartTime)
                    {
                        timeKeyString = timeKey;
                    }
                }
            }
            
            if(![timeKeyString isEqual: @""])
            {
                NSArray* tagInfoArray = [timesDict objectForKey:timeKeyString];
                int tagCount = [tagInfoArray count];
                totalCount += tagCount;
                [_xmlString appendString:[NSString stringWithFormat:@"%i", tagCount]];
            }

            [_xmlString appendString:@","];
        }
        
        [_xmlString appendString:[NSString stringWithFormat:@"%i\n", totalCount]];
    }
    
}



- (void)loadXMLStringWithTypeLive2Bench
{
    _xmlString = [NSMutableString string];
    
    [_xmlString appendString:@"<ALL_TAGS>\n"];
    
    NSArray* thumbDictKeys = [[self.thumbDict allKeys] sortedArrayUsingSelector:@selector(compare:)];
    
    for(NSString* thumbKey in thumbDictKeys)
    {
        NSDictionary* tag = [self.thumbDict objectForKey:thumbKey];
        
        [_xmlString appendString:@"<tag>\n"];
        
        @try{
            [_xmlString appendString:[NSString stringWithFormat:@"<id>%@</id>\n", [tag objectForKey:@"id"]]];
            [_xmlString appendString:[NSString stringWithFormat:@"<user>%@</user>\n", [tag objectForKey:@"user"]]];
            [_xmlString appendString:[NSString stringWithFormat:@"<colour>%@</colour>\n", [tag objectForKey:@"colour"]]];
            [_xmlString appendString:[NSString stringWithFormat:@"<homeTeam>%@</homeTeam>\n", [tag objectForKey:@"homeTeam"]]];
            [_xmlString appendString:[NSString stringWithFormat:@"<visitTeam>%@</visitTeam>\n", [tag objectForKey:@"visitTeam"]]];
            [_xmlString appendString:[NSString stringWithFormat:@"<displayTime>%@</displayTime>\n", [tag objectForKey:@"displaytime"]]];
            [_xmlString appendString:[NSString stringWithFormat:@"<duration>%.00fm</duration>\n", [[tag objectForKey:@"duration"] floatValue]/60]];
            [_xmlString appendString:[NSString stringWithFormat:@"<rating>%@</rating>\n", [tag objectForKey:@"rating"]]];
            [_xmlString appendString:[NSString stringWithFormat:@"<comment>%@</comment>\n", [tag objectForKey:@"comment"]]];
        }
        @catch (NSException *exception)
        {
            _xmlString = [NSMutableString stringWithString:@"XML could not be generated due to incomplete internal information"];
            return;
        }
        
        [_xmlString appendString:@"</tag>\n"];
    }
    
    [_xmlString appendString:@"</ALL_TAGS>\n"];
    
}
            

- (void)loadXMLStringWithTypeSportsCode
{
    _xmlString = [NSMutableString string];
    
    [_xmlString appendString:@"<file>\n<ALL_INSTANCES>\n"];
    
    NSString* colorString = @"000000";
    NSMutableArray* playerNames = [NSMutableArray arrayWithObjects:@"General", nil];
    
    NSArray* keyArray = [self.thumbDict allKeys];
    
    for(NSString* key in keyArray)
    {
        NSDictionary* tagDict = [self.thumbDict objectForKey:key];
        
        [_xmlString appendString:@"<instance>\n"];
        
        [_xmlString appendString:@"<ID>"];
        NSString* idString = [NSString stringWithFormat:@"%@",[tagDict objectForKey:@"id"]];
        [_xmlString appendString:idString];
        [_xmlString appendString:@"</ID>\n"];
        
        [_xmlString appendString:@"<start>"];
        NSNumber* startNum = [tagDict objectForKey:@"starttime"];
        NSString* startString = [NSString stringWithFormat:@"%@",startNum];
        [_xmlString appendString:startString];
        [_xmlString appendString:@"</start>\n"];
        
        [_xmlString appendString:@"<end>"];
        float startTime = [startNum floatValue];
        float duration = [[tagDict objectForKey:@"duration"] floatValue];
        float endTime = startTime + duration;
        [_xmlString appendString:[NSString stringWithFormat:@"%f", endTime]];
        [_xmlString appendString:@"</end>\n"];
        
        [_xmlString appendString:@"<code>"];
        if([[tagDict allKeys] containsObject:@"player"])
        {
            if([[tagDict objectForKey:@"player"] count]>0)
            {
                NSString* playerName = [[tagDict objectForKey:@"player"] firstObject];
                [playerNames addObject:playerName];
                [_xmlString appendString:playerName];
            }
        }
        else
            [_xmlString appendString:@"None"];
        
        [_xmlString appendString:@"</code>\n"];
        
        [_xmlString appendString:@"<label>\n"];
        [_xmlString appendString:@"<group>"];
        if([[tagDict allKeys] containsObject:@"action"] && ![[tagDict objectForKey:@"action"] isEqual: @""])
            [_xmlString appendString:[tagDict objectForKey:@"action"]];
        else
        {
            [_xmlString appendString:@"General"];
            colorString = [tagDict objectForKey:@"colour"];
        }
        
        [_xmlString appendString:@"</group>\n"];
        [_xmlString appendString:@"<text>"];
        [_xmlString appendString:[tagDict objectForKey:@"name"]];
        [_xmlString appendString:@"</text>\n"];
        [_xmlString appendString:@"</label>\n"];
        
        [_xmlString appendString:@"</instance>\n"];
    }
    
    
    [_xmlString appendString:@"</ALL_INSTANCES>\n\n"];
    
    [_xmlString appendString:@"<ROWS>\n"];
    
    for(NSString* playerName in playerNames)
    {
        [_xmlString appendString:@"<row>\n"];
        [_xmlString appendString:@"<code>"];
        
        [_xmlString appendString:playerName];
        [_xmlString appendString:@"</code>\n"];
        
        CGFloat red=0, green=0, blue=0;
        UIColor* codeColor = [JPStyle colorWithHex:colorString alpha:1];
        [codeColor getRed:&red green:&green blue:&blue alpha:nil];
        
        [_xmlString appendString:[NSString stringWithFormat:@"<R>%.00f</R>\n", red*65535]];
        [_xmlString appendString:[NSString stringWithFormat:@"<G>%.00f</G>\n", green*65535]];
        [_xmlString appendString:[NSString stringWithFormat:@"<B>%.00f</B>\n", blue*65535]];
        
        [_xmlString appendString:@"</row>\n"];
    }
    
    [_xmlString appendString:@"</ROWS>\n"];
    [_xmlString appendString:@"</file>\n"];
}










@end
