//
//  SettingsTableViewController.m
//  Settings
//
//  Created by dev on 2015-01-06.
//  Copyright (c) 2015 Avoca Technologies. All rights reserved.
//

#import "SettingsTableViewController.h"
#import "DetailViewController.h"
#import "SwipeableTableViewCell.h"

@interface SettingsTableViewController () <SwipeableCellDelegate> {

}

- (void)showDetailWithText:(NSString *)detailText;

@end

// This enum is used to identify the stored information
// with regards to the accessor options on each cell
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


@implementation SettingsTableViewController

- (instancetype)init {
    self = [super init];
    if (self) {
        [self.tableView registerClass:[SwipeableTableViewCell class] forCellReuseIdentifier:@"SwipeableCell"];

    }
    return self;
}


-(void) setDataArray:(NSArray *)dataArray{
    _dataArray = dataArray;
}
    // This indexPath object is used to instantiate the array with the indexPath objects
    // The reason it is -1 is because this is not a possible indexPath for the cells
//    NSIndexPath *somePath = [NSIndexPath indexPathForRow:-1 inSection:0];
//    
//    // This is simply to instantiate the array with indexPath objects
//    // Therefore we instantiate a mutable array that can contain the necessary information
//    // for the detail view controller to remember which cell was selected last
//    self.arrayWithSettingOptionChosen = [NSMutableArray arrayWithObjects:somePath, nil];
//    for (NSInteger i = 0; i < [_dataArray count]; ++i){
//        [self.arrayWithSettingOptionChosen addObject:somePath]; //This information only exists temporarily
//        // This array is contained by the settingsTableViewController
//    }


//- (NSArray *) dataArray{
//    NSMutableDictionary *returnDict = [NSMutableDictionary dictionaryWithDictionary: _dataDictionary];
//    for(int i = 1; i <= [_dataDictionary count]; ++i){
//        NSMutableDictionary *eachCellDictionary = [NSMutableDictionary dictionaryWithDictionary:[_dataDictionary objectForKey:[NSNumber numberWithInt:i]]];
//        char theNumber = [[eachCellDictionary objectForKey:@"OptionChar"] charValue];
//        if( (theNumber  & toggleIsThere) >0 ){
//            SwipeableTableViewCell *theCell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:(i-1) inSection:0]];
//            if([theCell.toggoButton isOn]){
//                [eachCellDictionary setObject:[NSNumber numberWithChar:toggleIsThere|toggleIsOn] forKey:@"OptionChar"];
//            }else{
//                [eachCellDictionary setObject:[NSNumber numberWithChar:toggleIsThere] forKey:@"OptionChar"];
//            }
//            
//        }
//        
//        if([eachCellDictionary objectForKey:@"Index"]){
//            NSIndexPath *optionIndexPath = (self.arrayWithSettingOptionChosen[i]);
//            int originalIndex = [[eachCellDictionary objectForKey:@"Index"] intValue];
//            if( optionIndexPath.row == -1){
//                NSLog(@"The if code is executing");
//                //[eachCellDictionary setObject:[NSNumber numberWithInt: originalIndex] forKey: @"Index"];
//            }else{
//                NSLog(@"The else code is executing");
//                [eachCellDictionary setObject:[NSNumber numberWithInt: optionIndexPath.row] forKey: @"Index"];
//            }
//            
//        }
//        [returnDict setObject:eachCellDictionary forKey:[NSNumber numberWithInt:(i)]];
//    }
//    return [returnDict copy];
//}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Settings";
    
    // This indexPath object is used to instantiate the array with the indexPath objects
    // The reason it is -1 is because this is not a possible indexPath for the cells
    NSIndexPath *somePath = [NSIndexPath indexPathForRow:-1 inSection:0];
    
//    // This is simply to instantiate the array with indexPath objects
//    // Therefore we instantiate a mutable array that can contain the necessary information
//    // for the detail view controller to remember which cell was selected last
//    self.arrayWithSettingOptionChosen = [NSMutableArray arrayWithObjects:somePath, nil];
//    for (NSInteger i = 0; i < [_dataDictionary count]; ++i){
//       [self.arrayWithSettingOptionChosen addObject:somePath]; //This information only exists temporarily
//        // This array is contained by the settingsTableViewController
//    }
//    
//    // This line ensures that the tableView ends at the last cell
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
}

#pragma mark - Table View


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // This table only contains one section
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _dataArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // This is because the dictionary was instatiated with NSNumber's that start off at 1
    int index = indexPath.row;
    ++index;
   
    // This is the initialization of the cell
    SwipeableTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"SwipeableCell" forIndexPath:indexPath];
    
    NSDictionary *cellDictionary = self.dataArray[indexPath.row];
    
    cell.contentView.translatesAutoresizingMaskIntoConstraints = YES;

    
    //Giving the cell an indexPath
    cell.indexPath = indexPath;
   
    // This is where the cell gets its label:
    [cell.myTextLabel setText: [cellDictionary objectForKey:@"SettingLabel"]];
    
    // This char will store the bits required for identifying to customized options each cell has
    char accessorOption = ([[cellDictionary objectForKey:@"OptionChar"] charValue]);
    
    
    if((accessorOption & listIsOn)> 0 || (accessorOption & customViewController) > 0 || (accessorOption & listOfToggles) > 0 ){
        // If the list is on, it should have a selection style and a disclosure indicator
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.selectionStyle = UITableViewCellSelectionStyleDefault;
    }
    
    // These lines of code set up the Cell based on what accessor option it has
    cell.toggoButton.hidden = !((accessorOption & toggleIsThere)>0);
    [cell.toggoButton setOn: (accessorOption & toggleIsOn)>0 animated:NO];
    cell.button1.hidden = !((accessorOption & oneButton)> 0);
    cell.button2.hidden = !((accessorOption & secondButton)>0);
    cell.functionalButton.hidden = !((accessorOption & functionalButton)>0);
    if(!(cell.button1.hidden && cell.button2.hidden)){
        // By forcing the awakeFromNib on specific cells, not all of them have to be swipeable
        [cell awakeFromNib];
    }
    // The list option is dealt with in another method
    
    cell.delegate = self;
    cell.tintColor = [UIColor orangeColor];
    return cell;
    

}

// This method is only here to make sure that only the cells that segue to other tables can be selected
- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // This is because the dictionary was instatiated with NSNumber's that start off at 1
    int index = indexPath.row;
    ++index;
    
    NSDictionary *settingsDictionary = self.dataArray[indexPath.row];
    
    // This only executes if there is a list
    if(([[ settingsDictionary objectForKey:@"OptionChar"] charValue]) & listIsOn || ([[ settingsDictionary objectForKey:@"OptionChar"] charValue])& customViewController || ([[ settingsDictionary objectForKey:@"OptionChar"] charValue])& listOfToggles){
        return indexPath;
    }
    
    // returning nil means this specific cell cannot be selected
    return nil;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    // This is because the dictionary was instatiated with NSNumber's that start off at 1
    int index = indexPath.row;
    ++index;
    
    
    NSDictionary *settingsDictionary = self.dataArray[indexPath.row];
    
    //Basic Version checking because the split view controller class is very different in ios 8
    if ([settingsDictionary objectForKey:@"CustomViewController"]) {
        if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")) {
            [self.splitViewController showDetailViewController:(UIViewController *)[settingsDictionary objectForKey:@"CustomViewController"] sender:self];
        } else {
            self.splitViewController.viewControllers = @[self, (UIViewController *)[settingsDictionary objectForKey:@"CustomViewController"]];
        }
        return;
    }
    
    //self.detailViewController.index = index;
    //detailViewController.navigationItem.leftBarButtonItem = self.splitViewController.displayModeButtonItem;
    
    //self.detailViewController.settingsTableViewController = self;
    //self.detailViewController.arrayOfOptions = [settingsDictionary objectForKey:@"Setting Options"];
    //self.detailViewController.arrayOfToggleOptions = [settingsDictionary objectForKey:@"Toggle Settings"];
    self.detailViewController.swipeableTableViewCell = (SwipeableTableViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];
    self.detailViewController.title =[settingsDictionary objectForKey:@"Setting Label"];
    self.detailViewController.dataDictionary = self.dataArray[indexPath.row][@"DataDictionary"];
    [self.detailViewController.tableView reloadData];
    
    
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")) {
        [self.splitViewController showDetailViewController: self.detailViewController sender:self];
    } else {
        self.splitViewController.viewControllers = @[self, self.detailViewController];
    }
    //[self.splitViewController showViewController: detailViewController sender: self];
    //[self.navigationController pushViewController:detailViewController animated:YES];
    
    
}



// THIS IS WHERE ALL THE SIGNALS ARE SENT
#pragma mark- Signal from Detail View Controller

- (void)choseCellWithString: (NSString*)optionLabel{
    NSLog(@"The chosen cell was %@", optionLabel);
}

#pragma mark - SwipeableCellDelegate


// This function is called upon when the cells toggle is switched
- (void)switchStateSignal:(BOOL)onOrOff fromCell: (SwipeableTableViewCell *) theCell{
    
    NSDictionary *signalPackage = @{@"Name": theCell.myTextLabel.text, @"Value": (onOrOff ? @YES:@NO), @"Type": @"Toggle"};
    [self.signalReciever settingChanged: signalPackage fromCell: theCell ];
    
}

// This function is called when the rightmost button is called upon
- (void)buttonOneActionForItemText:(NSString *)itemText
{
    // Passing control to another method that opens up a new window
    [self showDetailWithText:[NSString stringWithFormat: itemText]];
}

// This function is called when the leftmost button is called upon
- (void)buttonTwoActionForItemText:(NSString *)itemText
{
    // Passing control to another method that opens up a new window
    [self showDetailWithText:[NSString stringWithFormat: itemText]];
}

-(void)specificSettingChosen: (NSString *) theSetting fromCell: (SwipeableTableViewCell *)theCell{
    NSDictionary *signalPackage = @{ @"Name": theCell.myTextLabel.text , @"Value": theSetting, @"Type": @"List"};
    [self.signalReciever settingChanged: signalPackage fromCell: theCell ];
}

// CODE THAT CAN BE ALTERED BEGINS HERE:
// This function can be altered such that the page that pops up displays
// anything
- (void)showDetailWithText:(NSString *)detailText
{
    UIViewController *theViewController = [[UIViewController alloc] init];
    theViewController.view.backgroundColor = [UIColor whiteColor];
    theViewController.title = detailText;
    //[self presentViewController:buttonViewController animated:YES completion:nil];
    [self.navigationController pushViewController:theViewController animated:YES];
    
}

// CODE THAT CAN BE ALTERED ENDS HERE

- (void)closeModal
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void) selectCellAtIndexPath:(NSIndexPath *)indexPath{
    [self tableView:self.tableView didSelectRowAtIndexPath:indexPath];
}



@end



