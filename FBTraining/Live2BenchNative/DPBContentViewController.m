//
//  DPBContentViewController.m
//  Live2BenchNative
//
//  Created by Si Te Feng on 8/19/14.
//  Copyright (c) 2014 DEV. All rights reserved.
//

#import "DPBContentViewController.h"
//#import "JPStyle.h"
//#import "UserInterfaceConstants.h"
#import "NSObject+LBCloudConvenience.h"
#import "DPBContentNavigationController.h"


@interface DPBContentViewController ()

@end

@implementation DPBContentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UIBarButtonItem* dismissItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Dismiss", nil)  style:UIBarButtonSystemItemDone target:self action:@selector(dismissButtonPressed)];
    self.navigationItem.rightBarButtonItem = dismissItem;
    
//    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kiPadWidthFormSheetLandscape, kiPadHeightFormSheetLandscape) style:UITableViewStyleGrouped];
//    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"reuseIdentifier"];
//    self.tableView.delegate = self;
//    self.tableView.dataSource = self;
//    [self.view addSubview:self.tableView];
    
}


#pragma mark - Table View Delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.fileMetadatas count];
}


- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* cell = [self.tableView dequeueReusableCellWithIdentifier:@"reuseIdentifier"];
    
    DBMetadata* metaData = [self.fileMetadatas objectAtIndex:indexPath.row];
    
    cell.textLabel.text = metaData.filename;
    
    cell.imageView.image = [self typeImageWithFileMetadata:metaData];
    cell.imageView.contentMode = UIViewContentModeScaleAspectFit;
    
    if([metaData.icon isEqual:@"folder"])
    {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}


- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    DBMetadata* data = [self.fileMetadatas objectAtIndex:indexPath.row];
    
    NSString* fileName = data.filename;
    
    if([data.icon isEqual:@"folder"])
    {
        [self.navController pushContentsOfFolderWithFolderName:fileName];
    }
    else //is a file
    {
        [self.navController pushFileViewWithName:fileName];
    }
    
}



- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(editingStyle != UITableViewCellEditingStyleDelete)
        return;
    
    DBMetadata* data = [self.fileMetadatas objectAtIndex:indexPath.row];
        
    [self.navController deleteFileWithName:data.filename];
        
    
}





#pragma mark - Setter Methods

- (void)setFileMetadatas:(NSArray *)fileMetadatas
{
    _fileMetadatas = fileMetadatas;
    
    [self.tableView reloadData];
}



- (void)setTitle:(NSString *)title
{
    [super setTitle:title];
    
    if([title isEqual:@"/"])
        [super setTitle: @"myplayXplay Dropbox Viewer"];
}



#pragma mark - other methods

- (UIImage*)typeImageWithFileMetadata: (DBMetadata*)metadata
{
    NSString* name = metadata.filename;
    
    if([name rangeOfString:@"."].location != NSNotFound) //has extension
    {
        NSArray* substrings = [name componentsSeparatedByString:@"."];
        
        NSString* typeString = @"info";
        
        if([substrings count] > 0)
        {
            typeString = [substrings lastObject];
        }
        return [self imageWithTypeString:typeString];
    }
    else
    {
        NSString* typeString = @"file";
        
        if([metadata.icon isEqual:@"folder"])
            typeString = @"folder";
        
        return [self imageWithTypeString: typeString];
    }
    
}


- (void)dismissButtonPressed
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)testUploadPressed
{
    [self.navController uploadTextDataToTodayFolder];
}



- (DPBContentNavigationController*)navController
{
    DPBContentNavigationController* navController = nil;
    if([self.navigationController isKindOfClass:[DPBContentNavigationController class]])
        navController = (DPBContentNavigationController*)self.navigationController;
    
    return navController;
}




- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}








@end
