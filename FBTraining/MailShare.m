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
    for (NSData *videoClip in itemsToShare) {
        [self.mailViewController addAttachmentData:videoClip mimeType:@"video/mp4" fileName:@"fileNameNeedsReplacement"];
    }
}

- (void)mailComposeController:(MFMailComposeViewController *)controller
          didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError *)error{
    
}
@end
