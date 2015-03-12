//
//  ExportPlayersPopoverController.h
//  Live2BenchNative
//
//  Created by Si Te Feng on 7/30/14.
//  Copyright (c) 2014 DEV. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ExportPlayersSync.h"
#import <MessageUI/MessageUI.h>

@class ExportPlayersSync;
@interface ExportPlayersPopoverController : UITableViewController <JPExportPlayersSyncDelegate, MFMailComposeViewControllerDelegate>
{
    ExportPlayersSync* exportSyncer;
    
    NSArray*   sectionTitles;
    
    
    NSIndexPath*  _currentSelectedIndex;
    MFMailComposeViewController* emailController;
    
}









@end
