//
//  LeaguePickerViewController.m
//  Live2BenchNative
//
//  Created by DEV on 2013-04-22.
//  Copyright (c) 2013 DEV. All rights reserved.
//

#import "LeaguePickerViewController.h"

@interface LeaguePickerViewController ()

@end

@implementation LeaguePickerViewController

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
    [self.myTableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [globals.ALL_LEAGUES count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *simpleTableIdentifier = @"LeaguePicker";
    int tagNum = 33;
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    if ([[cell viewWithTag:tagNum] isKindOfClass:[AutoScrollLabel class]]){
        [[cell viewWithTag:tagNum] removeFromSuperview];
    }
//    for (UIView *subview in cell.subviews){
//        if ([[subview accessibilityLabel] isEqualToString:@"scrollableLabel"]){
//            [subview removeFromSuperview];
//        }
//    }
    //making an alphabetically sorted dictionary with key = name and object = hid.
    //there's probably an easier way, except that when using [dict allKeys] the object at the expected index is not correct. I don't know about this implementation.
    if(!sortedLeagueNames){
        NSArray* allhids = [globals.ALL_LEAGUES allKeys];
        sortedLeagueNames = [NSMutableArray arrayWithCapacity:[allhids count]];
        NSArray* sortedByName = [allhids sortedArrayUsingComparator:^NSComparisonResult(id a, id b){
            NSString* first = [[globals.ALL_LEAGUES objectForKey:a] objectForKey:@"name"];
            NSString* second = [[globals.ALL_LEAGUES objectForKey:b] objectForKey:@"name"];
            return [first compare:second];
        }];
        for(int x=0; x<allhids.count; x++){
            NSDictionary *dict = [globals.ALL_LEAGUES objectForKey:[sortedByName objectAtIndex:x]];
            [sortedLeagueNames addObject:[dict objectForKey:@"name"]];
        }
        [sortedLeagueNames sortUsingSelector:@selector(caseInsensitiveCompare:)];
        sortedLeagueDictionary = [NSMutableDictionary dictionaryWithObjects:sortedByName forKeys:sortedLeagueNames];
    }
    
    //grab the teams dictionary from the global dictionary
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
        UIView *selectedBG = [[UIView alloc] initWithFrame:cell.bounds];
        selectedBG.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        selectedBG.backgroundColor = [UIColor orangeColor];
        cell.selectedBackgroundView = selectedBG;
        cell.textLabel.highlightedTextColor = [UIColor whiteColor];
        cell.textLabel.font = [UIFont defaultFontOfSize:17.0f];
    }
    
    if ([[sortedLeagueNames objectAtIndex:[indexPath row]] length] > 33){
        AutoScrollLabel *scrollableText = [[AutoScrollLabel alloc] init];
        [scrollableText setFrame:CGRectMake(7,7,300,30)];
        [scrollableText setFont:[UIFont defaultFontOfSize:17.0f]];
        [scrollableText setText:[sortedLeagueNames objectAtIndex:[indexPath row]]];
        [scrollableText setAccessibilityLabel:@"scrollableLabel"];
        [scrollableText setTag:tagNum];
        [cell addSubview:scrollableText];
        cell.textLabel.text = @"";
    } else {
        cell.textLabel.text = [sortedLeagueNames objectAtIndex:[indexPath row]];
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
    NSString *thisLeagueKey = [sortedLeagueNames objectAtIndex:[indexPath row]];
//    NSString *thisLeagueHid = [sortedLeagueDictionary objectForKey:thisLeagueKey];
    //NSDictionary *thisLeague = [[NSDictionary alloc]initWithDictionary:[globals.ALL_LEAGUES objectForKey:thisLeagueHid]];
    globals.ENCODER_SELECTED_LEAGUE = thisLeagueKey;
    //globals.WHICH_SPORT = [[thisLeague objectForKey:@"sport"]lowercaseString];
    [self.delegate dismissLeaguePicker];
 
}



@end
