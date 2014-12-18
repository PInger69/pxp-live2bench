//
//  GDFileUploader.h
//  Live2BenchNative
//
//  Created by Si Te Feng on 8/14/14.
//  Copyright (c) 2014 DEV. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GTLDrive.h"
#import "GTMOAuth2ViewControllerTouch.h"
#import "NSObject+LBCloudConvenience.h"

@protocol GDFileUploaderDelegate;
@class TRVSMonitor;
@interface GDFileUploader : UIViewController
{
    TRVSMonitor*     monitor;
    
    NSString*         _todayFolderIdentifier;
    
    BOOL uploadSuccess;
    NSInteger currentFileNumber;
}


@property (nonatomic, strong) GTLServiceDrive* driveService;
@property (nonatomic, strong) NSMutableArray* currDriveFiles;

@property (nonatomic, strong) NSString* fileName;
@property (nonatomic, strong) NSData* fileData;
@property (nonatomic, strong) NSString* mimeType;

@property (nonatomic, assign) NSInteger exepectedFileNumber;

@property (nonatomic, strong) NSMutableArray* uploadedGTLFiles;


@property (nonatomic, weak) id<GDFileUploaderDelegate> delegate;

+ (instancetype)instance;

- (instancetype)initWithDriveService: (GTLServiceDrive*)driveService;
- (BOOL)isAuthorized;

- (void)uploadFileWithName: (NSString*)fileName data: (NSData*)data MIMEType: (NSString*)mimeType;

- (void)deleteDriveFile: (GTLDriveFile*)file;

- (void)downloadDriveFile: (GTLDriveFile*)file withCompletionHandler: (void (^)(NSData* data, BOOL success))handler;

//Saving Files
- (void)saveFileToTodayFolderWithName:(NSString*)fileName data:(NSData*)data mimeType:(NSString*)mimeType;


- (NSMutableArray*)getFileItemsWithParentFolderId: (NSString*)folderId folderName: (NSString*)folderName;

- (GTLDriveFile*)createFoldersIfNeccessaryForCalendarUnit: (NSInteger)unit parentIds: (NSArray*)parentIds;


@end


@protocol GDFileUploaderDelegate <NSObject>

- (void)fileUploader: (GDFileUploader*)uploader didFinishUploadingFileWithName: (NSString*)fileName isSuccessful: (BOOL)success;

- (void)fileUploader: (GDFileUploader*)uploader didFinishDeletingFileWithName: (NSString*)fileName isSuccessful: (BOOL)success;


@end

