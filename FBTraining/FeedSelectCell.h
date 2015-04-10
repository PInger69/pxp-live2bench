//
//  FeedSelectCell.h
//  Live2BenchNative
//
//  Created by 漠川 阮 on 15/4/8.
//  Copyright (c) 2015年 DEV. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DownloadButton.h"

@interface FeedSelectCell : UITableViewCell

@property (strong, nonatomic) UIImageView *feedView;
@property (strong, nonatomic) UILabel *feedName;
@property (strong, nonatomic) DownloadButton *downloadButton;

@property (nonatomic, copy) void(^downloadButtonBlock)();

- (instancetype)initWithImageData:(NSString *)url andName: (NSString *)name;
@end

