//
//  PxpDropboxActivity.h
//  Live2BenchNative
//
//  Created by dev on 2016-07-15.
//  Copyright © 2016 DEV. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PxpDropboxActivity : UIActivity

- (instancetype)initWithURLnameDict:(NSDictionary*)dict;

@property (nonatomic,strong) NSMutableDictionary * urlToFileName;

@property (nonatomic,strong) NSError * error;
@property (nonatomic,copy) void (^onActivityStart)(UIActivity*);
@property (nonatomic,copy) void (^onActivityComplete)(UIActivity*);
@property (nonatomic,copy) void (^onActivityProgress)(PxpDropboxActivity*activity,CGFloat progressOfCurrentFile);


@property (nonatomic,assign) NSInteger fileCount;
@property (nonatomic,assign) NSInteger filesUploaded;

@end
