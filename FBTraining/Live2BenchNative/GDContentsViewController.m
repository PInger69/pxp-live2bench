//
//  GDContentsViewController.m
//  Live2BenchNative
//
//  Created by Si Te Feng on 8/12/14.
//  Copyright (c) 2014 DEV. All rights reserved.
//

#import "GDContentsViewController.h"
#import "UserInterfaceConstants.h"
#import "NSObject+LBCloudConvenience.h"
#import "GDContentsTableCell.h"


@interface GDContentsViewController ()

@end



@implementation GDContentsViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];

    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    
    self.navController = (GDContentsNavigationController*) self.navigationController;

    ///////////////////////////////////////
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 540, 620) style:UITableViewStyleGrouped];
    self.tableView.dataSource = self;
    self.tableView.delegate = self.navController;
    [self.tableView registerClass:[GDContentsTableCell class] forCellReuseIdentifier:@"cell"];
    [self.view addSubview:self.tableView];
    
}


- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
   
}


- (void)reloadSubviews
{
    [self.tableView reloadData];
}


#pragma mark - Table View Data Source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.driveFiles count];
}


- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    GDContentsTableCell* cell = [self.tableView dequeueReusableCellWithIdentifier:@"cell"];
    
    cell.driveFile = [self.driveFiles objectAtIndex:indexPath.row];
    
    cell.fullPathString = [self.fullPathString stringByAppendingString:[NSString stringWithFormat:@"/%@",cell.driveFile.title]];
    
    if([cell.driveFile.mimeType isMIMETypeFolder])
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}




- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.navController deleteFileAtIndexPath:indexPath];
    
    
}








#pragma mark - Other Methods


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}




@end



