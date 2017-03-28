//
//  UIImageView+TagThumbnail.m
//  Live2Bench
//
//  When showing a tag, we want to be able to easily display the associated
//  thumbnail image. Generally, these are provided by the server, but the
//  server periodically fails to generate these images properly, so as a fall-back,
//  we can generate an image on the device.
//
//  Created by BC Holmes on 2017-02-08.
//  Copyright © 2017 Avoca. All rights reserved.
//

#import "UIImageView+TagThumbnail.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "Feed.h"

@implementation UIImageView (TagThumbnail)


-(void) pxp_setTagThumbnail:(Tag*) tag fromUrl:(NSString*) url source:(NSString*) source {
    if (url == nil) {
        self.image = [UIImage imageNamed:@"defaultTagView"];
        [self pxp_generateLocalScreenCapture:tag source:source];
    } else if (tag.eventInstance.local) {
        
        UIImage* thumbnail = [self pxp_thumbnailFromImageCache:url];
        if (thumbnail != nil) {
            self.image = thumbnail;
        } else {
            PXPLog(@"Tag \"%@\" (%@) does not seem to have a locally-saved thumbnail (url = %@)", tag.name, tag.ID, url);
            NSLog(@"Tag \"%@\" (%@) does not seem to have a locally-saved thumbnail (url = %@)", tag.name, tag.ID, url);
            [self pxp_generateLocalScreenCapture:tag source:source];
        }
    } else {
        [self sd_setImageWithURL:[NSURL URLWithString:url] placeholderImage:[UIImage imageNamed:@"defaultTagView"] completed:^(UIImage* image, NSError* error, SDImageCacheType cacheType, NSURL* imageURL) {
            if (error) {
                [self pxp_generateLocalScreenCapture:tag source:source];
            }
        }];
    }
}

-(void) pxp_setTagThumbnail:(Tag*) tag withSource:(NSString*) source {
    
    if (tag.isTelestration && [source isEqualToString:tag.telestration.sourceName]) {
        [self pxp_setTagTelestrationThumbnail:tag];
    } else {
        [self pxp_setTagThumbnail:tag fromUrl:tag.thumbnails[source] source:source];
    }
}

-(UIImage*) pxp_thumbnailFromImageCache:(NSString*) url {
    UIImage* thumbnail = [[SDImageCache sharedImageCache] imageFromMemoryCacheForKey:url];
    if (thumbnail == nil) {
        thumbnail = [[SDImageCache sharedImageCache] imageFromMemoryCacheForKey:url];
    }
    return thumbnail;
}

-(void) pxp_setTagTelestrationThumbnail:(Tag*) tag {
    PxpTelestration* tele = tag.telestration;
    
    NSString* checkName = (!tele.sourceName)?[tag.thumbnails allKeys][0]:tele.sourceName;
    NSString* imageURL = ([tag.thumbnails objectForKey:checkName])?[tag.thumbnails objectForKey:checkName]:[[tag.thumbnails allValues] firstObject];
    
    if (imageURL == nil) {
        self.image = [UIImage imageNamed:@"defaultTagView"];
        [self pxp_generateLocalScreenCapture:tag source:checkName];
    } else if (tag.eventInstance.local) {
        UIImage* thumbnail = [self pxp_thumbnailFromImageCache:imageURL];
        if (thumbnail != nil) {
            UIImage* imageWithTelestration = [tele renderOverImage:thumbnail view:self];
            if (imageWithTelestration != nil) {
                self.image = imageWithTelestration;
            } else {
                self.image = thumbnail;
            }
        } else {
            NSLog(@"Telestration \"%@\" (%@) does not seem to have a locally-saved thumbnail (url = %@)", tag.name, tag.ID, imageURL);
            PXPLog(@"Telestration \"%@\" (%@) does not seem to have a locally-saved thumbnail (url = %@)", tag.name, tag.ID, imageURL);
            [self pxp_generateLocalScreenCapture:tag source:checkName];
        }
    } else {
        [self sd_setImageWithURL:[NSURL URLWithString:imageURL] placeholderImage:[UIImage imageNamed:@"defaultTagView"] completed:^(UIImage* image, NSError* error, SDImageCacheType cacheType, NSURL* imageURL) {
            
            if (error) {
                [self pxp_generateLocalScreenCapture:tag source:checkName];
            } else if (image) {
                UIImage* imageWithTelestration = [tele renderOverImage:image view:self];
                if (imageWithTelestration != nil) {
                    self.image = imageWithTelestration;
                }
            }
        }];
    }
    
}

-(void) pxp_generateLocalScreenCapture:(Tag*) tag  XXXsource:(NSString*) source {
    Feed* feed = source && tag.eventInstance.feeds[source] ? tag.eventInstance.feeds[source] : tag.eventInstance.feeds.allValues.firstObject;

    if (feed.path) {
        AVURLAsset *asset=[[AVURLAsset alloc] initWithURL:feed.path options:nil];
        AVAssetImageGenerator *generator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
        generator.appliesPreferredTrackTransform=TRUE;
        NSTimeInterval time = tag.isTelestration && [source isEqualToString:tag.telestration.sourceName] ? tag.telestration.thumbnailTime : tag.time;

        CMTime thumbTime = CMTimeMakeWithSeconds(time,1);
        
        AVAssetImageGeneratorCompletionHandler handler = ^(CMTime requestedTime, CGImageRef imageRef, CMTime actualTime, AVAssetImageGeneratorResult result, NSError *error){
            
            UIImage* thumbnail = nil;
            if (result != AVAssetImageGeneratorSucceeded) {
                NSLog(@"couldn't generate thumbnail, error:%@", error);
            } else {
                NSLog(@"Image has been generated.");
                thumbnail = [UIImage imageWithCGImage:imageRef];
                if (thumbnail && tag.isTelestration && [source isEqualToString:tag.telestration.sourceName]) {
                    thumbnail = [tag.telestration renderOverImage:thumbnail view:self];
                }
            }
            dispatch_async(dispatch_get_main_queue(), ^(void){
                if (thumbnail == nil) {
                    self.image = [UIImage imageNamed:@"imageNotAvailable"];
                } else {
                    self.image = thumbnail;
                }
            });
        };
        
        CGSize maxSize = CGSizeMake(320, 180);
        generator.maximumSize = maxSize;
        [generator generateCGImagesAsynchronouslyForTimes:[NSArray arrayWithObject:[NSValue valueWithCMTime:thumbTime]] completionHandler:handler];
    }
}


// BCH: - the concern, here, is that, if we're scrolling, we might finish generating the thumbnail
//        after a cell has been reused. But this is the algorithm that was originally in place.
-(void) pxp_generateLocalScreenCapture:(Tag*) tag source:(NSString*) source {
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
        UIImage* thumbnail = [tag thumbnailForSource:source];
        if (thumbnail && tag.isTelestration && [source isEqualToString:tag.telestration.sourceName]) {
            thumbnail = [tag.telestration renderOverImage:thumbnail view:self];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^(void){
            if (thumbnail == nil) {
                self.image = [UIImage imageNamed:@"imageNotAvailable"];
            } else {
                self.image = thumbnail;
            }
        });
    });
}


-(void) pxp_setTagThumbnail:(Tag*) tag {
    
    if (tag.isTelestration) {
        [self pxp_setTagTelestrationThumbnail:tag];
    } else {
        [self pxp_setTagThumbnail:tag withSource:[tag.thumbnails allKeys].firstObject];
    }
}


@end
