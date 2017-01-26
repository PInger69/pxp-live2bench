//
//  FeedInspector.m
//  Live2BenchNative
//
//  Created by dev on 2015-07-20.
//  Copyright © 2015 DEV. All rights reserved.
//


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/// HELPER ACTION LIST ITEMS
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

#import "ActionListItem.h"

@interface LocalFileCheck : NSObject <ActionListItem>
@property (nonatomic,assign) BOOL isFinished;
@property (nonatomic,assign) BOOL isSuccess;
@property (nonatomic,weak)  id <ActionListItemDelegate>  delegate;

-(instancetype)initWithNSURL:(NSURL*)aURL;
-(void)start;
@end

@implementation LocalFileCheck
{
    NSURL* url;
}
@synthesize isFinished,isSuccess;
- (instancetype)initWithNSURL:(NSURL*)aURL
{
    self = [super init];
    if (self) {
        url = aURL;
    }
    return self;
}

-(void)start
{
    self.isSuccess  = [[NSFileManager defaultManager] fileExistsAtPath:url.absoluteString];
    self.isFinished = YES;
}

@end



////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


@interface ExternalFileCheck : NSObject <ActionListItem,NSURLConnectionDataDelegate>
@property (nonatomic,assign) BOOL isFinished;
@property (nonatomic,assign) BOOL isSuccess;
@property (nonatomic,weak)  id <ActionListItemDelegate>  delegate;
- (instancetype)initWithNSURL:(NSURL*)aURL;
-(void)start;
@end

@implementation ExternalFileCheck
{
    NSURL* url;
}
@synthesize isFinished,isSuccess;
- (instancetype)initWithNSURL:(NSURL*)aURL
{
    self = [super init];
    if (self) {
        url = aURL;
    }
    return self;
}


-(void)start
{
    NSURLRequest    * urlRequest        = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:5];
    NSURLConnection * connection = [NSURLConnection connectionWithRequest:urlRequest delegate:self];
    [connection start];
}


-(void)connection:(nonnull NSURLConnection *)connection didReceiveResponse:(nonnull NSURLResponse *)response
{
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
    if ([httpResponse statusCode]/100 == 2){
        self.isSuccess  = YES;
    } else {
        self.isSuccess  = NO;
    }
    [connection cancel];
    self.isFinished = YES;
}

@end

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

#import <AVFoundation/AVFoundation.h>
#import <AVFoundation/AVPlayerItem.h>
#import "FeedInspector.h"
@interface CorruptionCheck : NSObject <ActionListItem,NSURLConnectionDataDelegate>
@property (nonatomic,assign) BOOL isFinished;
@property (nonatomic,assign) BOOL isSuccess;
@property (nonatomic,weak)  id <ActionListItemDelegate>  delegate;
@property (nonatomic,weak)  FeedInspector *  inspector;

- (instancetype)initWithNSURL:(NSURL*)aURL inspector:(FeedInspector*)aInspector;
-(void)start;
@end

@implementation CorruptionCheck
{
    NSURL* url;
    
}
@synthesize isFinished,isSuccess;
- (instancetype)initWithNSURL:(NSURL*)aURL inspector:(FeedInspector*)aInspector
{
    self = [super init];
    if (self) {
        self.inspector = aInspector;
        url = aURL;
    }
    return self;
}


-(void)start
{
    AVURLAsset *asset                       = [AVURLAsset URLAssetWithURL:url options:nil];
    NSArray *requestedKeys                  = @[@"playable"];
    __block FeedInspector * weakInspector   = self.inspector;

    /* Tells the asset to load the values of any of the specified keys that are not already loaded. */
    [asset loadValuesAsynchronouslyForKeys:requestedKeys completionHandler:
    ^{
    dispatch_async( dispatch_get_main_queue(),
                ^{
                    self.isSuccess  = YES;
                    for (NSString *thisKey in requestedKeys)
                    {
                        NSError *error = nil;
                        AVKeyValueStatus keyStatus = [asset statusOfValueForKey:thisKey error:&error];
                        if (keyStatus == AVKeyValueStatusFailed)
                        {
                            [weakInspector.errors addObject:error];
                            self.isSuccess  = NO;
                            break;
                        }
                        
                    }

                    /* Use the AVAsset playable property to detect whether the asset can be played. */
                    if (!asset.playable)
                    {
                        /* Generate an error describing the failure. */
                        NSString *localizedDescription = NSLocalizedString(@"Item cannot be played", @"Item cannot be played description");
                        NSString *localizedFailureReason = NSLocalizedString(@"The assets tracks were loaded, but could not be made playable.", @"Item cannot be played failure reason");
                        NSDictionary *errorDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                                   localizedDescription, NSLocalizedDescriptionKey,
                                                   localizedFailureReason, NSLocalizedFailureReasonErrorKey,
                                                   nil];
                        NSError *assetCannotBePlayedError = [NSError errorWithDomain:@"StitchedStreamPlayer" code:0 userInfo:errorDict];
                        [weakInspector.errors addObject:assetCannotBePlayedError];
                        self.isSuccess  = NO;
                    }
                    
                    self.isFinished = YES;
                });
    }];
}


@end

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////



#import "FeedInspector.h"
#import <AVFoundation/AVFoundation.h>
#import <AVFoundation/AVPlayerItem.h>

@class LocalFileCheck;

@implementation FeedInspector

static FeedInspector * instance;

+ (void)initialize
{
    if (self == [FeedInspector class]) {
        instance = [[FeedInspector alloc]init];
    }
}

+(void)investigate:(Feed*)suspectFeed
{
    [instance checkingFeed:suspectFeed];
}




@synthesize suspectFeed =_suspectFeed;
@synthesize errors      = _errors;
@synthesize actionList  = _actionList;




- (instancetype)init
{
    self = [super init];
    if (self) {
        _errors     = [[NSMutableArray alloc]init];
        _actionList = [[ActionList alloc]init];
    }
    return self;
}



-(void)checkingFeed:(Feed*)aSuspectFeed
{
    if (!aSuspectFeed){
        NSLog(@"Nil Feed sent");
    
    }
    
    _suspectFeed            = aSuspectFeed;
    _suspectFeed.mode       = FeedModesInProcess;
    [_errors removeAllObjects];
    self.urlsToCheck             = [NSMutableArray arrayWithArray:[_suspectFeed allPaths]];

    
    // splice of the first URL and check it
    NSURL * aURL =     [self.urlsToCheck firstObject];
    [self.urlsToCheck removeObjectAtIndex:0];
    [self startCheckingURL:aURL];
}


// this is where the action list is built and started
-(void)startCheckingURL:(NSURL*)url
{
    [_actionList clear];
    __block FeedInspector * weakSelf = self;
    [_actionList onFinishList:^{
       
        if ([weakSelf.urlsToCheck count]) {
            NSURL * aURL =     [weakSelf.urlsToCheck firstObject];
            [weakSelf.urlsToCheck removeObjectAtIndex:0];
            [self startCheckingURL:aURL];
        } else {
                [weakSelf checkComplete];
        }
    }];
    
    
    
    if (url.isFileURL){
        
        [_actionList addItem:[[LocalFileCheck alloc]initWithNSURL:url] onItemFinish:^(BOOL succsess) {
            if (!succsess){
                NSDictionary *userInfo = @{
                                          NSLocalizedDescriptionKey:                NSLocalizedString(@"File is not on device", nil),
                                          NSLocalizedFailureReasonErrorKey:         NSLocalizedString(@"The files was not downloaded yet on the server or has been deleted from the device.", nil),
                                          NSLocalizedRecoverySuggestionErrorKey:    NSLocalizedString(@"Don't delete the file?", nil)
                                          };
                NSError * e = [[NSError alloc]initWithDomain:@"Missing File" code:-666 userInfo:userInfo];
                [weakSelf.errors addObject:e];
          
//                [weakSelf.actionList clear];
            }

        }];
    } else /*then its a web url*/ {
        [_actionList addItem:[[ExternalFileCheck alloc]initWithNSURL:url] onItemFinish:^(BOOL succsess) {
            if (!succsess){
                NSDictionary *userInfo = @{
                                           NSLocalizedDescriptionKey:                NSLocalizedString(@"File is not on Encoder", nil),
                                           NSLocalizedFailureReasonErrorKey:         NSLocalizedString(@"The files was not created yet on the server or has been deleted from the server.", nil),
                                           NSLocalizedRecoverySuggestionErrorKey:    NSLocalizedString(@"Contact the server guy", nil)
                                           };
                NSError * e = [[NSError alloc]initWithDomain:@"Missing File" code:-666 userInfo:userInfo];
                [weakSelf.errors addObject:e];
//                [weakSelf.actionList clear];
            }

        }];
    }
    
    
    [_actionList addItem:[[CorruptionCheck alloc]initWithNSURL:url inspector:self]];
    
    
    
    [_actionList start];
}




-(void)feedURLcheck2:(NSURL*)url
{
    [self checkComplete];
}


-(void)checkComplete
{
    if ([_errors count]) {
        self.suspectFeed.feedErrors = [_errors copy];
        for (NSError*err in _errors) {
            switch (err.code) {
                case -666:
                    self.suspectFeed.mode = FeedModesNotFound;
                    goto BAIL;
                    break;
                    
                default:
                    break;
//                    self.suspectFeed.mode = FeedModesCorrupt;
            }
        }
        
    } else { // no error then its fine
        self.suspectFeed.mode = FeedModesReady;
    }
    BAIL:
    [_errors removeAllObjects];
    [[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_FEED_INSPECTION_COMPLETE object:self.suspectFeed];
    self.suspectFeed = nil;
    
}



@end

