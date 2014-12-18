//
//  SelectPDFTableViewController.m
//  Live2BenchNative
//
//  Created by Si Te Feng on 7/29/14.
//  Copyright (c) 2014 DEV. All rights reserved.
//

#import "SelectPDFTableViewController.h"
#import "ZoneGraphPDFViewController.h"



@implementation SelectPDFTableViewController

- (instancetype)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    
    self.title = @"Manage Saved PDFs";
    
    UIBarButtonItem* dismissItem = [[UIBarButtonItem alloc] initWithTitle:@"Dismiss" style:UIBarButtonItemStyleDone target:self action:@selector(dismissButtonPressed:)];
    self.navigationItem.leftBarButtonItem = dismissItem;
    
    [self reloadPDFPaths];
    
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"reuseIdentifier"];
    
}



- (void)reloadPDFPaths
{
    NSFileManager* manager = [NSFileManager defaultManager];
    
    NSURL* documentURL = [NSURL URLWithString:[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject]];
    
    NSURL* pdfFolderUrl = [documentURL URLByAppendingPathComponent:@"pdfExports" isDirectory:YES];
    _pdfExportsPath = [pdfFolderUrl absoluteString];
    NSError* error = nil;
    self.pdfPaths = [manager contentsOfDirectoryAtPath:_pdfExportsPath error:&error];
    
    if(error) {
        NSLog(@"Error: %@", error);
    }
    
}



#pragma mark - Table View Data Source and Delegate Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.pdfPaths count];
}



- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* cell = [self.tableView dequeueReusableCellWithIdentifier:@"reuseIdentifier"];
    
    NSString* filePath = [self.pdfPaths objectAtIndex:indexPath.row];
    
    cell.textLabel.text = [[filePath pathComponents] lastObject];
    
    cell.imageView.image = [UIImage imageNamed:@"pdfIcon.png"];
    cell.imageView.contentMode = UIViewContentModeScaleAspectFit;
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ZoneGraphPDFViewController* pdfController = [[ZoneGraphPDFViewController alloc] initWithNibName:nil bundle:nil];
    
    pdfController.pdfFilePath = [self.pdfPaths objectAtIndex:indexPath.row];
    
    [self.navigationController pushViewController:pdfController animated:YES];
    
}



- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}



- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if(editingStyle != UITableViewCellEditingStyleDelete)
        return;
    
    NSString* pdfLocalPath = self.pdfPaths[indexPath.row];
    NSString* fullPdfPath = [_pdfExportsPath stringByAppendingPathComponent:pdfLocalPath];

    NSError* error = nil;
    [[NSFileManager defaultManager] removeItemAtPath:fullPdfPath error:&error];
    
    if(error)
    {
        NSLog(@"Deletion Error");
    }
    
    [self reloadPDFPaths];
    [self.tableView reloadData];
    
}






#pragma mark - Navigation Bar Button Callback Methods

- (void)dismissButtonPressed:(UIBarButtonItem*)button
{
    [self dismissViewControllerAnimated:YES completion:nil];
    
}




@end
