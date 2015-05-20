//
//  FBTrainingPeriodTableViewController.m
//  Live2BenchNative
//
//  Created by Nico Cvitak on 2015-05-19.
//  Copyright (c) 2015 DEV. All rights reserved.
//

#import "FBTrainingPeriodTableViewController.h"

#import "Tag.h"
#import "FBTrainingClipTableViewController.h"

@interface FBTrainingPeriodTableViewController () <UITableViewDataSource, UITableViewDelegate,UIPopoverControllerDelegate>

@property (strong, nonatomic, nonnull) UITableView *tableView;
@property (strong, nonatomic, nonnull) UIView *pullTabView;

@property (strong, nonatomic, nonnull) UISwipeGestureRecognizer *leftSwipeGestureRecognizer;
@property (strong, nonatomic, nonnull) UISwipeGestureRecognizer *rightSwipeGestureRecognizer;

@property (strong, nonatomic, nonnull) NSMutableDictionary *periods;

@property (strong, nonatomic, nullable) NSIndexPath *selectedIndexPath;
@property (strong, nonatomic, nullable) UIPopoverController *activePopoverController;

@property (assign, nonatomic) void *context;

@end

@implementation FBTrainingPeriodTableViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        self.tableView = [[UITableView alloc] init];
        self.pullTabView = [[UIView alloc] init];
        
        self.leftSwipeGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(leftSwipeGestureRecognized:)];
        self.leftSwipeGestureRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
        [self.tableView addGestureRecognizer:self.leftSwipeGestureRecognizer];
        
        self.rightSwipeGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(rightSwipeGestureRecognized:)];
        self.rightSwipeGestureRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
        [self.pullTabView addGestureRecognizer:self.rightSwipeGestureRecognizer];
        
        self.periods = [NSMutableDictionary dictionary];
        
        for (NSUInteger i = 0; i < 24; i++) {
            NSString *name = [NSString stringWithFormat:@"P%02lu", (unsigned long) i + 1];
            self.periods[name] = [NSMutableSet set];
           
            // temporary random generation
            for (NSUInteger j = 1; j < drand48() * 10; j++) {
                Tag *tag = [[Tag alloc] init];
                tag.name = name;
                tag.startTime = drand48() * 60.0;
                
                [self.periods[tag.name] addObject:tag];
            }
            
        }
        
        _context = &_context;
        
        [self.view addObserver:self forKeyPath:@"frame" options:NSKeyValueObservingOptionNew context:_context];
    }
    return self;
}

- (void)dealloc {
    [self.view removeObserver:self forKeyPath:@"frame" context:_context];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.frame = CGRectMake(0, 0, 160, self.view.frame.size.height);
    self.tableView.rowHeight = self.tableView.frame.size.height / 24.0;
    self.tableView.allowsMultipleSelection = NO;
    self.tableView.bounces = NO;
    self.tableView.pagingEnabled = NO;
    self.tableView.layoutMargins = UIEdgeInsetsZero;
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"UITableViewCell"];
    
    self.pullTabView.frame = CGRectMake(self.tableView.frame.size.width, self.view.frame.size.height / 2.0 - 64, 16, 128);
    self.pullTabView.backgroundColor = [[UIColor darkGrayColor] colorWithAlphaComponent:0.75];
    self.pullTabView.alpha = 0.0;
    
    [self.view addSubview:self.tableView];
    [self.view addSubview:self.pullTabView];
    
    // Uncomment the following line to preserve selection between presentations.
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    
    if (context == _context) {
        self.tableView.frame = CGRectMake(0, 0, 160, self.view.frame.size.height);
        self.tableView.rowHeight = self.tableView.frame.size.height / 24.0;
        self.pullTabView.frame = CGRectMake(self.tableView.frame.size.width, self.view.frame.size.height / 2.0 - 64, 16, 128);
    }
    
}

#pragma mark - gesture recognizers

- (void)leftSwipeGestureRecognized:(UISwipeGestureRecognizer *)recognizer {
    [UIView beginAnimations:nil context:nil];
    
    [UIView setAnimationDuration:0.2];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
    self.tableView.frame = CGRectMake(-self.tableView.frame.size.width, self.tableView.frame.origin.y, self.tableView.frame.size.width, self.tableView.frame.size.height);
    
    self.pullTabView.alpha = 1.0;
    self.pullTabView.frame = CGRectMake(0, self.pullTabView.frame.origin.y, self.pullTabView.frame.size.width, self.pullTabView.frame.size.height);
    
    
    [UIView commitAnimations];
}

- (void)rightSwipeGestureRecognized:(UISwipeGestureRecognizer *)recognizer {
    [UIView beginAnimations:nil context:nil];
    
    [UIView setAnimationDuration:0.2];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
    
    self.tableView.frame = CGRectMake(0, self.tableView.frame.origin.y, self.tableView.frame.size.width, self.tableView.frame.size.height);
    
    self.pullTabView.alpha = 0.0;
    self.pullTabView.frame = CGRectMake(self.tableView.frame.size.width, self.pullTabView.frame.origin.y, self.pullTabView.frame.size.width, self.pullTabView.frame.size.height);
    
    [UIView commitAnimations];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return self.periods.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell" forIndexPath:indexPath];
    
    cell.textLabel.text = [NSString stringWithFormat:@"%@ %ld", NSLocalizedString(@"Period", nil), (long) indexPath.row + 1];
    
    NSString *name = [NSString stringWithFormat:@"P%02ld", (long) indexPath.row + 1];
    NSSet *tagsForPeriod = self.periods[name];
    
    cell.accessoryType = tagsForPeriod.count > 0 ? UITableViewCellAccessoryDisclosureIndicator : UITableViewCellAccessoryNone;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    self.selectedIndexPath = indexPath;
    
    NSString *name = [NSString stringWithFormat:@"P%02ld", (long) indexPath.row + 1];
    NSSet *tagsForPeriod = self.periods[name];
    
    if (tagsForPeriod.count > 0) {
        FBTrainingClipTableViewController *clipTableViewController = [[FBTrainingClipTableViewController alloc] initWithTags:[tagsForPeriod allObjects]];
        
        CGFloat rowHeight = self.tableView.rowHeight;
        clipTableViewController.tableView.rowHeight = rowHeight;
        
        NSInteger numTags = [clipTableViewController tableView:clipTableViewController.tableView numberOfRowsInSection:0];
        CGFloat tableViewHeight = numTags * rowHeight;
        
        self.activePopoverController = [[UIPopoverController alloc] initWithContentViewController:clipTableViewController];
        
        self.activePopoverController.delegate = self;
        self.activePopoverController.popoverContentSize = CGSizeMake(160, tableViewHeight);
        self.activePopoverController.backgroundColor = [UIColor clearColor];
        
        UITableViewCell *cell = [self tableView:self.tableView cellForRowAtIndexPath:indexPath];
        
        CGFloat posY = cell.frame.origin.y + 2.0 - rowHeight / 3.0 + tableViewHeight / 2.0;
        posY = MIN(posY, self.tableView.bounds.size.height - tableViewHeight / 2.0 - 7.0);
        
        CGRect popoverRect = CGRectMake(cell.frame.origin.x + 160, posY, cell.frame.size.width, cell.frame.size.height);
        
        [self.activePopoverController presentPopoverFromRect:popoverRect inView:self.tableView permittedArrowDirections:0 animated:NO];
        
    } else {
        [self.tableView beginUpdates];
        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
        [self.tableView endUpdates];
        [self tableView:self.tableView didDeselectRowAtIndexPath:indexPath];
    }
    
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.selectedIndexPath = nil;
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

#pragma mark - UIPopoverControllerDelegate

- (BOOL)popoverControllerShouldDismissPopover:(UIPopoverController *)popoverController {
    [popoverController dismissPopoverAnimated:NO];
    return YES;
}

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController {
    [self.tableView beginUpdates];
    [self.tableView deselectRowAtIndexPath:self.selectedIndexPath animated:NO];
    [self.tableView endUpdates];
    [self tableView:self.tableView didDeselectRowAtIndexPath:self.selectedIndexPath];
    
    self.activePopoverController = nil;
}

#pragma mark - Gesture Recognizers



/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
