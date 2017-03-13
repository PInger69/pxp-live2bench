//
//  FeedSelectCell.h
//  Live2BenchNative
//
//  Created by 漠川 阮 on 15/4/8.
//  Copyright (c) 2015年 DEV. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DownloadButton.h"
#import "CustomButton.h"
#import "Event.h"
//#import "DowloadItem.h"

@interface FeedSelectCell : UITableViewCell

@property (readonly, strong, nonatomic, nonnull) UIImageView *feedView;
@property (readonly, strong, nonatomic, nonnull) UILabel *feedName;
@property (readonly, strong, nonatomic, nonnull) UILabel *dowdloadSize;
@property (strong, nonatomic, nonnull) NSString *dicKey;

@property (readonly, strong, nonatomic, nonnull) DownloadButton *downloadButton;
@property (readonly, strong, nonatomic, nonnull) CustomButton *playButton;
@property (nonatomic, copy, nullable) void(^downloadButtonBlock)();
@property (nonatomic, copy, nullable) void(^sendUserInfo)();
@property (nonatomic,strong, nullable)    Event           * event;

- (nonnull instancetype)initWithName: (nullable NSString *)name;

- (nonnull instancetype)initWithTag:(nonnull Tag *)tag source:(nullable NSString *)source;

- (void)positionWithFrame:(CGRect)frame;
@end


