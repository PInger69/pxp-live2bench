//
//  GroupDropboxActivity.m
//  Live2BenchNative
//
//  Created by dev on 2016-07-11.
//  Copyright © 2016 DEV. All rights reserved.
//

#import "GroupDropboxActivity.h"

@implementation GroupDropboxActivity
- (NSString *)activityType
{
    return @"pxplive2bench.dropbox.App";
}

- (NSString *)activityTitle
{
    return @"Copy files to Dropbox";
}
- (UIImage *)activityImage
{
    // Note: These images need to have a transparent background and I recommend these sizes:
    // iPadShare@2x should be 126 px, iPadShare should be 53 px, iPhoneShare@2x should be 100
    // px, and iPhoneShare should be 50 px. I found these sizes to work for what I was making.
    
//    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
//    {
//        return [UIImage imageNamed:@"iPadShare.png"];
//    }
//    else
//    {
//        return [UIImage imageNamed:@"iPhoneShare.png"];
//    }
//    
    
    return  nil;
}

- (BOOL)canPerformWithActivityItems:(NSArray *)activityItems
{
    for (NSInteger i = 0; i<[activityItems count]; i++) {
        
    }
//    activityItems con
    
    NSLog(@"%s", __FUNCTION__);
    return YES;
}

- (void)prepareWithActivityItems:(NSArray *)activityItems
{
    NSLog(@"%s",__FUNCTION__);
}

- (UIViewController *)activityViewController
{
    NSLog(@"%s",__FUNCTION__);
    return nil;
}

- (void)performActivity
{
    // This is where you can do anything you want, and is the whole reason for creating a custom
    // UIActivity
    
//    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"itms-apps://ax.itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=yourappid"]];
    [self activityDidFinish:YES];
}



@end
