//
//  ZoneGraphPDFViewController.h
//  Live2BenchNative
//
//  Created by Si Te Feng on 7/25/14.
//  Copyright (c) 2014 DEV. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZoneGraphPDFViewController : UIViewController <UIWebViewDelegate>



@property (nonatomic, strong) UIWebView* webView;

@property (nonatomic, strong) NSString* pdfFilePath;


@end

