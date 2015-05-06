//
//  infoViewController.m
//  Live2BenchNative
//
//  Created by 漠川 阮 on 15/3/9.
//  Copyright (c) 2015年 DEV. All rights reserved.
//

#import "infoViewController.h"
#import "CustomLabel.h"
#import "AppDelegate.h"
#import "UserCenter.h"
#import "EncoderManager.h"

@interface infoViewController ()

@property (strong, nonatomic) CustomLabel *appVersionLabel;
@property (strong, nonatomic) CustomLabel *systemVersionLabel;
@property (strong, nonatomic) CustomLabel *wifiLable;
@property (strong, nonatomic) CustomLabel *userLabel;
@property (strong, nonatomic) UIButton *eula;
@property (strong, nonatomic) NSMutableArray *arrayOfLabels;
@property (strong, nonatomic) UIButton *logoutButton;

@property (strong, nonatomic) UserCenter *userCenter;
@property (strong, nonatomic) EncoderManager *encoderManager;

@end

@implementation infoViewController

- (instancetype)initWithAppDelegate:(AppDelegate *)appDel {
    self = [super init];
    if (self) {
        self.arrayOfLabels = [NSMutableArray array];
        
        self.appVersionLabel = [[CustomLabel alloc] init];
        self.appVersionLabel.frame = CGRectMake(20, 0, 200, 50);
        self.appVersionLabel.text = [NSString stringWithFormat:@"%@:  %@", NSLocalizedString(@"App Version", nil),[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"]];
        [self.arrayOfLabels addObject:self.appVersionLabel];
        
        self.systemVersionLabel = [[CustomLabel alloc] init];
        self.systemVersionLabel.frame = CGRectMake(20, 0, 200, 50);
        self.systemVersionLabel.text = [NSString stringWithFormat:@"%@:  %@", NSLocalizedString(@"System Version", nil),[UIDevice currentDevice].systemVersion];
        [self.arrayOfLabels addObject:self.systemVersionLabel];
        
        self.userCenter = appDel.userCenter;
        self.userLabel = [[CustomLabel alloc] init];
        self.userLabel.frame = CGRectMake(20, 0, 200, 50);
        self.userLabel.text = [NSString stringWithFormat:@"%@:  %@", NSLocalizedString(@"User", nil), self.userCenter.customerEmail];
        [self.arrayOfLabels addObject:self.userLabel];
        
        self.wifiLable = [[CustomLabel alloc] initWithFrame:CGRectMake(20, 0, 300, 50)];
        self.wifiLable.text = [NSString stringWithFormat:@"%@:  %@", NSLocalizedString(@"WIFI Connection", nil) , [Utility myWifiName]];
        [self.arrayOfLabels addObject:self.wifiLable];
        
        self.eula = [[UIButton alloc] initWithFrame:CGRectMake(20, 0, 300, 50)];
        [self.eula setTitleColor:PRIMARY_APP_COLOR forState:UIControlStateNormal];
        [self.eula setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
        [self.eula addTarget:self action:@selector(viewLicense:) forControlEvents:UIControlEventTouchUpInside];
        [self.eula setTitle:NSLocalizedString(@"View Eula", nil) forState:UIControlStateNormal];
        self.eula.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        [self.arrayOfLabels addObject:self.eula];
        
        self.encoderManager = appDel.encoderManager;
    }
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"UITableViewCell"];
    [self.tableView reloadData];
    //self.tableView.dataSource = self;
    
    return self;
}

- (void)appLogOut:(id)sender {
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

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0:
            [self sendAppLogoutRequest];
            break;
            
        default:
            break;
    }
}

-(void)sendAppLogoutRequest{
    [self.encoderManager.logoutAction start];
    //    dismissEnabled = YES;
    //    [self dismiss];
}

-(void)viewLicense:(id)sender{
    EulaModalViewController *eulaViewController=[[EulaModalViewController   alloc]init];
    [self presentViewController:eulaViewController animated:YES completion:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    // Do any additional setup after loading the view.
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
    return [self.arrayOfLabels count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}





- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"UITableViewCell" forIndexPath:indexPath];
    
    [cell setFrame:CGRectMake(0, 0, 0, 0)];
    [cell setAutoresizingMask:UIViewAutoresizingNone];
    [cell setFrame:CGRectMake(15, indexPath.row * 44, 673.5, 44)];
    
    [cell.contentView addSubview:self.arrayOfLabels[indexPath.row]];
    if (indexPath.row == 2) {
        self.logoutButton = [[UIButton alloc] initWithFrame:CGRectMake(500, 0, 100, 50)];
        [self.logoutButton setTitle:NSLocalizedString(@"LOGOUT", nil) forState:UIControlStateNormal];
        [self.logoutButton setTitleColor:PRIMARY_APP_COLOR forState:UIControlStateNormal];
        [self.logoutButton addTarget:self action:@selector(appLogOut:) forControlEvents:UIControlEventTouchUpInside];
        [cell.contentView addSubview:self.logoutButton];
    }
    return cell;
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

