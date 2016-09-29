//
//  VideoUploadRecieptActivity.h
//  Live2BenchNative
//
//  Created by dev on 2016-08-18.
//  Copyright © 2016 DEV. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VideoUploadRecieptActivity : UIActivity


@property (nonatomic,strong) NSArray * clips;

@property (nonatomic,copy)          void (^onActivityProgress)(VideoUploadRecieptActivity*activity,CGFloat progress);
@property (copy, nonatomic)     void(^onRequestComplete)(VideoUploadRecieptActivity* activity);
@property (nonatomic,strong) NSString * progressMessage;
@property (nonatomic,strong) NSError * error;

- (instancetype)initWithClips:(NSArray*)clips;


@end
