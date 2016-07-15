
//
//  DropboxSettingsViewController.m
//  Live2BenchNative
//
//  Created by dev on 2016-07-12.
//  Copyright © 2016 DEV. All rights reserved.
//

#import "DropboxSettingsViewController.h"
#import "DropboxManager.h"
#import "DropboxUploadOperation.h"

@interface DropboxSettingsViewController ()
@property (nonatomic,strong) UILabel * label;

@end


@implementation DropboxSettingsViewController
- (instancetype)initWithAppDelegate:(nonnull AppDelegate *)appDel {
    return [super initWithAppDelegate:appDel name:NSLocalizedString(@"Dropbox", nil) identifier:@"Dropbox"];
}


-(void)viewDidLoad
{
    
    
    UIButton *(^makeButton)(NSString*,CGRect,SEL) = ^UIButton*(NSString*title,CGRect rect,SEL selector) {
        UIButton * btn = [[UIButton alloc]initWithFrame:rect];
        [btn setTitle:title forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [btn addTarget:self action:selector forControlEvents:UIControlEventTouchUpInside];
        btn.layer.borderWidth = 1;
        return btn;
    };
    
    
    UIButton * button = [[UIButton alloc]initWithFrame:CGRectMake(100, 100, 100, 100)];
    
    [button setTitle:@"Link" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(onLink:) forControlEvents:UIControlEventTouchUpInside];
    button.layer.borderWidth = 1;
    [self.view addSubview:button];
    
    
    
    UIButton * button1 = [[UIButton alloc]initWithFrame:CGRectMake(300, 100, 100, 100)];
    
    [button1 setTitle:@"make folder" forState:UIControlStateNormal];
    [button1 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [button1 addTarget:self action:@selector(onMakeFolder) forControlEvents:UIControlEventTouchUpInside];
    button1.layer.borderWidth = 1;
    [self.view addSubview:button1];
    
    
    
    
    
    [self.view addSubview:makeButton(@"Logout",CGRectMake(300, 400, 100, 100),@selector(onLogoutDropbox:))];
    
    
     [self.view addSubview:makeButton(@"Upload",CGRectMake(100, 400, 100, 100),@selector(onUpload))];
    
    
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    self.label = [[UILabel alloc]initWithFrame:CGRectMake(100, 200, 100, 100)];
    [self.label setText:@"test"];
    [self.view addSubview:self.label];
    [super viewDidLoad];
}




-(void)onLink:(id)sender
{
 
    
    if (![[DBSession sharedSession] isLinked]) {
           [[DropboxManager getInstance]connect];
        [[DBSession sharedSession] linkFromController:self];
    }
    

}


-(void)onMakeFolder
{
    if([[DropboxManager getInstance].session isLinked]){
        [[DropboxManager getInstance].restClient createFolder:@"/Live2BenchNative/"]; // make the folder if its not thay
    }
}


//logout of dropbox
- (void)onLogoutDropbox:(id)sender
{
    if ([[DBSession sharedSession] isLinked]) {
        [[DBSession sharedSession] unlinkAll];
    }
    
}

-(void)onUpload
{
    [[DropboxManager getInstance].queue cancelAllOperations];
    
    NSString *fileName = [NSString stringWithFormat:@"testVideo.mp4"];
    NSString *fromFileName = [NSString stringWithFormat:@"%@/bookmark/bookmarkvideo/2016-06-24_11-46-11_83ead9fe9b44bee8b98ad76b2e4b23513ec1dce5_local_vid_17+00hq.mp4",[UserCenter getInstance].localPath];
    
    
    DropboxUploadOperation * op = [[DropboxUploadOperation alloc]initUploadFile:fileName toPath:@"/Live2BenchNative/" withParentRev:nil fromPath:fromFileName];
    [op setCompletionBlock:^{
        NSLog(@"test");
    }];
    op.restClient = [[DBRestClient alloc] initWithSession:[DBSession sharedSession]];
    
    [[DropboxManager getInstance].queue addOperation:op];
    
}

@end
