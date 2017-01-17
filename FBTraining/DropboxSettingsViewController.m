
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
@property (nonatomic,strong) UILabel * labelUser;
@property (nonatomic,strong) UIButton * button;

@end


@implementation DropboxSettingsViewController
- (instancetype)initWithAppDelegate:(nonnull AppDelegate *)appDel {
    return [super initWithAppDelegate:appDel name:NSLocalizedString(@"Dropbox", nil) identifier:@"Dropbox"];
}


-(void)viewDidLoad
{
    
/*
    UIButton *(^makeButton)(NSString*,CGRect,SEL) = ^UIButton*(NSString*title,CGRect rect,SEL selector) {
        UIButton * btn = [[UIButton alloc]initWithFrame:rect];
        [btn setTitle:title forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [btn addTarget:self action:selector forControlEvents:UIControlEventTouchUpInside];
        btn.layer.borderWidth = 1;
        return btn;
    };
*/
    
    self.button = [[UIButton alloc]initWithFrame:CGRectMake(400, 50+40, 100, 30)];
    
    [self.button setTitle:@"Link" forState:UIControlStateNormal];
    [self.button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.button addTarget:self action:@selector(onLink:) forControlEvents:UIControlEventTouchUpInside];
    self.button.layer.borderWidth = 1;
    [self.view addSubview:self.button];
    
    
    
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    self.label = [[UILabel alloc]initWithFrame:CGRectMake(50, 50, 300, 30)];
    [self.label setText:@"Dropbox Linked to user:"];
    [self.view addSubview:self.label];
    
    
    self.labelUser = [[UILabel alloc]initWithFrame:CGRectMake(50, 50+40, 300, 30)];
    [self.labelUser setText:@"<no linked user>"];
    [self.view addSubview:self.labelUser];

    
    
    
    [super viewDidLoad];
    
    
    [[DropboxManager getInstance]connect];
    
    // check dropbox status
//    if ([[DBSession sharedSession] isLinked]) {
    
        [[DropboxManager getInstance].restClient loadAccountInfo];
//    }
    
    
    
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if ([[DBSession sharedSession] isLinked]) {
        
        [[DropboxManager getInstance].restClient loadAccountInfo];
    }
    if ([[DBSession sharedSession] isLinked]) {
        [self.button setTitle:@"Unlink" forState:UIControlStateNormal];

        [[DropboxManager getInstance] setOnUserConnected:^(NSString * userName) {
            self.labelUser.text = userName;
        }];

    } else {

        self.labelUser.text = @"<no linked user>";
        
        [self.button setTitle:@"Link" forState:UIControlStateNormal];
        
    }
    

}



-(void)onLink:(id)sender
{
    
    UIButton * button = (UIButton *) sender;
    
    
    
    if ([button.titleLabel.text isEqualToString:@"Link"]) {
           [[DropboxManager getInstance]connect];
        [[DBSession sharedSession] linkFromController:self];
        [button setTitle:@"Unlink" forState:UIControlStateNormal];
        [[DropboxManager getInstance].restClient loadAccountInfo];
        [[DropboxManager getInstance] setOnUserConnected:^(NSString * userName) {
            self.labelUser.text = userName;
            
        }];
    } else {
        [[DBSession sharedSession] unlinkAll];
        [DropboxManager getInstance].linkedUserName = nil;
        [button setTitle:@"Link" forState:UIControlStateNormal];
        self.labelUser.text = @"<no linked user>";
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
        [DropboxManager getInstance].linkedUserName = nil;
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
