//
//  FacebookShare.m
//  Live2BenchNative
//
//  Created by dev on 2015-03-16.
//  Copyright (c) 2015 DEV. All rights reserved.
//
#import <UIKit/UIKit.h>
#import "FacebookShare.h"
#import <Social/Social.h>
//#import <Accounts/Accounts.h>
#import <FacebookSDK/FacebookSDK.h>

@interface FacebookShare()

//@property (strong, nonatomic)

@end

@implementation FacebookShare
//
//-(UIViewController *)viewController{
//    SLComposeViewController *facebookViewController = [SLComposeViewController composeViewControllerForServiceType: SLServiceTypeFacebook];
//    return facebookViewController;
//}

-(UIImage *)icon{
    return [UIImage imageNamed:@"facebook.png"];
}

-(UIImage *)selectedIcon{
    return [UIImage imageNamed:@"facebookselected.png"];
}

-(void) linkInViewController: (UIViewController *)viewController{
    SLComposeViewController *facebookViewController = [SLComposeViewController composeViewControllerForServiceType: SLServiceTypeFacebook];
    
    [viewController presentViewController:facebookViewController animated:YES completion:nil];
}

-(void)shareItems: (NSArray *) itemsToShare inViewController: (UIViewController *) viewController{
    for (NSDictionary *tagDict in itemsToShare) {
        [self shareOnFaceBook: tagDict[@"mp4"]];
    }
}


-(void)shareOnFaceBook: (NSString *) localPath
{
    //sample_video.mov is the name of file
    //NSString *filePathOfVideo = [[NSBundle mainBundle] pathForResource:@"sample_video" ofType:@"mov"];
    
    //NSLog(@"Path  Of Video is %@", filePathOfVideo);
    NSData *videoData = [NSData dataWithContentsOfFile: localPath];
    //you can use dataWithContentsOfURL if you have a Url of video file
    //NSData *videoData = [NSData dataWithContentsOfURL:shareURL];
    //NSLog(@"data is :%@",videoData);
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   videoData, @"video.mov",
                                   @"video/quicktime", @"contentType",
                                   @"Video name ", @"name",
                                   @"description of Video", @"description",
                                   nil];
    
    if (FBSession.activeSession.isOpen)
    {
        [FBRequestConnection startWithGraphPath:@"me/videos"
                                     parameters:params
                                     HTTPMethod:@"POST"
                              completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                                  if(!error)
                                  {
                                      NSLog(@"RESULT: %@", result);
                                      //[self throwAlertWithTitle:@"Success" message:@"Video uploaded"];
                                  }
                                  else
                                  {
                                      NSLog(@"ERROR: %@", error.localizedDescription);
                                      //[self throwAlertWithTitle:@"Denied" message:@"Try Again"];
                                  }
                              }];
    }
    else
    {
        NSArray *permissions = [[NSArray alloc] initWithObjects:
                                @"publish_actions",
                                nil];
        // OPEN Session!
        [FBSession openActiveSessionWithPublishPermissions:permissions defaultAudience:FBSessionDefaultAudienceEveryone  allowLoginUI:YES
                                         completionHandler:^(FBSession *session,
                                                             FBSessionState status,
                                                             NSError *error) {
                                             if (error)
                                             {
                                                 NSLog(@"Login fail :%@",error);
                                             }
                                             else if (FB_ISSESSIONOPENWITHSTATE(status))
                                             {
                                                 [FBRequestConnection startWithGraphPath:@"me/videos"
                                                                              parameters:params
                                                                              HTTPMethod:@"POST"
                                                                       completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                                                                           if(!error)
                                                                           {
                                                                               // [self throwAlertWithTitle:@"Success" message:@"Video uploaded"];
                                                                               
                                                                               NSLog(@"RESULT: %@", result);
                                                                           }
                                                                           else
                                                                           {
                                                                               // [self throwAlertWithTitle:@"Denied" message:@"Try Again"];
                                                                               
                                                                               NSLog(@"ERROR: %@", error.localizedDescription);
                                                                           }
                                                                           
                                                                       }];
                                             }
                                         }];
    }
}

@end
