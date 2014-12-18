//
//  GDFileUploader.m
//  Live2BenchNative
//
//  Created by Si Te Feng on 8/14/14.
//  Copyright (c) 2014 DEV. All rights reserved.
//

#import "GDFileUploader.h"
#import "TRVSMonitor.h"
#import "NSObject+LBCloudConvenience.h"
#import "NSString+LBConvenience.h"
#import "SVStatusHUD.h"


static NSString* const kGoogleKeychain = @"MyPlayXPlay";
static NSString* const kGoogleClientID = @"518117084214-eub43cgdi21uvg36rfuoj5norfac64lf.apps.googleusercontent.com";
static NSString* const kGoogleClientSecret = @"7h1YuOnofrjAesnOG1TOpj7W";

@implementation GDFileUploader


+ (instancetype)instance
{
    static GDFileUploader* _instance = nil;
    @synchronized(self)
    {
        if(_instance == nil)
            _instance = [[GDFileUploader alloc] initWithDriveService:nil];
    }
    
    return _instance;
}


- (instancetype)initWithDriveService: (GTLServiceDrive*)driveService
{
    self = [super initWithNibName:nil bundle:nil];
    
    if(!driveService)
    {
        self.driveService = [[GTLServiceDrive alloc] init];
        self.driveService.authorizer = [GTMOAuth2ViewControllerTouch authForGoogleFromKeychainForName:kGoogleKeychain clientID:kGoogleClientID clientSecret:kGoogleClientSecret];
    }
    else {
        self.driveService = driveService;
    }
    

    [self resetVariables];
    
    return self;
}


#pragma mark - Accesses To Today's Folder

//Create folders necessary and add files to today folder
- (void)uploadFileWithName: (NSString*)fileName data: (NSData*)data MIMEType: (NSString*)mimeType
{

    self.fileName = fileName;
    self.fileData = data;
    self.mimeType = mimeType;
    
    if(![self isAuthorized])
    {
        [self presentAuthorizationView];
        return;
    }
    
    NSString* path = @"'root'";
    
    GTLQueryDrive* query = [GTLQueryDrive queryForFilesList];
    query.q = [NSString stringWithFormat:@"%@ in parents and trashed = false", path];
    
    [self.driveService executeQuery:query completionHandler:^(GTLServiceTicket *ticket, GTLDriveFileList* fileList, NSError *error) {
        
        if(error) {
            uploadSuccess = NO;
            NSLog(@"GOOGLE QUERY ERROR: %@", error);
            [self uploadFinished];
            return;
        }
            
        _currDriveFiles = [NSMutableArray array];
        
        for(GTLDriveFile* file in fileList.items)
        {
            [_currDriveFiles addObject:file];
        }
        
        for(int i=0; i<[_currDriveFiles count]; i++)
            NSLog(@"All root Files[%d]: %@",i, [[_currDriveFiles objectAtIndex:i] title]);
        
        ///////////
        dispatch_async(dispatch_get_main_queue(), ^{
            /////////////////////////////////////
            GTLDriveFile* myPlayXPlayFile = [self createFoldersIfNeccessaryForCalendarUnit:0 parentIds:@[@"root"]]; //create mainFolder
            [self getFileItemsWithParentFolderId: myPlayXPlayFile.identifier folderName:myPlayXPlayFile.title];
            //////////////////////////////////////
            //Assuming to find the current year folder inside _currDriveFiles
            GTLDriveFile* yearFile = [self createFoldersIfNeccessaryForCalendarUnit:NSCalendarUnitYear parentIds:@[[NSString stringWithFormat:@"%@", myPlayXPlayFile.identifier]]];
            [self getFileItemsWithParentFolderId:yearFile.identifier folderName:yearFile.title];
            
            /////////////////////////
            GTLDriveFile* monthFile = [self createFoldersIfNeccessaryForCalendarUnit:NSCalendarUnitMonth parentIds:@[[NSString stringWithFormat:@"%@", yearFile.identifier]]];
            [self getFileItemsWithParentFolderId:monthFile.identifier folderName:monthFile.title];
            
            ////
            GTLDriveFile* dayFile = [self createFoldersIfNeccessaryForCalendarUnit:NSCalendarUnitDay parentIds:@[[NSString stringWithFormat:@"%@", monthFile.identifier]]];
            [self getFileItemsWithParentFolderId:dayFile.identifier folderName:monthFile.title];
            
            ///*************************************
            
            //Store Data Into day folder
            [self saveFileToTodayFolderWithName:fileName data:data mimeType:mimeType];
            
            
        });
    }];
    
}



- (void)saveFileToTodayFolderWithName:(NSString*)fileName data:(NSData*)data mimeType:(NSString*)mimeType
{
    GTLDriveFile* file = [GTLDriveFile object];
    file.mimeType = mimeType;
    file.title = fileName;
    file.thumbnail = [self GTLThumbnailWithMIMEType:mimeType];
    
    GTLDriveParentReference* parentRef = [[GTLDriveParentReference alloc] init];
    parentRef.identifier = _todayFolderIdentifier;
    file.parents = @[parentRef];
    
    GTLUploadParameters* params = [GTLUploadParameters uploadParametersWithData:data MIMEType:mimeType];
    GTLQueryDrive* saveQuery = [GTLQueryDrive queryForFilesInsertWithObject:file uploadParameters:params];
    
    [self.driveService executeQuery:saveQuery completionHandler:^(GTLServiceTicket *ticket, GTLDriveFile* savedFile, NSError *error) {
        if(error)
        {
            NSLog(@"Google Drive: Error while saving File");
            uploadSuccess = NO;
            
        }
        else
        {
            [self.uploadedGTLFiles addObject:savedFile];
            NSLog(@"Save File Successful- [%@]", savedFile.title);
        }
        
        [self uploadFinished];
        
    }];
    
}



- (void)deleteDriveFile: (GTLDriveFile*)file
{
    
    GTLQueryDrive* deleteQuery = [GTLQueryDrive queryForFilesDeleteWithFileId:file.identifier];
    
    [self.driveService executeQuery:deleteQuery
                  completionHandler:^(GTLServiceTicket *ticket, id object, NSError *error) {
                      
                      if(error)
                      {
                          [self.delegate fileUploader:self didFinishDeletingFileWithName:file.title isSuccessful:YES];
                      }
                      else
                      {
                          [self.delegate fileUploader:self didFinishDeletingFileWithName:file.title isSuccessful:YES];
                      }
                  }];
    
    
}


- (void)downloadDriveFile: (GTLDriveFile*)file withCompletionHandler: (void (^)(NSData* data, BOOL success))handler
{
    GTMHTTPFetcher* fetcher = [self.driveService.fetcherService fetcherWithURLString:file.downloadUrl];
    
    [fetcher beginFetchWithCompletionHandler:^(NSData *data, NSError *error) {
       
        if(error)
        {
            NSLog(@"Error: %@", error.localizedDescription);
        }
        
        handler(data, !error);
        
    }];
    
    
}





#pragma mark - Ensure Today's Folder Exists

//also Put Results in _currDriveFiles
- (NSMutableArray*)getFileItemsWithParentFolderId: (NSString*)folderId folderName: (NSString*)folderName
{
    GTLQueryDrive* query = [GTLQueryDrive queryForFilesList];
    query.q = [NSString stringWithFormat:@"'%@' in parents and trashed = false", folderId];
    
    monitor = [[TRVSMonitor alloc] initWithExpectedSignalCount:1];
    
    [self.driveService executeQuery:query completionHandler:^(GTLServiceTicket *ticket, GTLDriveFileList* fileList, NSError *error) {
        if(error)
        {
            NSLog(@"Cannot Get Files in Folder: %@", folderName);
            uploadSuccess = NO;
            return;
        }
        
        NSArray* driveFiles = fileList.items;
        _currDriveFiles = [driveFiles mutableCopy];
        
        [monitor signal];
    }];
    
    [monitor wait];
    
    return _currDriveFiles;
}


//returns folder GTLDriveFile
- (GTLDriveFile*)createFoldersIfNeccessaryForCalendarUnit: (NSInteger)unit parentIds: (NSArray*)parentIds
{
    NSString* year = [self cloudDriveFolderNameWithTodaysDateWithCalendarUnit:NSCalendarUnitYear];
    NSString* month = [self cloudDriveFolderNameWithTodaysDateWithCalendarUnit:NSCalendarUnitMonth];
    NSString* day = [self cloudDriveFolderNameWithTodaysDateWithCalendarUnit:NSCalendarUnitDay];
    
    NSString* folderName = @"";
    NSMutableArray* folderParents = [NSMutableArray array];
    
    if(unit == 0)
        folderName = @"MyPlayXPlay";
    else {
        if(unit == NSCalendarUnitYear)
            folderName = year;
        else if(unit == NSCalendarUnitMonth)
            folderName = month;
        else if(unit == NSCalendarUnitDay)
            folderName = day;
    }
    
    for(NSString* parentId in parentIds)
    {
        GTLDriveParentReference* parent = [[GTLDriveParentReference alloc] init];
        parent.identifier = parentId;
        [folderParents addObject:parent];
    }
    
    
    BOOL folderWasCreated = NO;
    __block NSString* newFolderIdentifier = @"";
    __block GTLDriveFile* newDriveFile = nil;
    
    //check if folder has been created for today
    for(GTLDriveFile* file in _currDriveFiles)
    {
        if([file.title isEqual:folderName])
        {
            folderWasCreated = YES;
            newFolderIdentifier = file.identifier;
            newDriveFile = file;
        }
    }
    
    if(!folderWasCreated)
    {
        GTLDriveFile* folder = [[GTLDriveFile alloc] init];
        folder.title = folderName;
        folder.mimeType = @"application/vnd.google-apps.folder";
        
        folder.parents = folderParents;
        
        GTLQueryDrive* createFolder = [GTLQueryDrive queryForFilesInsertWithObject:folder uploadParameters:nil];
        
        monitor = [[TRVSMonitor alloc] initWithExpectedSignalCount:1];
        [self.driveService executeQuery:createFolder completionHandler:^(GTLServiceTicket *ticket, GTLDriveFile* savedFile, NSError *error) {
            if(error)
            {
                NSLog(@"Creating folder failed: %@", error.localizedDescription);
                uploadSuccess = NO;
                return;
            }
            
            newFolderIdentifier = savedFile.identifier;
            newDriveFile = savedFile;
            
            [monitor signal];
        }];
        
        [monitor wait];
    }

    
    if(unit== NSCalendarUnitDay)
        _todayFolderIdentifier = [newFolderIdentifier copy];
    
    return newDriveFile;
}





#pragma mark - Helper Methods

- (void)uploadFinished
{
    currentFileNumber++;
    
    [SVStatusHUD showWithImage:[UIImage imageNamed:@"googleDriveIconHUD"] status: [NSString stringWithFormat:@"Uploaded (%d/%d)", currentFileNumber, self.exepectedFileNumber] duration:1];
    
    [self.delegate fileUploader:self didFinishUploadingFileWithName:self.fileName isSuccessful:uploadSuccess];
    
    if(currentFileNumber >= self.exepectedFileNumber)
    {
        if(!uploadSuccess)
        {
            [SVStatusHUD showWithImage:[UIImage imageNamed:@"googleDriveIconHUD"] status:@"Upload Failed" duration:2];
        } else {
            [SVStatusHUD showWithImage:[UIImage imageNamed:@"googleDriveIconHUD"] status:@"Upload Successful" duration:2];
        }
        
        [self resetVariables];
    }
    
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

    [self presentViewController:authController animated:YES completion:nil];
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
        [self uploadFileWithName:self.fileName data:self.fileData MIMEType:self.mimeType];
    }
    
}


- (void)resetVariables
{
    currentFileNumber = 0;
    self.exepectedFileNumber = 1;
    self.uploadedGTLFiles = [@[] mutableCopy];
    uploadSuccess = YES;
}



// Helper for showing an alert
- (void)showAlert:(NSString *)title message:(NSString *)message
{
    UIAlertView *alert;
    alert = [[UIAlertView alloc] initWithTitle: title
                                       message: message
                                      delegate: nil
                             cancelButtonTitle: @"OK"
                             otherButtonTitles: nil];
    [alert show];
}



// Helper to check if user is authorized
- (BOOL)isAuthorized
{
    return [((GTMOAuth2Authentication *)self.driveService.authorizer) canAuthorize];
}


- (void)logout
{
    [GTMOAuth2ViewControllerTouch removeAuthFromKeychainForName:kGoogleKeychain];
    self.driveService.authorizer = nil;
}



@end
