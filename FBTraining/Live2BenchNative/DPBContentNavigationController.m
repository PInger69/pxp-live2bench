//
//  DPBContentNavigationController.m
//  Live2BenchNative
//
//  Created by Si Te Feng on 8/19/14.
//  Copyright (c) 2014 DEV. All rights reserved.
//

#import "DPBContentNavigationController.h"
#import "HNBorderButton.h"
#import "DPBFileUploader.h"
#import "UIColor+RGBValues.h"
//#import "UserInterfaceConstants.h"
#import "DPBContentViewController.h"
#import "DejalActivityView.h"
#import "NSObject+LBCloudConvenience.h"
#import "SVStatusHUD.h"

#import "LBCloudFileViewController.h"


@interface DPBContentNavigationController ()

@end

@implementation DPBContentNavigationController


- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    _todayFolderVerified = NO;
    _isReloadingCurrentView = NO;
    
    self.currentPath = @"/";
    
    NSString *root = kDropboxAppRoot;
    self.session = [[DBSession alloc] initWithAppKey:kDropboxAppKey appSecret:kDropboxAppSecret root:root];
    self.session.delegate = self;
    [DBSession setSharedSession:self.session];
    
    uploader = [[DPBFileUploader alloc] initWithSession: self.session];
    uploader.delegate = self;
    
    [self changeInterfaceBasedOnLinkStatus];
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    //Add Logout bar button item
    self.contentController.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Logout" style:UIBarButtonItemStylePlain target:self action:@selector(logout)];


}


- (void)sessionDidReceiveAuthorizationFailure:(DBSession *)session userId:(NSString *)userId
{
    [SVStatusHUD showWithImage:[UIImage imageNamed:@"dopboxIconHUD"] status:@"Authorization Failed"];
}

- (void)logout
{
    [self.session unlinkAll];
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (void)showLinkButton: (BOOL)isShown
{
    if(!linkButton)
    {
//        linkButton = [[HNBorderButton alloc] initWithFrame:CGRectMake(kiPadWidthFormSheetLandscape/2 - 50, kiPadHeightFormSheetLandscape/2, 100, 44)];
//        [linkButton setTitle:@"Link Dropbox" forState:UIControlStateNormal];
//        linkButton.color = [[UIColor greenColor] darkerColor];
//        [linkButton addTarget:self action:@selector(linkButtonPressed) forControlEvents:UIControlEventTouchUpInside];
//        [self.view addSubview:linkButton];
    }
    
    if(isShown)
    {
        linkButton.hidden = NO;
    }
    else
    {
        linkButton.hidden = YES;
    }
    
}


- (void)changeInterfaceBasedOnLinkStatus
{
    if(![[DBSession sharedSession] isLinked])
    {
        [self showLinkButton: YES];
    }
    else
    {
        [self showLinkButton: NO];
        [DejalActivityView activityViewForView:self.view withLabel:@"Loading myplayXplay Dropbox"];
        [uploader loadDirectoryContentsAsyncWithPath:@"/"];
        
        if(_checkLinkStatusTimer)
        {
            [_checkLinkStatusTimer invalidate];
            _checkLinkStatusTimer = nil;
        }
    }
}


- (void)linkButtonPressed
{
    if(![[DBSession sharedSession] isLinked])
    {
        [[DBSession sharedSession] linkFromController:self];
        
        if(!_checkLinkStatusTimer)
        {
            _checkLinkStatusTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(changeInterfaceBasedOnLinkStatus) userInfo:nil repeats:YES];
        }
        
    }
    else
    {
        [[[UIAlertView alloc] initWithTitle:@"Already Linked" message:@"You are already linked to your Dropbox" delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil] show];
    }
}



#pragma mark - File Uploader Delegate

- (void)fileUploader:(DPBFileUploader *)uploader didLoadDirectoryContentsWithMetadatas:(NSArray *)metadatas forDirectoryName:(NSString *)name error:(NSError *)error
{
    [DejalActivityView removeView];
    if(error)
        return;
    
    //Loading Metadata for table view
    self.contentController.fileMetadatas = metadatas;
    
    
    //setting a new currentPath if new item is selected
    if(_isReloadingCurrentView)
    {
        _isReloadingCurrentView = NO;
        return;
    }
    
    self.currentPath = [self.currentPath stringByAppendingPathComponent:name];

}


- (void)fileUploaderVerifiedTodayFolderExists:(DPBFileUploader *)uploaderl createdFolder: (BOOL)createdFolder
{
    if(uploaderl.state == DPBFileUploaderStateUploadingFile)
    {
        _todayFolderVerified = YES;
        [self uploadTextDataToTodayFolder];
    }
    
    if(createdFolder)
    {
        _isReloadingCurrentView = YES;
        [uploader loadDirectoryContentsAsyncWithPath:self.currentPath];
    }
}


- (void)fileUploader:(DPBFileUploader *)uploader didUploadFileWithFileName:(NSString *)name error:(NSError *)error
{
    [DejalActivityView removeView];
    
    if(error)
    {
        return;
    }
    
    NSLog(@"Did Upload Successfully: %@", name);
}


- (void)fileUploader:(DPBFileUploader *)uploaderl didDeleteFileAtPath:(NSString *)path error:(NSError *)error
{
    [DejalActivityView removeView];
    
    if(error)
        return;
    
    [DejalActivityView activityViewForView:self.view withLabel:@"Reloading Folder"];
    _isReloadingCurrentView = YES;
    [uploaderl loadDirectoryContentsAsyncWithPath:self.currentPath];
}


- (void)fileUploader:(DPBFileUploader *)uploader didLoadFileWithName:(NSString *)name fileData:(NSData*)data fileURL:(NSURL*)url type:(NSString *)type error:(NSError *)error
{
    [DejalActivityView removeView];
    
    LBCloudFileViewController* fileController = [[LBCloudFileViewController alloc] initWithFileName:name data:data mimeType:[self MIMETypeWithDropboxTypeString:type]];
    fileController.fileURL = url;
    
    NSLog(@"File Type: %@\n\n", fileController.mimeType);
    
    [self pushViewController:fileController animated:YES];
}


#pragma mark - Public Methods

- (void)pushContentsOfFolderWithFolderName: (NSString*)folderName
{
    NSString* path = [self.currentPath stringByAppendingPathComponent:folderName];
    
    [DejalActivityView activityViewForView:self.view withLabel:[NSString stringWithFormat:@"Loading %@", folderName]];
    
    DPBContentViewController* contentController = [[DPBContentViewController alloc] initWithNibName:nil bundle:nil];
    
    [self pushViewController:contentController animated:YES];
    
    [uploader loadDirectoryContentsAsyncWithPath:path];
    
}



- (void)uploadTextDataToTodayFolder //Remove Any Time
{
    [DejalActivityView activityViewForView:self.view withLabel:@"Uploading Data"];
    if(!_todayFolderVerified)
    {
        uploader.state = DPBFileUploaderStateUploadingFile;
        [uploader createTodayFolderIfNeccessary];
        return;
    }
    
    uploader.state = DPBFileUploaderStateNone;
    
    [uploader uploadFileAsyncWithFileName: [NSString stringWithFormat:@"Hello There #:%d", arc4random()%392] data:[@"Hello World" dataUsingEncoding:NSUTF8StringEncoding] destPath:[self dropboxTodayFolderPath]];
    
}


- (void)deleteFileWithName:(NSString *)fileName
{
    [DejalActivityView activityViewForView:self.view withLabel:@"Deleting Item"];
    NSString* path = [self.currentPath stringByAppendingPathComponent:fileName];
    
    [uploader deletePath:path];
}


- (void)pushFileViewWithName: (NSString*)name
{
    [DejalActivityView activityViewForView:self.view withLabel:@"Loading File"];
    
    self.currentPath = [self.currentPath stringByAppendingPathComponent:name];
    
    [uploader loadFileWithPath:self.currentPath];
    
}




#pragma mark - Nav Controller Delegate

- (void)navigationBar:(UINavigationBar *)navigationBar didPopItem:(UINavigationItem *)item
{
    self.currentPath = [self.currentPath stringByDeletingLastPathComponent];
    NSLog(@"Back: %@", self.currentPath);
}



#pragma mark - Convenience

- (DPBContentViewController*)contentController
{
    DPBContentViewController* controller = (DPBContentViewController*)[self.viewControllers lastObject];
    return controller;
}


- (void)setCurrentPath:(NSString *)currentPath
{
    _currentPath = currentPath;
    
    self.contentController.title = currentPath;
    
}



#pragma mark - View Controller Life Cycle

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
    
}







@end
