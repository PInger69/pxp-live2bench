//
//  LogoViewController.h
//  Live2BenchNative
//
//  Created by dev on 13-02-17.
//  Copyright (c) 2013 DEV. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomTabViewController.h"
#import "EulaModalViewController.h"
#import "SettingsViewController.h"
#import "IconButton.h"
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>

@class EulaModalViewController;
@class SettingsViewController;

@interface LogoViewController : CustomTabViewController<MFMailComposeViewControllerDelegate,UIGestureRecognizerDelegate,UITabBarDelegate>{
    
    NSArray *paths;
    NSString *documentsDirectory;
    NSFileManager *fileManager;
    NSString *handleLogoPagePath;
    EulaModalViewController *eulaModalViewController;
    SettingsViewController  *settingsViewController;
    MFMailComposeViewController *mailController;
    
    UIBarButtonItem *hardwareTab;
    UIBarButtonItem *taggingTab;
    UIBarButtonItem *contactTab;
    UIBarButtonItem *settingsTab;
    UIBarButtonItem *googleDriveTab;
    UIBarButtonItem *dropboxTab;
}
@property(nonatomic,strong) MFMailComposeViewController *mailController;
@property(nonatomic,strong) UITapGestureRecognizer *tapBehindGesture;


-(void)hideSettings;

@end
