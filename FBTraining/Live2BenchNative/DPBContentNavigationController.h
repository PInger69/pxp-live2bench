//
//  DPBContentNavigationController.h
//  Live2BenchNative
//
//  Created by Si Te Feng on 8/19/14.
//  Copyright (c) 2014 DEV. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <DropboxSDK/DropboxSDK.h>
#import "DPBFileUploader.h"

@class DPBFileUploader, HNBorderButton;
@interface DPBContentNavigationController : UINavigationController <DPBFileUploaderDelegate, UINavigationBarDelegate, DBSessionDelegate>
{
    DPBFileUploader*       uploader;
    
    HNBorderButton*        linkButton;
    NSTimer*     _checkLinkStatusTimer;
    
    BOOL         _todayFolderVerified;
    BOOL         _isReloadingCurrentView;
}



@property (nonatomic, strong) DBSession* session;


@property (nonatomic, strong) NSString* currentPath;


- (void)pushContentsOfFolderWithFolderName: (NSString*)folderName;

- (void)uploadTextDataToTodayFolder;

- (void)deleteFileWithName: (NSString*)fileName;
- (void)pushFileViewWithName: (NSString*)name;


@end
