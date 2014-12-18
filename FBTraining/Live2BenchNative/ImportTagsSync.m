//
//  ImportTagsSync.m
//  Live2BenchNative
//
//  Created by Si Te Feng on 7/16/14.
//  Copyright (c) 2014 DEV. All rights reserved.
//

#import "ImportTagsSync.h"
#import "Globals.h"
#import "JPXMLTag.h"
#import "TagMarker.h"

@implementation ImportTagsSync

- (id)initWithDelay: (float)delay
{
    self = [super init];
    if(self)
    {
        globals = [Globals instance];
        self.delay = delay;
        self.uploadedTagNum = 0;
        _totalTagNum = 0;
        _paused = YES;
        _started = NO;
        self.isSaving = false;
        
    }
    return self;
}

- (id)initWithGroupXMLTags: (NSDictionary*)groupTags textXMLTags:(NSDictionary*)textTags delay: (float)delay
{
    self = [self initWithDelay:delay];
    
    self.groupXMLTags = groupTags;
    self.textXMLTags = textTags;
    
    [self reloadTagDictsArrayFromXMLTags];
    
    return self;
}


- (void)reloadTagDictsArrayFromXMLTags
{
    self.tagDictsArray = [NSMutableArray array];
    _totalTagNum = 0;
    
    for(NSString* tagKey in self.textXMLTags)
    {
        NSArray* XMLTagArray = [self.textXMLTags objectForKey:tagKey];
        NSInteger subIndex = 0;
        
        for(JPXMLTag* tag in XMLTagArray)
        {
            NSString* subLetter = [self letterWithIndex:subIndex];
            
            //NO Duration Type
//            NSMutableDictionary* tagDict = [[self tagDictWithXMLTag:tag withSubletter:subLetter] mutableCopy];
//            [tagDict setObject:tagKey forKey:@"name"];
//            [tagDict setObject:@true forKey:@"isxmltag"];
//            [self.tagDictsArray addObject:tagDict];
            
            for(int i=0; i<2; i++)
            {
                BOOL isStart = YES;
                if(i==1)
                    isStart = NO;
                
                NSMutableDictionary* tagDict = [[self tagDictWithXMLTag:tag withSubletter:subLetter isStartDuration:isStart] mutableCopy];
                
                [tagDict setObject:tagKey forKey:@"name"];
                [tagDict setObject:@true forKey:@"isxmltag"];
                [self.tagDictsArray addObject:tagDict];
            }
            
            subIndex++;
            _totalTagNum++;
        }
    }
    
}


- (NSDictionary*)tagDictWithXMLTag: (JPXMLTag*)tag
{
    return [self tagDictWithXMLTag:tag withSubletter:@""];
}


//Currently Not Using
- (NSDictionary*)tagDictWithXMLTag: (JPXMLTag*)tag withSubletter: (NSString*)subLetter
{
    float duration = (tag.endTime - tag.startTime) * 60.0f;
    float time = (tag.endTime + tag.startTime) / 2.0f *60.0f + self.delay;
    float startTime = tag.startTime*60 + self.delay;
    
    //Make the Dictionary for Live2Bench tab
    NSMutableDictionary* tagDict = nil;
    
    if([globals.WHICH_SPORT isEqual:@"hockey"])
    {
        tagDict = [[NSMutableDictionary alloc]initWithObjectsAndKeys:
                   globals.EVENT_NAME,@"event",
                   tag.textName,@"name",
                   @"000000",@"colour",
                   [globals.ACCOUNT_INFO objectForKey:@"hid"],@"user",
                   [NSString stringWithFormat:@"%.02f", time],@"time",
                   [ImportTagsSync timeStringFromSeconds:time], @"displaytime",
                   [NSNumber numberWithFloat:startTime], @"starttime",
                   [NSString stringWithFormat:@"%.02f", duration], @"duration",
                   [NSString stringWithFormat:@"temp_%@%@",[NSNumber numberWithFloat:time], subLetter] ,@"id",
                   @"0", @"type",
                   @"", @"comment",
                   [NSNumber numberWithInteger:tag.identifier], @"xmlId",
                   @"0", @"rating",
                   @"0", @"coachpick",
                   @"0", @"bookmark",
                   @"0", @"deleted",
                   @"0",@"edited",
                   @true, @"isxmltag", nil];
    }
    else if ([globals.WHICH_SPORT isEqualToString:@"soccer"] || [globals.WHICH_SPORT isEqualToString:@"football"] || [globals.WHICH_SPORT isEqualToString:@"rugby"])
    {
        tagDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
        [NSString stringWithFormat:@"temp_%@%@",[NSNumber numberWithFloat:time], subLetter], @"id",
        @"000000", @"colour",
        @"XML Import", @"comment",
        @"0", @"type",
        @[tag.code], @"player",
        [NSString stringWithFormat:@"%.02f", duration], @"duration",
        globals.EVENT_NAME, @"event",
        [NSNumber numberWithInteger:tag.identifier], @"xmlId",
        @0, @"islive",
        tag.textName, @"name",
        @"", @"rating",
        [NSNumber numberWithFloat:startTime], @"starttime",
        @1, @"success",
        [ImportTagsSync timeStringFromSeconds:time], @"displaytime",
        [NSString stringWithFormat:@"%.02f", time], @"time",
        [globals.ACCOUNT_INFO objectForKey:@"hid"], @"user", nil];
        
    }
    else
    {
        tagDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                   [NSString stringWithFormat:@"temp_%@%@",[NSNumber numberWithFloat:time], subLetter], @"id",
                   @"000000", @"colour",
                   @"XML Import", @"comment",
                   @"0", @"type",
                   @[tag.code], @"player",
                   [NSString stringWithFormat:@"%.02f", duration], @"duration",
                   globals.EVENT_NAME, @"event",
                   [NSNumber numberWithInteger:tag.identifier], @"xmlId",
                   @0, @"islive",
                   tag.textName, @"name",
                   @"", @"rating",
                   [NSNumber numberWithFloat:startTime], @"starttime",
                   @1, @"success",
                   [ImportTagsSync timeStringFromSeconds:time], @"displaytime",
                   [NSString stringWithFormat:@"%.02f", time], @"time",
                   [globals.ACCOUNT_INFO objectForKey:@"hid"], @"user", nil];
    }

    
    return tagDict;
}


- (NSDictionary*)tagDictWithXMLTag:(JPXMLTag *)tag withSubletter:(NSString *)subLetter isStartDuration: (BOOL)isStart
{
//    float duration = (tag.endTime - tag.startTime) * 60.0f;
    float time = (tag.endTime + tag.startTime) / 2.0f *60.0f + self.delay;
    float startTime = tag.startTime*60 + self.delay;
    float endTime = tag.endTime* 60 + self.delay;
    
    //Make the Dictionary for Live2Bench tab
    NSMutableDictionary* tagDict = nil;
    NSString *UUID = [[[UIDevice currentDevice] identifierForVendor]UUIDString];
    
    tagDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                   [NSString stringWithFormat:@"temp_%@%@",[NSNumber numberWithFloat:time], subLetter], @"id",
                   @"000000", @"colour",
                   @"XML Import", @"comment",
                   @[tag.code], @"player",
                   globals.EVENT_NAME, @"event",
                   [NSNumber numberWithInteger:tag.identifier], @"xmlId",
                   UUID, @"deviceid",
                   @"toBeImplemented", @"name",
                   [globals.ACCOUNT_INFO objectForKey:@"hid"], @"user", nil];
    
    if(isStart)
    {
        [tagDict setObject:@"99" forKey:@"type"];
        [tagDict setObject:[NSNumber numberWithFloat:startTime] forKey:@"time"];
    }
    else {
        [tagDict setObject:@"100" forKey:@"type"];
        [tagDict setObject:[NSNumber numberWithFloat:endTime] forKey:@"time"];

    }
        
    return tagDict;
}




- (NSString*)letterWithIndex: (NSInteger)i
{
    NSArray* letters = @[@"a",@"b",@"c",@"d",@"e",@"f",@"g",@"h",@"i",@"j",@"k",@"l",@"m",@"n",@"o",@"p",@"q",@"r",@"s",@"t",@"u",@"v",@"w",@"x",@"y",@"z"];
    if(i<26)
        return letters[i];
    else
        return [NSString stringWithFormat:@"%@%@", letters[i/26], letters[i%26]];
}



#pragma mark - Controlling send progress
- (void)start
{
    if(_paused == NO)
    {
        return;
    }
    
    _paused = NO;
    [self sendOneTagInformationToServer];
}

- (void)pause
{
    _paused = YES;
    self.isSaving = NO;
}


//send the tagset request to the server
-(void)sendOneTagInformationToServer{

    self.isSaving = YES;

    if (self.tagDictsArray.count < 1) {
        [self.delegate importTagsSyncDidFinishUploadingTags];
        return;
    }
    
    
    if(!_currentProcessingTag)
    {
        _currentProcessingTag = [[self.tagDictsArray objectAtIndex:0] mutableCopy];
        [self.tagDictsArray removeObjectAtIndex:0];
    }

    NSMutableDictionary* mutableDict = [_currentProcessingTag mutableCopy];
    
    //Online Tagging
    if(globals.HAS_MIN && globals.eventExistsOnServer)
    {
        if((![globals.CURRENT_ENC_STATUS isEqualToString:encStateLive] && ![globals.CURRENT_ENC_STATUS isEqualToString:encStatePaused]) && ([globals.EVENT_NAME isEqualToString:@"live"]|| [globals.EVENT_NAME isEqualToString:@""]))
        {
            [self.delegate importTagsSyncDidFinishUploadingTags];
            return;
        }
        
        if(![globals.EVENT_NAME isEqualToString:@"live"])
        {
//            [self saveImageLocallyWithDict:mutableDict];
        }
        
        //Send Information To Server
        NSError *error;
        NSString *unencodedName = [mutableDict objectForKey:@"name"];
        NSString *encodedName = [self encodeSpecialCharacters:unencodedName];
        
        [mutableDict removeObjectForKey:@"name"];
        [mutableDict setObject:encodedName forKey:@"name"];
        //current absolute time in seconds
        double currentSystemTime = CACurrentMediaTime();
        [mutableDict setObject:[NSString stringWithFormat:@"%f",currentSystemTime] forKey:@"requesttime"];
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:mutableDict options:0 error:&error];
        NSString *jsonString;
        if (!jsonData || error) {
            NSLog(@"JSON DATA must exist: ERROR:[%@]", error);
        }
        else
        {
            jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
            jsonString = [jsonString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        }
        
        NSString *url;
        
        url = [NSString stringWithFormat:@"%@/min/ajax/tagset/%@",globals.URL,jsonString];

        NSURLRequest *urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
        NSURLConnection *connection = [NSURLConnection connectionWithRequest:urlRequest delegate:self];
        
    }
    else //if (!globals.HAS_MIN|| (globals.HAS_MIN && !globals.eventExistsOnServer)){
    {
        if(globals.IS_LOCAL_PLAYBACK == false)
        {
            [self.delegate importTagsSyncDidFinishUploadingTags];
            return;
        }
        
        [self saveImageLocallyWithDict:mutableDict];
        
    }
    
}

//TODO: REMOVE, NOT USED
- (void)sendTwoDurationTagsInformationToServer
{
    self.isSaving = YES;
    
    if (self.tagDictsArray.count < 1) {
        [self.delegate importTagsSyncDidFinishUploadingTags];
        return;
    }
    
    
    if(!_currentProcessingTag)
    {
        _currentProcessingTag = [[self.tagDictsArray objectAtIndex:0] mutableCopy];
        [self.tagDictsArray removeObjectAtIndex:0];
    }
    
    NSMutableDictionary* mutableDict = [_currentProcessingTag mutableCopy];
    
    //Online Tagging
    if(globals.HAS_MIN && globals.eventExistsOnServer)
    {
        if((![globals.CURRENT_ENC_STATUS isEqualToString:encStateLive] && ![globals.CURRENT_ENC_STATUS isEqualToString:encStatePaused]) && ([globals.EVENT_NAME isEqualToString:@"live"]|| [globals.EVENT_NAME isEqualToString:@""]))
        {
            [self.delegate importTagsSyncDidFinishUploadingTags];
            return;
        }
        
        //Send Information To Server
        NSError *error;
        NSString *unencodedName = [mutableDict objectForKey:@"name"];
        NSString *encodedName = [self encodeSpecialCharacters:unencodedName];
        
        [mutableDict removeObjectForKey:@"name"];
        [mutableDict setObject:encodedName forKey:@"name"];
        
        
        //current absolute time in seconds
        double currentSystemTime = CACurrentMediaTime();
        [mutableDict setObject:[NSString stringWithFormat:@"%f",currentSystemTime] forKey:@"requesttime"];
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:mutableDict options:0 error:&error];
        NSString *jsonString;
        if (!jsonData || error) {
            NSLog(@"JSON DATA must exist: ERROR:[%@]", error);
        }
        else
        {
            jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
            jsonString = [jsonString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        }
        
        NSString *url;
        
        url = [NSString stringWithFormat:@"%@/min/ajax/tagset/%@",globals.URL,jsonString];
        
        NSURLRequest *urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
        NSURLConnection *connection = [NSURLConnection connectionWithRequest:urlRequest delegate:self];
        
    }
    else //if (!globals.HAS_MIN|| (globals.HAS_MIN && !globals.eventExistsOnServer)){
    {
        if(globals.IS_LOCAL_PLAYBACK == false)
        {
            [self.delegate importTagsSyncDidFinishUploadingTags];
            return;
        }
        
        [self saveImageLocallyWithDict:mutableDict];
        
    }
    
}



- (void)finishedAddingCurrentTag
{
    self.isSaving = NO;
    _currentProcessingTag = nil;
    self.uploadedTagNum++;
    self.progress = (float)self.uploadedTagNum/_totalTagNum;
    [self.delegate importTagsSyncProgressChangedTo: self.progress];
    
    if(!_paused)
        [self sendOneTagInformationToServer];

}


- (void)saveImageLocallyWithDict: (NSMutableDictionary*)mutableDict
{
    //Offline Tagging
    NSString* filePath =[[globals.EVENTS_PATH stringByAppendingPathComponent:globals.EVENT_NAME] stringByAppendingPathComponent:@"Thumbnails.plist"];
    NSString* imageName = [NSString stringWithFormat:@"%@.jpg", [mutableDict objectForKey:@"id"]];
    NSString* imagePath = [globals.THUMBNAILS_PATH stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@", imageName]];
    [globals.CURRENT_EVENT_THUMBNAILS setObject:mutableDict forKey:[mutableDict objectForKey:@"id"]];
    
    [mutableDict setObject:imagePath forKey:@"url"];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, NULL), ^{
        
        if(![[NSFileManager defaultManager] fileExistsAtPath:globals.THUMBNAILS_PATH isDirectory:NULL])
        {
            [[NSFileManager defaultManager] createDirectoryAtPath:globals.THUMBNAILS_PATH withIntermediateDirectories:YES attributes:nil error:NULL];
        }
        
        if(![[NSFileManager defaultManager] fileExistsAtPath:filePath isDirectory:NULL])
        {
            [[NSFileManager defaultManager] createFileAtPath:filePath contents:nil attributes:nil];
        }
        
        UIImage* placeholderImg = [UIImage imageNamed:@"live.png"];
        UIImage* screenshotImage = [self videoScreenshotWithTime:[mutableDict objectForKey:@"time"]];
        
        if(!screenshotImage)
            screenshotImage = placeholderImg;
        
        NSData* imageData = UIImageJPEGRepresentation(screenshotImage, 0.5);
        [imageData writeToFile:imagePath atomically:NO];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [self finishedAddingCurrentTag];
            
        });
        
    });
}



- (UIImage*)videoScreenshotWithTime: (NSString*)time //in tagDict(seconds)
{
    //create thumbnail using avfoundation and save it in the local dir
    NSURL *videoURL = [NSURL URLWithString:globals.CURRENT_PLAYBACK_EVENT];
    AVAsset *asset = [AVAsset assetWithURL:videoURL];
    AVAssetImageGenerator *imageGenerator = [[AVAssetImageGenerator alloc]initWithAsset:asset];
    [imageGenerator setMaximumSize:CGSizeMake(190, 106)];
    [imageGenerator setApertureMode:AVAssetImageGeneratorApertureModeProductionAperture];
    //CMTime time = [[dict objectForKey:@"cmtime"] CMTimeValue];//CMTimeMake(30, 1);
    CMTime cmTime = CMTimeMakeWithSeconds([time floatValue], 1);
    CGImageRef imageRef = [imageGenerator copyCGImageAtTime:cmTime actualTime:NULL error:NULL];
    UIImage *thumbnail = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);

    return thumbnail;
}




#pragma mark - NS URL Connection Delegate

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    [self finishedAddingCurrentTag];
}



-(NSString *)encodeSpecialCharacters:(NSString*)inputString
{
    NSString *encodedString = (NSString *)CFBridgingRelease(
    CFURLCreateStringByAddingPercentEscapes(
        NULL,
        (CFStringRef)inputString ,
        NULL,
        (CFStringRef)@"/#%^{}|`\"\\?",
        kCFStringEncodingUTF8 ));
    return encodedString;
}


+ (NSString*)timeStringFromSeconds: (float)totSeconds
{
    long second = (long)totSeconds % 60;
    NSString* secondString = @"00";
    if(second <= 9)
    {
        secondString = [NSString stringWithFormat:@"0%li", second];
    } else {
        secondString = [NSString stringWithFormat:@"%li", second];
    }
    
    long minute = (long)totSeconds / 60 % 60;
    
    NSString* minuteString = @"00";
    if(minute <= 9)
    {
        minuteString = [NSString stringWithFormat:@"0%li", minute];
    } else {
        minuteString = [NSString stringWithFormat:@"%li", minute];
    }
    
    long hour   = (long)totSeconds / 60 / 60;
    
    NSString* timeString = [NSString stringWithFormat:@"%li:%@:%@", hour, minuteString, secondString];
    
    return timeString;
    
}


@end
