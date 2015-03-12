//
//  DPBFileUploader.m
//  Live2BenchNative
//
//  Created by Si Te Feng on 8/19/14.
//  Copyright (c) 2014 DEV. All rights reserved.
//

#import "DPBFileUploader.h"
#import "NSObject+LBCloudConvenience.h"
#import "SVStatusHUD.h"


@implementation DPBFileUploader


- (instancetype)initWithSession: (DBSession*)session
{
    self = [super init];
    
    self.session = session;
    
    self.expectedUploadNum = 1;
    _currentUploadNum = 0;
    
    return self;
}


#pragma mark - Core Methods

- (void)createTodayFolderIfNeccessary
{
    privateClient = [[DBRestClient alloc] initWithSession:[DBSession sharedSession]];
    privateClient.delegate = self;
    
    _createdFolder = NO;
    [self loadDirectoryContentsAsyncWithPath:@"/" withRestClient:privateClient];
    
}


//levels: 1-year,   2-month,  3-day,  4-folder within a day
- (void)createTodayFolderIfNeccessaryWithCurrentPath: (NSString*)path contents: (NSArray*)contents
{
    NSString* lastPath = [path lastPathComponent];
    NSString* todayLastPath = [self cloudDriveFolderNameWithTodaysDateWithCalendarUnit:NSCalendarUnitDay];
    NSLog(@"Today Last Path: %@ [compare] lastPath: %@", todayLastPath, lastPath);
    
    if(![lastPath isEqual:todayLastPath])
    {
        //The folder path needs to be verified to exist
        NSString* childFolder = [self cloudDriveFolderNameWithTodaysDateWithCalendarUnit:NSCalendarUnitYear];
        
        if([lastPath isEqual: [self cloudDriveFolderNameWithTodaysDateWithCalendarUnit:NSCalendarUnitYear]])
        {
            childFolder = [self cloudDriveFolderNameWithTodaysDateWithCalendarUnit:NSCalendarUnitMonth];
        } else if([lastPath isEqual: [self cloudDriveFolderNameWithTodaysDateWithCalendarUnit:NSCalendarUnitMonth]])
        {
            childFolder = [self cloudDriveFolderNameWithTodaysDateWithCalendarUnit:NSCalendarUnitDay];
        }
        
        NSString* childPath = [path stringByAppendingPathComponent:childFolder];
        
        for(DBMetadata* data in contents)
        {
            NSString* folderName = data.filename;
            
            if([childFolder isEqual:folderName])
            {
                [self loadDirectoryContentsAsyncWithPath:childPath withRestClient:privateClient];
                return;
            }
        }
        
        //Child folder was not found
        [privateClient createFolder:childPath];
        _createdFolder = YES;
        
    }
    else //is day folder
    {
        [self.delegate fileUploaderVerifiedTodayFolderExists:self createdFolder:_createdFolder];
    }
    
}


- (void)uploadFileAsyncWithFileName: (NSString*)name data: (NSData*)data destPath: (NSString*)destPath
{
    
    if(![[DBSession sharedSession] isLinked])
    {
        NSLog(@"Dropbox: Cannot upload since the app is not linked");
        return;
    }
    
    NSString* dropboxPath = [self dropboxDownloadLocalDirectoryPath];
    
    NSString* filePath = [dropboxPath stringByAppendingPathComponent:name];
    
    [[NSFileManager defaultManager] createFileAtPath:filePath contents:data attributes:nil];
    
    self.restClient = [[DBRestClient alloc] initWithSession:[DBSession sharedSession]];
    self.restClient.delegate = self;
    
    [self.restClient uploadFile:name toPath:destPath withParentRev:nil fromPath:filePath];
    
}


//@"/" specifies root folder
- (void)loadDirectoryContentsAsyncWithPath: (NSString*)path
{
    if(![[DBSession sharedSession] isLinked])
    {
        NSLog(@"Dropbox: Cannot upload since the app is not linked");
        return;
    }
    
    self.restClient = [[DBRestClient alloc] initWithSession:[DBSession sharedSession]];
    self.restClient.delegate = self;
    [self loadDirectoryContentsAsyncWithPath:path withRestClient:self.restClient];
}

- (void)loadDirectoryContentsAsyncWithPath: (NSString*)path withRestClient: (DBRestClient*)client
{
    
    [client loadMetadata:path];
    
}


//Delete a File or Directory
- (void)deletePath: (NSString*)path
{
    self.restClient = [[DBRestClient alloc] initWithSession:[DBSession sharedSession]];
    self.restClient.delegate = self;
    [self.restClient deletePath:path];
}


- (void)loadFileWithPath:(NSString *)dropboxPath
{
    self.restClient = [[DBRestClient alloc] initWithSession:[DBSession sharedSession]];
    self.restClient.delegate = self;
    [self.restClient loadFile:dropboxPath intoPath:[self dropboxDownloadLocalDirectoryPath]];
    
}


#pragma mark - Dropbox Rest Client Delegate

//upload
- (void)restClient:(DBRestClient *)client uploadProgress:(CGFloat)progress forFile:(NSString *)destPath from:(NSString *)srcPath
{
    NSLog(@"Upload Progress: %.00f \n", progress);
    if([self.delegate respondsToSelector:@selector(fileUploader:uploadProgressChanged:forFileName:)])
        [self.delegate fileUploader:self uploadProgressChanged:progress forFileName:[destPath lastPathComponent]];
}


- (void)restClient:(DBRestClient*)restClient uploadedFile:(NSString *)destPath from:(NSString *)srcPath metadata:(DBMetadata *)metadata
{
    NSLog(@"Dropbox: UPLOADED FILE [%@]", metadata.filename);
    
    _currentUploadNum++;
    if(_currentUploadNum < self.expectedUploadNum)
        [SVStatusHUD showWithImage:[UIImage imageNamed:@"dropboxIconHUD"] status:[NSString stringWithFormat:@"Uploaded (%d,%d)", _currentUploadNum, self.expectedUploadNum]];
    else
        [SVStatusHUD showWithImage:[UIImage imageNamed:@"dropboxIconHUD"] status:@"Upload Successful"];
    
    [self.delegate fileUploader:self didUploadFileWithFileName:metadata.filename error:nil];
    
    [[NSFileManager defaultManager] removeItemAtPath:srcPath error:nil];
}


- (void)restClient:(DBRestClient *)client uploadFileFailedWithError:(NSError *)error
{
    _currentUploadNum++;
    NSLog(@"Upload Failed: %@", error.localizedDescription);
    [self.delegate fileUploader:self didUploadFileWithFileName:nil error:error];
}



//Directory Contents
- (void)restClient:(DBRestClient*)client loadedMetadata:(DBMetadata *)metadata
{
    NSLog(@"Directory Contents Loaded For %@", metadata.path);
    
    if([client isEqual:self.restClient])
    {
        if(metadata.isDirectory) {
            
            NSArray* fileContents = metadata.contents;
            [self.delegate fileUploader:self didLoadDirectoryContentsWithMetadatas:fileContents forDirectoryName:metadata.filename error:nil];
        }
    }
    else //Is private, so just checking if folder exists
    {
        if(metadata.isDirectory) {
            NSArray* fileContents = metadata.contents;
            
            NSString* fullPath = metadata.path;
            NSLog(@"path: %@", fullPath);
            
            [self createTodayFolderIfNeccessaryWithCurrentPath:metadata.path contents:fileContents];
            
        }
    }
    
}


- (void)restClient:(DBRestClient *)client loadMetadataFailedWithError:(NSError *)error
{
    NSLog(@"Load Directory Content Error: %@", error.localizedDescription);
    [self.delegate fileUploader:self didLoadDirectoryContentsWithMetadatas:nil forDirectoryName:nil error:error];
}



//Load File Contents

- (void)restClient:(DBRestClient *)client loadedFile:(NSString *)destPath contentType:(NSString *)contentType metadata:(DBMetadata *)metadata
{
    NSLog(@"File Loaded [%@]", metadata.filename);
    NSString* filepath = [self dropboxDownloadLocalDirectoryPath];
    NSData* fileData = [NSData dataWithContentsOfFile:filepath];

    [self.delegate fileUploader:self didLoadFileWithName:metadata.filename fileData:fileData fileURL:[NSURL URLWithString:filepath] type:contentType error:nil];
}


- (void)restClient:(DBRestClient *)client loadFileFailedWithError:(NSError *)error
{
    NSLog(@"Load File Error: %@", error.localizedDescription);
    [self.delegate fileUploader:self didLoadFileWithName:nil fileData:nil fileURL:nil type:nil error:error];
}


//Folder Created

- (void)restClient:(DBRestClient *)client createdFolder:(DBMetadata *)folder
{
    [self createTodayFolderIfNeccessaryWithCurrentPath:folder.path contents:folder.contents];
    
}

- (void)restClient:(DBRestClient *)client createFolderFailedWithError:(NSError *)error
{
    NSLog(@"Dropbox: Failed Creating New Folder");
}


//Path/folder/ file deleted

- (void)restClient:(DBRestClient *)client deletedPath:(NSString *)path
{
    [self.delegate fileUploader:self didDeleteFileAtPath:path error:nil];
}


- (void)restClient:(DBRestClient *)client deletePathFailedWithError:(NSError *)error
{
    NSLog(@"Deleting Path Error: %@", error.localizedDescription);
    [self.delegate fileUploader:self didDeleteFileAtPath:nil error:error];
}


#pragma mark - Setter Methods

- (void)setSession:(DBSession *)session
{
    _session = session;
    [DBSession setSharedSession:session];
    
    if(![session isLinked])
    {
        NSLog(@"Dropbox: Cannot upload since the app is not linked");
        return;
    }
    
    self.restClient = [[DBRestClient alloc] initWithSession:[DBSession sharedSession]];
    self.restClient.delegate = self;
}



#pragma mark - Convenience Methods

- (NSString*)dropboxDownloadLocalDirectoryPath
{
    NSString* cachePath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject];
    
    NSString* dropboxDownloadPath = [cachePath stringByAppendingPathComponent:@"dropbox"];
    
    BOOL isDir;
    BOOL exists = [[NSFileManager defaultManager] fileExistsAtPath:dropboxDownloadPath isDirectory:&isDir];
    
    if(!exists)
    {
        [[NSFileManager defaultManager] createDirectoryAtPath:dropboxDownloadPath withIntermediateDirectories:NO attributes:nil error:nil];
    }
    
    return dropboxDownloadPath;
    
}





@end
