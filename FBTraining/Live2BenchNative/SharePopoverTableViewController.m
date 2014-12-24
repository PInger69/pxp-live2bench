//
//  SharePopoverTableViewController.m
//  Live2BenchNative
//
//  Created by Si Te Feng on 6/23/14.
//  Copyright (c) 2014 DEV. All rights reserved.
//

#import "SharePopoverTableViewController.h"
#import "JPGraphPDFGenerator.h"
#import "ZoneGraphPDFViewController.h"
#import "Globals.h"
#import "SelectPDFTableViewController.h"
//#import "GDTestViewController.h"
//#import "GDContentsNavigationController.h"
//#import "GDContentsViewController.h"
//#import "GDFileUploader.h"
#import "DPBFileUploader.h"


@interface SharePopoverTableViewController ()

@end

NSString* const reuseIdentifier = @"LeftIconCell";

@implementation SharePopoverTableViewController

- (instancetype)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        
        [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:reuseIdentifier];
        
        self.graphGenerator = [[JPGraphPDFGenerator alloc] init];
        
        cellTitles = @[@[@"Save To Device Only", @"Save & Export To PDF Reader", @"Save & Email Graph As PDF", @"Save to Google Drive", @"Save To Dropbox"], @[@"Manage Saved PDFs"]];
        imageNames = @[@[@"saveIcon",@"iBooksIcon", @"mailIcon", @"googleDriveIcon", @"dropboxIcon"], @[@"pdfIcon.png"]];
        
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
    return cellTitles.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    return [cellTitles[section] count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    if(!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    }
    
    
    cell.imageView.image = [UIImage imageNamed:imageNames[indexPath.section][indexPath.row]];
    cell.textLabel.text = cellTitles[indexPath.section][indexPath.row];
    
    return cell;
}


- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if(section == 0)
    {
        return @"Save & Export as PDF";
    }
    else
    {
        return @"Utility";
    }
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    Globals* globals = [Globals instance];
    UITableViewCell* cell = [self.tableView cellForRowAtIndexPath:indexPath];
    
    if(indexPath.section == 0)
    {
        NSString* fileName = [NSString stringWithFormat:@"%@.pdf", globals.HUMAN_READABLE_EVENT_NAME];
        [self.graphGenerator savePDFWithFileName:fileName];
        NSString* filePath = [[self.graphGenerator pdfExportPath] stringByAppendingPathComponent:fileName];
        
        switch (indexPath.row) {
            case 0:
            {
                _pdfController = [[ZoneGraphPDFViewController alloc] init];
                
                UINavigationController* navController = [[UINavigationController alloc] initWithRootViewController:_pdfController];
                navController.modalPresentationStyle = UIModalPresentationFormSheet;
                UIBarButtonItem* buttonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(dismissWebViewController)];
                _pdfController.navigationItem.leftBarButtonItem = buttonItem;
                
                [self presentViewController:navController animated:YES completion:nil];

                break;
            }
            case 1:
            {
                documentInteractionController = [UIDocumentInteractionController interactionControllerWithURL:[NSURL fileURLWithPath:filePath]];
                BOOL isValid = [documentInteractionController presentOpenInMenuFromRect:cell.frame inView:self.tableView animated:YES]; // Provide where u want to read pdf from yourReadPdfButton
                
                if (!isValid) {
                    NSString * messageString = @"No PDF reader was found on your device, please download a PDF reader (eg. iBooks).";
                    UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:messageString delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
                    [alertView show];
                }

            }
                break;
            case 2:
            {
                mailController = [[MFMailComposeViewController alloc] init];
                mailController.mailComposeDelegate = self;
                [mailController setSubject:[NSString stringWithFormat:@"MyPlayXPlay PDF Export: %@", fileName]];
                [mailController setMessageBody:[NSString stringWithFormat:@"PDF for Zone Graph is Attached: %@", fileName] isHTML:NO];
                [mailController addAttachmentData:[NSData dataWithContentsOfFile:filePath] mimeType:@"application/pdf" fileName:fileName];
                [self presentViewController:mailController animated:YES completion:nil];
            }
                break;
            case 3:
            {
//                GDFileUploader* uploader = [[GDFileUploader alloc] initWithDriveService:nil];
//                uploader.delegate = self;
                
//                [uploader uploadFileWithName:fileName data:[NSData dataWithContentsOfFile:filePath] MIMEType:@"application/pdf"];
                
                [self.graphGenerator deletePDFWithFileName:fileName];
            }
                break;
            case 4:
            {
                DBSession* session = [[DBSession alloc] initWithAppKey:kDropboxAppKey appSecret:kDropboxAppSecret root:kDropboxAppRoot];
                if(![session isLinked])
                {
                    [session linkFromController:self];
                    return;
                }
                
                _dropboxUploader = [[DPBFileUploader alloc] initWithSession:session];
                
                [_dropboxUploader uploadFileAsyncWithFileName:fileName data:[NSData dataWithContentsOfFile:filePath] destPath:[self dropboxTodayFolderPath]];
            }
                break;
            default:
                break;
        }
    }
    else if(indexPath.section == 1)
    {
        switch (indexPath.row) {
           
            case 0:
            {
                [self displayAllPDFs];
                break;
            }

            default:
                break;
        }
        
    }
    
    if([self.delegate respondsToSelector:@selector(sharePopoverControllerDidFinishSelectionWithIndex:)] && !((indexPath.row == 1 || indexPath.row == 2) && indexPath.section==0))
    {
        [self.delegate sharePopoverControllerDidFinishSelectionWithIndex:indexPath];
    }
    
    
}




- (void)displayAllPDFs
{
    SelectPDFTableViewController* selectController = [[SelectPDFTableViewController alloc] initWithStyle:UITableViewStyleGrouped];
    UINavigationController* navController = [[UINavigationController alloc] initWithRootViewController:selectController];
    navController.modalPresentationStyle = UIModalPresentationFormSheet;
    [self presentViewController:navController animated:YES completion:nil];
    
}



- (void)dismissWebViewController
{
    [self dismissViewControllerAnimated:YES completion:nil];

}



#pragma mark - Share Delegate Methods

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    [self dismissViewControllerAnimated:YES completion:nil];

    [self.delegate sharePopoverControllerDidFinishSelectionWithIndex:[NSIndexPath indexPathForRow:2 inSection:0]];
}


- (void)fileUploader:(GDFileUploader *)uploader didFinishUploadingFileWithName:(NSString *)fileName isSuccessful:(BOOL)success
{
    //Alert already presented
}



@end
