//
//  ExportPlayersPopoverController.m
//  Live2BenchNative
//
//  Created by Si Te Feng on 7/30/14.
//  Copyright (c) 2014 DEV. All rights reserved.
//

#import "ExportPlayersPopoverController.h"
#import "ExportPlayersSync.h"
#import "Globals.h"


const NSString* kExportPlayerDirectoryName = @"PlayerExports";

@implementation ExportPlayersPopoverController


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    exportSyncer = [[ExportPlayersSync alloc] init];
    exportSyncer.delegate = self;
    
    sectionTitles = @[@"Export Player Tags in CSV"];//,@"Export Player Tags in XML"];
    
    _currentSelectedIndex = [NSIndexPath indexPathForRow:-1 inSection:-1];
    
}



- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    
    return [sectionTitles count];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 3;
}


- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* cell = [self.tableView dequeueReusableCellWithIdentifier:@"reuseIdentifier"];
    
    if(!cell) {
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"reuseIdentifier"];
    }
 
    NSArray* exportTitles = @[@"Copy", @"Save To Device", @"Save & Email File"];
    
    cell.textLabel.text = exportTitles[indexPath.row];
    
    return cell;
}


- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return sectionTitles[section];
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    _currentSelectedIndex = indexPath;
    
    if(indexPath.section == 0)
        exportSyncer.exportType = @"csv";
    else if(indexPath.section ==1)
        exportSyncer.exportType = @"xml";
    
    [exportSyncer startConvertingAsynchronously];
    
}



- (void)exportPlayersSync:(ExportPlayersSync*)syncer didFinishLoadingWithString:(NSString *)result
{
    
    NSMutableString* fileName = [[[Globals instance] HUMAN_READABLE_EVENT_NAME] mutableCopy];
    [fileName appendFormat:@".%@", syncer.exportType];
    
    NSString* newFilePath = @"";
    
    if(_currentSelectedIndex.row == 0)
    {
         //copy
        [[UIPasteboard generalPasteboard] setString:result];
    }
    else
    {
        newFilePath = [self saveTextFileWithName:fileName folderName:[kExportPlayerDirectoryName copy] withString:result];
    }
    
    if(_currentSelectedIndex.row == 2)
    {
        emailController = [[MFMailComposeViewController alloc] init];
        emailController.mailComposeDelegate = self;
        
        [emailController setSubject:[NSString stringWithFormat:@"MyPlayXPlay Export: %@", fileName]];
        
        [emailController addAttachmentData:[NSData dataWithContentsOfFile:newFilePath] mimeType:[NSString stringWithFormat:@"text/%@", syncer.exportType] fileName:fileName];
        
        [self presentViewController:emailController animated:YES completion:nil];
    }
    else
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"ExportPlayersPopoverControllerDidFinishSelection" object:nil];
    }
    
    
}


//Folder name nil means root Documents Folder
//RETURNS Absolute New Path of the New File

- (NSString*)saveTextFileWithName: (NSString*)fileName folderName: (NSString*)folderName withString: (NSString*)string
{
    NSFileManager* manager = [NSFileManager defaultManager];
    
    //Getting Folder Path
    NSURL* documentUrl = [[manager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] firstObject];
    
    if(folderName && ![folderName isEqual:@""])
    {
        NSURL* folderURL = [documentUrl URLByAppendingPathComponent:folderName];
        
        BOOL fileExists = [manager fileExistsAtPath:[documentUrl absoluteString] isDirectory:YES];
        if(!fileExists)
        {
            [manager createDirectoryAtURL:folderURL withIntermediateDirectories:NO attributes:nil error:nil];
        }
        
        documentUrl = [folderURL copy];
    }
    
    //Saving File into the directory
    NSData* fileData = [string dataUsingEncoding:NSUTF32StringEncoding];
    NSURL* fileUrl = [documentUrl URLByAppendingPathComponent:fileName];
    
    BOOL saveSuccess = [manager createFileAtPath:[fileUrl path] contents:fileData attributes:nil];
    
    if(saveSuccess)
    {
        NSLog(@"Successfully Saved File: %@", fileName);
    } else {
        NSLog(@"File Save Error: %d - message: %s", errno, strerror(errno));
    }
    
    return [fileUrl path];
    
}


- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    [self dismissViewControllerAnimated:YES completion:nil];
    
    if(error)
    {
        [[[UIAlertView alloc] initWithTitle:@"Email Send Error" message:@"Message could not be sent." delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles: nil] show];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ExportPlayersPopoverControllerDidFinishSelection" object:nil];
}





@end
