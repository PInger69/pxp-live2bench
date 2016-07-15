//
//  PxpDropboxActivity.h
//  Live2BenchNative
//
//  Created by dev on 2016-07-15.
//  Copyright © 2016 DEV. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PxpDropboxActivity : UIActivity

@property (nonatomic,strong) NSMutableDictionary * urlToFileName;

@property (nonatomic,strong) NSError * error;
@property (nonatomic,copy) void (^onActivityComplete)(UIActivity*);
@property (nonatomic,copy) void (^onActivityProgress)(CGFloat);


@end
