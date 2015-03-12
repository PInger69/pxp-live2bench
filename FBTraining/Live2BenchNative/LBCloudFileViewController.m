//
//  LBCloudFileViewController.m
//  Live2BenchNative
//
//  Created by Si Te Feng on 8/22/14.
//  Copyright (c) 2014 DEV. All rights reserved.
//

#import "LBCloudFileViewController.h"
//#import "UserInterfaceConstants.h"
//#import "JPStyle.h"


@interface LBCloudFileViewController ()

@end

@implementation LBCloudFileViewController

- (instancetype)initWithFileName: (NSString*)name data: (NSData*)data mimeType: (NSString*)mimeType
{
    self = [super initWithNibName:nil bundle:nil];
    
    self.fileData = data;
    self.mimeType = mimeType;
    self.fileName = name;
    
    self.title = name;
    
    return self;
    
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    UIBarButtonItem* dismissItem = [[UIBarButtonItem alloc] initWithTitle:@"Dismiss" style:UIBarButtonItemStylePlain target:self action:@selector(dismissButtonPressed:)];
    UIBarButtonItem* plusButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"plusIcon-32"] style:UIBarButtonItemStyleDone target:self action:@selector(plusButtonPressed)];
    UIBarButtonItem* minusButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"minusIcon-32"] style:UIBarButtonItemStyleDone target:self action:@selector(minusButtonPressed)];
    
    self.navigationItem.rightBarButtonItems = @[dismissItem, plusButton, minusButton];
    
    
    _fileDataString = [[NSString alloc] initWithData:self.fileData encoding:NSUTF8StringEncoding];
    _fontSize = 25;
    
    self.webView = [[UIWebView alloc] initWithFrame:CGRectMake(0,0,100,100)];//CGRectMake(0, 0, kiPadWidthFormSheetLandscape, kiPadHeightFormSheetLandscape)
    
    if(self.fileURL != nil)
    {
        NSURLRequest* req = [NSURLRequest requestWithURL:self.fileURL];
        [self.webView loadRequest:req];
    }
    else if([self mimeTypeIsText])
    {
        plusButton.enabled = YES;
        minusButton.enabled = YES;
        [self loadWebviewWithTextString:_fileDataString withFontSize:_fontSize];
    }
    else
    {
        plusButton.enabled = NO;
        minusButton.enabled = NO;
        [self.webView loadData:self.fileData MIMEType:self.mimeType textEncodingName:nil baseURL:nil];
    }
    [self.webView setBackgroundColor:[UIColor lightGrayColor]];
    self.webView.scalesPageToFit = YES;
    [self.view addSubview:self.webView];
    
    //////////////////
    self.playerView = [[LBCloudPlayerView alloc] initWithFrame:self.webView.frame];
    self.playerView.hidden = YES;
    [self.view addSubview:self.playerView];
    
    /////////////////////////////////
//    if([self.mimeType isEqual:@"video/mp4"])
//    {
//        self.playerView.hidden = NO;
//        AVAsset* asset = [AVAsset assetWithURL:self.fileURL];
//        
//        self->playerItem = [[AVPlayerItem alloc] initWithAsset:asset];
//        
//        videoPlayer = [AVPlayer playerWithPlayerItem:self->playerItem];
//        
//        [self.playerView setPlayer:videoPlayer];
//        
//        if(videoPlayer.status == AVPlayerStatusReadyToPlay)
//            [videoPlayer play];
//        else
//            NSLog(@"videoPlayerItem Error");
//    }
    
}











                                
#pragma mark - Convenience Methods

- (BOOL)mimeTypeIsText
{
    NSArray* textTypes = @[@"text/xml",@"text/plain",@"text/csv",@"text/json",@"text/xml"];
    
    return [textTypes containsObject:self.mimeType];
}
                                

- (void)loadWebviewWithTextString: (NSString*)textString withFontSize: (CGFloat)fontSize
{
    if([self.mimeType isEqual:@"text/xml"])
    {
        textString = [textString stringByReplacingOccurrencesOfString:@"<" withString:@"&lt"];
        textString = [textString stringByReplacingOccurrencesOfString:@">" withString:@"&gt <br/>"];
    }
    
    NSString *contentHTML = [NSString stringWithFormat:@"<html> \n"
                             "<head> \n"
                             "<style type=\"text/css\"> \n"
                             "body {font-family: \"%@\"; font-size: %@;}\n"
                             "</style> \n"
                             "</head> \n"
                             "<body>%@</body> \n"
                             "</html>", @"helvetica", [NSNumber numberWithInt:fontSize], textString];
    
    [self.webView loadHTMLString:contentHTML baseURL:nil];
}




#pragma mark - Setter Methods

- (void)setFileName:(NSString *)fileName
{
    _fileName = fileName;
    
    self.title = fileName;
}


#pragma mark - Nav Bar Item Callback Methods

- (void)dismissButtonPressed:(UIBarButtonItem*)button
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)plusButtonPressed
{
    _fontSize += 6;
    [self loadWebviewWithTextString:_fileDataString withFontSize:_fontSize];
}

- (void)minusButtonPressed
{
    _fontSize -= 6;
    [self loadWebviewWithTextString:_fileDataString withFontSize:_fontSize];

}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];

}







@end
