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
    }
    return self;
}


- (nullable NSString *)activityTitle
{
    return [NSString stringWithFormat:@"Upload %lu files to Dropbox", (unsigned long)[self.urls count]];
}

//- (nullable UIImage *)activityImage
//{
//    return nil;
//}

- (BOOL)canPerformWithActivityItems:(NSArray *)activityItems {
    for (NSURL *url in activityItems) {
        if ([url isKindOfClass:[NSURL class]]) {
            return YES;
        }
    }
    
    return NO;
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
    for (NSURL *url in self.urls) {
        NSString * fileName = @"asdf";
        DropboxUploadOperation * op = [[DropboxUploadOperation alloc]initUploadFile:fileName toPath:@"/Live2BenchNative/" withParentRev:nil fromPath:[url absoluteString ]];
        
        op.restClient = [[DBRestClient alloc] initWithSession:[DBSession sharedSession]];
        [[DropboxManager getInstance].queue addOperation:op];

    }
    


}


@end
