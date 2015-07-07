//
//  InfoSettingViewController.m
//  Live2BenchNative
//
//  Created by Nico Cvitak on 2015-05-06.
//  Copyright (c) 2015 DEV. All rights reserved.
//

#import "InfoSettingViewController.h"

@interface InfoSettingViewController () <SwipeableCellDelegate, UITableViewDataSource, UIAlertViewDelegate>

@property (strong, nonatomic, nonnull) UITableView *tableView;

@property (strong, nonatomic, nonnull) SwipeableTableViewCell *appVersionCell;
@property (strong, nonatomic, nonnull) SwipeableTableViewCell *systemVersionCell;
@property (strong, nonatomic, nonnull) SwipeableTableViewCell *userCell;
@property (strong, nonatomic, nonnull) SwipeableTableViewCell *wifiCell;
@property (strong, nonatomic, nonnull) SwipeableTableViewCell *eulaCell;
@property (strong, nonatomic, nonnull) SwipeableTableViewCell *colorCell;

@property (strong, nonatomic, nonnull) NSArray *cells;

@end

@implementation InfoSettingViewController

- (instancetype)initWithAppDelegate:(nonnull AppDelegate *)appDel {
    self = [super initWithAppDelegate:appDel name:NSLocalizedString(@"Information", nil) identifier:@"Information"];
    if (self) {
        
        self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) style:UITableViewStyleGrouped];
        self.tableView.dataSource = self;
        self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
        self.navigationItem.leftItemsSupplementBackButton = YES;
        [self.tableView registerClass:[SwipeableTableViewCell class] forCellReuseIdentifier:@"SwipeableCell"];
        [self.view addSubview:self.tableView];
        
        NSInteger nCells = 6;
        NSMutableArray *cells = [NSMutableArray arrayWithCapacity:6];
        for (NSInteger i = 0; i < nCells; i++) {
            SwipeableTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"SwipeableCell"];
            cell.button1.hidden = YES;
            cell.button2.hidden = YES;
            cell.functionalButton.enabled = NO;
            cell.toggoButton.hidden = YES;
            cell.indexPath = [NSIndexPath indexPathForRow:i inSection:0];
            
            [cell.functionalButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
            cell.delegate = self;
            
            [cells addObject:cell];
        }
        
        SwipeableTableViewCell *appVersion = cells[0];
        appVersion.myTextLabel.text = [NSString stringWithFormat:@"%@:", NSLocalizedString(@"App Version", nil)];
        [appVersion.functionalButton setTitle:[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"] forState:UIControlStateNormal];
        
        self.appVersionCell = appVersion;
        
        SwipeableTableViewCell *sysVersion = cells[1];
        sysVersion.myTextLabel.text = [NSString stringWithFormat:@"%@:", NSLocalizedString(@"System Version", nil)];
        [sysVersion.functionalButton setTitle:[UIDevice currentDevice].systemVersion forState:UIControlStateNormal];
        self.systemVersionCell = sysVersion;
        
        SwipeableTableViewCell *user = cells[2];
        user.myTextLabel.text = [NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"User", nil), self.userCenter.customerEmail];
        [user.functionalButton setTitle:NSLocalizedString(@"Logout", nil) forState:UIControlStateNormal];
        [user.functionalButton setTitleColor:PRIMARY_APP_COLOR forState:UIControlStateNormal];
        user.functionalButton.enabled = YES;
        self.userCell = user;
        
        SwipeableTableViewCell *wifi = cells[3];
        wifi.myTextLabel.text = [NSString stringWithFormat:@"%@:", NSLocalizedString(@"Wifi Connection", nil)];
        [wifi.functionalButton setTitle:[Utility myWifiName] forState:UIControlStateNormal];
        self.wifiCell = wifi;
        
        SwipeableTableViewCell *eula = cells[4];
        eula.myTextLabel.text = [NSString stringWithFormat:@"%@:", NSLocalizedString(@"EULA", nil)];
        [eula.functionalButton setTitle:NSLocalizedString(@"View", nil) forState:UIControlStateNormal];
        [eula.functionalButton setTitleColor:PRIMARY_APP_COLOR forState:UIControlStateNormal];
        
        eula.functionalButton.enabled = YES;
        self.eulaCell = eula;
        
        SwipeableTableViewCell *color = cells[5];
        color.myTextLabel.text = [NSString stringWithFormat:@"%@:", NSLocalizedString(@"Color", nil)];
        [color.functionalButton setTitle:@"" forState:UIControlStateNormal];
        [color.functionalButton setBackgroundColor:self.userCenter.customerColor];
        self.colorCell = color;
        
        self.cells = cells;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(login:) name:NOTIF_CREDENTIALS_VERIFY_RESULT object:nil];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIF_CREDENTIALS_VERIFY_RESULT object:nil];
}

- (void)login:(NSNotification *)note {
    self.userCell.myTextLabel.text = [NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"User", nil), self.userCenter.customerEmail];
    [self.colorCell.functionalButton setBackgroundColor:self.userCenter.customerColor];
}

- (void)logout {
    BOOL hasInternet = [Utility hasInternet];
    if (!hasInternet) {
        CustomAlertView *errorView;
        errorView = [[CustomAlertView alloc]
                     initWithTitle: @"myplayXplay"
                     message: @"Please connect to the internet to log out."
                     delegate: nil
                     cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [errorView show];
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
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)refresh {
    
}

- (void)viewLicense {
    EulaModalViewController *eulaViewController = [[EulaModalViewController alloc] init];
    [self presentViewController:eulaViewController animated:YES completion:nil];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.cells.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return self.cells[indexPath.row];
}

#pragma mark - SwipeableTableViewCellDelegate

- (void)buttonOneActionForItemText:(NSString *)itemText {
    
}

- (void)buttonTwoActionForItemText:(NSString *)itemText {
    
}

- (void)functionalButtonFromCell:(SwipeableTableViewCell *)cell {
    if (cell == self.userCell) {
        [self logout];
    } else if (cell == self.eulaCell) {
        [self viewLicense];
    }
}

- (void)switchStateSignal:(BOOL)onOrOff fromCell:(SwipeableTableViewCell *)theCell {
    
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if ( [[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:@"Yes"]) {
        //logout the user
        [[NSNotificationCenter defaultCenter] postNotificationName: NOTIF_LOGOUT_USER object:nil];
    }
    [CustomAlertView removeAlert:alertView];
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
