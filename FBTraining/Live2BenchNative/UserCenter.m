//
//  UserCenter.m
//  Live2BenchNative
//
//  Created by dev on 2014-12-04.
//  Copyright (c) 2014 DEV. All rights reserved.
//




// This class is the center point for all user data such as the tag names and other user data
// all plists will be loaded to this class if it should be accsessed
// it will manage making, updating and retreving pl data
#import "UserCenter.h"

#define PLIST_THUMBNAILS        @"Thumbnails.plist"
#define PLIST_PLAYER_SETUP      @"players-setup.plist"
#define PLIST_TAG_BUTTONS       @"TagButtons.plist"

@implementation UserCenter
{
    NSString        * localPath;
    NSFileManager   * fileManager;
    id              tagNameObserver;
    BOOL            observering;
}

@synthesize tagNames = _tagNames;

@synthesize userPick = _userPick;

@synthesize currentEventThumbnails = _currentEventThumbnails;



-(id)initWithLocalDocPath:(NSString*)aLocalDocsPath
{
    self = [super init];
    if (self) {
        localPath       = aLocalDocsPath;
        observering     = NO;
        fileManager     = [NSFileManager defaultManager];
        
        // notifications will mostly be coming from the cloud Encoder
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(update:) name:NOTIF_USER_CENTER_UPDATE object:nil];
    }
    return self;
}


// This updates this class based of the keys in the userdict
-(void)update:(NSNotification*)note
{
    NSDictionary * data = note.userInfo;

    if ([data objectForKey:@"userPick"]) self.userPick = [data objectForKey:@"userPick"];
}


-(void)enableObservers:(BOOL)isObserve
{
    if (observering && !isObserve){
        [[NSNotificationCenter defaultCenter]removeObserver:tagNameObserver];
    } else if (!observering && isObserve) {
        tagNameObserver =    [[NSNotificationCenter defaultCenter]addObserverForName:NOTIF_TAG_NAMES_FROM_CLOUD object:nil queue:nil usingBlock:^(NSNotification *note) {
            NSLog(@"I see data");
            NSMutableArray * tgnames = [note.userInfo mutableCopy];
            if (tgnames){
                _tagNames = tgnames;
                
                
//                NSError *error;
                NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                NSString *documentsDirectory = [paths objectAtIndex:0];
               
                
                NSString *plistPath = [documentsDirectory stringByAppendingPathComponent:PLIST_TAG_BUTTONS];
//                if (![fileManager fileExistsAtPath: plistPath])
//                {
//                    NSString *bundle = [[NSBundle mainBundle] pathForResource:@”myPlistFile” ofType:@”plist”];
//                    [fileManager copyItemAtPath:bundle toPath:plistPath error:&error];
//                }
                [_tagNames writeToFile:plistPath atomically: YES];

              
            } else {
                _tagNames = [self _buildTagNames:localPath];
            }
        }];
    }
    observering = isObserve;
}



-(NSMutableArray*)_buildTagNames:(NSString*)aLocalPath
{
//    NSMutableArray * list = [[NSMutableArray alloc] init];
    NSString *tagFilePath = [aLocalPath stringByAppendingPathComponent:PLIST_TAG_BUTTONS];
    
    return  [[NSMutableArray alloc] initWithContentsOfFile:tagFilePath];
}



@end
