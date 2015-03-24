//
//  DropboxShare.m
//  Live2BenchNative
//
//  Created by dev on 2015-03-13.
//  Copyright (c) 2015 DEV. All rights reserved.
//

#import "DropboxShare.h"
#import "DPBContentViewController.h"
#import "DPBContentNavigationController.h"
#import "UIKit/UIKit.h"
#import <DropboxSDK/DropboxSDK.h>

@interface DropboxShare ()<DBRestClientDelegate>

@property (nonatomic, strong) DBRestClient *restClient;

@end

@implementation DropboxShare

-(instancetype) init{
    self = [super init];
    if (self){
        DPBContentViewController* viewController = [[DPBContentViewController alloc] initWithNibName:nil bundle:nil];
        
        DPBContentNavigationController* navController = [[DPBContentNavigationController alloc] initWithRootViewController:viewController];
        navController.modalPresentationStyle = UIModalPresentationFormSheet;
        
       // self.viewController = navController;
        
        self.restClient = [[DBRestClient alloc] initWithSession:[DBSession sharedSession]];
        self.restClient.delegate = self;

    }
    return self;
}

-(UIImage *)icon{
    return [UIImage imageNamed:@"dropboxico.png"];
}

-(UIImage *)selectedIcon{
    return [UIImage imageNamed:@"dropboxicoSel.png"];
}



-(void)shareItems: (NSArray *) itemsToShare{
    for (NSDictionary *tagDict in itemsToShare) {
        // Write a file to the local documents directory
        NSString *localDir = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
        NSString *filename = @"somename";
        NSString *localPath = [localDir stringByAppendingPathComponent:filename];

        
        // Upload file to Dropbox
        NSString *destDir = @"/";
        [self.restClient uploadFile:filename toPath:destDir withParentRev:nil fromPath:localPath];
    }
}


- (void)restClient:(DBRestClient *)client uploadedFile:(NSString *)destPath
              from:(NSString *)srcPath metadata:(DBMetadata *)metadata {
    NSLog(@"File uploaded successfully to path: %@", metadata.path);
}

- (void)restClient:(DBRestClient *)client uploadFileFailedWithError:(NSError *)error {
    NSLog(@"File upload failed with error: %@", error);
}

-(void)linkInViewController:(UIViewController *)viewController{
    if (![[DBSession sharedSession] isLinked]) {
        [[DBSession sharedSession] linkFromController: viewController];
    }
}

@end
