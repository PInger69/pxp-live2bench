//
//  PxpMailClipActivity.m
//  Live2BenchNative
//
//  Created by dev on 2016-07-20.
//  Copyright © 2016 DEV. All rights reserved.
//

#import "PxpMailClipActivity.h"
#import <MessageUI/MessageUI.h>


#import "Clip.h"

@interface PxpMailClipActivity () <MFMailComposeViewControllerDelegate>

@end


@implementation PxpMailClipActivity
{
    MFMailComposeViewController *mailComposeViewController;
}


- (instancetype)initWithClips:(NSArray*)clips
{
    self = [super init];
    if (self) {
        self.clips = clips;
    }
    return self;
}

- (nullable NSString *)activityTitle
{
    return [NSString stringWithFormat:@"Email Clips"];
}



- (UIImage *)activityImage
{
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) {
        return [UIImage imageNamed:@"MailIcon"]; //240 px x 240px
    }
    else {
        return [UIImage imageNamed:@"MailIcon"];// 120px x 120px
    }
}

- (BOOL)canPerformWithActivityItems:(NSArray *)activityItems {
    
    BOOL check = YES;
    
//    for (NSURL *url in activityItems) {
//        if (![url isKindOfClass:[NSURL class]]) {
//            check = NO;
//        }
//    }
    
    return check;
}

- (void)prepareWithActivityItems:(NSArray *)activityItems {
//    NSMutableArray * pool = [NSMutableArray new];
//    for (NSURL *url in activityItems) {
//        if ([url isKindOfClass:[NSURL class]]) {
//            [pool addObject:url];
//        }
//    }
//    
//    self.urls  = [pool copy];
    
}



- (void)performActivity
{
    if (!self.presetingViewController)    {
     
        [self activityDidFinish:YES];
        return;
    }
    
    mailComposeViewController = [[MFMailComposeViewController alloc] init];
    if (mailComposeViewController) {
        mailComposeViewController.mailComposeDelegate = self;
    //    [mailComposeViewController setToRecipients:@[@"mattt@nshipster•com"]];
        [mailComposeViewController setSubject:@"Live2Bench Clips"];
    //    [mailComposeViewController setMessageBody:@"Lorem ipsum dolor sit amet"
    //                                       isHTML:NO];
        
        
        [mailComposeViewController setMessageBody:[self buildMessageFromClips:self.clips] isHTML:YES];
        
        [self attachClipToEmail:self.clips mailComposer:mailComposeViewController];
        [self.presetingViewController presentViewController:mailComposeViewController animated:YES completion:^{
//TODO: make no email Error
        }];
    } else {
        
    }
}



-(void)attachClipToEmail:(NSArray*)theClips mailComposer:(MFMailComposeViewController*)mailComposer
{
    for (Clip* aclip in theClips) {
        NSString * clipName = aclip.name;
        NSString * clipTime = aclip.displayTime;
//        NSArray * videoKeys = [aclip.videosBySrcKey allKeys];;
        NSArray * videoKeys = aclip.videoFiles;
        
        for (NSString * key in videoKeys) {
            
            //NSString * videoString = aclip.videosBySrcKey[key];
            NSString* videoString = key;
            
            NSURL * filePath = [NSURL fileURLWithPath:videoString];
            NSLog(@"Checking to see if clip file exists: %@ %@", videoString, [[NSFileManager defaultManager] fileExistsAtPath:videoString] ? @"YES" : @"NO");
            NSData * videoData = [NSData dataWithContentsOfURL:filePath];
            NSString * scourse = key;
            NSString* destinationfileName = [NSString stringWithFormat:@"%@_%@_%@_%@.mp4",clipName,[Utility dateFromEvent:aclip.eventName],clipTime,scourse];
            if (videoData != nil) {
                [mailComposer addAttachmentData:videoData mimeType:@"video/mp4" fileName:destinationfileName];
            }
            
        }

    }


}


-(void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{

    NSLog(@"%s",__FUNCTION__);
    [mailComposeViewController dismissViewControllerAnimated:YES completion:^{
        
    }];
}



-(NSString*)buildMessageFromClips:(NSArray*)clips
{
    NSMutableString * text = [NSMutableString new];
    
    [text appendString:@"<html><body>"];
    for (Clip *aClip in clips) {

        [text appendString:[NSString stringWithFormat:@"<strong>%@</strong><br/>",aClip.name]];
        [text appendString:[NSString stringWithFormat:@"File Names: <br/>"]];
        
        NSArray * videoKeys = [aClip.videosBySrcKey allKeys];;
        for (NSString * key in videoKeys) {
//            NSString * videoString = aClip.videosBySrcKey[key];
            
//            NSURL * filePath = [NSURL fileURLWithPath:videoString];
            NSString * scourse = key;
            NSString* destinationfileName = [NSString stringWithFormat:@"%@_%@_%@_%@.mp4",aClip.name,[Utility dateFromEvent:aClip.eventName],aClip.displayTime,scourse];
            
            [text appendString:[NSString stringWithFormat:@"&nbsp&nbsp&nbsp&nbsp%@<br/>",destinationfileName]];
        }
        
        
        
        
        
        
        if (aClip.rating) {
            
            [text appendString:[NSString stringWithFormat:@"Rating: "]];
            
            for (NSInteger i = 0; i < aClip.rating; i++) {
                [text appendString:@"*"];
            }
            
            [text appendString:@"<br/>"];
            
        }
        if (![aClip.comment isEqualToString:@""]) [text appendString:[NSString stringWithFormat:@"Comment: %@<br/>",aClip.comment]];
        
        [text appendString:@"---<br/>"];
        
    }
    [text appendString:@"</body></html>"];

    
    
    
    
    return [text copy];

}



@end
