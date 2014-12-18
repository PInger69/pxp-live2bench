//
//  GDContentsNavigationController.m
//  Live2BenchNative
//
//  Created by Si Te Feng on 8/12/14.
//  Copyright (c) 2014 DEV. All rights reserved.
//

#import "GDContentsNavigationController.h"
#import "GDContentsViewController.h"
#import "NSString+LBConvenience.h"
#import "TRVSMonitor.h"
#import "GTLBase64.h"
#import "NSObject+LBCloudConvenience.h"
#import "GDContentsTableCell.h"
#import "DejalActivityView.h"
#import "GDFileUploader.h"
#import "SVStatusHUD.h"
#import "LBCloudFileViewController.h"


@interface GDContentsNavigationController ()

@end

//static const uint64_t kDefaultTimout = 30;

static NSString* const kGoogleKeychain = @"MyPlayXPlay";
static NSString* const kGoogleClientID = @"518117084214-eub43cgdi21uvg36rfuoj5norfac64lf.apps.googleusercontent.com";
static NSString* const kGoogleClientSecret = @"7h1YuOnofrjAesnOG1TOpj7W";

@implementation GDContentsNavigationController

#pragma mark - Initialization

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _folderFileStack = [NSMutableArray array];

    self.driveService = [[GTLServiceDrive alloc] init];
    self.driveService.authorizer = [GTMOAuth2ViewControllerTouch authForGoogleFromKeychainForName:kGoogleKeychain clientID:kGoogleClientID clientSecret:kGoogleClientSecret];
    
    uploader = [[GDFileUploader alloc] initWithDriveService:self.driveService];
    uploader.delegate = self;
    
}


- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    UIBarButtonItem* dismissButton = [[UIBarButtonItem alloc] initWithTitle:@"Dismiss" style:UIBarButtonSystemItemCancel target:self action:@selector(dismissViewController)];
    UIBarButtonItem* logoutButton = [[UIBarButtonItem alloc] initWithTitle:@"Logout" style:UIBarButtonItemStylePlain target:self action:@selector(logout)];
    
    GDContentsViewController* viewCon = [self.viewControllers objectAtIndex:0];
    viewCon.navigationItem.rightBarButtonItem = dismissButton;
    viewCon.navigationItem.leftBarButtonItem = logoutButton;
    
    viewCon.title = @"myplayXplay Google Drive Viewer";
    viewCon.fullPathString = @"~";
    
    if(![self isAuthorized])
        [self presentAuthorizationView];
    else
        [self requestMyPlayXPlayFileList];
}


- (void)presentAuthorizationView
{
    GTMOAuth2ViewControllerTouch *authController;
    authController = [[GTMOAuth2ViewControllerTouch alloc] initWithScope:kGTLAuthScopeDriveFile
                                                                clientID:kGoogleClientID
                                                            clientSecret:kGoogleClientSecret
                                                        keychainItemName:kGoogleKeychain
                                                                delegate:self
                                                        finishedSelector:@selector(viewController:finishedWithAuth:error:)];
    [self pushViewController:authController animated:YES];
}


- (void)logout
{
    [GTMOAuth2ViewControllerTouch removeAuthFromKeychainForName:kGoogleKeychain];

    self.driveService.authorizer = nil;

    [self dismissViewControllerAnimated:YES completion:nil];
}


// Completion of the authorization process
- (void)viewController:(GTMOAuth2ViewControllerTouch *)viewController
      finishedWithAuth:(GTMOAuth2Authentication *)authResult
                 error:(NSError *)error
{
    if (error != nil)
    {
        [self showAlert:@"Authentication Error" message:error.localizedDescription];
        self.driveService.authorizer = nil;
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    else
    {
        NSLog(@"Authorized to Google Drive");
        self.driveService.authorizer = authResult;
        [self.navigationController popViewControllerAnimated:YES];
        [self requestMyPlayXPlayFileList];
    }
    
}


#pragma mark - UI Table View Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    GDContentsViewController* contentsController = [[GDContentsViewController alloc] initWithNibName:nil bundle:nil];
    
    GDContentsTableCell* cell = (GDContentsTableCell*)[tableView cellForRowAtIndexPath:indexPath];
    GTLDriveFile* folderFile = cell.driveFile;
    
    [DejalActivityView activityViewForView:self.view withLabel:[NSString stringWithFormat:@"Loading: %@", folderFile.title]];
    
    if([folderFile.mimeType isMIMETypeFolder])
    {
        contentsController.title = cell.fullPathString;
        contentsController.fullPathString = cell.fullPathString;
        
        NSMutableArray* filesArray = [uploader getFileItemsWithParentFolderId:folderFile.identifier folderName:folderFile.title];
        contentsController.driveFiles = filesArray;
        
        [self pushViewController:contentsController animated:YES];
        
        [_folderFileStack addObject:[folderFile copy]];
        _currentFiles = [filesArray copy];
        
        [DejalActivityView removeView];
    }
    else
    {
        GTLDriveFile* driveFile = folderFile;
        
        [uploader downloadDriveFile:driveFile withCompletionHandler:^(NSData *data, BOOL success) {
            
            if(!success)
            {
                [SVStatusHUD showWithImage:[UIImage imageNamed:@"downloadFailedHUD"] status:@"Download Failed"];
                [DejalActivityView removeView];
                return;
            }
            
            LBCloudFileViewController* fileController = [[LBCloudFileViewController alloc] initWithFileName:driveFile.title data:data mimeType:driveFile.mimeType];
            
            [self pushViewController:fileController animated:YES];
            
            [DejalActivityView removeView];
            
        }];
    
    }
    
    
}


- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}


- (void)deleteFileAtIndexPath: (NSIndexPath*)indexPath
{
    [DejalActivityView activityViewForView:self.view withLabel:@"Deleting Item"];
    
    GTLDriveFile* file = [_currentFiles objectAtIndex:indexPath.row];
    
    [uploader deleteDriveFile:file];
}



#pragma mark - Uploader Delegate
- (void)fileUploader:(GDFileUploader *)uploader didFinishUploadingFileWithName:(NSString *)fileName isSuccessful:(BOOL)success
{
    if(!success)
    {
        [self showAlert:@"Failed to export" message:@"The File failed to export to Google Drive"];
    }
    else
    {
        [self showAlert:@"Exported Successfully" message:[NSString stringWithFormat:@"Successfully Uploaded the file <%@> to Google Drive",fileName]];
    }
    
}



- (void)fileUploader:(GDFileUploader *)uploaderl didFinishDeletingFileWithName:(NSString *)fileName isSuccessful:(BOOL)success
{
    if(!success)
        return;
    
    [DejalActivityView activityViewForView:self.view withLabel:@"Reloading Folder Files"];
    
    GTLDriveFile* folderFile = [_folderFileStack lastObject];
    _currentFiles = [uploader getFileItemsWithParentFolderId:folderFile.identifier folderName:folderFile.title];
    
    self.contentViewController.driveFiles = [_currentFiles copy];
    [self.contentViewController.tableView reloadData];
    [DejalActivityView removeView];
}




#pragma mark - Accesses To Today's Folder

- (void)requestMyPlayXPlayFileList
{
    uploader.driveService = self.driveService;
    NSString* path = @"'root'";
    
    //Loading Indicator
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    [DejalActivityView activityViewForView:self.view withLabel:@"Loading MyPlayXPlay Folder"];
    
    GTLQueryDrive* query = [GTLQueryDrive queryForFilesList];
    query.q = [NSString stringWithFormat:@"%@ in parents and trashed = false", path];
    
    [self.driveService executeQuery:query completionHandler:^(GTLServiceTicket *ticket, GTLDriveFileList* fileList, NSError *error) {
        
            if(error) {
                NSLog(@"GOOGLE QUERY ERROR: %@", error);
                [SVStatusHUD showWithImage:[UIImage imageNamed:@"wifi.png"] status:@"Unable To Connect"];
                [self dismissViewControllerAnimated:YES completion:nil];
                return;
            }
        
            _currDriveFiles = [NSMutableArray array];
            
            for(GTLDriveFile* file in fileList.items)
            {
                [_currDriveFiles addObject:file];
            }
        
        for(int i=0; i<[_currDriveFiles count]; i++)
            NSLog(@"All root Files[%d]: %@",i, [[_currDriveFiles objectAtIndex:i] title]);
        
        uploader.currDriveFiles = _currDriveFiles;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            /////////////////////////////////////
            GTLDriveFile* myPlayXPlayFile = [uploader createFoldersIfNeccessaryForCalendarUnit:0 parentIds:@[@"root"]]; //create mainFolder
            NSMutableArray* fileItems = [uploader getFileItemsWithParentFolderId: myPlayXPlayFile.identifier folderName:myPlayXPlayFile.title];
            
            ///*************************************
            if([_folderFileStack count]==0)
                [_folderFileStack addObject:[myPlayXPlayFile copy]];
            if(!_currentFiles)
                _currentFiles = [fileItems copy];
            
            GDContentsViewController* contentsController = [self.viewControllers firstObject];
            contentsController.driveFiles = fileItems;
            [contentsController reloadSubviews];
            
            [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
            [DejalActivityView removeView];
        });
    }];
}








#pragma mark - Convenience Methods

- (GDContentsViewController*)contentViewController
{
    GDContentsViewController* controller = (GDContentsViewController*)[self.viewControllers lastObject];
    return controller;
}


// Helper for showing an alert
- (void)showAlert:(NSString *)title message:(NSString *)message
{

    [SVStatusHUD showWithImage:[UIImage imageNamed:@"googleDriveIconHUD"] status:title];
}

- (BOOL)isAuthorized
{
    return [((GTMOAuth2Authentication *)self.driveService.authorizer) canAuthorize];
}



#pragma mark - Other Methods
- (void)navigationBar:(UINavigationBar *)navigationBar didPopItem:(UINavigationItem *)item
{
    [_folderFileStack removeLastObject];
    _currentFiles = [[self.contentViewController driveFiles] copy];
    
    for(GTLDriveFile* file in _currentFiles)
    {
        NSLog(@"DrFiles: %@", file.title);
    }
}


- (void)dismissViewController
{
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
