//
//  FeedSelectionTableViewController.m
//  Live2BenchNative
//
//  Created by Nico Cvitak on 2015-05-22.
//  Copyright (c) 2015 DEV. All rights reserved.
//

#import "FeedSelectionController.h"
#import "Feed.h"

@interface FeedSelectionController () <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic, nonnull) UISwipeGestureRecognizer *leftSwipeGestureRecognizer;
@property (strong, nonatomic, nonnull) UISwipeGestureRecognizer *rightSwipeGestureRecognizer;

@property (strong, nonatomic, nonnull) UITableView *tableView;
@property (assign, nonatomic) BOOL *isPresented;

@end

@implementation FeedSelectionController
{
    void *_context;
}

- (instancetype)initWithFeeds:(nonnull NSArray *)feeds
{
    self = [super init];
    if (self) {
        self.view.clipsToBounds = YES;
        
        self.feeds = feeds;
        
        self.leftSwipeGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(leftSwipeGestureRecognized:)];
        self.rightSwipeGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(rightSwipeGestureRecognized:)];
        
        self.leftSwipeGestureRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
        self.rightSwipeGestureRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
        
        [self.view addGestureRecognizer:self.leftSwipeGestureRecognizer];
        [self.view addGestureRecognizer:self.rightSwipeGestureRecognizer];
        
        self.tableView = [[UITableView alloc] init];
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        self.tableView.backgroundColor = [UIColor clearColor];
        self.tableView.backgroundView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleExtraLight]];
        self.tableView.bounces = NO;
        
        self.isPresented = NO;
        
        [self.view addSubview:self.tableView];
        
        _context = &_context;
        
        [self.view addObserver:self forKeyPath:@"frame" options:NSKeyValueObservingOptionNew context:_context];
        
        [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"UITableViewCell"];
    }
    return self;
}

- (instancetype)init
{
    return [self initWithFeeds:@[]];
}

- (void)dealloc
{
    [self.view removeObserver:self forKeyPath:@"frame" context:_context];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.frame = self.view.bounds;
    // Uncomment the following line to preserve selection between presentations.
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (context == _context) {
        
        if (self.isPresented) {
            self.tableView.frame = self.view.bounds;
        } else {
            self.tableView.frame = CGRectMake(self.view.frame.size.width, 0, self.view.frame.size.width, self.view.frame.size.height);
        }
        
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

- (void)setFeeds:(nonnull NSArray *)feeds {
    _feeds = feeds;
    self.tableView.rowHeight = self.tableView.frame.size.height / MAX(self.feeds.count, 1);
    [self.tableView reloadData];
}

- (void)leftSwipeGestureRecognized:(UISwipeGestureRecognizer *)recognizer {
    [self present:YES];
}

- (void)rightSwipeGestureRecognized:(UISwipeGestureRecognizer *)recognizer {
    [self dismiss:YES];
}

- (void)present:(BOOL)animated {
    if (!self.isPresented) {
        
        if (animated) {
            [UIView beginAnimations:nil context:nil];
            [UIView setAnimationDuration:0.2];
        }
        
        self.tableView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
        
        if (animated) {
            [UIView commitAnimations];
        }
        self.isPresented = YES;
    }
     
}

- (void)dismiss:(BOOL)animated {
    
    if (self.isPresented) {
        if (animated) {
            [UIView beginAnimations:nil context:nil];
            [UIView setAnimationDuration:0.2];
        }
        
        self.tableView.frame = CGRectMake(self.view.frame.size.width, 0, self.view.frame.size.width, self.view.frame.size.height);
        
        if (animated) {
            [UIView commitAnimations];
        }
        
        self.isPresented = NO;
    }
    
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return self.feeds.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell" forIndexPath:indexPath];
    
    Feed *feed = self.feeds[indexPath.row];
    
    unsigned long n;
    
    NSString *feedSourceName = feed.sourceName ? feed.sourceName : @"s_00";
    NSString *soruceName = sscanf(feedSourceName.UTF8String, "s_%lu", &n) == 1 ? [NSString stringWithFormat:@"Cam %lu", n] : feedSourceName;
    
    cell.textLabel.text = soruceName;
    cell.textLabel.highlightedTextColor = PRIMARY_APP_COLOR;
    cell.backgroundColor = [UIColor clearColor];
    // Configure the cell...
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.delegate) {
        [self.delegate feedSelectionController:self didSelectFeed:self.feeds[indexPath.row]];
    }
    [tableView beginUpdates];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [tableView endUpdates];
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
