//
//  PxpDropboxActivity.m
//  Live2BenchNative
//
//  Created by dev on 2016-07-15.
//  Copyright © 2016 DEV. All rights reserved.
//

#import "PxpDropboxActivity.h"
#import "DropboxManager.h"
#import "DropboxUploadOperation.h"

@interface PxpDropboxActivity ()

@property (nonatomic,strong) NSArray * urls;

@end

@implementation PxpDropboxActivity


- (instancetype)init
{
    self = [super init];
    if (self) {
        self.urlToFileName = [NSMutableDictionary new];
        self.filesUploaded  = 1;
    }
    return self;
}


- (instancetype)initWithURLnameDict:(NSDictionary*)dict
{
    self = [super init];
    if (self) {
        self.urlToFileName  = [dict mutableCopy];
        self.fileCount      = [self.urlToFileName count];
        self.filesUploaded  = 1;
    }
    return self;
}



- (nullable NSString *)activityTitle
{
//    return [NSString stringWithFormat:@"Upload %lu files to Dropbox", (unsigned long)[self.urls count]];
    return [NSString stringWithFormat:@"Upload Clips to Dropbox"];
}

- (nullable UIImage *)activityImage
{
    return [UIImage imageNamed:@"Dropbox"];
}

- (BOOL)canPerformWithActivityItems:(NSArray *)activityItems {
    
    BOOL check = YES;
    
    for (NSURL *url in activityItems) {
        if (![url isKindOfClass:[NSURL class]]) {
            check = NO;
        }
    }
    
    return check;
}

- (void)prepareWithActivityItems:(NSArray *)activityItems {
    NSMutableArray * pool = [NSMutableArray new];
    for (NSURL *url in activityItems) {
        if ([url isKindOfClass:[NSURL class]]) {
            [pool addObject:url];
        }
    }
    
    self.urls  = [pool copy];
    
}

- (void)performActivity
{
    
    
    // debug
//    [[DropboxManager getInstance].queue cancelAllOperations];
    // debug end
    
    
    if (![[DBSession sharedSession] isLinked]) {
    
            [[[UIAlertView alloc]
               initWithTitle:@"Dropbox" message:@"Please login on the setting page." delegate:nil
               cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil]
           
             show];
        [self activityDidFinish:YES];
        return ;
    }
    
    self.onActivityStart(self);
    __weak PxpDropboxActivity * weakSelf = self;
    
    NSOperation * finisherBlock = [NSBlockOperation blockOperationWithBlock:^{
        [self activityDidFinish:YES];
        weakSelf.onActivityComplete(self);
    }];
    
    
    self.fileCount = [self.urls count];
    for (NSURL *url in self.urls) {
        NSString * urlString = [url relativePath];
        NSString * fileName = [self.urlToFileName objectForKey:urlString];
        
        

        
        
        
        DropboxUploadOperation * op = [[DropboxUploadOperation alloc]initUploadFile:fileName toPath:@"/Live2BenchNative/" withParentRev:nil fromPath:urlString];
      
        [op setCompletionBlock:^{
            weakSelf.filesUploaded++;
        }];
        
        [op setOnOperationProgress:^(CGFloat currentFileProgress) {
            weakSelf.onActivityProgress(weakSelf,currentFileProgress);
        }];
        
        [finisherBlock addDependency:op];
        
        op.restClient = [[DBRestClient alloc] initWithSession:[DBSession sharedSession]];
        [[DropboxManager getInstance].queue addOperation:op];
       
    }
    
    [[NSOperationQueue mainQueue]addOperation:finisherBlock];
}

@end
