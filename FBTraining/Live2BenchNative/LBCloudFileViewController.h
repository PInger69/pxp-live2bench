//
//  LBCloudFileViewController.h
//  Live2BenchNative
//
//  Created by Si Te Feng on 8/22/14.
//  Copyright (c) 2014 DEV. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "LBCloudPlayerView.h"

@interface LBCloudFileViewController : UIViewController <UIScrollViewDelegate>
{
    //used if is text file
    CGFloat   _fontSize;
    
    NSString* _fileDataString;
    
    AVPlayerItem* playerItem;
    AVPlayer*   videoPlayer;
    
}



@property (nonatomic, strong) NSString* mimeType;
@property (nonatomic, strong) NSString* fileName;
@property (nonatomic, strong) NSData*   fileData;
@property (nonatomic, strong) NSURL*    fileURL;


@property (nonatomic, strong) UIWebView* webView;

@property (nonatomic, strong) LBCloudPlayerView* playerView;


- (instancetype)initWithFileName: (NSString*)name data: (NSData*)data mimeType: (NSString*)mimeType;



@end
