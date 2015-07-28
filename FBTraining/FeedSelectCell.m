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

#import "Tag.h"
#import "Feed.h"
#import "AVAsset+Image.h"

@implementation FeedSelectCell

- (nonnull instancetype)initWithImageData:(nullable NSString *)url andName: (nullable NSString *)name{
    self = [super init];
    if (self) {
        _feedName = [[UILabel alloc] init];
        _feedView = [[UIImageView alloc] init];
        
        _dicKey = name ? name : @"";
        
        unsigned long n;
        _feedName.text = sscanf(name.UTF8String, "s_%lu", &n) == 1 ? [NSString stringWithFormat:@"Cam %lu", n] : name;
        
        ImageAssetManager *imageAssetManager = [[ImageAssetManager alloc]init];
        
        
        [imageAssetManager imageForURL:url atImageView:self.feedView];
        
        _downloadButton = [[DownloadButton alloc] init];;
        [_downloadButton addTarget:self action:@selector(downloadButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        
        _playButton = [CustomButton buttonWithType:UIButtonTypeCustom];
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

- (nonnull instancetype)initWithTag:(nonnull Tag *)tag source:(nullable NSString *)source {
    self = [super init];
    if (self) {
        _feedName = [[UILabel alloc] init];
        _feedView = [[UIImageView alloc] init];
        
        if (!source) {
            source = tag.event.feeds.allKeys.firstObject;
        }
        
        NSString * __nonnull src = source ? source : @"";
        source = source;
        
        _dicKey = src;
        
        unsigned long n;
        _feedName.text = sscanf(source.UTF8String, "s_%lu", &n) == 1 ? [NSString stringWithFormat:@"Cam %lu", n] : source;
        
        UIImage *thumb = [tag thumbnailForSource:source];
        
        ImageAssetManager *imageAssetManager = [[ImageAssetManager alloc]init];
        
        if (thumb) {
            self.feedView.image = thumb;
        } else {
            PxpTelestration *tele = tag.thumbnails.count <= 1 || [tag.telestration.sourceName isEqualToString:source] ? tag.telestration : nil;
            
            [imageAssetManager imageForURL:tag.thumbnails[source] atImageView:self.feedView withTelestration:tele];
        }
        
        _downloadButton = [[DownloadButton alloc] init];;
        
        _playButton = [CustomButton buttonWithType:UIButtonTypeCustom];
        //don't set tag to 0, by default, uiview's tag is 0
        [self.playButton setTag:101];
        [self.playButton setEnabled:YES];
        [self.playButton setPlayButton];
        [self.playButton addTarget:self action:@selector(playButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [self.playButton setShowsTouchWhenHighlighted: YES];
        [self.contentView setBackgroundColor:[UIColor colorWithRed:0.955 green:0.955 blue:0.955 alpha:0.8]];
        
        [self.contentView addSubview: self.feedName];
        [self.contentView addSubview:self.feedView];
        
        if (tag.type != TagTypeTele) {
            [self.downloadButton addTarget:self action:@selector(downloadButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
            [self.contentView addSubview: self.downloadButton];
        }
        

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
    if (self.downloadButtonBlock) {
        self.downloadButtonBlock();
    }
}

- (void)playButtonPressed:(id)sender {
    if (self.sendUserInfo) {
        self.sendUserInfo(_dicKey);
    }
}

- (void)positionWithFrame:(CGRect)frame {
    
    [_feedView setFrame:CGRectMake(44, 0, (16.0 / 9.0) * frame.size.height, frame.size.height)];
    [_feedName setFrame:CGRectMake(_feedView.frame.origin.x + _feedView.frame.size.width + 10, 0, 100, frame.size.height)];
    [_downloadButton setFrame:CGRectMake(276, (frame.size.height - 34) / 2.0, 34, 34)];
    [_playButton setFrame:CGRectMake(CGRectGetMaxX(_downloadButton.frame) + 60, (frame.size.height - 30) / 2.0, 30, 30)];
}



@end


