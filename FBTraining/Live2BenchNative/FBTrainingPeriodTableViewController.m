//
//  FBTrainingPeriodTableViewController.m
//  Live2BenchNative
//
//  Created by Nico Cvitak on 2015-05-19.
//  Copyright (c) 2015 DEV. All rights reserved.
//

#import "FBTrainingPeriodTableViewController.h"

#import "Tag.h"

@interface FBTrainingPeriodTableViewController () <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic, nonnull) UITableView *tableView;
@property (strong, nonatomic, nonnull) UITableView *auxiliaryTableView;

@property (strong, nonatomic, nonnull) UISwipeGestureRecognizer *auxiliarySwipeGestureRecognizer;

@property (strong, nonatomic, nonnull) NSArray *periods;
@property (strong, nonatomic, nullable) NSIndexPath *selectedIndexPath;

@end

@implementation FBTrainingPeriodTableViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.tableView = [[UITableView alloc] init];
        self.tableView.dataSource = self;
        self.tableView.delegate = self;
        self.tableView.allowsMultipleSelection = NO;
        
        self.auxiliaryTableView = [[UITableView alloc] init];
        self.auxiliaryTableView.dataSource = self;
        self.auxiliaryTableView.delegate = self;
        
        self.auxiliarySwipeGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(auxiliarySwipeGestureRecognized:)];
        self.auxiliarySwipeGestureRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
        [self.auxiliaryTableView addGestureRecognizer:self.auxiliarySwipeGestureRecognizer];
        
        NSMutableArray *periods = [NSMutableArray array];
        for (NSUInteger i = 0; i < 24; i++) {
            NSMutableArray *tags = [NSMutableArray array];
            
            for (NSUInteger j = 0; j < 6; j++) {
                Tag *tag = [[Tag alloc] init];
                tag.name = [NSString stringWithFormat:@"Clip %ld", (long) j + 1];
                
                [tags addObject:tag];
            }
            
            [periods addObject:tags];
        }
        self.periods = periods;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.frame = CGRectMake(0, 0, 320, self.view.frame.size.height);
    self.tableView.frame = CGRectMake(0, 0, 160, self.view.frame.size.height);
    self.auxiliaryTableView.frame = CGRectMake(0, 0, 160, self.view.frame.size.height);
    
    // auxiliary goes first so it is behind
    [self.view addSubview:self.auxiliaryTableView];
    [self.view addSubview:self.tableView];
    
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"UITableViewCell"];
    [self.auxiliaryTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"UITableViewCell"];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)auxiliarySwipeGestureRecognized:(UISwipeGestureRecognizer *)recognizer {
    [self.tableView deselectRowAtIndexPath:self.selectedIndexPath animated:YES];
    [self tableView:self.tableView didDeselectRowAtIndexPath:self.selectedIndexPath];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    
    if (tableView == self.tableView) {
        return self.periods.count;
    } else if (tableView == self.auxiliaryTableView) {
        NSArray *tags = self.selectedIndexPath ? self.periods[self.selectedIndexPath.row] : nil;
        return tags ? tags.count : 0;
    } else {
        return 0;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell" forIndexPath:indexPath];
    
    if (tableView == self.tableView) {
        
        cell.textLabel.text = [NSString stringWithFormat:@"%@ %ld", NSLocalizedString(@"Period", nil), (long) indexPath.row + 1];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        return cell;
    } else if (tableView == self.auxiliaryTableView) {
        
        Tag *tag = self.periods[self.selectedIndexPath.row][indexPath.row];
        
        cell.textLabel.text = [NSString stringWithFormat:@"%ld - %@", (long) self.selectedIndexPath.row + 1, tag.name];
        
        return cell;
    } else {
        return nil;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == self.tableView) {
        
        if (self.selectedIndexPath && indexPath.row == self.selectedIndexPath.row) {
            
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
            [self tableView:tableView didDeselectRowAtIndexPath:indexPath];
            
        } else {
            
            self.selectedIndexPath = indexPath;
            [self.auxiliaryTableView reloadData];
            
            [UIView beginAnimations:@"AuxiliarySlideOut" context:nil];
            [UIView setAnimationDuration:0.3];
            
            // Make the animatable changes.
            self.auxiliaryTableView.frame = CGRectMake(160, 0, self.auxiliaryTableView.frame.size.width, self.auxiliaryTableView.frame.size.height);
            
            // Commit the changes and perform the animation.
            [UIView commitAnimations];
        }
        
    } else if (tableView == self.auxiliaryTableView) {
        
    }
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == self.tableView) {
        
        self.selectedIndexPath = nil;
        [self.auxiliaryTableView reloadData];
        
        [UIView beginAnimations:@"AuxiliarySlideIn" context:nil];
        [UIView setAnimationDuration:0.3];
        
        // Make the animatable changes.
        self.auxiliaryTableView.frame = CGRectMake(0, 0, self.auxiliaryTableView.frame.size.width, self.auxiliaryTableView.frame.size.height);
        
        // Commit the changes and perform the animation.
        [UIView commitAnimations];
        
        
    } else if (tableView == self.auxiliaryTableView) {
        
    }
}


/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */

/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
 } else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }
 }
 */

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
