//
//  SettingsPageViewController.m
//  Live2BenchNative
//
//  Created by dev on 2015-02-24.
//  Copyright (c) 2015 DEV. All rights reserved.
//

#import "SettingsPageViewController.h"
#import "SettingsTableViewController.h"
#import "DetailViewController.h"
#import "SettingsViewController.h"
#import "AccountsViewController.h"
#import "infoViewController.h"
#import "UserCenter.h"
#import "EncoderManager.h"

@interface SettingsPageViewController ()

@property (strong, nonatomic) UISplitViewController *splitViewController;
@property (strong, nonatomic) SettingsTableViewController *settingsTable;
@property (strong, nonatomic) DetailViewController *detailViewController;
@property (strong, nonatomic) NSArray *settingsArray;
@property (strong, nonatomic) EncoderManager *encoderManager;
@property (strong, nonatomic) UserCenter *userCenter;

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
        self.settingsArray =@[ @{@"SettingLabel": @"Encoder Controls" , @"OptionChar" :[NSNumber numberWithChar:customViewController], @"CustomViewController" : [[SettingsViewController alloc]initWithAppDelegate:appDel]},
                               
                               @{ @"SettingLabel" : @"Something On or Off", @"OptionChar": [NSNumber numberWithChar:toggleIsThere|toggleIsOn]},
                               
//                               @{ @"SettingLabel" : @"An Unplausible Setting", @"OptionChar":  [NSNumber numberWithChar:oneButton] },
                               
                               @{ @"SettingLabel" : @"Social Media", @"OptionChar":  [NSNumber numberWithChar:oneButton | secondButton] },
                               
//                               @{ @"SettingLabel" : @"Another Toggle", @"OptionChar":  [NSNumber numberWithChar:toggleIsThere] },
                               
                               @{ @"SettingLabel" : @"Languages", @"OptionChar":  [NSNumber numberWithChar:listIsOn] , @"DataDictionary": [NSMutableDictionary dictionaryWithDictionary: @{@"Setting Options":
                                                                                                                                                                                               @[@"English", @"French", @"Mandarin", @"Italian", @"Korean", @"Hindi", @"Russian", @"Japanese"], @"Index":
                                                                                                                                                                                               [NSNumber numberWithInt:5]} ] },
                               
                               @{ @"SettingLabel" : @"Colors", @"OptionChar":  [NSNumber numberWithChar:listIsOn] , @"DataDictionary": [NSMutableDictionary dictionaryWithDictionary: @{@"Setting Options":
                                                                                                                                                                                               @[@"blue", @"red", @"yellow"], @"Index": [NSNumber numberWithInt:1]} ] },
                                                                                                                                        
                                @{ @"SettingLabel" : @"Toast Observer", @"OptionChar":  [NSNumber numberWithChar: toggleIsThere | toggleIsOn] },
                                   
                                   
//                                @{@"SettingLabel": @"Accounts" , @"OptionChar" :[NSNumber numberWithChar:customViewController], @"CustomViewController" : [[AccountsViewController alloc]init]},
//                                
//                               @{@"SettingLabel": @"Information" , @"OptionChar" :[NSNumber numberWithChar:customViewController], @"CustomViewController" : [[infoViewController alloc]initWithAppDelegate:appDel]},
                               
                                @{ @"SettingLabel" : @"Alerts", @"OptionChar":  [NSNumber numberWithChar:listIsOn] , @"DataDictionary": [NSMutableDictionary dictionaryWithDictionary: @{       @"Setting Options":
                                                                                                                                                                                             @[@"Some Alert", @"Another Alert", @"Mandarin Alert", @"Italian Alert", @"Korean Alert", @"Hindi Alert", @"Russian", @"Japanese"],
                                                                                                                                                                                                @"Toggle Settings":
                                                                                                                                                                                                    @[ @1, @0, @1, @0, @1, @0, @1, @1]}] },
                               
                               @{ @"SettingLabel" : @"Information", @"OptionChar":  [NSNumber numberWithChar:listIsOn] , @"DataDictionary": [NSMutableDictionary dictionaryWithDictionary: @{       @"Setting Options":
                                                                                                                                                                                                        @[@"App Version :", @"System Version :", [NSString stringWithFormat:@"User :  %@", appDel.userCenter.customerEmail], @"WIFI Connection :", @"Eula :"],
                                                                                                                                                                                                    @"Function Buttons":
                                                                                                                                                                                                        @[ @0, @0, @1, @0, @1]
                                                                                                                                                                                                    , @"Function Labels": @[[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"], [UIDevice currentDevice].systemVersion, @"Logout",[Utility myWifiName], @"View"] }]},
                               
                               @{ @"SettingLabel" : @"Acounts", @"OptionChar":  [NSNumber numberWithChar:listIsOn] , @"DataDictionary": [NSMutableDictionary dictionaryWithDictionary: @{       @"Setting Options":
                                                                                                                                                                                                    @[@"Dropbox", @"Facebook", @"GoogleDrive"],
                                                                                                                                                                                                @"Function Buttons":
                                                                                                                                                                                                    @[ @1, @1, @1], @"Function Labels": @[@"Link", @"Link", @"Link"] }]}


                                   ];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(viewLicense:) name:@"Setting - Eula :" object:nil];
        NSString *userName = [NSString stringWithFormat:@"Setting - User :  %@", appDel.userCenter.customerEmail];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appLogout:) name:userName object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appLogoutCompleted:) name:NOTIF_USER_LOGGED_OUT object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appLoginCompleted:) name: NOTIF_CREDENTIALS_VERIFY_RESULT object:nil];
    }
    return self;
}

#pragma mark - Notification methods

-(void)viewLicense:(NSNotification *)note {
    EulaModalViewController *eulaViewController=[[EulaModalViewController   alloc]init];
    [self presentViewController:eulaViewController animated:YES completion:nil];
}

-(void)appLogoutCompleted: (NSNotification *) note{
    
}

-(void)appLoginCompleted: (NSNotification *) note{
    for (NSDictionary *eachSetting in self.settingsArray) {
        if([eachSetting[@"SettingLabel"] isEqualToString:@"Information"]){
            NSMutableDictionary *dataDictionary = (NSMutableDictionary *)eachSetting[@"DataDictionary" ];
            NSMutableArray *settingLabels = [NSMutableArray arrayWithArray:dataDictionary[@"Setting Options"]];
            settingLabels[2] = [NSString stringWithFormat:@"User :  %@", self.userCenter.customerEmail];
            [dataDictionary setObject: settingLabels forKey:@"Setting Options"];
            [self.detailViewController.tableView reloadData];
            
            NSString *userName = [NSString stringWithFormat:@"Setting - User :  %@", self.userCenter.customerEmail];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appLogout:) name:userName object:nil];

            
        }
    }
}

- (void)appLogout:(NSNotification *) note{
    BOOL hasInternet = self.encoderManager.hasInternet;
    if (!hasInternet) {
        CustomAlertView *errorView;
        errorView = [[CustomAlertView alloc]
                     initWithTitle: @"myplayXplay"
                     message: @"Please connect to the internet to log out."
                     delegate: self
                     cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [errorView show];
        //        [globals.ARRAY_OF_POPUP_ALERT_VIEWS addObject:errorView];
    }else{
        [[NSNotificationCenter defaultCenter] postNotificationName:@"hideSettings" object:self];
        CustomAlertView *alertView;
        alertView = [[CustomAlertView alloc]
                     initWithTitle: @"myplayXplay"
                     message: @"If you log out, you need internet to log in. Are you sure you want to log out?"
                     delegate: self
                     cancelButtonTitle:@"Yes" otherButtonTitles:@"Cancel", nil];
        alertView.accessibilityValue = @"appLogOut";
        [alertView show];
        alertView.delegate = self;
        //        [globals.ARRAY_OF_POPUP_ALERT_VIEWS addObject:alertView];
    }
    
}

//- (void)appLogout:(NSNotification *)note {
//    NSLog(@"Trying to logout");
//    
//
//    CustomAlertView *alert = [[CustomAlertView alloc] init];
//    [alert setTitle:@"myplayXplay"];
//    [alert setMessage:@"Are you sure you want to delete this Event?"];
//    [alert setDelegate:self]; //set delegate to self so we can catch the response in a delegate method
//    [alert addButtonWithTitle:@"Yes"];
//    [alert addButtonWithTitle:@"No"];
//    [alert show];
//}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{

    
    if ( [[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:@"Yes"])
    {
        [CustomAlertView removeAlert:alertView];
        [[NSNotificationCenter defaultCenter] postNotificationName: NOTIF_LOGOUT_USER object:nil];
        return;
    }
    
    [CustomAlertView removeAlert:alertView];
    
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //SettingsViewController *encoderControls = [[SettingsViewController alloc] ini]
    
    self.splitViewController = [[UISplitViewController alloc] init];
    SettingsTableViewController *settingsTable = [[SettingsTableViewController alloc] init];
    settingsTable.dataArray = self.settingsArray;
    settingsTable.splitViewController = self.splitViewController;
    self.detailViewController = [[DetailViewController alloc] initViewController];
    
    
    
    settingsTable.detailViewController = self.detailViewController;
    //self.detailViewController.settingsTableViewController = settingsTable;
    
    [self.splitViewController setViewControllers: @[settingsTable, self.detailViewController]];
    [self.splitViewController.view setFrame:CGRectMake(0, 55, self.view.frame.size.width, self.view.frame.size.height - 55)];
    [self.view addSubview: self.splitViewController.view];
    [settingsTable selectCellAtIndexPath: [NSIndexPath indexPathForRow: 0 inSection:0]];
    
    //[self addChildViewController:self.splitViewController];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
