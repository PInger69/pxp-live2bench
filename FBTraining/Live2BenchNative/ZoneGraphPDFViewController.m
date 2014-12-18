//
//  ZoneGraphPDFViewController.m
//  Live2BenchNative
//
//  Created by Si Te Feng on 7/25/14.
//  Copyright (c) 2014 DEV. All rights reserved.
//

#import "ZoneGraphPDFViewController.h"
#import "JPGraphPDFGenerator.h"
#import <CoreText/CoreText.h>
#import "UserInterfaceConstants.h"
#import "Globals.h"

@implementation ZoneGraphPDFViewController


- (instancetype)init
{
    self = [self initWithNibName:nil bundle:nil];
    return self;
}


- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    self.pdfFilePath = [NSString stringWithFormat:@"%@.pdf",[Globals instance].HUMAN_READABLE_EVENT_NAME];
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor lightGrayColor];
    self.title = self.pdfFilePath;
    
    CGRect viewRect = self.view.bounds;
    
    self.webView = [[UIWebView alloc] initWithFrame:viewRect];
    self.webView.delegate = self;
    [self.view addSubview:self.webView];
    

}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.view.bounds = self.view.superview.bounds;
    
//    self.webView.frame = CGRectMake(0, kiPadNavigationBarHeight, self.view.bounds.size.width, self.view.bounds.size.height - kiPadNavigationBarHeight);
    self.webView.frame = CGRectMake(0, kiPadNavigationBarHeight, 540, 620 - kiPadNavigationBarHeight);
    
    [self displayPDFOnWebView];
}


- (void)displayPDFOnWebView
{
    
    NSURL* url = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] firstObject];
    
    NSURL* fileUrl = [[url URLByAppendingPathComponent:@"pdfExports"] URLByAppendingPathComponent:self.pdfFilePath];
    
    if(!fileUrl)
    {
        NSLog(@"NO FILE AVAILABLE");
        [[[UIAlertView alloc] initWithTitle:@"File Does Not Exist" message:@"There was an error saving the file, please try again." delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles: nil] show];
        return;
    }
    
    
    NSURLRequest* urlReq = [NSURLRequest requestWithURL:fileUrl];
    
    [self.webView setScalesPageToFit:YES];
    [self.webView loadRequest:urlReq];

}


- (void)webViewDidFinishLoad:(UIWebView *)webView
{
//    NSString *jsCommand = [NSString stringWithFormat:@"document.body.style.zoom = 1.5;"];
//    [self.webView stringByEvaluatingJavaScriptFromString:jsCommand];
//    
//    self.webView.scrollView.contentOffset = CGPointMake(0, kiPadNavigationBarHeight);
}








@end
