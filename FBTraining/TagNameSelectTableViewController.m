//
//  TagNameSelectTableViewController.m
//  Live2BenchNative
//
//  Created by Nico Cvitak on 2015-07-22.
//  Copyright © 2015 DEV. All rights reserved.
//

#import "TagNameSelectTableViewController.h"

@interface TagNameSelectTableViewController ()

@property (strong, nonatomic, nonnull) NSArray *tagNames;

@end

@implementation TagNameSelectTableViewController

- (nonnull instancetype)init {
    self = [super init];
    if (self) {
        _tagNames = @[];
    }
    return self;
}

- (nullable instancetype)initWithCoder:(nonnull NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        _tagNames = @[];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"UITableViewCell"];
    
    if ([UIDevice currentDevice].systemVersion.doubleValue >= 8.0) {
        self.tableView.backgroundView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleDark]];
        self.tableView.backgroundColor = [UIColor clearColor];
    } else {
        self.tableView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.75];
    }
    
    // Uncomment the following line to preserve selection between presentations.
    self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
    // Dispose of any resources that can be recreated.
}

#pragma mark - Getters / Setters

- (void)setTagDescriptors:(nonnull NSArray *)tagDescriptors {
    NSArray *sortedTagDescriptors = [tagDescriptors sortedArrayUsingDescriptors:@[
                                                                                  [NSSortDescriptor sortDescriptorWithKey:@"position" ascending:YES],
                                                                                  [NSSortDescriptor sortDescriptorWithKey:@"order" ascending:YES]]];
    
    NSMutableArray *tagNames = [NSMutableArray array];
    
    for (NSUInteger i = 0; i < sortedTagDescriptors.count; i++) {
        NSDictionary *tagDescriptor = sortedTagDescriptors[i];
        NSString *tagName = tagDescriptor[@"name"];
        
        if (tagName && ![tagName hasPrefix:@"-"]) {
            [tagNames addObject:tagName];
        }
    }
    
    self.tagNames = tagNames;
}

- (void)setTagNames:(nonnull NSArray *)tagNames {
    _tagNames = tagNames;
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.tagNames.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell" forIndexPath:indexPath];
    
    // Configure the cell...
    cell.textLabel.text = self.tagNames[indexPath.row];
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.textLabel.highlightedTextColor = tableView.tintColor;
    cell.backgroundColor = [UIColor clearColor];
    
    UIView *selectedView = [[UIView alloc] init];
    selectedView.backgroundColor = [PRIMARY_APP_COLOR colorWithAlphaComponent:0.1];
    
    cell.selectedBackgroundView = selectedView;
    
    return cell;
}

- (void)tableView:(nonnull UITableView *)tableView didSelectRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    [self.tagNameSelectResponder didSelectTagName:self.tagNames[indexPath.row]];
}

- (nullable NSIndexPath *)tableView:(nonnull UITableView *)tableView willSelectRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    NSString *tagName = self.tagNames[indexPath.row];
    return tagName.length > 0 && ![tagName hasPrefix:@"-"] ? indexPath : nil;
}

- (CGFloat)tableView:(nonnull UITableView *)tableView heightForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    return tableView.bounds.size.width * pow(PHI_INV, 3);
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
