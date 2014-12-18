//
//  GDContentsViewController.h
//  Live2BenchNative
//
//  Created by Si Te Feng on 8/12/14.
//  Copyright (c) 2014 DEV. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GTMOAuth2ViewControllerTouch.h"
#import "GTLDrive.h"
#import "GDContentsNavigationController.h"

@class GDContentsNavigationController;
@interface GDContentsViewController : UIViewController<UITableViewDataSource, UINavigationControllerDelegate>
{
    
}


@property (nonatomic, weak) GDContentsNavigationController<UITableViewDelegate>* navController;

@property (nonatomic, strong) NSString* fullPathString;

@property (nonatomic, strong) NSArray* driveFiles;


@property (nonatomic, strong) UITableView* tableView;


- (void)reloadSubviews;





@end
