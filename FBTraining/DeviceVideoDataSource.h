//
//  DeviceVideoDataSource.h
//  Live2BenchNative
//
//  Created by dev on 2016-06-09.
//  Copyright © 2016 DEV. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DeviceVideoDataSource : NSObject <UITableViewDataSource,UICollectionViewDataSource>
@property (nonatomic, strong) NSMutableArray * videos;
@end
