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
        _feedName = [[UILabel alloc] init];
        _feedView = [[UIImageView alloc] init];
        _dicKey = [[NSString alloc]init];
        
        
        unsigned long n;
        sscanf(name.UTF8String, "s_%lu", &n);
        _dicKey = name;
        _feedName.text = [NSString stringWithFormat:@"Cam %lu", n];
        
        ImageAssetManager *imageAssetManager = [[ImageAssetManager alloc]init];
        [imageAssetManager imageForURL:url atImageView:self.feedView];
        
        _downloadButton = [[DownloadButton alloc] init];;
        [_downloadButton addTarget:self action:@selector(downloadButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        
        self.playButton = [CustomButton buttonWithType:UIButtonTypeCustom];
        //don't set tag to 0, by default, uiview's tag is 0
        [self.playButton setTag:101];
        [self.playButton setEnabled:YES];
        [self.playButton setPlayButton];
        [self.playButton addTarget:self action:@selector(playButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [self.playButton setShowsTouchWhenHighlighted: YES];
        [self.contentView setBackgroundColor:[UIColor colorWithRed:0.955 green:0.955 blue:0.955 alpha:0.8]];
        
        [self.contentView addSubview: self.feedName];
        [self.contentView addSubview:self.feedView];
        [self.contentView addSubview: self.downloadButton];
        [self.contentView addSubview:self.playButton];
        
        [self setSelectionStyle:UITableViewCellEditingStyleNone];
        
    }
    return self;
}

-(void)setFrame:(CGRect)frame{
    [super setFrame:frame];
    [self positionWithFrame:frame];
}

- (void)downloadButtonPressed:(id)sender {
    self.downloadButtonBlock();
}

- (void)playButtonPressed:(id)sender {
    self.sendUserInfo();
}

- (void)positionWithFrame:(CGRect)frame {
    
    [_feedView setFrame:CGRectMake(44, 0, (16.0 / 9.0) * frame.size.height, frame.size.height)];
    [_feedName setFrame:CGRectMake(_feedView.frame.origin.x + _feedView.frame.size.width + 10, 0, 100, frame.size.height)];
    [_downloadButton setFrame:CGRectMake(276, (frame.size.height - 34) / 2.0, 34, 34)];
    [_playButton setFrame:CGRectMake(CGRectGetMaxX(_downloadButton.frame) + 60, (frame.size.height - 30) / 2.0, 30, 30)];
}



@end


