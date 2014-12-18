//
//  TeamPickerViewController.m
//  Live2BenchNative
//
//  Created by DEV on 2013-04-19.
//  Copyright (c) 2013 DEV. All rights reserved.
//

#import "TeamPickerViewController.h"

@interface TeamPickerViewController ()

@end

@implementation TeamPickerViewController

@synthesize myTableView;
- (id)init
{
    self = [super init];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    if(!globals)
    {
        globals=[Globals instance];
    }
    self.myTableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    self.myTableView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    [self.myTableView setSeparatorInset:UIEdgeInsetsMake(0.0f, 15.0f, 0.0f, 15.0f)];
    [self.myTableView setDataSource:self];
    [self.myTableView setDelegate:self];
    [self.view addSubview:self.myTableView];
    // Do any additional setup after loading the view from its nib.
}

- (void) viewWillAppear:(BOOL)animated{
  
    [super viewWillAppear:animated];
    
    if (!sortedTeamNames) {
        NSArray* allhids = [globals.ALL_TEAMS allKeys];
        sortedTeamNames = [[NSMutableArray alloc]init];
        NSArray* sortedByName = [allhids sortedArrayUsingComparator:^NSComparisonResult(id a, id b){
            NSString* first = [[globals.ALL_TEAMS objectForKey:a] objectForKey:@"name"];
            NSString* second = [[globals.ALL_TEAMS objectForKey:b] objectForKey:@"name"];
            return [first compare:second];
        }];
        for(int x=0; x<allhids.count; x++){
            NSDictionary *dict = [globals.ALL_TEAMS objectForKey:[sortedByName objectAtIndex:x]];
            [sortedTeamNames addObject:[dict objectForKey:@"name"]];
        }
        [sortedTeamNames sortUsingSelector:@selector(caseInsensitiveCompare:)];
        sortedTeamDictionary = [NSMutableDictionary dictionaryWithObjects:sortedByName forKeys:sortedTeamNames];
    }
        
    [self.myTableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    globals.DID_RECEIVE_MEMORY_WARNING = TRUE;
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSString*)nameAtIndexPath:(NSIndexPath *)indexPath
{
    return [sortedTeamNames objectAtIndex:indexPath.row];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [sortedTeamNames count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *simpleTableIdentifier = @"TeamPicker";
    int tagNum = 35;
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
       
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
        cell.textLabel.font = [UIFont defaultFontOfSize:17.0f];
        UIView *selectedBG = [[UIView alloc] initWithFrame:cell.bounds];
        selectedBG.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        selectedBG.backgroundColor = [UIColor orangeColor];
        cell.selectedBackgroundView = selectedBG;
        cell.textLabel.highlightedTextColor = [UIColor whiteColor];
    } else {
        if ([[cell viewWithTag:tagNum] isKindOfClass:[AutoScrollLabel class]]){
            [[cell viewWithTag:tagNum] removeFromSuperview];
        }
    }
    
    NSString *teamName = [self nameAtIndexPath:indexPath];
    if ([teamName length] > 35){
        AutoScrollLabel *scrollableText = [[AutoScrollLabel alloc] init];
        [scrollableText setFrame:CGRectMake(7,7,300,30)];
        [scrollableText setFont:[UIFont defaultFontOfSize:17.0f]];
        [scrollableText setText:teamName];
        [scrollableText setTag:tagNum];
        [scrollableText setAccessibilityLabel:@"scrollableLabel"];
        [cell addSubview:scrollableText];
        [cell.textLabel setText:@""];
    } else {
        cell.textLabel.text = teamName;
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    int tagNum = 35;
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if ([[cell viewWithTag:tagNum] isKindOfClass:[AutoScrollLabel class]])
    {
        ((AutoScrollLabel*)[cell viewWithTag:tagNum]).textColor = [UIColor whiteColor];
    }
    
    //grab the selected team dictionary from the global dictionary
    NSString *selectedTeam = [self nameAtIndexPath:indexPath];
    //NSString *thisTeamHid = [sortedTeamDictionary objectForKey:thisTeamKey];
    //NSDictionary *thisTeam = [[NSDictionary alloc]initWithDictionary:[globals.ALL_TEAMS objectForKey:thisTeamHid]];
    
    if(self.view.tag >0)//we are picking the away team
    {
        globals.ENCODER_SELECTED_AWAY_TEAM = selectedTeam;//[thisTeam objectForKey:@"name"];
    }else{
        globals.ENCODER_SELECTED_HOME_TEAM = selectedTeam;//[thisTeam objectForKey:@"name"];
    }
    
    if(globals.PLAYING_TEAMS_HIDS.count > 1)
    {
        [globals.PLAYING_TEAMS_HIDS removeAllObjects];
    }
    [globals.PLAYING_TEAMS_HIDS addObject: [sortedTeamDictionary objectForKey:selectedTeam]];//[thisTeam objectForKey:@"hid"]];
    
    [self.delegate dismissTeamPicker];
}

@end
