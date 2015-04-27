//
//  DetailViewController.m
//  Setting
//
//  Created by dev on 2015-01-05.
//  Copyright (c) 2015 dev. All rights reserved.
//

#import "DetailViewController.h"
#import "SwipeableTableViewCell.h"



@interface DetailViewController () <SwipeableCellDelegate> {
}
@property (strong, nonatomic) NSString * title;
//@property (strong, nonatomic) NSMutableDictionary *dataDictionary;



@end

@implementation DetailViewController

-(instancetype)initViewController{
    self = [super init];
    if (self){
        // Instantiating a Table View Controller for the Detail View Controller
        UITableView *newTableView = [[UITableView alloc] initWithFrame:CGRectMake(10, 0, self.view.frame.size.width - 20, self.view.frame.size.height) style:UITableViewStyleGrouped];
        [self.view addSubview:newTableView];
        self.tableView = newTableView;
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
        self.navigationItem.leftItemsSupplementBackButton = YES;
        
        [self.tableView registerClass:[SwipeableTableViewCell class] forCellReuseIdentifier:@"SwipeableCell"];
        self.tintColor = [UIColor orangeColor];
    }
    return self;
}

-(void)setDataDictionary:(NSMutableDictionary *)dataDictionary {
    _dataDictionary = dataDictionary;
    if(_dataDictionary[@"Toggle Settings"]){
        [_dataDictionary setObject:[_dataDictionary[@"Toggle Settings"] mutableCopy] forKey:@"Toggle Settings"];
    }else if(_dataDictionary[@"Function Buttons"]){
        [_dataDictionary setObject:[_dataDictionary[@"Function Buttons"] mutableCopy] forKey:@"Function Buttons"];
    }
}

-(void) inputData:(NSMutableDictionary *)dataDictionary{
    self.dataDictionary = dataDictionary;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    return ([self.dataDictionary[@"Setting Options"] count]);
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([self.dataDictionary[@"Toggle Settings"] count]) {
        return nil;
    }else if (self.dataDictionary[@"Function Labels"]){
        return nil;
    }
    return indexPath;
}

#pragma mark - Managing the detail item

//- (void)setDetailItem:(id)newDetailItem {
//    if (_detailItem != newDetailItem) {
//        _detailItem = newDetailItem;
//        
//        // Update the view.
//        [self configureView];
//    }
//}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //self.title = self.swipeableTableViewCell.myTextLabel.text;
    // Initiating the Cell
    SwipeableTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"SwipeableCell"];
    
    //This sets the selectionStyle of the cell, since not all SwipeableCells
    // have a selection style
    cell.selectionStyle = UITableViewCellSelectionStyleBlue;
    
    //The cell is being reused therefore all of its unused properties must
    // be hidden
    cell.button1.hidden = YES;
    cell.button2.hidden = YES;
    
    cell.functionalButton.backgroundColor = [UIColor clearColor];
    cell.functionalButton.enabled = NO;

    [cell.myTextLabel setText: self.dataDictionary[@"Setting Options"][indexPath.row]];
    
    
    if (self.dataDictionary[@"Toggle Settings"]){
        //This is the case where there is a list of Toggle Buttons
        cell.toggoButton.hidden = NO;
        [cell.toggoButton setOn: [((NSNumber *)self.dataDictionary[@"Toggle Settings"][indexPath.row]) intValue]];
    }else if(self.dataDictionary[@"Function Labels"]){
        //This is the case when there is a list that has buttons with different functions
        if( [((NSString *)self.dataDictionary[@"Function Labels"][indexPath.row]) hasPrefix:@"Color"] ){
            NSArray *bothStrings = [((NSString *)self.dataDictionary[@"Function Labels"][indexPath.row]) componentsSeparatedByString:@"-"];
            
            [cell.functionalButton setTitle: @"" forState:UIControlStateNormal];
            cell.functionalButton.backgroundColor = [Utility colorWithHexString: bothStrings[1]];
            
//            CGRect functionalFrame = cell.functionalButton.frame;
//            functionalFrame.origin.x -= 5;
//            functionalFrame.origin.y += 5;
//            functionalFrame.size.height -=5;
//            
//            cell.functionalButton.frame = functionalFrame;
            cell.functionalButton.layer.cornerRadius = 20.0;
            cell.functionalButton.hidden = NO;
            cell.functionalButton.enabled = NO;
        }else{
            [cell.functionalButton setTitle: self.dataDictionary[@"Function Labels"][indexPath.row] forState:UIControlStateNormal];
            cell.functionalButton.hidden = NO;
            if([((NSNumber *)self.dataDictionary[@"Function Buttons"][indexPath.row]) intValue]){
                [cell.functionalButton setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
                cell.functionalButton.enabled = YES;
            }else{
                [cell.functionalButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
                cell.functionalButton.enabled = NO;
            }
        }
        
    }else if([self.dataDictionary[@"Index"] intValue] == indexPath.row){
        // This is the case where there is a list of choices
        PXPLog(@"%@", self.dataDictionary);
        PXPLog(@"%i", [self.dataDictionary[@"Index"] intValue]);
        PXPLog(@"The indexPath is %@", indexPath);
        cell.myTextLabel.textColor = self.tintColor;
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
//    NSString *item = _arrayOfOptions[indexPath.row ];
//    cell.itemText = item;
//    
//    if (self.arrayOfToggleOptions){
//        cell.toggoButton.hidden = NO;
//        [cell.toggoButton setOn: [((NSNumber *)self.arrayOfToggleOptions[indexPath.row]) intValue]];
//        
//    }else{
//    
//        //All this code is to remember the selection of the setting if its a list
//        // The data is kept in the Settings Table View Controller so that it is never
//        // trashed, because the Detail View Controller can get deallocated
//        NSIndexPath *thisPath = [self.settingsTableViewController.arrayWithSettingOptionChosen objectAtIndex:self.index];
//        
//        int originalIndex =  ([([([self.settingsTableViewController.dataDictionary objectForKey:[NSNumber numberWithInt:self.index]]) objectForKey:@"Index"]) intValue]);
//        if(([([self.settingsTableViewController.dataDictionary objectForKey:[NSNumber numberWithInt:self.index]]) objectForKey:@"Index"]) == nil){
//            originalIndex = -1;
//        }else if( thisPath.row != -1){
//            originalIndex = -1;
//        }
//        
//        
//        if([self.settingsTableViewController.arrayWithSettingOptionChosen[self.index] isEqual:indexPath]){
//            cell.myTextLabel.textColor = self.tintColor;
//            cell.accessoryType = UITableViewCellAccessoryCheckmark;
//        }else if( originalIndex == (int)indexPath.row){
//            cell.myTextLabel.textColor = self.tintColor;
//            cell.accessoryType = UITableViewCellAccessoryCheckmark;
//            self.settingsTableViewController.arrayWithSettingOptionChosen[self.index] = [NSIndexPath indexPathForRow: originalIndex inSection: 0];
//        }
//    }
//        
    //This line makes the DetailViewController the delegate for each cell
    cell.delegate = self;
    cell.tintColor = [UIColor orangeColor];
    return cell;
}


- (void)configureView {
    // Update the user interface for the detail item.
//    if (self.detailItem) {
//
//    }
    

}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    // Do any additional setup after loading the view, typically from a nib.
    [self configureView];
}

-(void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self configureView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
    // Dispose of any resources that can be recreated.
}
- (void)switchStateSignal:(BOOL)onOrOff fromCell: (SwipeableTableViewCell *) theCell{
    
    NSDictionary *signalPackage = @{@"Name": theCell.myTextLabel.text, @"Value": (onOrOff ? @YES:@NO), @"Type": @"Toggle"};
    PXPLog(@"%@", signalPackage);
    
    NSMutableArray *toggleArray = (NSMutableArray *) self.dataDictionary[@"Toggle Settings"];
    NSIndexPath *cellIndexPath = [self.tableView indexPathForCell: theCell];
    toggleArray[cellIndexPath.row] = onOrOff ? @1:@0;
    
    [self.settingsTableViewController settingChangedInDetailViewController: self withSignal:signalPackage];
    
}

- (void)functionalButtonFromCell: (SwipeableTableViewCell *) cell{
    
    NSDictionary *signalPackage = @{@"Name": cell.myTextLabel.text , @"Value": @1, @"Type": @"FunctionalButton", @"ButtonTitle": cell.functionalButton.titleLabel.text};
    [self.settingsTableViewController settingChangedInDetailViewController:self withSignal: signalPackage];
    //[[NSNotificationCenter defaultCenter] postNotificationName:notificationName object:nil];
}

#pragma mark - Selecting the Cell
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSNumber *oldIndex = (NSNumber *)self.dataDictionary[@"Index"];
    NSIndexPath *oldPath = [NSIndexPath indexPathForRow: [oldIndex intValue] inSection:0];
    
    SwipeableTableViewCell *cell = (SwipeableTableViewCell*)[tableView cellForRowAtIndexPath: oldPath];
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.myTextLabel.textColor = [UIColor blackColor];
    
    
    
    cell = (SwipeableTableViewCell*)[tableView cellForRowAtIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
    cell.myTextLabel.textColor = cell.tintColor;
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    [self.dataDictionary setObject: [NSNumber numberWithInt:indexPath.row] forKey:@"Index"];
    
    NSDictionary *signalPackage = @{@"Name": cell.myTextLabel.text, @"Value": cell.myTextLabel.text, @"Type": @"ListOption"};
    [self.settingsTableViewController settingChangedInDetailViewController: self withSignal: signalPackage];
//    // These first lines replace the 
//    NSIndexPath *oldPath = [self.settingsTableViewController.arrayWithSettingOptionChosen objectAtIndex:self.index];
//    SwipeableTableViewCell *cell = (SwipeableTableViewCell*)[tableView cellForRowAtIndexPath: oldPath];
//    cell.accessoryType = UITableViewCellAccessoryNone;
//    cell.myTextLabel.textColor = [UIColor blackColor];
//    cell = (SwipeableTableViewCell*)[tableView cellForRowAtIndexPath:indexPath];
//    cell.accessoryType = UITableViewCellAccessoryCheckmark;
//    //cell.myTextLabel.textColor = [UIColor colorWithRed:0.00 green:122.0/255.0 blue:1.0 alpha:1.0];
//    cell.myTextLabel.textColor = cell.tintColor;
//    
//    //self.settingsTableViewController choseCellWithString:[[self.settingsTableViewController.dataDictionary objectForKey:[NSNumber numberWithInt:(self.index + 1)]] objectForKey:@"Setting Options"][indexPath.row]];
//    self.settingsTableViewController.arrayWithSettingOptionChosen[self.index] = indexPath;
//    [self.settingsTableViewController specificSettingChosen: cell.myTextLabel.text fromCell:self.swipeableTableViewCell];
//    
//    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}

#pragma mark - TableView Delegate Methods

//- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
//    return headerView;
//}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 30.0;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    
    if([[self.dataDictionary[@"Setting Options"] firstObject] isEqualToString:@"Dropbox"]){
        UILabel *fbAndEmailNote =[[UILabel alloc] initWithFrame:CGRectMake(15,  10, 703.5, 80)];
        [fbAndEmailNote setBackgroundColor:[UIColor clearColor]];
        [fbAndEmailNote setNumberOfLines:2];
        [fbAndEmailNote setLineBreakMode:NSLineBreakByWordWrapping];
        [fbAndEmailNote setTextAlignment: NSTextAlignmentCenter];
        [fbAndEmailNote setTextColor:[Utility colorWithHexString:@"#575757"]];
        [fbAndEmailNote setText:@"Note: Login settings for Facebook and Email are available in your iPad's settings app."];
        
        return fbAndEmailNote;
    }
    
    return nil;

}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 30.0;
}


@end
