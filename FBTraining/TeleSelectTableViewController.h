//
//  TeleSelectTableViewController.h
//  Live2BenchNative
//
//  Created by Nico Cvitak on 2015-07-23.
//  Copyright © 2015 DEV. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TagSelectResponder.h"

@interface TeleSelectTableViewController : UITableViewController

@property (weak, nonatomic, nullable) id<TagSelectResponder> tagSelectResponder;
@property (strong, nonatomic, nullable) Event *event;
@property (assign, nonatomic) BOOL ascending;

@end
