//
//  MailShare.m
//  Live2BenchNative
//
//  Created by dev on 2015-03-13.
//  Copyright (c) 2015 DEV. All rights reserved.
//

#import "MailShare.h"
#import <MessageUI/MessageUI.h>

@interface MailShare () <MFMailComposeViewControllerDelegate>

@property (strong, nonatomic) MFMailComposeViewController *mailViewController;

@end

@implementation MailShare

-(instancetype)init{
    self = [super init];
    if (self){
        //self.mailViewController = [[MFMailComposeViewController alloc] init];
        
    }
    return self;
}

-(UIImage *)icon{
    return [UIImage imageNamed:@"mail.png"];
}

-(UIImage *)selectedIcon{
    return [UIImage imageNamed:@"mailselected.png"];
}



-(void)shareItems: (NSArray *) itemsToShare inViewController: (UIViewController *) viewController{
    self.mailViewController = [[MFMailComposeViewController alloc] init];
    self.mailViewController.mailComposeDelegate = self;
    for (NSDictionary *videoClip in itemsToShare) {
        [self.mailViewController addAttachmentData: [NSData dataWithContentsOfFile: [videoClip objectForKey: @"mp4" ]] mimeType:@"video/mp4" fileName:[videoClip objectForKey: @"mp4" ]];
    }
    
    //[viewController.parentViewController presentModalViewController:self.mailViewController animated:YES];
    [viewController.parentViewController presentViewController:self.mailViewController animated:YES completion:nil];
}

- (void)mailComposeController:(MFMailComposeViewController *)controller
          didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError *)error{
    //[viewControllerRef dismissViewControllerAnimated:controller completion:nil];
    [controller dismissViewControllerAnimated:YES completion:nil];
    self.mailViewController = nil;
}
@end
