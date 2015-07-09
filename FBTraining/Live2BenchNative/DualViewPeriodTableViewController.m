//
//  DualViewPeriodTableViewController.m
//  Live2BenchNative
//
//  Created by Nico Cvitak on 2015-05-19.
//  Copyright (c) 2015 DEV. All rights reserved.
//

#import "DualViewPeriodTableViewController.h"

@interface DualViewPeriodTableViewController () <UITableViewDataSource, UITableViewDelegate,UIPopoverControllerDelegate>

@property (strong, nonatomic, nonnull) UITableView *tableView;
@property (strong, nonatomic, nonnull) UIView *pullTabView;

@property (strong, nonatomic, nonnull) UISwipeGestureRecognizer *leftSwipeGestureRecognizer;
@property (strong, nonatomic, nonnull) UISwipeGestureRecognizer *rightSwipeGestureRecognizer;

@property (strong, nonatomic, nonnull) NSMutableDictionary *periods;

@property (strong, nonatomic, nonnull) DualViewClipTableViewController *clipTableViewController;

@property (assign, nonatomic) void *context;

@end

@implementation DualViewPeriodTableViewController
{
    NSComparisonResult (^tagComparator)(Tag *a, Tag *b);
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        self.tableView = [[UITableView alloc] init];
        self.pullTabView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleLight]];
        
        self.leftSwipeGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(leftSwipeGestureRecognized:)];
        self.leftSwipeGestureRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
        [self.tableView addGestureRecognizer:self.leftSwipeGestureRecognizer];
        
        self.rightSwipeGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(rightSwipeGestureRecognized:)];
        self.rightSwipeGestureRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
        [self.pullTabView addGestureRecognizer:self.rightSwipeGestureRecognizer];
        
        self.tagNames = @[];
        
        self.periods = [NSMutableDictionary dictionary];
        
        self.clipTableViewController = [[DualViewClipTableViewController alloc] initWithTags:@[]];
        [self addChildViewController:self.clipTableViewController];
        
        tagComparator = ^NSComparisonResult(Tag *a, Tag *b) {
            return a.time > b.time ? NSOrderedDescending : a.time < b.time ? NSOrderedAscending : NSOrderedSame;
        };
        
        _tags  = [[NSMutableArray alloc]init];
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
    self.tableView.allowsMultipleSelection = NO;
    self.tableView.bounces = NO;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.backgroundView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleExtraLight]];
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"UITableViewCell"];
    
    self.pullTabView.frame = CGRectMake(self.tableView.frame.size.width, self.view.frame.size.height / 2.0 - 64, 16, 128);
    self.pullTabView.alpha = 0.0;
    
    [self.view addSubview:self.clipTableViewController.view];
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
        if (self.tagNames.count > 0) {
            self.tableView.rowHeight = floor(self.tableView.frame.size.height / MAX(self.tagNames.count, 12));
        }
        self.pullTabView.frame = CGRectMake(self.tableView.frame.size.width, self.view.frame.size.height / 2.0 - 64, 16, 128);
    }
    
}

- (void)setDelegate:(nullable id<DualViewTagControllerDelegate>)delegate {
    _delegate = delegate;
    self.clipTableViewController.delegate = delegate;
}

- (void)setTableWidth:(CGFloat)tableWidth {
    self.tableView.frame = CGRectMake(self.tableView.frame.origin.x, self.tableView.frame.origin.y, tableWidth, self.tableView.frame.size.height);
}

- (CGFloat)tableWidth {
    return self.tableView.frame.size.width;
}

- (void)setTagNames:(nonnull NSArray *)tagNames {
    _tagNames = tagNames;
    
    for (NSString *tagName in self.tagNames) {
        self.periods[tagName] = [NSMutableArray array];
    }
    if (self.tagNames.count > 0) {
        self.tableView.rowHeight = floor(self.tableView.frame.size.height / MAX(self.tagNames.count, 12));
    }
    [self.tableView reloadData];
}

- (void)setTags:(nonnull NSMutableArray *)tags {
    
    [_tags removeAllObjects];
    
    // clear the tag sets
    for (NSMutableArray *tagArray in [self.periods allValues]) {
        [tagArray removeAllObjects];
    }
    
    // add in the new tags
    for (Tag *tag in tags) {
        [self addTag:tag];
    }
}

- (void)addTag:(nonnull Tag *)tag {
    
    if (tag.type != TagTypeDeleted && tag.type != TagTypeOpenDuration) {
        
        BOOL found = NO;
        for (NSUInteger i = 0; !found && i < _tags.count; i++) {
            if ([_tags[i] uniqueID] == tag.uniqueID) {
                _tags[i] = tag;
                found = YES;
            }
        }
        if (!found) {
            [_tags addObject:tag];
        }
        
        // we need to add the tag such that the array remains sorted
        NSMutableArray *tagArray = self.periods[tag.name];
        if (tagArray) {
            NSUInteger index = [tagArray indexOfObject:tag inSortedRange:(NSRange){0, tagArray.count} options:NSBinarySearchingInsertionIndex usingComparator:tagComparator];
            
            // modify the tag if the
            if (index < tagArray.count && [tagArray[index] uniqueID] == tag.uniqueID) {
                tagArray[index] = tag;
            } else {
                [tagArray insertObject:tag atIndex:index];
            }
        }
        [self.tableView reloadData];
        [self.clipTableViewController.tableView reloadData];
    }
    
}

- (void)removeTag:(nonnull Tag *)tag {
    [_tags removeObject:tag];
    [self.periods[tag.name] removeObject:tag];
    [self.tableView reloadData];
    [self.clipTableViewController.tableView reloadData];
}

#pragma mark - Hide / Show stuff

- (void)setHidden:(BOOL)hidden animated:(BOOL)animated {
    _hidden = hidden;
    if (hidden) {
        [self dismiss:animated];
    } else {
        [self show:animated];
    }
}

- (void)setHidden:(BOOL)hidden {
    [self setHidden:hidden animated:NO];
}

- (void)dismiss:(BOOL)animated {
    [self.clipTableViewController dismiss:animated];
    
    if (animated) {
        [UIView beginAnimations:nil context:nil];
        
        [UIView setAnimationDuration:0.2];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
    }
    
    self.tableView.frame = CGRectMake(-self.tableView.frame.size.width, self.tableView.frame.origin.y, self.tableView.frame.size.width, self.tableView.frame.size.height);
    self.clipTableViewController.view.frame = CGRectMake(self.clipTableViewController.view.frame.origin.x - self.tableView.frame.size.width, self.clipTableViewController.view.frame.origin.y, self.clipTableViewController.view.frame.size.width, self.clipTableViewController.view.frame.size.height);
    
    self.pullTabView.alpha = 1.0;
    self.pullTabView.frame = CGRectMake(0, self.pullTabView.frame.origin.y, self.pullTabView.frame.size.width, self.pullTabView.frame.size.height);
    
    if (animated) {
        [UIView commitAnimations];
    }
}

- (void)show:(BOOL)animated {
    if (animated) {
        [UIView beginAnimations:nil context:nil];
        
        [UIView setAnimationDuration:0.2];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
    }
    
    self.tableView.frame = CGRectMake(0, self.tableView.frame.origin.y, self.tableView.frame.size.width, self.tableView.frame.size.height);
    
    self.clipTableViewController.view.frame = CGRectMake(self.clipTableViewController.view.frame.origin.x + self.tableView.frame.size.width, self.clipTableViewController.view.frame.origin.y, self.clipTableViewController.view.frame.size.width, self.clipTableViewController.view.frame.size.height);
    
    self.pullTabView.alpha = 0.0;
    self.pullTabView.frame = CGRectMake(self.tableView.frame.size.width, self.pullTabView.frame.origin.y, self.pullTabView.frame.size.width, self.pullTabView.frame.size.height);
    
    if (animated) {
        [UIView commitAnimations];
    }
}

#pragma mark - gesture recognizers

- (void)leftSwipeGestureRecognized:(UISwipeGestureRecognizer *)recognizer {
    if (!self.hidden) {
        [self dismiss:YES];
    }
}

- (void)rightSwipeGestureRecognized:(UISwipeGestureRecognizer *)recognizer {
    if (!self.hidden ) {
        [self show:YES];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return self.tagNames.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell" forIndexPath:indexPath];
    
    NSString *name = self.tagNames[indexPath.row];
    NSArray *tagsForPeriod = self.periods[name];
    
    cell.textLabel.text = name;
    cell.backgroundColor = [UIColor clearColor];
    cell.textLabel.highlightedTextColor = PRIMARY_APP_COLOR;
    cell.selectionStyle = UITableViewCellSelectionStyleGray;
    cell.accessoryType = tagsForPeriod.count > 0 ? UITableViewCellAccessoryDisclosureIndicator : UITableViewCellAccessoryNone;
    
    return cell;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *name = self.tagNames[indexPath.row];
    
    if ([name hasPrefix:@"-"]) {
        return nil;
    } else {
        
        NSIndexPath *selected = [tableView indexPathForSelectedRow];
        
        if (![selected isEqual:indexPath]) {
            [tableView beginUpdates];
            [tableView deselectRowAtIndexPath:selected animated:YES];
            [tableView endUpdates];
            [self tableView:tableView didDeselectRowAtIndexPath:selected];
        }
        
        return ![selected isEqual:indexPath] || !self.clipTableViewController.presented ? indexPath : nil;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *name = self.tagNames[indexPath.row];
    
    if (self.delegate) {
        [self.delegate tagController:self didSelectTagNamed:name];
    }
    
    NSArray *tagsForPeriod = self.periods[name];
    
    if (tagsForPeriod.count > 0) {
        
        CGFloat rowHeight = self.tableView.rowHeight;
        self.clipTableViewController.tableView.rowHeight = rowHeight;
        
        NSInteger numTags = tagsForPeriod.count;
        CGFloat tableViewHeight = numTags * rowHeight;
        
        CGFloat posY = rowHeight * indexPath.row;
        posY = MAX(0, MIN(posY, self.tableView.frame.size.height - tableViewHeight));
        
        CGRect popoverRect = CGRectMake(self.tableView.frame.size.width, posY, self.tableView.frame.size.width, self.tableView.frame.size.height - posY + 1);
        
        self.clipTableViewController.view.frame = popoverRect;
        self.clipTableViewController.tags = tagsForPeriod;
        [self.clipTableViewController.tableView reloadData];
        [self.clipTableViewController present:YES];
    }
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.clipTableViewController dismiss:YES];
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
