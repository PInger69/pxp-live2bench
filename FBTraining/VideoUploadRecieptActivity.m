//
//  VideoUploadRecieptActivity.m
//  Live2BenchNative
//
//  Created by dev on 2016-08-18.
//  Copyright © 2016 DEV. All rights reserved.
//

#import "VideoUploadRecieptActivity.h"
#import "UploadOperation.h"
#import <MessageUI/MessageUI.h>
#import "UserCenter.h"
#import "Clip.h"
#import "CustomAlertControllerQueue.h"

@interface VideoUploadRecieptActivity () <MFMailComposeViewControllerDelegate>
@property (nonatomic,strong) NSOperationQueue * queue;
@property (nonatomic,strong)    MFMailComposeViewController *mailComposeViewController;

@property (nonatomic,strong) NSMutableArray * links;
@end



@implementation VideoUploadRecieptActivity
{

}

- (instancetype)initWithClips:(NSArray*)clips
{
    self = [super init];
    if (self) {
        self.clips = clips;
        self.queue = [NSOperationQueue mainQueue];
        self.progressMessage = @"";
        self.links = [NSMutableArray new];
    }
    return self;
}


- (nullable NSString *)activityTitle
{
    return [NSString stringWithFormat:@"Upload Video to Pxp Cloud"];
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

- (void)prepareWithActivityItems:(NSArray *)activityItems
{
    
}




- (void)performActivity
{
    NSURL * location = [[NSURL alloc]initWithString:@"http://myplayxplay.net/max/xsUpload/ajax"];
    
    __weak VideoUploadRecieptActivity * weakActivity1 = self;
    
    NSBlockOperation * finishBlock = [NSBlockOperation blockOperationWithBlock:^{
        [weakActivity1 activityDidFinish:YES];
    }];
    
    NSURL * fileUrl;
    UploadOperation * prevOp;
    for (NSInteger i = 0; i< [self.clips count]; i++) {
        
        Clip * theClip =self.clips[i];
        fileUrl = [NSURL fileURLWithPath:theClip.videoFiles[0]];//self.clips[i];
        
        
        
        UploadOperation * uploadOp = [[UploadOperation alloc]initWith:location fileToBeUploaded:fileUrl];
        uploadOp.league     = theClip.rawData[@"displaytime"];
        uploadOp.vTeam      = theClip.rawData[@"visitTeam"];
        uploadOp.hTeam      = theClip.rawData[@"homeTeam"];
        uploadOp.clipName   = theClip.name;
        uploadOp.clipTime   = theClip.rawData[@"displaytime"];
        uploadOp.clipDate   = [Utility dateFromEvent:theClip.localRawData[@"event"]];
        
        
        __weak VideoUploadRecieptActivity * weakActivity = self;
        
        [uploadOp setOnRequestProgress:^(UploadOperation * op) {
            [weakActivity processProgress:op];
        }];

        [uploadOp setOnRequestRecieved:^(UploadOperation * op) {
           NSMutableDictionary * dict = [[Utility JSONDatatoDict:op.data] mutableCopy];
            
            
            if (!dict[@"success"]) {
                NSLog(@"ERROR  %@",dict);
            }
            
            
            [dict setObject:op.clipName forKey:@"name"];
            [dict setObject:op.vTeam forKey:@"vTeam"];
            [dict setObject:op.hTeam forKey:@"hTeam"];
            [dict setObject:op.league forKey:@"league"];
            [dict setObject:op.clipTime forKey:@"time"];
            [dict setObject:op.clipDate forKey:@"date"];
            
            NSLog(@"%@",dict);
            if (dict&& dict[@"xsURL"]) {
                
                [self.links addObject:dict[@"xsURL"]];
                [[UserCenter getInstance]saveVideoRecieptData:dict];
                
            }
            
        }];

        
        if (prevOp) {
            [uploadOp addDependency:prevOp];
        }
        [finishBlock addDependency:uploadOp];
        
        [self.queue addOperation:uploadOp];
        
        prevOp = uploadOp;
    }
    
    
    [self.queue addOperation:finishBlock];
}

-(void)processProgress:(UploadOperation *) operation
{
    self.progressMessage = @"Uploading...";
    if(self.onActivityProgress)self.onActivityProgress(self,(CGFloat)(((CGFloat)operation.sentBytes) / ((CGFloat)operation.expectedBytes)));
}

- (void)activityDidFinish:(BOOL)completed
{
    
    
    NSMutableString * text = [NSMutableString new];
    
    
    
    for (NSInteger i =0; i< [self.links count]; i++) {
        [text appendString:self.links[i]];
        [text appendString:@"\n"];
    }
    
    [self makeEmail:text];
    self.onRequestComplete(self);
    [super activityDidFinish:completed];

}


-(void)makeEmail:(NSString*)message
{
    self.mailComposeViewController = [[MFMailComposeViewController alloc] init];
    if (self.mailComposeViewController) {
        //TODO: make no email Error
        self.mailComposeViewController.mailComposeDelegate = self;
        [self.mailComposeViewController setSubject:@"Live2Bench Clips"];

        [self.mailComposeViewController setMessageBody:message
                                           isHTML:NO];
        [ROOT_VIEW_CONTROLLER presentViewController:self.mailComposeViewController animated:YES completion:^{
            
        }];
    } else {
        //TODO: make no email Error
    }



}

-(void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    [self.mailComposeViewController dismissViewControllerAnimated:YES completion:^{
        
    }];
}



-(void)showError:(NSString*)errorMessage
{
    UIAlertController * alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"myplayXplay",nil)
                                                                    message:errorMessage
                                                             preferredStyle:UIAlertControllerStyleAlert];
    
    
    
    
    UIAlertAction* okayButton = [UIAlertAction
                                 actionWithTitle:@"OK"
                                 style:UIAlertActionStyleDefault
                                 handler:^(UIAlertAction * action)
                                 {
                                     [[CustomAlertControllerQueue getInstance] dismissViewController:alert animated:YES completion:nil];
                                 }];
    
    
    [alert addAction:okayButton];
    
    (void)[[CustomAlertControllerQueue getInstance]presentViewController:alert inController:ROOT_VIEW_CONTROLLER animated:YES style:AlertIndecisive completion:nil];
    
    


}




@end
