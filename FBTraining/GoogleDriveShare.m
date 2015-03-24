//
//  GoogleDriveShare.m
//  Live2BenchNative
//
//  Created by dev on 2015-03-17.
//  Copyright (c) 2015 DEV. All rights reserved.
//

#import "GTLDrive.h"
#import "GTMOAuth2ViewControllerTouch.h"
#import "GoogleDriveShare.h"

@interface GoogleDriveShare()

@property (nonatomic, strong) GTLServiceDrive *driveService;
@property (nonatomic, strong) GTMOAuth2ViewControllerTouch *authenticationViewController;
@property (nonatomic, strong) UINavigationController *navigationController;

@end

static NSString *const kKeychainItemName = @"iOSDriveSample: Google Drive";
static NSString *const kClientId = @"52573695379-quihf24hkhl85airhcncc7mpb9fq7caa.apps.googleusercontent.com";
static NSString *const kClientSecret = @"8KBtj-7KpMnnCtNDkrGGP0UD";


@implementation GoogleDriveShare



-(instancetype)init{
    self = [super init];
    if(self){
        self.driveService = [[GTLServiceDrive alloc] init];
        self.driveService.authorizer = [GTMOAuth2ViewControllerTouch authForGoogleFromKeychainForName: kKeychainItemName
                                    clientID: kClientId
                                clientSecret: kClientSecret];
        SEL finishedSelector = @selector(viewController:finishedWithAuth:error:);

        self.authenticationViewController =
                [[GTMOAuth2ViewControllerTouch alloc] initWithScope:kGTLAuthScopeDriveFile
                                                           clientID:kClientId
                                                       clientSecret:kClientSecret
                                                   keychainItemName:kKeychainItemName
                                                           delegate:self
                                                   finishedSelector:finishedSelector];

    }
    return self;
}

-(UIImage *)icon{
    return [UIImage imageNamed:@"arrowButton.png"];
}

-(UIImage *)selectedIcon{
    return [UIImage imageNamed:@"dropboxicoSel.png"];
}

-(void)shareItems: (NSArray *) itemsToShare inViewController: (UIViewController *) viewController{
    if(self.isLoggedIn){
        for (NSDictionary *itemToShare in itemsToShare) {
            NSString *filePath = itemToShare[@"mp4"];
            NSData *videoData = [NSData dataWithContentsOfFile: filePath];
            [self uploadData: videoData];
        }
    }else{
        NSLog(@"This person is not signed in");
    }
}

- (void)uploadData:(NSData *) videoData
{
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"'myplayXplay Uploaded File ('EEEE MMMM d, YYYY h:mm a, zzz')"];
    
    GTLDriveFile *file = [GTLDriveFile object];
    file.title = [dateFormat stringFromDate:[NSDate date]];
    file.descriptionProperty = @"Uploaded from the myplayXplay";
    file.mimeType = @"video/mp4";
    
    //NSData *data = UIImagePNGRepresentation((UIImage *)image);
    GTLUploadParameters *uploadParameters = [GTLUploadParameters uploadParametersWithData:videoData MIMEType:file.mimeType];
    GTLQueryDrive *query = [GTLQueryDrive queryForFilesInsertWithObject:file
                                                       uploadParameters:uploadParameters];
    
    //UIAlertView *waitIndicator = [self showWaitIndicator:@"Uploading to Google Drive"];
    
    [self.driveService executeQuery:query
                  completionHandler:^(GTLServiceTicket *ticket,
                                      GTLDriveFile *insertedFile, NSError *error) {
                      //[waitIndicator dismissWithClickedButtonIndex:0 animated:YES];
                      if (error == nil)
                      {
                          NSLog(@"File ID: %@", insertedFile.identifier);
                          NSLog(@"FileSaved!");
                          //[self showAlert:@"Google Drive" message:@"File saved!"];
                      }
                      else
                      {
                          NSLog(@"An error occurred: %@", error);
                          //[self showAlert:@"Google Drive" message:@"Sorry, an error occurred!"];
                      }
                  }];
}

-(void)linkInViewController:(UIViewController *)viewController{
    if (!self.navigationController) {
  
        self.authenticationViewController.view.autoresizingMask = UIViewAutoresizingNone;
        UINavigationController *navController = [[UINavigationController alloc]initWithRootViewController: self.authenticationViewController];
        
        [navController.view setFrame:CGRectMake(212, 768, 600, 650)];
        [navController.view.layer setBorderColor: [UIColor lightGrayColor].CGColor];
        [navController.view.layer setBorderWidth:1.0];
        [viewController.view addSubview: navController.view];
        
        UIBarButtonItem *cancelButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(googleNavigationButton:)];
        self.authenticationViewController.navigationItem.leftBarButtonItem = cancelButtonItem;
        
        [UIView animateWithDuration: 0.5  animations:^{
            [navController.view setFrame:CGRectMake(212, 59, 600, 650)];
        }];
        
        self.navigationController = navController;
    }

}

- (void)viewController:(GTMOAuth2ViewControllerTouch *)viewController
      finishedWithAuth:(GTMOAuth2Authentication *)authResult
                 error:(NSError *)error
{
    if (error != nil)
    {
        // Auth failed, handle the error
    }
    else
    {
        // Auth successful
        self.driveService.authorizer = authResult;
        self.isLoggedIn = YES;
    }
}

-(void)googleNavigationButton: (UIBarButtonItem *) sender{
    [UIView animateWithDuration: 0.5  animations:^{
        [self.navigationController.view setFrame:CGRectMake(212, 768, 600, 650)];
    } completion:^(BOOL finished) {
        [self.navigationController.view removeFromSuperview];
        self.navigationController = nil;
    }];
    
}

@end
