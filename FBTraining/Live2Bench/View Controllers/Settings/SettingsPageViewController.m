
//
//  SettingsPageViewController.m
//  Live2BenchNative
//
//  Created by dev on 2015-02-24.
//  Copyright (c) 2015 DEV. All rights reserved.
//

#import "SettingsPageViewController.h"
#import "SettingsTableViewController.h"
#import "EncoderControlsViewController.h"
#import "AccountsViewController.h"
#import "UserCenter.h"
#import "LogoViewController.h"
#import "BitRateViewController.h"
#import "PxpLogViewController.h"
#import "CreditsViewController.h"

#import "InfoSettingViewController.h"
#import "ToastObserverSettingViewController.h"
#import "AlertsSettingViewController.h"
#import "TabsSettingViewController.h"
#import "PreferencesViewController.h"
#import "SideTagSettingsViewController.h"
#import "FeedMappingViewController.h"
#import "DropboxSettingsViewController.h"
#import "VideoRecieptTableViewController.h"

@interface SettingsPageViewController () <SettingsTableViewControllerSelectDelegate>

@property (strong, nonatomic) NSArray *defaultSettings;

@property (strong, nonatomic) NSString *settingsDirectoryPath;
@property (strong, nonatomic) NSString *settingsPlistPath;

// Setting Definition
// Setting Display Name
// - CustomViewController?
// - Identifier
@property (strong, nonatomic) NSArray *settingDefinitions;

// New Settings Structure
// Identifier
//   - Type
//   - Data
@property (strong, nonatomic) NSMutableDictionary *settingsDictionary;

@property (strong, nonatomic) UISplitViewController *splitViewController;
@property (strong, nonatomic) SettingsTableViewController *settingsTable;
@property (strong, nonatomic) NSMutableArray *settingsArray;
@property (strong, nonatomic) EncoderManager *encoderManager;
@property (strong, nonatomic) UserCenter *userCenter;
@property (strong, nonatomic) UINavigationController *googleNavigationController;

@property (strong, nonatomic) NSString *userName;



@end


NS_OPTIONS(NSInteger, style){
    toggleIsThere = 1<<0,
    toggleIsOn = 1<<1,
    listIsOn = 1<<2,
    oneButton = 1<<3,
    secondButton = 1<<4,
    customViewController = 1<<5,
    listOfToggles = 1 << 6,
    functionalButton = 1 << 7
    
};

@implementation SettingsPageViewController

-(instancetype)initWithAppDelegate:(AppDelegate *)appDel{
    self = [super initWithAppDelegate:appDel];
    if (self){
        self.encoderManager = appDel.encoderManager;
        self.userCenter = appDel.userCenter;
        [self setMainSectionTab:NSLocalizedString(@"Settings",nil)  imageName:@"settingsButton"];
        
        // Initialize Custom View Controllers
        
//        VideoRecieptTableViewController * videoRecieptTableViewController       = [[VideoRecieptTableViewController alloc]init];
        
        
        // Setting Definitions to be loaded
        //  Name: the display name of the setting
        //  ViewContoller?: a custom view controller to load when the setting is clicked
        //  Identifier?: identifier of the setting data to loaded, or passed into the view controller
        
        
        NSMutableArray * tempDefinitions = [NSMutableArray new];
        
        // just to cut down some typing
        NSDictionary * setPref = [[PxpPreference dictionary] objectForKey:@"SettingsItems"];

        if ([setPref[@"EncoderControls"] boolValue]) {
            EncoderControlsViewController *encoderControlsViewController = [[EncoderControlsViewController alloc] initWithAppDelegate:appDel];
            [tempDefinitions addObject:@{
                           @"Name": NSLocalizedString(@"Encoder Controls", nil),
                           @"ViewController": encoderControlsViewController
                           }];
        }
        if ([setPref[@"Welcome"] boolValue]) {
            LogoViewController *welcomeViewController = [[LogoViewController alloc] initWithAppDelegate:appDel];
            [tempDefinitions addObject:@{
                                           @"Name": NSLocalizedString(@"Welcome", nil),
                                           @"ViewController": welcomeViewController
                                           }];
        }
        if ([setPref[@"Preference"] boolValue]) {
            PreferencesViewController * preferencesViewController = [[PreferencesViewController alloc]initWithAppDelegate:appDel];
            [tempDefinitions addObject:@{
                                           @"Name": NSLocalizedString(@"Preferences", nil),
                                           @"ViewController": preferencesViewController
                                           }];
        }
        if ([setPref[@"BitRate"] boolValue]) {
            BitRateViewController *bitRateViewController = [[BitRateViewController alloc] initWithAppDelegate:appDel];
            [tempDefinitions addObject:@{
                                           @"Name": NSLocalizedString(@"Bit Rate", nil),
                                           @"ViewController": bitRateViewController
                                           }];
        }
        if ([setPref[@"ScreenMirroring"] boolValue]) [tempDefinitions addObject:@{
                                           @"Name": NSLocalizedString(@"Screen Mirroring", nil),
                                           @"Identifier": @"ScreenMirroring"
                                           }];
        if ([setPref[@"ToastObserver"] boolValue]) {
            ToastObserverSettingViewController *toastObserverSettingViewController = [[ToastObserverSettingViewController alloc] initWithAppDelegate:appDel];
            [tempDefinitions addObject:@{
                                       @"Name": toastObserverSettingViewController.name,
                                       @"ViewController": toastObserverSettingViewController,
                                       @"Identifier": toastObserverSettingViewController.identifier
                                       }];
        }
        if ([setPref[@"Alerts"] boolValue]) {
            AlertsSettingViewController *alertsSettingViewController = [[AlertsSettingViewController alloc] initWithAppDelegate:appDel];
            [tempDefinitions addObject:@{
                                       @"Name": alertsSettingViewController.name,
                                       @"ViewController": alertsSettingViewController,
                                       @"Identifier": alertsSettingViewController.identifier
                                       }];
        }
        if ([setPref[@"Information"] boolValue]) {
            InfoSettingViewController *informationSettingViewController = [[InfoSettingViewController alloc] initWithAppDelegate:appDel];
            [tempDefinitions addObject:@{
                                           @"Name": informationSettingViewController.name,
                                           @"ViewController": informationSettingViewController,
                                           @"Identifier": informationSettingViewController.identifier
                                           }];
        }
        if ([setPref[@"MainTabs"] boolValue]) {
            TabsSettingViewController *tabsSettingViewController = [[TabsSettingViewController alloc] initWithAppDelegate:appDel];
            
            [tempDefinitions addObject:@{
                                           @"Name": tabsSettingViewController.name,
                                           @"ViewController": tabsSettingViewController,
                                           @"Identifier": tabsSettingViewController.identifier
                                           }];
        }
        if ([setPref[@"TagSets"] boolValue]) {
            SideTagSettingsViewController * tagSetSettingViewController = [[SideTagSettingsViewController alloc] initWithAppDelegate:appDel name:@"Tag Set" identifier:@"Tag Set"];
            [tempDefinitions addObject:@{
                                           @"Name": tagSetSettingViewController.name,
                                           @"ViewController": tagSetSettingViewController,
                                           @"Identifier": tagSetSettingViewController.identifier
                                           }];
        }

        if ([setPref[@"FeedMap"] boolValue]) {
            FeedMappingViewController *feedMappingViewController = [[FeedMappingViewController alloc] initWithAppDelegate:appDel name:@"Feed Map" identifier:@"Feed Map"];
            [tempDefinitions addObject:@{
                                       @"Name": feedMappingViewController.name,
                                       @"ViewController": feedMappingViewController,
                                       @"Identifier": feedMappingViewController.identifier
                                       }];
        }
        
        
        if ([setPref[@"Dropbox"] boolValue]) {
            DropboxSettingsViewController *dropboxViewController = [[DropboxSettingsViewController alloc] initWithAppDelegate:appDel];
            
            [tempDefinitions addObject:@{
                              @"Name": dropboxViewController.name,
                              @"ViewController": dropboxViewController,
                              @"Identifier": dropboxViewController.identifier
                              }];
        }
        
        if ([setPref[@"VideoReciept"] boolValue]) {
            [tempDefinitions addObject:@{
                                          @"Name": @"Video Reciept",
                                          @"ViewController": [[VideoRecieptTableViewController alloc]init]
//                                                                 
                                          }];
        }
        
        if ([setPref[@"Credits"] boolValue]) {
            CreditsViewController *creditsViewController = [[CreditsViewController alloc] initWithAppDelegate:appDel];
            [tempDefinitions addObject:@{
                                          @"Name": creditsViewController.name,
                                          @"ViewController": creditsViewController,
                                          @"Identifier": creditsViewController.identifier
                                          }];
        }

        

        if ([setPref[@"Log"] boolValue]) {
            
            [tempDefinitions addObject:@{
                                          @"Name": NSLocalizedString(@"Log", nil),
                                          @"ViewController": [[PxpLogViewController alloc] initWithAppDelegate:appDel]
                                          }];
        }
        if ([setPref[@"Logout"] boolValue]) {
            [tempDefinitions addObject:@{
                                         @"Name": @"Logout",
                                         @"Identifier": @"Logout"
                                         }];
        }
        

        self.settingDefinitions = [tempDefinitions copy];
        self.settingsDictionary = [NSMutableDictionary dictionary];
        
        // Set default settings
        self.settingsDictionary[@"ScreenMirroring"] = @YES;
        
        // Load defaults from setting view controllers
        for (NSDictionary *settingDefinition in self.settingDefinitions) {
            if ([settingDefinition[@"ViewController"] isKindOfClass:[SettingItemViewController class]]) {
                SettingItemViewController *vc = settingDefinition[@"ViewController"];
                self.settingsDictionary[vc.identifier] = vc.settingData;
            }
        }
        
        // Begin New Settings Plist Configuration
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        
        NSString *settingsPlistName = @"Settings.plist";
        NSString *settingsDataPath = [documentsDirectory stringByAppendingPathComponent:@"/Settings"];
        NSString *settingsPlistPath = [settingsDataPath stringByAppendingPathComponent:settingsPlistName];
        
        self.settingsDirectoryPath = settingsDataPath;
        self.settingsPlistPath = settingsPlistPath;
        
        [self loadSettingsFromPlist];
        
//        PXPLog(@"Settings Loaded: \n%@\n", self.settingsDictionary);
        
        // Tell toggle observers to update their values since we loaded from the plist
        for (NSDictionary *identifier in self.settingsDictionary) {
            if ([self.settingsDictionary[identifier] isKindOfClass:[NSNumber class]]) {
                [[NSNotificationCenter defaultCenter] postNotificationName:[NSString stringWithFormat:@"Setting - %@", identifier]
                                                                    object:nil
                                                                  userInfo:@{
                                                                             @"Value": self.settingsDictionary[identifier]
                                                                             }];
            }
        }
        
        _userName = [NSString stringWithFormat:@"User :  %@", appDel.userCenter.customerEmail];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(settingRequest:) name:NOTIF_REQUEST_SETTINGS object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(saveSettings) name:UIApplicationWillTerminateNotification object:nil];
        
        self.splitViewController = [[UISplitViewController alloc] init];
        self.settingsTable = [[SettingsTableViewController alloc] initWithSettingDefinitions:self.settingDefinitions settings:self.settingsDictionary];
        self.settingsTable.dataArray = self.settingsArray;
        self.settingsTable.splitViewController = self.splitViewController;
        self.settingsTable.selectDelegate = self;
        
        [self.splitViewController setViewControllers: @[self.settingsTable, [UIViewController new]]];
        [self.splitViewController.view setFrame:CGRectMake(0, 55, self.view.frame.size.width, self.view.frame.size.height - 55)];
        [self.view addSubview: self.splitViewController.view];
        
        [self.settingsTable selectCellAtIndexPath: [NSIndexPath indexPathForRow: 0 inSection:0]];
    }
    return self;
}

- (void)loadSettingsFromPlist {
    if ([[NSFileManager defaultManager] fileExistsAtPath:self.settingsPlistPath]) {
        NSDictionary *settingsPlist = [NSDictionary dictionaryWithContentsOfFile:self.settingsPlistPath];
        
        for (NSString *identifier in settingsPlist) {
            
            if ([settingsPlist[identifier] isKindOfClass:[NSDictionary class]]
                && [self.settingsDictionary[identifier] isKindOfClass:[NSMutableDictionary class]]) {
                
                for (NSString *subIdentifier in settingsPlist[identifier]) {
                    
                    if ([settingsPlist[identifier][subIdentifier] isKindOfClass:[self.settingsDictionary[identifier][subIdentifier] class]]) {
                        self.settingsDictionary[identifier][subIdentifier] = settingsPlist[identifier][subIdentifier];
                    }
                    
                }
                
            } else if ([settingsPlist[identifier] isKindOfClass:[NSNumber class]]
                       && [self.settingsDictionary[identifier] isKindOfClass:[NSNumber class]]) {
                self.settingsDictionary[identifier] = settingsPlist[identifier];
            }
            
        }
        
    } else {
        PXPLog(@"\"Settings.plist\" does not exist!");
    }
}

#pragma mark - Notification methods

-(void)settingRequest: (NSNotification *)note{
    
    NSString *identifier = note.userInfo[@"Identifier"];
    void(^action)(id data) = note.userInfo[@"Action"];
    
    id data = [self.settingsDictionary objectForKey:identifier];
    if (action) action(data);
}

-(void)viewLicense {
    EulaModalViewController *eulaViewController=[[EulaModalViewController alloc]init];
    [self presentViewController:eulaViewController animated:YES completion:nil];
}

-(void) saveSettings{
    
    // create settings directory if it does not already exist
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:self.settingsDirectoryPath]) {
        [fileManager createDirectoryAtPath:self.settingsDirectoryPath withIntermediateDirectories:NO attributes:nil error:nil];
    }
    
    // save settings in plist
    [self.settingsDictionary writeToFile:self.settingsPlistPath atomically:NO];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    //[self saveSettings];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
    // Dispose of any resources that can be recreated.
}


#pragma mark - OnSelectNonViewController
-(void)selectedSettingDefinition:(NSDictionary*)definition
{
    if (definition[@"Name"] && [definition[@"Name"] isEqualToString:@"Logout"]) {
        [self logout];
    }
    
    
}


- (void)logout {
    BOOL hasInternet = [Utility hasInternet];
    UIAlertController * alert;
    
    if (!hasInternet || !self.encoderManager.hasMAX) {
        
        
        alert = [UIAlertController alertControllerWithTitle:alertMessageTitle
                                                    message:@"Please connect to the internet to log out."
                                             preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* cancelButtons = [UIAlertAction
                                        actionWithTitle:@"OK"
                                        style:UIAlertActionStyleCancel
                                        handler:^(UIAlertAction * action)
                                        {
                                            [[CustomAlertControllerQueue getInstance] dismissViewController:alert animated:YES completion:nil];
                                        }];
        [alert addAction:cancelButtons];
        
        
    }else{
        [[NSNotificationCenter defaultCenter] postNotificationName:@"hideSettings" object:self];
        alert = [UIAlertController alertControllerWithTitle:alertMessageTitle
                                                    message:@"If you log out, you need internet to log in. Are you sure you want to log out?"
                                             preferredStyle:UIAlertControllerStyleAlert];
        
        
        // build YES button
        UIAlertAction* yesButtons = [UIAlertAction
                                     actionWithTitle:@"Yes"
                                     style:UIAlertActionStyleDefault
                                     handler:^(UIAlertAction * action)
                                     {
                                         [[CustomAlertControllerQueue getInstance] dismissViewController:alert animated:YES completion:^{
                                             [[NSNotificationCenter defaultCenter] postNotificationName: NOTIF_LOGOUT_USER object:nil];
                                         }];
                                     }];
        [alert addAction:yesButtons];
        
        
        // build NO button
        UIAlertAction* cancelButtons = [UIAlertAction
                                        actionWithTitle:@"No"
                                        style:UIAlertActionStyleCancel
                                        handler:^(UIAlertAction * action)
                                        {
                                            [[CustomAlertControllerQueue getInstance] dismissViewController:alert animated:YES completion:nil];
                                        }];
        [alert addAction:cancelButtons];
        
    }
    
    
    
    BOOL isAllowed = [[CustomAlertControllerQueue getInstance]presentViewController:alert inController:self animated:YES style:AlertIndecisive completion:nil];
    
    if (!isAllowed) {
        [[NSNotificationCenter defaultCenter] postNotificationName: NOTIF_LOGOUT_USER object:nil];
    }
    
    
    
    
    
    
}



/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
