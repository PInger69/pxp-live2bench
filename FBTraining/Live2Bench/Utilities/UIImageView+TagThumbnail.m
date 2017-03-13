//
//  UIImageView+TagThumbnail.m
//  Live2Bench
//
//  Created by BC Holmes on 2017-02-08.
//  Copyright © 2017 Avoca. All rights reserved.
//

#import "UIImageView+TagThumbnail.h"
#import <SDWebImage/UIImageView+WebCache.h>

@implementation UIImageView (TagThumbnail)


-(void) pxp_setTagThumbnailFromUrl:(NSString*) url {
    if (url == nil) {
        self.image = [UIImage imageNamed:@"defaultTagView"];
    } else {
        [self sd_setImageWithURL:[NSURL URLWithString:url] placeholderImage:[UIImage imageNamed:@"defaultTagView"] options:SDWebImageRefreshCached completed:^(UIImage* image, NSError* error, SDImageCacheType cacheType, NSURL* imageURL) {
            if (error) {
                NSLog(@"Error downloading image at URL %@: %@", imageURL, error.localizedDescription);
                self.image = [UIImage imageNamed:@"imageNotAvailable"];
            }
        }];
    }
}

-(void) pxp_setTagThumbnail:(Tag*) tag withSource:(NSString*) source {
    
    if (tag.isTelestration && [source isEqualToString:tag.telestration.sourceName]) {
        [self pxp_setTagTelestrationThumbnail:tag];
    } else {
        [self pxp_setTagThumbnailFromUrl:tag.thumbnails[source]];
    }
}

-(void) pxp_setTagTelestrationThumbnail:(Tag*) tag {
    PxpTelestration* tele = tag.telestration;
    
    NSString* checkName = (!tele.sourceName)?[tag.thumbnails allKeys][0]:tele.sourceName;
    NSString* imageURL = ([tag.thumbnails objectForKey:checkName])?[tag.thumbnails objectForKey:checkName]:[[tag.thumbnails allValues] firstObject];
    
    if (imageURL == nil) {
        self.image = [UIImage imageNamed:@"defaultTagView"];
    } else {
        [self sd_setImageWithURL:[NSURL URLWithString:imageURL] placeholderImage:[UIImage imageNamed:@"defaultTagView"] options:SDWebImageRefreshCached completed:^(UIImage* image, NSError* error, SDImageCacheType cacheType, NSURL* imageURL) {
            
            if (error) {
                NSLog(@"Error downloading image at URL %@: %@", imageURL, error.localizedDescription);
                self.image = [UIImage imageNamed:@"imageNotAvailable"];
            } else if (image) {
                UIImage* imageWithTelestration = [tele renderOverImage:image view:self];
                if (imageWithTelestration != nil) {
                    self.image = imageWithTelestration;
                }
            }
        }];
    }
    
}

-(void) pxp_setTagThumbnail:(Tag*) tag {
    
    if (tag.isTelestration) {
        [self pxp_setTagTelestrationThumbnail:tag];
    } else {
        [self pxp_setTagThumbnailFromUrl:[[tag.thumbnails allValues] firstObject]];
    }
}


@end
