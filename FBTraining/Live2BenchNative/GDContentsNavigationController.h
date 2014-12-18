//
//  GDContentsNavigationController.h
//  Live2BenchNative
//
//  Created by Si Te Feng on 8/12/14.
//  Copyright (c) 2014 DEV. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GTMOAuth2ViewControllerTouch.h"
#import "GTLDrive.h"
#import "GDFileUploader.h"


@class TRVSMonitor, GDFileUploader, DejalActivityView;
@interface GDContentsNavigationController : UINavigationController <UITableViewDelegate, GDFileUploaderDelegate, UINavigationBarDelegate>
{
    TRVSMonitor*       monitor;
    GDFileUploader*    uploader;
    DejalActivityView* activityView;
    
    NSString*       _currDriveCreatedFolderName;
    
    NSMutableArray* _currDriveFiles; //array of GTLDriveFiles for Loading
    
    
    NSString*  _todayFolderIdentifier;
    NSMutableArray* _myPlayXPlayFiles; //GTLDriveFile

    
    NSMutableArray* _currentFiles;
   
    NSMutableArray* _folderFileStack; //GTLDriveFile array
}

@property (nonatomic, strong) GTLServiceDrive* driveService;



- (void)deleteFileAtIndexPath: (NSIndexPath*)indexPath;



@end
