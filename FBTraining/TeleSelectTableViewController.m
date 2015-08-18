//
//  TeleSelectTableViewController.m
//  Live2BenchNative
//
//  Created by Nico Cvitak on 2015-07-23.
//  Copyright © 2015 DEV. All rights reserved.
//

#import "TeleSelectTableViewController.h"

#import "ImageAssetManager.h"

@interface TeleSelectTableViewCell : UITableViewCell

@property (strong, nonatomic, nullable) Tag *teleTag;

@end

@implementation TeleSelectTableViewCell
{
    UIImageView * __nonnull _thumbnailView;
     UILabel * __nonnull _timeLabel;
}

- (nonnull instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(nullable NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _timeLabel = [[UILabel alloc] init];
        _thumbnailView = [[UIImageView alloc] init];
        _thumbnailView.contentMode = UIViewContentModeScaleAspectFit;
        _thumbnailView.backgroundColor = [UIColor blackColor];
        
        _timeLabel.textColor = [UIColor whiteColor];
        _timeLabel.highlightedTextColor = PRIMARY_APP_COLOR;
        _timeLabel.textAlignment = NSTextAlignmentRight;
        _timeLabel.adjustsFontSizeToFitWidth = YES;
        
        [self addSubview:_timeLabel];
        [self addSubview:_thumbnailView];
        
        UIView *selectedView = [[UIView alloc] init];
        selectedView.backgroundColor = [PRIMARY_APP_COLOR colorWithAlphaComponent:0.1];
        self.selectedBackgroundView = selectedView;
        
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)setTeleTag:(nullable Tag *)teleTag {
    _teleTag = teleTag;
    
    UIImage *thumb = [teleTag thumbnailForSource:teleTag.telestration.sourceName];
    
    _timeLabel.text = teleTag.displayTime;
    if (thumb) {
        _thumbnailView.image = thumb;
    } else {
        //ImageAssetManager *imageAssetManager = [[ImageAssetManager alloc] init];
        
        NSString *url = teleTag.telestration.sourceName && teleTag.thumbnails[teleTag.telestration.sourceName] ? teleTag.thumbnails[teleTag.telestration.sourceName] : teleTag.thumbnails.allValues.firstObject;
        [[ImageAssetManager getInstance] imageForURL:url atImageView:_thumbnailView withTelestration:teleTag.telestration];
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat thumbWidth = self.bounds.size.height * (16.0 / 9.0);
    
    _timeLabel.frame = CGRectMake(self.bounds.origin.x + 11.0, self.bounds.origin.y, self.bounds.size.width - thumbWidth - 22.0, self.bounds.size.height);
    _thumbnailView.frame = CGRectMake(self.bounds.origin.x + self.bounds.size.width - thumbWidth, self.bounds.origin.y, thumbWidth, self.bounds.size.height);

    _timeLabel.font = [UIFont systemFontOfSize:self.bounds.size.height * PHI_INV];
}

@end

@interface TeleSelectTableViewController ()

@end

static  NSPredicate * __nonnull _tagFilterPredicate;
static __nonnull NSComparator _tagSortBlock;

@implementation TeleSelectTableViewController
{
    NSMutableArray *_teleTags;
}

+ (void)initialize {
    _tagFilterPredicate = [NSPredicate predicateWithFormat:@"type = %ld", (long) TagTypeTele];
    _tagSortBlock = ^(Tag *a, Tag *b) {
        return a.startTime > b.startTime ? NSOrderedAscending : a.startTime < b.startTime ? NSOrderedDescending : NSOrderedSame;
    };
}

- (nonnull instancetype)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self) {
        _teleTags = [NSMutableArray array];
        _event = nil;
        _ascending = NO;
    }
    return self;
}

#pragma mark - Getters / Setters

- (void)setEvent:(nullable Event *)event {
    if (_event) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIF_TAG_RECEIVED object:_event];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIF_TAG_MODIFIED object:_event];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIF_TAGS_ARE_READY object:_event];
    }
    _event = event;
    if (_event) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tagUpdateHandler:) name:NOTIF_TAG_RECEIVED object:_event];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tagUpdateHandler:) name:NOTIF_TAG_MODIFIED object:_event];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tagReadyHandler:) name:NOTIF_TAGS_ARE_READY object:_event];
    }
    
    self.tags = _event.tags ? _event.tags : @[];
}

- (void)setAscending:(BOOL)ascending {
    _ascending = ascending;
    [self.tableView reloadData];
}

- (void)setTags:(nonnull NSArray *)tags {
    NSArray *teleTags = [tags filteredArrayUsingPredicate:_tagFilterPredicate];
    
    _teleTags = [NSMutableArray array];
    
    for (Tag *tag in teleTags) {
        NSUInteger i = [_teleTags indexOfObject:tag inSortedRange:NSMakeRange(0, _teleTags.count) options:NSBinarySearchingInsertionIndex usingComparator:_tagSortBlock];
        
        [_teleTags insertObject:tag atIndex:i];
    }
    [self.tableView reloadData];
}

- (void)addTag:(nonnull Tag *)tag {
    if (tag.type == TagTypeTele) {
        NSUInteger i = [_teleTags indexOfObject:tag inSortedRange:NSMakeRange(0, _teleTags.count) options:NSBinarySearchingInsertionIndex | NSBinarySearchingFirstEqual usingComparator:_tagSortBlock];
        
        if (i < _teleTags.count && [_teleTags[i] isEqual: tag]) {
            _teleTags[i] = tag;
            [self.tableView reloadRowsAtIndexPaths:@[[self indexPathForTagIndex:i]] withRowAnimation:UITableViewRowAnimationAutomatic];
        } else {
            [_teleTags insertObject:tag atIndex:i];
            
            [self.tableView beginUpdates];
            [self.tableView insertRowsAtIndexPaths:@[[self indexPathForTagIndex:i]] withRowAnimation:UITableViewRowAnimationAutomatic];
            [self.tableView endUpdates];
        }
    }
}

- (void)removeTag:(nonnull Tag *)tag {
    if (tag.type == TagTypeTele) {
        NSUInteger i = [_teleTags indexOfObject:tag inSortedRange:NSMakeRange(0, _teleTags.count) options:NSBinarySearchingFirstEqual usingComparator:_tagSortBlock];
        
        if (i < _teleTags.count && [_teleTags[i] isEqual:tag]) {
            [_teleTags removeObjectAtIndex:i];
            
            [self.tableView beginUpdates];
            [self.tableView deleteRowsAtIndexPaths:@[[self indexPathForTagIndex:i]] withRowAnimation:UITableViewRowAnimationAutomatic];
            [self.tableView endUpdates];
        }
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tableView registerClass:[TeleSelectTableViewCell class] forCellReuseIdentifier:@"TeleSelectTableViewCell"];
    
    self.tableView.rowHeight = 88.0;
    
    if ([UIDevice currentDevice].systemVersion.doubleValue >= 8.0) {
        UIVisualEffectView *visualEffectView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleDark]];
        self.tableView.backgroundView = visualEffectView;
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

#pragma mark - Notification Handling

- (void)tagUpdateHandler:(NSNotification *)note {
    NSArray *tags = note.userInfo[@"tags"];
    for (Tag *tag in tags) {
        if (tag.type == TagTypeDeleted) {
            [self removeTag:tag];
        } else {
            [self addTag:tag];
        }
    }
}

- (void)tagsReadyHandler:(NSNotification *)note {
    self.tags = _event.tags ? _event.tags : @[];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _teleTags.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TeleSelectTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TeleSelectTableViewCell" forIndexPath:indexPath];
    
    // Configure the cell...
    cell.teleTag = _teleTags[[self tagIndexForIndexPath:indexPath]];
    
    return cell;
}

- (CGFloat)tableView:(nonnull UITableView *)tableView heightForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    return self.tableView.rowHeight;
}

- (NSUInteger)tagIndexForIndexPath:(nonnull NSIndexPath *)indexPath; {
    return _ascending ? _teleTags.count - indexPath.row - 1 : indexPath.row;
}

- (nonnull NSIndexPath *)indexPathForTagIndex:(NSUInteger)tagIndex {
    return [NSIndexPath indexPathForRow:_ascending ? _teleTags.count - tagIndex - 1 : tagIndex inSection:0];
}

- (void)tableView:(nonnull UITableView *)tableView didSelectRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    Tag *tag = _teleTags[[self tagIndexForIndexPath:indexPath]];
    [self.tagSelectResponder didSelectTag:tag source:tag.telestration.sourceName ? tag.telestration.sourceName : tag.event.feeds.allKeys.firstObject];
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
