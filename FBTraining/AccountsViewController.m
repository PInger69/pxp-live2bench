//
//  AccountsViewController.m
//  Live2BenchNative
//
//  Created by dev on 2015-03-10.
//  Copyright (c) 2015 DEV. All rights reserved.
//

#import "AccountsViewController.h"
#import "BorderlessButton.h"
#import "CustomLabel.h"


@interface AccountsViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UIView *dropBoxContainer;
@property (nonatomic, strong) BorderlessButton *dropBoxLabel;
@property (nonatomic, strong) BorderlessButton *dropBoxLogout;

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *arrayOfAccounts;

//@property (nonatomic, strong) UILabel *userName;

@end

@implementation AccountsViewController

-(instancetype) init{
    self = [super init];
    if (self){
        self.arrayOfAccounts = @[@"DropBox", @"Google", @"Email"];
        self.view.backgroundColor = [UIColor whiteColor];
        [self setupView];
    }
    return self;
}

-(void)setupView{
//    self.dropBoxContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 40, self.view.bounds.size.width, 40)];
//    self.dropBoxContainer.autoresizingMask = UIViewAutoresizingFlexibleWidth;
//    [self.dropBoxContainer.layer setBorderColor:[[Utility colorWithHexString:@"#575757"] CGColor]];
//    [self.dropBoxContainer.layer setBorderWidth:1.2f];
//    
//    self.dropBoxLabel = [BorderlessButton buttonWithType:UIButtonTypeCustom];
//    [self.dropBoxLabel setFrame:CGRectMake(10, 5, 300, 40)];
//    
//    self.dropBoxLabel.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
//    self.dropBoxLabel.contentEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0);
//    [self.dropBoxLabel setTitle:@"DropBox" forState:UIControlStateNormal];
//    [self.dropBoxContainer addSubview: self.dropBoxLabel];
    
//    BorderlessButton *dropboxLogout = [BorderlessButton buttonWithType:UIButtonTypeCustom];
//    [dropboxLogout setFrame:CGRectMake(self.view.frame.size.width-80, 5, 70, self.dropBoxLabel.frame.size.height)];
//    dropboxLogout.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
//    NSString *logoutTitle = NO ? @"Unlink":@"Link";
//    [dropboxLogout setTitle:logoutTitle forState:UIControlStateNormal];
//    //[dropboxLogout addTarget:self action:@selector(logoutDropbox:) forControlEvents:UIControlEventTouchUpInside];
//    [dropboxLogout setTitleColor:[Utility colorWithHexString:@"#575757"] forState:UIControlStateNormal];
//    [self.dropBoxContainer addSubview: dropboxLogout];
//    self.dropBoxLogout = dropboxLogout;
    
    self.tableView = [[UITableView alloc] initWithFrame: self.view.frame style:UITableViewStyleGrouped];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self.view addSubview: self.tableView];
    
    UILabel *fbAndEmailNote =[[UILabel alloc] initWithFrame:CGRectMake(5, self.arrayOfAccounts.count * 44 + 10, self.tableView.frame.size.width, 80)];
    [fbAndEmailNote setBackgroundColor:[UIColor clearColor]];
    [fbAndEmailNote setNumberOfLines:2];
    [fbAndEmailNote setLineBreakMode:NSLineBreakByWordWrapping];
    [fbAndEmailNote setTextColor:[Utility colorWithHexString:@"#575757"]];
    [fbAndEmailNote setText:NSLocalizedString(@"Note: Login settings for Facebook and Email are available in your iPad's settings app.",nil)];
    [self.view addSubview:fbAndEmailNote];
    
    //    CustomLabel *userLabel = [CustomLabel labelWithStyle:CLStyleBlack];
    //    userLabel.text = @"User:";
    //    userLabel.frame = CGRectMake(15.0f, CGRectGetMaxY(self.view.frame) - 45.0f, 45.0f, 30.0f);
    //    userLabel.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin;
    //    [self.view addSubview:userLabel];
    //
    //    self.userName = [CustomLabel labelWithStyle:CLStyleGrey];
    //    self.userName.frame = CGRectMake(CGRectGetMaxX(userLabel.frame), userLabel.frame.origin.y, 207.0f, 30.0f);
    //    self.userName.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin;
    //    [self.view addSubview: self.userName];
    
    //
    //    BorderlessButton *logoutButton = [BorderlessButton buttonWithType:UIButtonTypeSystem];
    //    [logoutButton setTitle:@"Logout" forState:UIControlStateNormal];
    //    logoutButton.frame = CGRectMake(self.view.frame.size.width - 90.0f, userLabel.frame.origin.y, 75.0f, 30.0f);
    //    logoutButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin;
    //    [logoutButton addTarget:self action:@selector(appLogOut:) forControlEvents:UIControlEventTouchUpInside];
    //    [self.view addSubview:logoutButton];
    
    
    [self.view addSubview: self.dropBoxContainer];
    [self.view addSubview: fbAndEmailNote];
    //    [self.view addSubview: userLabel];
    
    
}


-(void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    //[self setupView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    PXPLog(@"*** didReceiveMemoryWarning ***");
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table View Data Source
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.arrayOfAccounts.count;
}

-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [[UITableViewCell alloc]init];
    
    UIView *viewBoxContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 703.5, 44)];
    viewBoxContainer.autoresizingMask = UIViewAutoresizingNone;
    [viewBoxContainer.layer setBorderColor:[[Utility colorWithHexString:@"#575757"] CGColor]];
    [viewBoxContainer.layer setBorderWidth:1.2f];
    
    BorderlessButton *accountLabel = [BorderlessButton buttonWithType:UIButtonTypeCustom];
    [accountLabel setFrame:CGRectMake(10, 5, 300, 40)];
    accountLabel.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    accountLabel.contentEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0);
    [accountLabel setTitle:self.arrayOfAccounts[indexPath.row] forState:UIControlStateNormal];
    [viewBoxContainer addSubview: accountLabel];

    
    BorderlessButton *logoutButton = [BorderlessButton buttonWithType:UIButtonTypeCustom];
    [logoutButton setFrame:CGRectMake(viewBoxContainer.frame.size.width-80, 5, 70, accountLabel.frame.size.height)];
    logoutButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    NSString *logoutTitle = NO ? @"Unlink":@"Link";
    [logoutButton setTitle:logoutTitle forState:UIControlStateNormal];
    //[dropboxLogout addTarget:self action:@selector(logoutDropbox:) forControlEvents:UIControlEventTouchUpInside];
    [logoutButton setTitleColor:[Utility colorWithHexString:@"#575757"] forState:UIControlStateNormal];
    [viewBoxContainer addSubview: logoutButton];
    //self.dropBoxLogout = dropboxLogout;
    
    [cell addSubview: viewBoxContainer];

    return cell;
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

