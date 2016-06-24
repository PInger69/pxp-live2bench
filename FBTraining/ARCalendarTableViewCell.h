//
//  ARCalendarTableViewCell.h
//  Live2BenchNative
//
//  Created by dev on 2015-02-27.
//  Copyright (c) 2015 DEV. All rights reserved.
//
#import "DeletableTableViewCell.h"
#import <UIKit/UIKit.h>
#import "CustomButton.h"
#import "DownloadButton.h"
#import "DownloadItem.h"

@interface ARCalendarTableViewCell : DeletableTableViewCell

//@property (nonatomic,strong) DownloadButton     * downloadButton;
//@property (nonatomic,strong) CustomButton       * playButton;

@property (strong, nonatomic) UILabel   * dateLabel;
@property (strong, nonatomic) UILabel   * timeLabel;
@property (strong, nonatomic) UILabel   * titleLabel;
@property (strong, nonatomic) UILabel   * downloadInfoLabel;
@property (strong, nonatomic) UILabel   * leagueLabel;
@property (strong, nonatomic) UILabel   * dateDescription;
@property (strong, nonatomic) UILabel   * leagueDescription;
@property (strong, nonatomic) UIButton  * downloadAll;

//@property (strong, nonatomic) DownloadItem *downloadItem;

//@property (nonatomic, copy) void(^sendUserInfo)();
//@property (nonatomic, copy) void(^downloadButtonBlock)();

- (void)isSelected:(BOOL)selected;


@end

