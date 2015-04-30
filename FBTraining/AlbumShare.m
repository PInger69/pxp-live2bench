//
//  AlbumShare.m
//  Live2BenchNative
//
//  Created by dev on 2015-03-13.
//  Copyright (c) 2015 DEV. All rights reserved.
//
#import <UIKit/UIKit.h>
#import "AlbumShare.h"

@implementation AlbumShare

-(UIImage *)icon{
    return [UIImage imageNamed:@"saveToAlbum.png"];
}

-(UIImage *)selectedIcon{
    return [UIImage imageNamed:@"saveToAlbumSelected.png"];
}

-(void)shareItems: (NSArray *) itemsToShare inViewController: (UIViewController *) viewController{
    SEL completionSelector = @selector(video: didFinishSavingWithError: contextInfo:);
    for (NSDictionary *videoClip in itemsToShare) {
        BOOL videoCompatibilty = UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(videoClip[@"mp4"]);
        if (videoCompatibilty) {
            self.tasksToComplete++;
            UISaveVideoAtPathToSavedPhotosAlbum(videoClip[@"mp4"], self, completionSelector, nil);
        }else{
            
        }
        //[self.mailViewController addAttachmentData:videoClip mimeType:@"application/mp4" fileName:@"fileNameNeedsReplacement"];
    }
}

- (void)video: (NSString *) videoPath didFinishSavingWithError: (NSError *) error contextInfo: (void *) contextInfo{
    
    self.tasksCompleted ++;
    if(self.tasksToComplete == self.tasksCompleted){
        self.tasksCompleted = 0;
        self.tasksToComplete = 0;
    }
}

@end
