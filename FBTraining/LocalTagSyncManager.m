//
//  LocalTagSyncManager.m
//  Live2BenchNative
//
//  Created by dev on 2016-06-20.
//  Copyright © 2016 DEV. All rights reserved.
//

#import "LocalTagSyncManager.h"


#import "EncoderOperation.h"

@interface LocalTagSyncManager ()
@property (nonatomic,strong) NSOperationQueue       * uploadTagQueue;
@property (nonatomic,strong) NSMutableDictionary    * allTags;
@property (nonatomic,strong) NSMutableDictionary    * allModTags;


@end


@implementation LocalTagSyncManager


- (instancetype)initWithDocsPath:(NSString*)aDocsPath
{
    self = [super init];
    if (self) {
        self.localPath      = aDocsPath;
        self.uploadTagQueue = [NSOperationQueue new];
        self.uploadTagQueue.maxConcurrentOperationCount = 1;
        
        
        BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath: [_localPath stringByAppendingPathComponent:@"localTags.plist"] isDirectory:NULL];
        if (!fileExists) {
            if (![@{} writeToFile: [_localPath stringByAppendingPathComponent:@"localTags.plist"] atomically:YES]) {
                PXPLog(@"Error writing tag to device -LS001");
            }
            
            if (![@{} writeToFile: [_localPath stringByAppendingPathComponent:@"modifiedTags.plist"] atomically:YES]) {
                PXPLog(@"Error writing tag to device -LS002");
            }
        }
        
        
        
        
        NSString        * aPath        = [self.localPath stringByAppendingPathComponent:@"localTags.plist"];
        self.allTags    = [[NSMutableDictionary dictionaryWithContentsOfFile:aPath] mutableCopy];
        NSArray         * locTagsKeys   = [self.allTags allKeys];
        
        for (NSString * tagKey in locTagsKeys) {
            NSDictionary * tagDict = self.allTags[tagKey];
            [self makeOperation:tagDict hash:tagKey isMod:NO];
        }

        
        aPath              = [self.localPath stringByAppendingPathComponent:@"modifiedTags.plist"];
        self.allModTags    = [[NSMutableDictionary dictionaryWithContentsOfFile:aPath] mutableCopy];
        locTagsKeys        = [self.allModTags allKeys];
        for (NSString * tagKey1 in locTagsKeys) {
            NSDictionary * tagDict1 = self.allTags[tagKey1];
            [self makeOperation:tagDict1 hash:tagKey1 isMod:YES];
        }
        
    }
    return self;
}


-(void)addTag:(NSDictionary*)tagData
{
    // add tag to data
    NSString* hash = [[NSUUID UUID]UUIDString];
    
    [self.allTags setObject:tagData forKey:hash];
    
    
    

    
    // write to file
    if (![self.allTags writeToFile: [_localPath stringByAppendingPathComponent:@"localTags.plist"] atomically:YES]) {
        PXPLog(@"Error writing tag to device -LS001");
    }
    
    [self makeOperation:tagData hash:hash isMod:NO];
}


-(void)addMod:(NSDictionary*)tagData
{
    // add tag to data
    NSString* hash = [[NSUUID UUID]UUIDString];
    
    [self.allTags setObject:tagData forKey:hash];
 
    // write to file
    if (![self.allTags writeToFile: [_localPath stringByAppendingPathComponent:@"modifiedTags.plist"] atomically:YES]) {
        PXPLog(@"Error writing tag to device -LS002");
    }
    
    [self makeOperation:tagData hash:hash isMod:YES];
}

-(void)removeTagByKey:(NSString*)aKey
{
    [self.allTags removeObjectForKey:aKey];
    if (![self.allTags writeToFile: [_localPath stringByAppendingPathComponent:@"localTags.plist"] atomically:YES]) {
        PXPLog(@"Error writing/removing tag to device");
    }
    
    [self.allModTags removeObjectForKey:aKey];
    if (![self.allModTags writeToFile: [_localPath stringByAppendingPathComponent:@"modifiedTags.plist"] atomically:YES]) {
        PXPLog(@"Error writing/removing tag to device");
    }
}

-(void)updateWithEncoder:(id<EncoderProtocol>)encoder
{
    for (EncoderOperationLocalTagPost * operation in self.uploadTagQueue.operations) {
        // if its the special operation
        if (!operation.isReady && !operation.isFinished && !operation.isExecuting) {
            [operation updateWithEncoder:encoder];
        }
    }
}

-(void)makeOperation:(NSDictionary*)tagData hash:(NSString*)hash isMod:(BOOL)isMod
{
    EncoderOperationLocalTagPost * operation = (isMod)?[[EncoderOperationLocalTagPost alloc]initTagModData:tagData]:[[EncoderOperationLocalTagPost alloc]initTagData:tagData];
    
    __weak EncoderOperationLocalTagPost * weakOperation = operation;
    __weak LocalTagSyncManager * weakSelf           = self;
    operation.tagHash = hash;
    
    [operation setCompletionBlock:^{
        if (weakOperation.success) {
            [weakSelf removeTagByKey:weakOperation.tagHash];
        }
    }];
    // if the operation is successful then delete the dict and remove from plist
    
    [self.uploadTagQueue addOperation:operation];
}







@end
