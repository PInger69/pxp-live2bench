//
//  EmailActivity.m
//  Live2BenchNative
//
//  Created by dev on 2016-09-12.
//  Copyright © 2016 DEV. All rights reserved.
//

#import "EmailActivity.h"



@interface EmailActivity () <MFMailComposeViewControllerDelegate>

@end

@implementation EmailActivity
{

}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.mailComposeViewController = [[MFMailComposeViewController alloc] init];
    }
    return self;
}



- (nullable NSString *)activityTitle
{
    return [NSString stringWithFormat:@"Email"];
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


    if (self.mailComposeViewController) {
        self.mailComposeViewController.mailComposeDelegate = self;
        
        NSData *fileData = [NSData dataWithContentsOfFile:[PxpLog deviceLogPath]];
        
        //    [mailComposeViewController setToRecipients:@[@"mattt@nshipster•com"]];
        [self.mailComposeViewController setSubject:@"Device Log"];
        //    [mailComposeViewController setMessageBody:@"Lorem ipsum dolor sit amet"
        //                                       isHTML:NO];
        [self.mailComposeViewController addAttachmentData:fileData mimeType:@"text/plain" fileName:@"DeviceLog.txt"];
        
        
        
        [self.presetingViewController presentViewController:self.mailComposeViewController animated:YES completion:^{
            //TODO: make no email Error
        }];
    } else {
        //error
    }
}

-(void)launch
{
    
    if (self.mailComposeViewController) {
        self.mailComposeViewController.mailComposeDelegate = self;
        
        NSData *fileData = [NSData dataWithContentsOfFile:[PxpLog deviceLogPath]];
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"yyyy-MM-dd";
        

        
        
        NSString *subject = [NSString stringWithFormat:@"Device Log %@",[formatter stringFromDate:[NSDate new]]];
        
        [self.mailComposeViewController setToRecipients:@[@"ireel@avocatec.com"]];
        [self.mailComposeViewController setSubject:subject];
        //    [mailComposeViewController setMessageBody:@"Lorem ipsum dolor sit amet"
        //                                       isHTML:NO];
        [self.mailComposeViewController addAttachmentData:fileData mimeType:@"text/plain" fileName:@"DeviceLog.txt"];
        
        
        
        [self.presetingViewController presentViewController:self.mailComposeViewController animated:YES completion:^{
            //TODO: make no email Error
        }];
    } else {
      // error
    }


}

-(void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    [self.mailComposeViewController dismissViewControllerAnimated:YES completion:^{
        
    }];
}


@end
