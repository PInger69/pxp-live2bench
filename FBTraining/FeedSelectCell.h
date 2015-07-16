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

@property (strong, nonatomic) UIImageView *feedView;
@property (strong, nonatomic) UILabel *feedName;
@property (strong, nonatomic) NSString *dicKey;

@property (strong, nonatomic) DownloadButton *downloadButton;
@property (strong, nonatomic) CustomButton *playButton;
@property (nonatomic, copy) void(^downloadButtonBlock)();
@property (nonatomic, copy) void(^sendUserInfo)();
@property (nonatomic,strong)    Event           * event;

- (instancetype)initWithImageData:(NSString *)url andName: (NSString *)name;

- (nonnull instancetype)initWithTag:(nonnull Tag *)tag source:(nullable NSString *)source;

- (void)positionWithFrame:(CGRect)frame;
@end


