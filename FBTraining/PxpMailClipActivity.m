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
    return check;
}

- (void)prepareWithActivityItems:(NSArray *)activityItems {
    
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
        [mailComposeViewController setSubject:@"Live2Bench Clips"];
        
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
        for (NSString* videoString in aclip.videoFiles) {
            NSURL * filePath = [NSURL fileURLWithPath:videoString];
            NSData * videoData = [NSData dataWithContentsOfURL:filePath];
            NSString* destinationfileName = [videoString lastPathComponent];
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
        
        
        for (NSString* videoString in aClip.videoFiles) {
            [text appendString:[NSString stringWithFormat:@"&nbsp&nbsp&nbsp&nbsp%@<br/>",[videoString lastPathComponent]]];
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
