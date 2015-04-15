//
//  DownloadButton.h
//  Live2BenchNative
//
//  Created by Dev on 2013-10-04.
//  Copyright (c) 2013 DEV. All rights reserved.
//

#import "CustomButton.h"
#import "UIImage+animatedGIF.h"
#import "DownloadItem.h"

typedef enum{
    DBDefault = 0,
    DBDownloading = 1,
    DBDownloaded = 2
} DBDownloadState ;

@interface DownloadButton : CustomButton

@property (assign, nonatomic) float progress;
@property (strong, nonatomic) DownloadItem *downloadItem;

@property (assign, nonatomic) BOOL downloadCancelled;
@property (assign, nonatomic) BOOL downloadComplete;

-(void)setState:(DBDownloadState)state;

@end
