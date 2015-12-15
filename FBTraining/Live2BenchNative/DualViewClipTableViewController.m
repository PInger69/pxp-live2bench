//
//  DualViewClipTableViewController.m
//  Live2BenchNative
//
//  Created by Nico Cvitak on 2015-05-20.
//  Copyright (c) 2015 DEV. All rights reserved.
//

#import "DualViewClipTableViewController.h"

#import "Tag.h"

@interface DualViewClipTableViewController () <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic, nonnull) UISwipeGestureRecognizer *swipeGestureRecognizer;

@end

@implementation DualViewClipTableViewController
{
    void *_context;
}

- (instancetype)initWithTags:(nonnull NSArray *)tags {
    self = [super init];
    if (self) {
        self.tableView = [[UITableView alloc] init];
        
        self.tags = tags;
        
        self.swipeGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeRecognized:)];
        self.swipeGestureRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
        self.view.frame = CGRectZero;
        
        _presented = YES;
        
        _context = &_context;
        
        [self.view addObserver:self forKeyPath:@"frame" options:NSKeyValueObservingOptionNew context:_context];
    }
    return self;
}

- (instancetype)init {
    return [self initWithTags:@[]];
}

- (void)dealloc {
    [self.view removeObserver:self forKeyPath:@"frame" context:_context];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.clipsToBounds = YES;
    
    self.tableView.backgroundColor = [UIColor clearColor];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"UITableViewCell"];
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.allowsMultipleSelection = NO;
    self.tableView.bounces = NO;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    [self.tableView addGestureRecognizer:self.swipeGestureRecognizer];
    
    [self.view addSubview:self.tableView];
    
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
        
        if (self.presented) {
            self.tableView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
        } else {
            self.tableView.frame = CGRectMake(-self.view.frame.size.width, 0, self.view.frame.size.width, self.view.frame.size.height);
        }
        
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

- (void)swipeRecognized:(UISwipeGestureRecognizer *)recognizer {
    [self dismiss:YES];
    //[self.view removeFromSuperview];
}

#pragma mark - Hide / Show

- (void)present:(BOOL)animated {
    if (!self.presented) {
        
        if (animated) {
            [UIView beginAnimations:nil context:nil];
            [UIView setAnimationDuration:0.2];
        }
        
        self.tableView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
        
        if (animated) {
            [UIView commitAnimations];
        }
        
        _presented = YES;
    }
}

- (void)dismiss:(BOOL)animated {
    if (self.presented) {
        
        if (animated) {
            [UIView beginAnimations:nil context:nil];
            [UIView setAnimationDuration:0.2];
        }
        
        self.tableView.frame = CGRectMake(-self.view.frame.size.width, 0, self.view.frame.size.width, self.view.frame.size.height);
        
        if (animated) {
            [UIView commitAnimations];
        }
        
        _presented = NO;
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    NSInteger count = self.tags.count;
    return count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell" forIndexPath:indexPath];
    
    // Configure the cell...
    Tag *tag = self.tags[indexPath.row];
    
    cell.textLabel.text = [NSString stringWithFormat:@"Clip %@", tag.displayTime];
    cell.backgroundColor = [UIColor clearColor];
    cell.textLabel.highlightedTextColor = PRIMARY_APP_COLOR;
    cell.selectionStyle = UITableViewCellSelectionStyleGray;
    cell.backgroundView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleExtraLight]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.delegate) {
        [self.delegate clipController:self didSelectTagClip:self.tags[indexPath.row]];
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
