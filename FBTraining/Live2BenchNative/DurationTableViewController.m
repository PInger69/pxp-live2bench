//
//  DurationTableViewController.m
//  StatsImportXML
//
//  Created by Si Te Feng on 7/10/14.
//  Copyright (c) 2014 Si Te Feng. All rights reserved.
//

#import "DurationTableViewController.h"

#import "DurationTableViewCell.h"
#import "JPXMLTag.h"
#import "Globals.h"
#import "CustomTabBar.h"
#import "ImportTagsSync.h"


@interface DurationTableViewController ()

@end

@implementation DurationTableViewController

- (instancetype)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        
        [self.tableView registerClass:[DurationTableViewCell class] forCellReuseIdentifier:@"reuseIdentifier"];
        
        globals = [Globals instance];
        self.xmlTags = @[];
        
        self.delayInSeconds = 0.0f;
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    

    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.xmlTags count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DurationTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"reuseIdentifier" forIndexPath:indexPath];
    
    JPXMLTag* tag = [self.xmlTags objectAtIndex:indexPath.row];
    
    if(tag)
    {
        cell.idValueLabel.text = [NSString stringWithFormat:@"%i", tag.identifier];
        cell.codeValueLabel.text = tag.code;
        cell.startValueLabel.text = [NSString stringWithFormat:@"%.02fm", tag.startTime];
        cell.endValueLabel.text = [NSString stringWithFormat:@"%.02fm", tag.endTime];
    }
    
    return cell;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    return 100;
}


- (BOOL) tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    globals.DID_GO_TO_LIVE = FALSE;
    //globals.IS_LOOP_MODE = TRUE;
    
    //is there a way to work around this?
    int apstSkipTimer= 99;
    globals.CURRENT_APP_STATE = apstSkipTimer;
    
    CustomTabBar* tabController = (CustomTabBar*)[[[[UIApplication sharedApplication] windows] firstObject] rootViewController];
    
    Live2BenchViewController *tempFirstCont= [tabController.viewControllers objectAtIndex:2];
    
    JPXMLTag* tag = [self.xmlTags objectAtIndex:indexPath.row];
    
    ImportTagsSync* tagSync = [[ImportTagsSync alloc] initWithDelay:self.delayInSeconds];
    NSDictionary* tagDict = [tagSync tagDictWithXMLTag:tag];
    
    globals.CURRENT_PLAYBACK_TAG=[[NSDictionary alloc]initWithDictionary:tagDict];
    globals.IS_TAG_PLAYBACK=TRUE;
    globals.START_TAG_PLAYBACK = TRUE;
    

    [self.parentPopover dismissPopoverAnimated:YES];
    [tabController setSelectedViewController:tempFirstCont];
}





/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
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
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

//{
//    colour = ffa900;
//    comment = "";
//    deleted = 0;
//    displaytime = "0:01:27";
//    duration = 20;
//    event = "2014-07-15_17-02-59_50c0298886d706488af9c6222efad86849898ecd_local";
//    homeTeam = "Bournemouth AFC";
//    id = 1;
//    islive = 1;
//    name = "Coach Tag";
//    own = 0;
//    rating = "";
//    starttime = "77.270672";
//    success = 1;
//    time = "87.270672";
//    type = 0;
//    url = "http://192.168.1.8:80/events/live/thumbs/tn1.jpg";
//    user = a6f16ab483da9847d431a822e6c85e144dc54f30;
//    visitTeam = Black;
//}

@end
