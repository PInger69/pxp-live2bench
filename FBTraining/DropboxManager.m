//
//  DropboxManager.m
//  Live2BenchNative
//
//  Created by dev on 2016-07-13.
//  Copyright © 2016 DEV. All rights reserved.
//

#import "DropboxManager.h"
#import <DropboxSDK/DropboxSDK.h>

@interface DropboxManager () <DBSessionDelegate, DBNetworkRequestDelegate,DBRestClientDelegate>


@property (nonatomic,strong) NSString * relinkUserId;
@property (nonatomic,strong) NSString * appKey;
@property (nonatomic,strong) NSString * appSecret;
@property (nonatomic,strong) NSString * root;



@end



static DropboxManager * _instance;
@implementation DropboxManager

+(DropboxManager*)getInstance
{
    return _instance;
}



+(void)initialize
{
    _instance = [DropboxManager new];
}


- (instancetype)init
{
    self = [super init];
    if (self) {
        
        self.queue = [NSOperationQueue new];
        self.queue.maxConcurrentOperationCount = 1;
        
        
        
        
        // Set these variables before launching the app
        self.appKey        = @"huc2enjbl496cq8";
        self.appSecret     = @"0w4addrpazk3p9n";
        self.root          = kDBRootDropbox; // Should be set to either kDBRootAppFolder or kDBRootDropbox
        // You can determine if you have App folder access or Full Dropbox along with your consumer key/secret
        // from https://dropbox.com/developers/apps

        NSString* errorMsg = nil;
        if ([self.appKey rangeOfCharacterFromSet:[[NSCharacterSet alphanumericCharacterSet] invertedSet]].location != NSNotFound) {
            errorMsg = @"Make sure you set the app key correctly in DBRouletteAppDelegate.m";
        } else if ([self.appSecret rangeOfCharacterFromSet:[[NSCharacterSet alphanumericCharacterSet] invertedSet]].location != NSNotFound) {
            errorMsg = @"Make sure you set the app secret correctly in DBRouletteAppDelegate.m";
        } else if ([self.root length] == 0) {
            errorMsg = @"Set your root to use either App Folder of full Dropbox";
        } else {
            NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"Info" ofType:@"plist"];
            NSData *plistData = [NSData dataWithContentsOfFile:plistPath];
            NSDictionary *loadedPlist =
            [NSPropertyListSerialization
             propertyListFromData:plistData mutabilityOption:0 format:NULL errorDescription:NULL];
            NSString *scheme = [[[[loadedPlist objectForKey:@"CFBundleURLTypes"] objectAtIndex:0] objectForKey:@"CFBundleURLSchemes"] objectAtIndex:0];
            if ([scheme isEqual:@"db-huc2enjbl496cq8"]) {
                errorMsg = @"Set your URL scheme correctly in DBRoulette-Info.plist";
            }
        }

        
//        - (DBRestClient *)restClient {
//            if (!restClient) {
//                restClient =
//                [[DBRestClient alloc] initWithSession:[DBSession sharedSession]];
//                restClient.delegate = self;
//            }
//            return restClient;
//        }
//        
//        
//        if ([[DBSession sharedSession] isLinked]) {
//            restClient=nil;
//            [self restClient];
//            [dbUploadTimer invalidate];
//            dbUploadTimer =nil;
//            [self uploadClipsToDB];
//        }

        
    }
    return self;
}


-(void)connect
{
    
//     self.restClient = [[DBRestClient alloc] initWithSession:[DBSession sharedSession]];
//     self.restClient.delegate = self;
//    
    
    
    self.session =
    [[DBSession alloc] initWithAppKey:self.appKey appSecret:self.appSecret root:self.root];
    self.session.delegate = self; // DBSessionDelegate methods allow you to handle re-authenticating
    [DBSession setSharedSession:self.session];
    [DBRequest setNetworkRequestDelegate:self];

    
    self.restClient = [[DBRestClient alloc] initWithSession:[DBSession sharedSession]];
    self.restClient.delegate = self;
    
    [self.restClient loadAccountInfo];
}


#pragma mark -
#pragma mark DBSessionDelegate methods

- (void)sessionDidReceiveAuthorizationFailure:(DBSession*)session userId:(NSString *)userId {
    self.relinkUserId = userId;
//    [[[[UIAlertView alloc]
//       initWithTitle:@"Dropbox Session Ended" message:@"Do you want to relink?" delegate:self
//       cancelButtonTitle:@"Cancel" otherButtonTitles:@"Relink", nil]
//      autorelease]
//     show];
}


//#pragma mark -
//#pragma mark UIAlertViewDelegate methods
//
//- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)index {
//    if (index != alertView.cancelButtonIndex) {
//        [[DBSession sharedSession] linkUserId:relinkUserId fromController:rootViewController];
//    }
//    
//    relinkUserId = nil;
//}
//

#pragma mark -
#pragma mark DBNetworkRequestDelegate methods

static int outstandingRequests;

- (void)networkRequestStarted {
    outstandingRequests++;
    if (outstandingRequests == 1) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    }
}

- (void)networkRequestStopped {
    outstandingRequests--;
    if (outstandingRequests == 0) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    }
}

#pragma mark -

- (void)restClient:(DBRestClient*)client loadedMetadata:(DBMetadata*)metadata {
    
    
    NSArray* validExtensions = [NSArray arrayWithObjects:@"mp4", nil];
    NSMutableArray* newPhotoPaths = [NSMutableArray new];
    for (DBMetadata* child in metadata.contents) {
        NSString* extension = [[child.path pathExtension] lowercaseString];
        if (!child.isDirectory && [validExtensions indexOfObject:extension] != NSNotFound) {
            [newPhotoPaths addObject:child.path];
        }
    }
}

- (void)restClient:(DBRestClient*)client metadataUnchangedAtPath:(NSString*)path {
    NSLog(@"%s",__FUNCTION__);

}

- (void)restClient:(DBRestClient*)client loadMetadataFailedWithError:(NSError*)error {
    //NSLog(@"restClient:loadMetadataFailedWithError: %@", [error localizedDescription]);
//    [self displayError];
//    [self setWorking:NO];
    NSLog(@"%s",__FUNCTION__);

}

- (void)restClient:(DBRestClient*)client loadedThumbnail:(NSString*)destPath {
//    [self setWorking:NO];
    NSLog(@"%s",__FUNCTION__);

}

- (void)restClient:(DBRestClient*)client loadThumbnailFailedWithError:(NSError*)error {
//    [self setWorking:NO];
//    [self displayError];
    NSLog(@"%s",__FUNCTION__);

}

- (void)restClient:(DBRestClient*)client loadedAccountInfo:(DBAccountInfo*)info
{
    self.linkedUserName = [info displayName];
    if (self.onUserConnected) self.onUserConnected(self.linkedUserName);
}


@end
