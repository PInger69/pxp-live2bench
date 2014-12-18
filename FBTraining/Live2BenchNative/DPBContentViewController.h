//
//  DPBContentViewController.h
//  Live2BenchNative
//
//  Created by Si Te Feng on 8/19/14.
//  Copyright (c) 2014 DEV. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <DropboxSDK/DropboxSDK.h>

@class DPBContentNavigationController;
@interface DPBContentViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>




@property (nonatomic, strong) NSArray* fileMetadatas;

@property (nonatomic, strong) UITableView* tableView;








@end
