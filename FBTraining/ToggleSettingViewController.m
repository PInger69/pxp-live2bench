//
//  ToggleSettingViewController.m
//  Live2BenchNative
//
//  Created by Nico Cvitak on 2015-05-06.
//  Copyright (c) 2015 DEV. All rights reserved.
//

#import "ToggleSettingViewController.h"

@interface ToggleSettingViewController () <UITableViewDataSource, SwipeableCellDelegate>

@property (strong, nonatomic, nonnull) UITableView *tableView;

@end

@implementation ToggleSettingViewController

@synthesize delegate = _delegate;
@synthesize toggles = _toggles;
@synthesize tableView = _tableView;

- (nonnull instancetype)initWithAppDelegate:(nonnull AppDelegate *)appDel name:(nonnull NSString *)name identifier:(nonnull NSString *)identifier toggles:(nonnull NSArray *)toggles {
    self = [super initWithAppDelegate:appDel name:name identifier:identifier];
    if (self) {
        
        self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) style:UITableViewStyleGrouped];
        self.tableView.dataSource = self;
        self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
        self.navigationItem.leftItemsSupplementBackButton = YES;
        [self.tableView registerClass:[SwipeableTableViewCell class] forCellReuseIdentifier:@"SwipeableCell"];
        [self.view addSubview:self.tableView];
        
        _toggles = toggles;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.toggles.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    SwipeableTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"SwipeableCell"];
    cell.indexPath = indexPath;
    cell.delegate = self;
    cell.button1.hidden = YES;
    cell.button2.hidden = YES;
    cell.functionalButton.hidden = YES;
    cell.toggoButton.hidden = NO;
    cell.toggoButton.tintColor = PRIMARY_APP_COLOR;
    cell.toggoButton.onTintColor = PRIMARY_APP_COLOR;
    
    NSString *toggleName = self.toggles[indexPath.row][@"Name"];
    NSString *toggleIdentifier = self.toggles[indexPath.row][@"Identifier"];
    
    cell.myTextLabel.text = toggleName;
    cell.toggoButton.on = [self.settingData[toggleIdentifier] boolValue];
    
    return cell;
}

#pragma mark - SwipeableCellDelegate

- (void)buttonOneActionForItemText:(NSString *)itemText {
    
}

- (void)buttonTwoActionForItemText:(NSString *)itemText {
    
}

- (void)functionalButtonFromCell:(UITableViewCell *)cell {
    
}

- (void)switchStateSignal:(BOOL)onOrOff fromCell:(SwipeableTableViewCell *)theCell {
    NSString *toggleIdentifier = self.toggles[theCell.indexPath.row][@"Identifier"];
    self.settingData[toggleIdentifier] = [NSNumber numberWithBool:onOrOff];
    
    [self.delegate toggleStateDidChangeWithIdentifier:toggleIdentifier state:onOrOff];
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
