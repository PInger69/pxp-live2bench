//
//  SharePopoverTableViewController.h
//  Live2BenchNative
//
//  Created by Si Te Feng on 6/23/14.
//  Copyright (c) 2014 DEV. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
//#import "GDFileUploader.h"

@protocol JPSharePopoverDelegate;
@class JPGraphPDFGenerator, ZoneGraphPDFViewController, DPBFileUploader, GDFileUploader;
@interface SharePopoverTableViewController : UITableViewController <MFMailComposeViewControllerDelegate>
{
    JPGraphPDFGenerator* graphGen;
    
    NSArray* cellTitles;
    NSArray* imageNames;
    
    
    ZoneGraphPDFViewController* _pdfController;
    
    MFMailComposeViewController* mailController;
    UIDocumentInteractionController* documentInteractionController;
    
    
    DPBFileUploader* _dropboxUploader;
    
}




@property (nonatomic, strong) JPGraphPDFGenerator* graphGenerator;

@property (nonatomic, strong) id<JPSharePopoverDelegate> delegate;



@end

@protocol JPSharePopoverDelegate <NSObject>

@optional
- (void)sharePopoverControllerDidFinishSelectionWithIndex: (NSIndexPath*)indexPath;

@end