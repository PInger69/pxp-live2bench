
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
#import "GTMOAuth2ViewControllerTouch.h"
#import "GTLDrive.h"
#import "EncoderManager.h"
#import "SocialSharingManager.h"
#import "LogoViewController.h"
#import "BitRateViewController.h"
#import "PxpLogViewController.h"

@interface SettingsPageViewController () //<SettingsTableDelegate>

@property (strong, nonatomic) NSArray *defaultSettings;

@property (strong, nonatomic) UISplitViewController *splitViewController;
@property (strong, nonatomic) SettingsTableViewController *settingsTable;
@property (strong, nonatomic) DetailViewController *detailViewController;
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
        
        //UIColor *tagColor = [Utility colorWithHexString:colorString];
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString *plistName = @"Setting.plist";
        NSString *dataPath = [documentsDirectory stringByAppendingPathComponent: @"/Setting"];
        NSString *path = [dataPath stringByAppendingPathComponent: plistName];
        
        //We need to define all of the default settings so that when the plist is loaded we can add any missing settings
        
        NSMutableDictionary *encoderControlsSetting =[NSMutableDictionary dictionaryWithDictionary:@{@"SettingLabel": @"Encoder Controls" , @"OptionChar" :[NSNumber numberWithChar:customViewController], @"CustomViewController" : [[SettingsViewController alloc]initWithAppDelegate:appDel]}];
        
        NSMutableDictionary *welcomeSetting =[NSMutableDictionary dictionaryWithDictionary:@{@"SettingLabel": @"Welcome" , @"OptionChar" :[NSNumber numberWithChar:customViewController], @"CustomViewController" : [[LogoViewController alloc]initWithAppDelegate:appDel]}];
        
        NSMutableDictionary *bitRateSetting =[NSMutableDictionary dictionaryWithDictionary:@{@"SettingLabel": @"Bit Rate" , @"OptionChar" :[NSNumber numberWithChar:customViewController], @"CustomViewController" : [[BitRateViewController alloc]initWithAppDelegate:appDel]}];
        
        NSMutableDictionary *screenMirroringSetting =[NSMutableDictionary dictionaryWithDictionary:@{ @"SettingLabel" : @"Screen Mirroring", @"OptionChar": [NSNumber numberWithChar:toggleIsThere|toggleIsOn]}];
        
        NSMutableDictionary *toastObserverSetting =[NSMutableDictionary dictionaryWithDictionary:@{ @"SettingLabel" : @"Toast Observer", @"OptionChar":  [NSNumber numberWithChar: listOfToggles],@"DataDictionary":[NSMutableDictionary dictionaryWithDictionary:@{@"Setting Options":@[@"Download Complete", @"Tag Synchronized", @"Tag Received"], @"Toggle Settings":@[@1,@1,@1]}] }];
        
        NSMutableDictionary *alertsSetting =[NSMutableDictionary dictionaryWithDictionary:@{ @"SettingLabel" : @"Alerts", @"OptionChar":  [NSNumber numberWithChar: listOfToggles] , @"DataDictionary": [NSMutableDictionary dictionaryWithDictionary: @{       @"Setting Options":
                                                                                                                                                                                                                                                                    @[@"Notification Alerts", @"Encoder Alerts", @"Device Alerts", @"Indecisive Alert"],
                                                                                                                                                                                                                                                                @"Toggle Settings":
                                                                                                                                                                                                                                                                    @[@1, @1, @1, @1]}] }];
        
        NSMutableDictionary *informationSetting =[NSMutableDictionary dictionaryWithDictionary: @{ @"SettingLabel" : @"Information", @"OptionChar":  [NSNumber numberWithChar:listIsOn] , @"DataDictionary": [NSMutableDictionary dictionaryWithDictionary: @{       @"Setting Options":
                                                                                                                                                                                                                                                                         @[@"App Version :", @"System Version :", [NSString stringWithFormat:@"User :  %@", @"Not Signed In"], @"WIFI Connection :", @"Eula :", @"Colour :"],
                                                                                                                                                                                                                                                                     @"Function Buttons":
                                                                                                                                                                                                                                                                         @[ @0, @0, @1, @0, @1, @0]
                                                                                                                                                                                                                                                                     , @"Function Labels": @[@"Unknown", @"2.0.0", @"Logout", @"Not Connected", @"View", [@"Color-" stringByAppendingString:@"nil"]] }]}];
        
        NSMutableDictionary *accountsSetting = [NSMutableDictionary dictionaryWithDictionary:@{ @"SettingLabel" : @"Accounts", @"OptionChar":  [NSNumber numberWithChar:listIsOn], @"DataDictionary": [NSMutableDictionary dictionaryWithDictionary: @{       @"Setting Options":
                                                                                                                                                                                                                                                                  @[@"Dropbox",  @"GoogleDrive"],
                                                                                                                                                                                                                                                              @"Function Buttons":
                                                                                                                                                                                                                                                                  @[ @1, @1], @"Function Labels": @[@"Link", @"Link"] }]}];
        
        NSMutableDictionary *languagesSetting = [NSMutableDictionary dictionaryWithDictionary:@{ @"SettingLabel" : @"Languages", @"OptionChar":  [NSNumber numberWithChar:listIsOn] , @"DataDictionary": [NSMutableDictionary dictionaryWithDictionary: @{@"Setting Options":
                                                                                                                                                                                                                                                              @[@"English"], @"Index":
                                                                                                                                                                                                                                                              [NSNumber numberWithInt:0]} ] }];
        
        
        NSMutableDictionary *tabsSetting =[NSMutableDictionary dictionaryWithDictionary:@{ @"SettingLabel" : @"Tabs", @"OptionChar":  [NSNumber numberWithChar: listOfToggles], @"DataDictionary": [NSMutableDictionary dictionaryWithDictionary: @{ @"Setting Options":
                                                                                                                                                                                                                                                         @[@"Calendar", @"Injury", @"Live2Bench", @"Clip View", @"List View", @"My Clip"],
                                                                                                                                                                                                                                                     @"Toggle Settings":
                                                                                                                                                                                                                                                         @[@1, @1, @1, @1, @1, @1]}] }];
        
        NSMutableDictionary *logSetting =[NSMutableDictionary dictionaryWithDictionary:@{@"SettingLabel": @"Log" , @"OptionChar" :[NSNumber numberWithChar:customViewController], @"CustomViewController" : [[PxpLogViewController alloc]initWithAppDelegate:appDel]}];
        
        self.defaultSettings = @[
                                 encoderControlsSetting,
                                 welcomeSetting,
                                 bitRateSetting,
                                 screenMirroringSetting,
                                 toastObserverSetting,
                                 alertsSetting,
                                 informationSetting,
                                 accountsSetting,
                                 languagesSetting,
                                 tabsSetting,
                                 logSetting,
                                 ];
        
        // We initialize the setting array with the default settings first to account for any new settings
        self.settingsArray = [NSMutableArray arrayWithArray:self.defaultSettings];
        

        if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {

            NSDictionary *settingDictionary = [[NSDictionary alloc]initWithContentsOfFile:path];
            
            [self loadSettingsFromArray:settingDictionary[@"SettingsArray"]];
            
             /*
            self.settingsArray = settingDictionary[@"SettingsArray"];
            for (NSMutableDictionary *setting in self.settingsArray) {
                
                // extract setting information
                NSString *label = setting[@"SettingLabel"];
                NSInteger optionType = [setting[@"OptionChar"] integerValue];
                
                if ([(NSNumber *)setting[@"OptionChar"] intValue] & customViewController) {
                    setting[@"CustomViewController"] = [[NSClassFromString(setting[@"CustomViewController"]) alloc]  initWithAppDelegate: appDel];
                }
            }
              */
        }
        
        //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(viewLicense:) name:@"Setting - Eula :" object:nil];
        _userName = [NSString stringWithFormat:@"User :  %@", appDel.userCenter.customerEmail];
        //        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appLogout:) name:userName object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(operationInInformation:) name:@"Setting - Information" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appLogoutCompleted:) name:NOTIF_USER_LOGGED_OUT object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appLoginCompleted:) name: NOTIF_CREDENTIALS_VERIFY_RESULT object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didPressLink:) name: @"Setting - Accounts" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(settingRequest:) name:NOTIF_REQUEST_SETTINGS object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(saveSettings) name:UIApplicationWillTerminateNotification object:nil];
        //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didPressGoogleLink) name: @"Setting - GoogleDrive" object:nil];
        [self refreshSettings];
        
        
    }
    return self;
}

-(void)loadSettingsFromArray:(NSArray *)settingsArray {
    NSMutableDictionary *availableSettings = [NSMutableDictionary dictionary];
    for (NSMutableDictionary *setting in self.settingsArray) {
        availableSettings[setting[@"SettingLabel"]] = setting;
    }
    
    for (NSMutableDictionary *loadSetting in settingsArray) {
        
        // it must be in the defaults for it to be extracted
        NSMutableDictionary *currentSetting;
        if ((currentSetting = [availableSettings objectForKey:loadSetting[@"SettingLabel"]])) {
            
            NSInteger currentOption = [currentSetting[@"OptionChar"] integerValue];
            NSInteger loadOption = [loadSetting[@"OptionChar"] integerValue];
            
            // option type must be identical to be extracted
            if (currentOption == loadOption) {
                
                NSArray *currentSettingOptions = currentSetting[@"DataDictionary"][@"Setting Options"];
                NSArray *loadSettingOptions = loadSetting[@"DataDictionary"][@"Setting Options"];
                
                if (loadOption & listOfToggles) {
                    for (NSUInteger i = 0; i < currentSettingOptions.count && i < loadSettingOptions.count; i++) {
                        if ([currentSettingOptions[i] isEqualToString:loadSettingOptions[i]]) {
                            currentSetting[@"DataDictionary"][@"Toggle Settings"] = loadSetting[@"DataDictionary"][@"Toggle Settings"];
                        }
                    }
                }
                
            }
        }
    }
}

-(void)refreshSettings{
    NSString *wifiName = [Utility myWifiName];
    if (!wifiName) {
        wifiName = @"Not Connected";
    }
    
    NSString *colorString = [[[NSDictionary alloc] initWithContentsOfFile:self.userCenter.accountInfoPath] objectForKey:@"tagColour"];
    if (!colorString) {
        colorString = @"nil";
    }
    
    NSMutableDictionary *setting6 =[NSMutableDictionary dictionaryWithDictionary: @{ @"SettingLabel" : @"Information", @"OptionChar":  [NSNumber numberWithChar:listIsOn] , @"DataDictionary": [NSMutableDictionary dictionaryWithDictionary: @{       @"Setting Options":
                                                                                                                                                                                                                                                           @[@"App Version :", @"System Version :", [NSString stringWithFormat:@"User :  %@", self.userCenter.customerEmail], @"WIFI Connection :", @"Eula :", @"Colour :"],
                                                                                                                                                                                                                                                       @"Function Buttons":
                                                                                                                                                                                                                                                           @[ @0, @0, @1, @0, @1, @0]
                                                                                                                                                                                                                                                       , @"Function Labels": @[[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"], [UIDevice currentDevice].systemVersion, @"Logout", wifiName, @"View", [@"Color-" stringByAppendingString:colorString]] }]}];
    
    self.settingsArray[6] = setting6;
}

#pragma mark - Notification methods

-(void)operationInInformation:(NSNotification *)note {
    if ([note.userInfo[@"Name"] isEqualToString:self.userName]) {
        [self appLogout];
    }
    if ([note.userInfo[@"Name"] isEqualToString:@"Eula :"]) {
        [self viewLicense];
    }
}

-(void) settingRequest: (NSNotification *)note{
    NSString *settingName = note.userInfo[@"name"];
    
    NSDictionary *parameterDictionary;
    for (NSDictionary *setting in self.settingsArray) {
        if ([setting[@"SettingLabel"]  isEqualToString:settingName]) {
            switch ([setting[@"OptionChar"] intValue])
            {
                case (listIsOn):
                {
                    void(^blockName)(NSDictionary *settingDictionary) = note.userInfo[@"block"];
                    NSNumber *indexNumber = (NSNumber *)(setting[@"DataDictionary"][@"Index"]);
                    NSString *settingOption = [((NSArray *)setting[@"DataDictionary"][@"Setting Options"]) objectAtIndex: [indexNumber intValue]];
                    parameterDictionary = @{@"ChosenSetting": settingOption};
                    blockName(parameterDictionary);
                    break;
                }
                case (listOfToggles):
                {
                    void(^blockName)(NSArray *settingLabels, NSArray *toggleValues) = note.userInfo[@"block"];
                    //parameterDictionary = [NSDictionary dictionaryWithObjects:(setting[@"DataDictionary"][@"Toggle Settings"]) forKeys:(setting[@"DataDictionary"][@"Setting Options"])];
                    blockName(setting[@"DataDictionary"][@"Setting Options"], setting[@"DataDictionary"][@"Toggle Settings"]);
                    break;
                }
                case (toggleIsThere | toggleIsOn):
                case (toggleIsThere):
                {
                    void(^blockName)(NSDictionary *settingDictionary) = note.userInfo[@"block"];
                    int onOrOffInt = [(NSNumber *)setting[@"OptionChar"] intValue] & toggleIsOn;
                    BOOL onOrOff = (onOrOffInt ? YES: NO);
                    NSNumber *boolNumber = [NSNumber numberWithBool: onOrOff];
                    parameterDictionary = @{@"Name" : settingName, @"Type": @"Toggle", @"Value": boolNumber};
                    blockName(parameterDictionary);
                    break;
                }
            }
        }
    }
}

-(void)viewLicense {
    EulaModalViewController *eulaViewController=[[EulaModalViewController alloc]init];
    [self presentViewController:eulaViewController animated:YES completion:nil];
}

-(void)appLogoutCompleted: (NSNotification *) note{
    
    NSString *userName = [NSString stringWithFormat:@"Setting - User :  %@", self.userCenter.customerEmail];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:userName object:nil];
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

- (void)appLogout{
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
    //settingsTable.signalReciever = self;
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

//- (void)settingChanged: (NSDictionary *) settingChangeDictionary fromCell: (id) swipeableTableCell{
//    NSNotification *settingNotification = [NSNotification notificationWithName:[ @"Setting - " stringByAppendingString:  settingChangeDictionary[@"Name"]] object:nil userInfo:settingChangeDictionary];
//
//    [[NSNotificationCenter defaultCenter] postNotification: settingNotification];
//}

- (void)didPressLink : (NSNotification *) note {
    [[SocialSharingManager commonManager] linkSocialObject:note.userInfo[@"Name"] inViewController:self];
}


-(void) saveSettings{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *plistName = @"Setting.plist";
    NSString *dataPath = [documentsDirectory stringByAppendingPathComponent: @"/Setting"];
    NSString *path = [dataPath stringByAppendingPathComponent: plistName];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:dataPath]){
        [[NSFileManager defaultManager] createDirectoryAtPath:dataPath withIntermediateDirectories:NO attributes:nil error:nil];
    }
    
    NSMutableArray *savingSettingsArray = [self.settingsArray mutableCopy];
    
    for (NSMutableDictionary *setting in savingSettingsArray) {
        if ([(NSNumber *)setting[@"OptionChar"] intValue] & customViewController) {
            setting[@"CustomViewController"] = NSStringFromClass([setting[@"CustomViewController"] class]);
            NSLog(@"The customViewController string is %@", setting[@"CustomViewController"]);
        }
    }
    
    NSDictionary *settingsDictionary = @{@"SettingsArray": savingSettingsArray};
    [settingsDictionary writeToFile:path atomically:NO];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    //[self saveSettings];
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
