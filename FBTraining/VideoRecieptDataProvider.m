//
//  VideoRecieptDataProvider.m
//  Live2BenchNative
//
//  Created by dev on 2016-08-19.
//  Copyright © 2016 DEV. All rights reserved.
//

#import "VideoRecieptDataProvider.h"
#import "PostOperation.h"
#import "VideoRecieptTableViewCell.h"
#import "VideoRecieptTableViewController.h"
#import "UserCenter.h"
#import "VideoRecieptStatusOperation.h"
#import <MessageUI/MessageUI.h>


@interface VideoRecieptDataProvider () <MFMailComposeViewControllerDelegate>

@property (nonatomic,copy) void (^onRefreshComplete)();
@property (nonatomic,strong) NSOperationQueue   * queue;
@property (nonatomic,strong) NSArray            * videoDataList;
@property (nonatomic,strong) UITableView        * tableView;

@property (nonatomic,strong) NSMutableArray     * dataList;

@property (nonatomic,strong)    MFMailComposeViewController *mailComposeViewController;
@end


@implementation VideoRecieptDataProvider
static UIImage * _orangeFill;

- (instancetype)initWithTableView:(UITableView*)tableView
{
    self = [super init];
    if (self) {
        _orangeFill = [Utility makeOnePixelUIImageWithColor:PRIMARY_APP_COLOR];
        self.tableView  = tableView;
        self.queue      = [NSOperationQueue new];
        self.videoDataList   = [NSMutableArray new];
        self.dataList   = [NSMutableArray new];

        
      // [[UserCenter getInstance]videoRecieptDataClear];
        [tableView registerNib:[UINib nibWithNibName:@"VideoRecieptTableViewCell" bundle:nil] forCellReuseIdentifier:@"RecieptCell"];
    }
    return self;
}


-(void)refreshWithKeys:(NSArray*)keys onRefreshComplete:(void(^)())refreshComplete
{
    
    self.onRefreshComplete  = refreshComplete;
    self.videoDataList           = [NSMutableArray arrayWithArray:keys];
    
    [Utility hasInternetOnComplete:^(BOOL succsess) {
        if (succsess){
            [self refresh];
        } else {
            NSLog(@"NO INTERNET");
            self.onRefreshComplete();
        }
    }];
    

    
    
    
    
    
}


-(void)refreshOnRefreshComplete:(void(^)())refreshComplete
{
    
    self.onRefreshComplete  = refreshComplete;
    self.videoDataList           = [[UserCenter getInstance]videoRecieptKeys];
    
    [Utility hasInternetOnComplete:^(BOOL succsess) {
        if (succsess){
            [self refresh];
        } else {
            NSLog(@"NO INTERNET");
            


            
            self.onRefreshComplete();
        }
    }];
    
    
    
    
    
    
    
}



-(void)refresh
{
    [self.dataList removeAllObjects];
    NSString * deviceType   = [UserCenter getInstance].customerAuthorization;
    NSString * userAuth     = [UserCenter getInstance].customerID;
    
    
    NSBlockOperation * blocker = [NSBlockOperation blockOperationWithBlock:^{
        NSSortDescriptor *sorter1 = [NSSortDescriptor
                                     sortDescriptorWithKey:@"date"
                                     ascending:YES
                                     selector:@selector(compare:)];
        NSSortDescriptor *sorter2 =[NSSortDescriptor
                                    sortDescriptorWithKey:@"time"
                                    ascending:YES
                                    selector:@selector(caseInsensitiveCompare:)];
        
        [self.dataList sortUsingDescriptors:@[sorter1,sorter2]];
        
        
        self.onRefreshComplete();
    }];
    
    for (NSDictionary* aVideoData in self.videoDataList) {
        NSString * key = aVideoData[@"xsKey"];
        
        VideoRecieptStatusOperation * checkVideo = [[VideoRecieptStatusOperation alloc]initWithKey:key
                                                                                            device:deviceType
                                                                                          customer:userAuth];

        [checkVideo setOnRequestRecieved:^(VideoRecieptStatusOperation * op) {
            
            
            NSError * error;
            if (op.data){
                
                NSString * theKeyForVideo = op.videoKey;
                NSMutableDictionary * videoData = [[[UserCenter getInstance]videoRecieptDataForKey:theKeyForVideo]mutableCopy];
                NSDictionary * dataFromServer = [Utility JSONDatatoDict:op.data error:&error];
                [videoData setObject:dataFromServer[@"access"] forKey:@"access"];
              
                [self.dataList addObject:videoData];
            
            }
            

        }];
  
        [blocker addDependency:checkVideo];
        
        [self.queue addOperation:checkVideo];
    }
    

    // TODO: sort by date and time
    
    [self.queue addOperation:blocker];
}






- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    return [self.dataList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger r = indexPath.row;
    
    NSDictionary * cellData = self.dataList[r];
    
    
    NSString * date     = (cellData[@"date"])   ? cellData[@"date"]   : @"<date missing>";
    NSString * hTeam    = (cellData[@"hTeam"])  ? [NSString stringWithFormat:@"Home: \t%@",cellData[@"hTeam"]] : @"<hteam missing>";
    NSString * league   = (cellData[@"league"]) ? cellData[@"league"] : @"<league missing>";
    NSString * vTeam    = (cellData[@"vTeam"])  ? [NSString stringWithFormat:@"Away: \t%@",cellData[@"vTeam"]]  : @"<vteam missing>";
    NSString * name     = (cellData[@"name"])   ? cellData[@"name"]   : @"<name missing>";
    NSString * time     = (cellData[@"time"])   ? cellData[@"time"]   : @"<time missing>";
    NSString * linkURL  = (cellData[@"xsURL"])  ? cellData[@"xsURL"]  : @"";
    
    
    VideoRecieptTableViewCell *cell  =  [tableView dequeueReusableCellWithIdentifier:@"RecieptCell"];
    if (!cell) {
        cell = [[VideoRecieptTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"RecieptCell"];
    }
    
    
    void (^buttonStyling)(UIButton*) = ^void(UIButton*btn){
    
        btn.tag = r;
        btn.layer.borderWidth = 1;
        btn.layer.borderColor = PRIMARY_APP_COLOR.CGColor;
        btn.titleLabel.textColor = PRIMARY_APP_COLOR;
        [btn setTitleColor:PRIMARY_APP_COLOR forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
        [btn setBackgroundImage:_orangeFill forState:UIControlStateHighlighted];
    };
    
    
    // buttons
    [cell.onCopyButton addTarget:self action:@selector(cellCopyButton:) forControlEvents:UIControlEventTouchUpInside];
    buttonStyling(cell.onCopyButton);
    [cell.onEmailButton addTarget:self action:@selector(cellEmailButton:) forControlEvents:UIControlEventTouchUpInside];
    buttonStyling(cell.onEmailButton);
    [cell.viewersToLogButton addTarget:self action:@selector(logButton:) forControlEvents:UIControlEventTouchUpInside];
    buttonStyling(cell.viewersToLogButton);
    
    
    
    
    // populate data
    
    
    NSArray * accessArray = cellData[@"access"];
    cell.indicatorView.layer.cornerRadius = 8;
    cell.indicatorView.layer.backgroundColor = ([accessArray count])?[[UIColor greenColor]CGColor ]:[[UIColor lightGrayColor]CGColor];
    
    
    cell.labelReciept.text = [NSString stringWithFormat:@"%@  %@",date,time];
    cell.tagNameLabel.text = name;
    cell.linkUrl        = linkURL;
    cell.homeTeamLabel.text = hTeam;
    cell.awayTeamLabel.text = vTeam;
    
    if ([accessArray count]){
        
        NSMutableString * txt = [NSMutableString new];
        for (NSDictionary * accessDic in accessArray) {
            [txt appendFormat:accessDic[@"who"],@" "];
        }
        
        cell.labelViewedBy.text = [NSString stringWithFormat:@"Viewed By: %@",txt];
    } else {
        cell.labelViewedBy.text = @"";
    }
    
    return cell;
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

//- (nullable NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section;    // fixed font style. use custom view (UILabel) if you want something different
//- (nullable NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section;

// Editing

// Individual rows can opt out of having the -editing property set for them. If not implemented, all rows are assumed to be editable.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

// Moving/reordering

// Allows the reorder accessory view to optionally be shown for a particular row. By default, the reorder control will be shown only if the datasource implements -tableView:moveRowAtIndexPath:toIndexPath:
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

// Index

//- (nullable NSArray<NSString *> *)sectionIndexTitlesForTableView:(UITableView *)tableView
//{
//    return  nil;
//}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
    return 0;
}

// Data manipulation - insert and delete support

// After a row has the minus or plus button invoked (based on the UITableViewCellEditingStyle for the cell), the dataSource must commit the change
// Not called for edit actions using UITableViewRowAction - the action's handler will be invoked instead
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{

}

// Data manipulation - reorder / moving support

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath
{

}




-(void)cellEmailButton:(UIButton*)sender
{
    
    
    NSDictionary * cellData = self.dataList[sender.tag];


    
    NSLog(@"%s",__FUNCTION__);
    self.mailComposeViewController = [[MFMailComposeViewController alloc] init];
    if (self.mailComposeViewController) {
        //TODO: make no email Error
        self.mailComposeViewController.mailComposeDelegate = self;
        [self.mailComposeViewController setSubject:@"Live2Bench Clips"];
        
        [self.mailComposeViewController setMessageBody:cellData[@"xsURL"]
                                                isHTML:NO];
        [ROOT_VIEW_CONTROLLER presentViewController:self.mailComposeViewController animated:YES completion:^{
            
        }];
    } else {
        //TODO: make no email Error
    }

    
   
}
#pragma mark - MFMailComposeViewControllerDelegate
-(void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    [self.mailComposeViewController dismissViewControllerAnimated:YES completion:^{
        
    }];
}
#pragma mark -

-(void)cellCopyButton:(UIButton*)sender
{
    NSLog(@"%s",__FUNCTION__);
    
     NSDictionary * cellData = self.dataList[sender.tag];
    [UIPasteboard generalPasteboard].string = cellData[@"xsURL"];
    
}

-(void)logButton:(UIButton*)sender
{
    
    
    NSDictionary * cellData = self.dataList[sender.tag];
    NSArray * accessArray = cellData[@"access"];
    NSString * date     = (cellData[@"date"])   ? cellData[@"date"]   : @"<date missing>";
    
    NSString * name     = (cellData[@"name"])   ? cellData[@"name"]   : @"<name missing>";
    NSString * time     = (cellData[@"time"])   ? cellData[@"time"]   : @"<time missing>";

    
    PXPLog(@"+++ Viewers for %@  %@  %@ +++",date,time,name);
    for (NSDictionary * accessData in accessArray) {
        PXPLog(@"   %@  ip: %@",accessData[@"whenaccess"],accessData[@"who"]);
    }
    
    PXPLog(@"++++++++++");
    
}

@end
