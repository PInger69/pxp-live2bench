//
//  DropboxUploadOperation.m
//  Live2BenchNative
//
//  Created by dev on 2016-07-14.
//  Copyright © 2016 DEV. All rights reserved.
//

#import "DropboxUploadOperation.h"


@interface DropboxUploadOperation () <DBRestClientDelegate>
@property (nonatomic,strong) NSString * fileName;
@property (nonatomic,strong) NSString * toPath;
@property (nonatomic,strong) NSString * parentRev;
@property (nonatomic,strong) NSString * fromPath;

@end



@implementation DropboxUploadOperation
{
    
    BOOL _isFinished;
    BOOL _isExecuting;
}




- (instancetype)initUploadFile:(NSString *)fileName toPath:(NSString *)toPath withParentRev:(NSString *)parentRev fromPath:(NSString *)fromPath
{
    self = [super init];
    if (self) {
        _isExecuting        = NO;
        _isFinished         = NO;
        self.fileName       = fileName;
        self.toPath         = toPath;
        self.parentRev      = parentRev;
        self.fromPath       = fromPath;
    }
    return self;
}



- (void)cancel
{
    [super cancel];
    //    if ([self isExecuting]) {
    [self setExecuting:NO];
    [self setFinished:YES];
    //    }
}


-(void)start
{
    NSLog(@"%s",__FUNCTION__);

    if ([self isCancelled]) {
        [self setFinished:YES];
        
    }
    [self setExecuting:YES];

    self.restClient.delegate = self;
    

    dispatch_async(dispatch_get_main_queue(), ^{
        [self.restClient uploadFile:self.fileName toPath:self.toPath withParentRev:self.parentRev fromPath:self.fromPath];        
    });
    
}



-(BOOL)isConcurrent
{
    return YES;
}

- (void)setExecuting:(BOOL)isExecuting {
    if (isExecuting != _isExecuting) {
        [self willChangeValueForKey:@"isExecuting"];
        _isExecuting = isExecuting;
        [self didChangeValueForKey:@"isExecuting"];
    }
}

- (BOOL)isExecuting
{
    return _isExecuting;
}

- (void)setFinished:(BOOL)isFinished
{
    [self willChangeValueForKey:@"isFinished"];
    // Instance variable has the underscore prefix rather than the local
    _isFinished = isFinished;
    [self didChangeValueForKey:@"isFinished"];
}

- (BOOL)isFinished
{
    return _isFinished || [self isCancelled];
}


#pragma mark - DBRestClientDelegate methods start

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


- (void)restClient:(DBRestClient*)client uploadProgress:(CGFloat)progress forFile:(NSString*)destPath from:(NSString*)srcPath
{
    
    if (self.onOperationProgress) {
        self.onOperationProgress(progress);
    }
    NSLog(@"%f",progress);
}

-(void)restClient:(DBRestClient *)client uploadedFile:(NSString *)destPath from:(NSString *)srcPath metadata:(DBMetadata *)metadata
{
    [self setExecuting:NO];
    [self setFinished:YES];

}

- (void)restClient:(DBRestClient*)client metadataUnchangedAtPath:(NSString*)path {
}

- (void)restClient:(DBRestClient*)client loadMetadataFailedWithError:(NSError*)error {
    //NSLog(@"restClient:loadMetadataFailedWithError: %@", [error localizedDescription]);
    [self displayError];
//    [self setWorking:NO];
}

- (void)restClient:(DBRestClient*)client loadedThumbnail:(NSString*)destPath {
//    [self setWorking:NO];
}

- (void)restClient:(DBRestClient*)client loadThumbnailFailedWithError:(NSError*)error {
//    [self setWorking:NO];
    [self displayError];
}

- (void)displayError {
    [[[UIAlertView alloc]
      initWithTitle:@"Error Loading Clip" message:@"There was an error loading your Clip."
      delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil]
     show];
}



#pragma mark - DBRestClientDelegate methods end
@end
