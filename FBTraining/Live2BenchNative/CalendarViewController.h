//
//  CalendarViewController.h
//  Live2BenchNative
//
//  Created by DEV on 2013-01-21.
//  Copyright (c) 2013 DEV. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomTabViewController.h"
#import "EncoderManager.h"

@interface CalendarViewController : CustomTabViewController<UITableViewDelegate, UITextViewDelegate>{
    
}

@property (nonatomic,strong) UITableView *tableView;

@end
