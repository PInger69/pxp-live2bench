//
//  DurationTableViewController.h
//  StatsImportXML
//
//  Created by Si Te Feng on 7/10/14.
//  Copyright (c) 2014 Si Te Feng. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Globals;
@interface DurationTableViewController : UITableViewController
{
    Globals*    globals;
}

@property (nonatomic, weak) UIPopoverController* parentPopover;

@property (nonatomic, strong) NSArray* xmlTags; //array of JPXMLTag


@property (nonatomic, assign) float delayInSeconds;

@end
