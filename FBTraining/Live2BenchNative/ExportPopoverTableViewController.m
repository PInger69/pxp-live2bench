//
//  ExportPopoverTableViewController.m
//  Live2BenchNative
//
//  Created by Si Te Feng on 7/22/14.
//  Copyright (c) 2014 DEV. All rights reserved.
//

#import "ExportPopoverTableViewController.h"
#import "ExportTagsSync.h"
#import "Globals.h"
//#import "GDFileUploader.h"
#import "DPBFileUploader.h"


@interface ExportPopoverTableViewController ()

@end

@implementation ExportPopoverTableViewController

- (instancetype)initWithStyle:(UITableViewStyle)style statsDicts: (NSDictionary*)dicts startTime: (float)start endTime: (float)end
{
    self = [super initWithStyle:style];
    if (self) {
        
        globals = [Globals instance];
        
        _exportSync = [[ExportTagsSync alloc] initWithGlobalsCurrentEventThumbnails:globals.CURRENT_EVENT_THUMBNAILS];
        _exportSync.statsDicts = dicts;
        _exportSync.delegate = self;
        _exportSync.duration = CGPointMake(start, end);
        
        self.statsDicts = dicts;
        
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"reuseIdentifier"];
    
    _sectionOptionStrings = @[@"Export XML SportsCode Format", @"Export XML Live2Bench Format", @"Export CSV Format", @"Export JSON Format"];
    
    
}



#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [_sectionOptionStrings  count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 4;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"reuseIdentifier" forIndexPath:indexPath];
    
    NSArray* titleOptions = @[@"Copy Content",@"Email Content", @"Save To Google Drive", @"Save To Dropbox"];
    NSArray* cellImages = @[@"copyIcon.png",@"mailIcon.png", @"googleDriveIcon", @"dropboxIcon"];
    
    cell.textLabel.text = titleOptions[indexPath.row];
    
    cell.imageView.image = [UIImage imageNamed:cellImages[indexPath.row]];
    cell.imageView.contentMode = UIViewContentModeScaleAspectFit;
    
    return cell;
}



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    _currentRowSelection = indexPath.row;
    _currentSectionSelection = indexPath.section;
    
    if(indexPath.section == 0) {
        
        _exportSync.type = JPExportTagTypeSportsCode;
        [_exportSync startConvertingAsynchronously];
    }
    else if(indexPath.section == 1)
    {
        _exportSync.type = JPExportTagTypeLive2Bench;
        [_exportSync startConvertingAsynchronously];
    }
    else if(indexPath.section == 2)
    {
        _exportSync.type = JPExportTagTypeCSV;
        [_exportSync startConvertingAsynchronously];
    }
    else if(indexPath.section == 3)
    {
        NSData* jsonData = [NSJSONSerialization dataWithJSONObject:globals.CURRENT_EVENT_THUMBNAILS options:nil error:nil];
        
        NSString* jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        
        [self exportStringWithCurrentOption:jsonString];
    }
}



- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    
    return _sectionOptionStrings[section];
    
}


#pragma mark - JP Export Tag Delegate

- (void)exportTagSync: (ExportTagsSync*)sync didFinishConvertingWithFileData: (NSData*)data
{
    NSString* xmlString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    [self exportStringWithCurrentOption:xmlString];

}


- (void)exportStringWithCurrentOption: (NSString*)string
{
    if(_currentRowSelection == 0)
    {
        UIPasteboard* pb = [UIPasteboard generalPasteboard];
        [pb setString:string];
    }
    else if(_currentRowSelection == 1)
    {
        _mailController = [[MFMailComposeViewController alloc] init];
        _mailController.mailComposeDelegate = self;
        [_mailController setSubject:[NSString stringWithFormat:@"XML for Event: %@", globals.HUMAN_READABLE_EVENT_NAME]];
        
        [_mailController setMessageBody:[NSString stringWithFormat:@"Event: %@\nExport Time: %@\n\n%@", globals.HUMAN_READABLE_EVENT_NAME, [NSDate date], string] isHTML:NO];
        
        if([MFMailComposeViewController canSendMail])
            [self presentViewController:_mailController animated:YES completion:nil];
    }
    else if(_currentRowSelection == 2)
    {
        NSData* fileData = [string dataUsingEncoding:NSUTF8StringEncoding];
        
        NSString* fileName = [NSString stringWithFormat:@"%@: [%@]", _sectionOptionStrings[_currentSectionSelection], [globals HUMAN_READABLE_EVENT_NAME]];
        
        NSArray* mimeTypes = @[@"text/xml", @"text/xml", @"text/csv", @"text/json"];
        
//        _GDUploader = [[GDFileUploader alloc] initWithDriveService:nil];
//        [_GDUploader uploadFileWithName:fileName data:fileData MIMEType:mimeTypes[_currentSectionSelection]];
        
    }
    else if(_currentRowSelection == 3)
    {
        NSData* fileData = [string dataUsingEncoding:NSUTF8StringEncoding];
        
        NSArray* fileTypes = @[@"xml", @"xml", @"csv", @"json"];
        
        NSString* fileName = [NSString stringWithFormat:@"%@: [%@].%@", _sectionOptionStrings[_currentSectionSelection], [globals HUMAN_READABLE_EVENT_NAME], fileTypes[_currentSectionSelection]];
        
        DBSession* dropboxSession = [[DBSession alloc] initWithAppKey:kDropboxAppKey appSecret:kDropboxAppSecret root:kDropboxAppRoot];
        
        [DBSession setSharedSession:dropboxSession];
        
        if(![dropboxSession isLinked])
        {
            [[DBSession sharedSession] linkFromController:self];
            return;
        }
        
        if(!_DPBUploader)
            _DPBUploader = [[DPBFileUploader alloc] initWithSession:dropboxSession];
        _DPBUploader.session = dropboxSession;
        
        [_DPBUploader uploadFileAsyncWithFileName:fileName data:fileData destPath:[self dropboxTodayFolderPath]];
        
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}



- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    [self dismissViewControllerAnimated:YES completion:nil];
    if(error)
    {
        [[[UIAlertView alloc] initWithTitle:@"Error Sending Message" message:error.localizedDescription delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles: nil] show];
    }
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
