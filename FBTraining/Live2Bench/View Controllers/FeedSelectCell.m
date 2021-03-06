//
//  FeedSelectCell.m
//  Live2BenchNative
//
//  Created by 漠川 阮 on 15/4/8.
//  Copyright (c) 2015年 DEV. All rights reserved.
//

#import "FeedSelectCell.h"
#import "DownloadItem.h"

#import "Tag.h"
#import "Feed.h"
#import "AVAsset+Image.h"
#import "UIImageView+TagThumbnail.h"

@implementation FeedSelectCell

- (nonnull instancetype)initWithName: (nullable NSString *)name{
    self = [super init];
    if (self) {
        _dowdloadSize   = [[UILabel alloc] init];
        [_dowdloadSize setFont:[UIFont fontWithName:@"HelveticaNeue" size:12]];
        
        _feedName       = [[UILabel alloc] init];
        _feedView       = [[UIImageView alloc] init];

        _dowdloadSize.textAlignment = NSTextAlignmentRight;
        _dowdloadSize.text = @"";
        
        _dicKey = name ? name : @"";
        
        unsigned long n;
        _feedName.text = sscanf(name.UTF8String, "s_%lu", &n) == 1 ? [NSString stringWithFormat:@"Cam %lu", n] : name;
        
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
        [self.contentView addSubview: self.dowdloadSize];
        [self.contentView addSubview:self.feedView];
        [self.contentView addSubview: self.downloadButton];
        [self.contentView addSubview:self.playButton];
        
        [self setSelectionStyle:UITableViewCellSelectionStyleNone];
        
    }
    return self;
}

- (nonnull instancetype)initWithTag:(nonnull Tag *)tag source:(nullable NSString *)source {
    self = [super init];
    if (self) {
        _dowdloadSize   = [[UILabel alloc] init];
        [_dowdloadSize setFont:[UIFont fontWithName:@"HelveticaNeue" size:12]];
        
        _feedName = [[UILabel alloc] init];
        _feedView = [[UIImageView alloc] init];
        
        _dowdloadSize.textAlignment = NSTextAlignmentRight;
        _dowdloadSize.text = @"";
        if (!source) {
            source = tag.eventInstance.feeds.allKeys.firstObject;
        }
        
        NSString * __nonnull src = source ? source : @"";
        source = source;
        
        _dicKey = src;
        
        unsigned long n;
        _feedName.text = sscanf(source.UTF8String, "s_%lu", &n) == 1 ? [NSString stringWithFormat:@"Cam %lu", n] : source;
        
        [self.feedView pxp_setTagThumbnail:tag withSource:source];
        
        _downloadButton = [[DownloadButton alloc] init];;
        
        _playButton = [CustomButton buttonWithType:UIButtonTypeCustom];
        //don't set tag to 0, by default, uiview's tag is 0
        [self.playButton setTag:101];
        [self.playButton setEnabled:YES];
        [self.playButton setPlayButton];
        [self.playButton addTarget:self action:@selector(playButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [self.playButton setShowsTouchWhenHighlighted: YES];
        [self.contentView setBackgroundColor:[UIColor colorWithRed:0.955 green:0.955 blue:0.955 alpha:0.8]];

        [self.contentView addSubview: self.dowdloadSize];
        [self.contentView addSubview: self.feedName];
        [self.contentView addSubview: self.feedView];
        
        if (tag.type != TagTypeTele && tag.duration != 0) {
            [self.downloadButton addTarget:self action:@selector(downloadButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
            [self.contentView addSubview: self.downloadButton];
        }
        

        [self.contentView addSubview:self.playButton];
        
        [self setSelectionStyle:UITableViewCellSelectionStyleNone];
    }
    return self;
}

-(void)setFrame:(CGRect)frame{
    [super setFrame:frame];
    [self positionWithFrame:frame];
}

- (void)downloadButtonPressed:(id)sender {
    DownloadButton * button = (DownloadButton *) sender;
    button.isPressed = YES;
    [button setEnabled:NO];
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
    
    [_feedView          setFrame:CGRectMake(44, 0, (16.0 / 9.0) * frame.size.height, frame.size.height)];
    [_feedName          setFrame:CGRectMake(_feedView.frame.origin.x + _feedView.frame.size.width + 10, 0, 100, frame.size.height)];
    [_dowdloadSize      setFrame:CGRectMake(CGRectGetMaxX(frame) - 230, 0, 100, frame.size.height)];
    [_downloadButton    setFrame:CGRectMake(CGRectGetMaxX(frame) - 120, (frame.size.height - 34) / 2.0, 34, 34)];
    [_playButton        setFrame:CGRectMake(CGRectGetMaxX(frame) - 60, (frame.size.height - 30) / 2.0, 30, 30)];
}



@end


