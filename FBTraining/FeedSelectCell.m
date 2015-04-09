//
//  FeedSelectCell.m
//  Live2BenchNative
//
//  Created by 漠川 阮 on 15/4/8.
//  Copyright (c) 2015年 DEV. All rights reserved.
//

#import "FeedSelectCell.h"
#import "ImageAssetManager.h"
#import "DownloadItem.h"

@implementation FeedSelectCell

- (instancetype)initWithImageData:(NSString *)url andName: (NSString *)name{
    self = [super init];
    if (self) {
        _feedName = [[UILabel alloc] initWithFrame:CGRectMake(160, 22.25, 100, 33)];
        _feedView = [[UIImageView alloc] initWithFrame:CGRectMake(30, 0, 115, 155/2)];
        _feedName.text = name;
        ImageAssetManager *imageAssetManager = [[ImageAssetManager alloc]init];
        [imageAssetManager imageForURL:url atImageView:self.feedView];
        
        _downloadButton = [[DownloadButton alloc] initWithFrame:CGRectMake(320, 22.25, 33, 33)];
        [_downloadButton addTarget:self action:@selector(downloadButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        
        [self addSubview: self.feedName];
        [self addSubview:self.feedView];
        [self addSubview: self.downloadButton];
    }
    return self;
}

- (void)downloadButtonPressed:(id)sender {
    self.downloadButtonBlock();
}

@end

