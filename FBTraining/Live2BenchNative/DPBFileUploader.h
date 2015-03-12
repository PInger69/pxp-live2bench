//
//  DPBFileUploader.h
//  Live2BenchNative
//
//  Created by Si Te Feng on 8/19/14.
//  Copyright (c) 2014 DEV. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <DropboxSDK/DropboxSDK.h>
#import "NSObject+LBCloudConvenience.h"

typedef NS_ENUM(NSInteger, DPBFileUploaderState)
{
    DPBFileUploaderStateNone = 0,
    DPBFileUploaderStateVerifyingTodayFolder,
    DPBFileUploaderStateUploadingFile,
    DPBFileUploaderStateRetrievingDirectoryContent
    
};


static NSString* kDropboxAppKey = @"ibkgyjosekrjp9s";
static NSString* kDropboxAppSecret = @"kptsa2z0nqo3xoa";
#define kDropboxAppRoot kDBRootAppFolder
// Should be set to either kDBRootAppFolder or kDBRootDropbox

@protocol DPBFileUploaderDelegate;
@interface DPBFileUploader : UIViewController <DBRestClientDelegate>
{
    DBRestClient* privateClient;
    
//    NSArray*      _currDirectoryContentsChecking; //used during checking folder exists process
    BOOL       _createdFolder;
    
    NSInteger   _currentUploadNum;
}




@property (nonatomic, strong) DBSession* session;

@property (nonatomic, strong) DBRestClient* restClient;

@property (nonatomic, assign) NSInteger expectedUploadNum;

@property (nonatomic, weak) id<DPBFileUploaderDelegate> delegate;
@property (nonatomic, assign) DPBFileUploaderState  state;


//Public Methods
- (instancetype)initWithSession: (DBSession*)session;

- (void)createTodayFolderIfNeccessary;
- (void)uploadFileAsyncWithFileName: (NSString*)name data: (NSData*)data destPath: (NSString*)destPath;
- (void)loadDirectoryContentsAsyncWithPath: (NSString*)path;
- (void)deletePath: (NSString*)path;

- (void)loadFileWithPath:(NSString*)dropboxPath;

//Convenience
- (NSString*)dropboxDownloadLocalDirectoryPath;

@end


@protocol DPBFileUploaderDelegate <NSObject>

@optional
- (void)fileUploaderVerifiedTodayFolderExists: (DPBFileUploader*)uploader createdFolder: (BOOL)created;

- (void)fileUploader: (DPBFileUploader*)uploader uploadProgressChanged: (CGFloat)progress forFileName: (NSString*)name;

- (void)fileUploader: (DPBFileUploader*)uploader didUploadFileWithFileName: (NSString*)name error: (NSError*)error;

//Directory
- (void)fileUploader: (DPBFileUploader*)uploader didLoadDirectoryContentsWithMetadatas: (NSArray*)metadatas forDirectoryName: (NSString*)name error:(NSError*)error;

//Did Load File
- (void)fileUploader: (DPBFileUploader*)uploader didLoadFileWithName: (NSString*)name fileData: (NSData*)data fileURL:(NSURL*)url type: (NSString*)type error: (NSError*)error;

- (void)fileUploader: (DPBFileUploader*)uploader didDeleteFileAtPath: (NSString*)path error: (NSError*)error;


@end

