//
//  VideoRecieptDataProvider.h
//  Live2BenchNative
//
//  Created by dev on 2016-08-19.
//  Copyright © 2016 DEV. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VideoRecieptDataProvider : NSObject <UITableViewDataSource>

- (instancetype)initWithTableView:(UITableView*)tableView;

-(void)refreshWithKeys:(NSArray*)keys onRefreshComplete:(void(^)())refreshComplete;
-(void)refreshOnRefreshComplete:(void(^)())refreshComplete;

@end
