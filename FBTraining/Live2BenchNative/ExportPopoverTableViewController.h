//
//  ExportPopoverTableViewController.h
//  Live2BenchNative
//
//  Created by Si Te Feng on 7/22/14.
//  Copyright (c) 2014 DEV. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ExportTagsSync.h"
#import <MessageUI/MessageUI.h>
#import "GDFileUploader.h"
#import "DPBFileUploader.h"


@class ExportTagsSync, Globals;
@interface ExportPopoverTableViewController : UITableViewController <JPExportTagSyncDelegate, MFMailComposeViewControllerDelegate>
{
    Globals* globals;
    
    NSArray* _sectionOptionStrings;
    
    ExportTagsSync* _exportSync;
    MFMailComposeViewController* _mailController;
    
    NSInteger  _currentRowSelection;
    NSInteger  _currentSectionSelection;
    
    GDFileUploader* _GDUploader;
    DPBFileUploader* _DPBUploader;
}


- (instancetype)initWithStyle:(UITableViewStyle)style statsDicts: (NSDictionary*)dicts startTime: (float)start endTime: (float)end;


@property (nonatomic, strong) NSDictionary* statsDicts;




@end
