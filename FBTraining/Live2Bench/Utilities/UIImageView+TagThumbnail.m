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

-(void) pxp_setTagThumbnail:(Tag*) tag {
    
    __weak UIImageView* weakImageView = self;
    if (tag.isTelestration) {
        PxpTelestration* tele = tag.telestration;
        
        NSString* checkName = (!tele.sourceName)?[tag.thumbnails allKeys][0]:tele.sourceName;
        NSString* imageURL = ([tag.thumbnails objectForKey:checkName])?[tag.thumbnails objectForKey:checkName]:[NSString stringWithFormat:@"%@.png",[[NSUUID UUID]UUIDString]];
        
        
        [self sd_setImageWithURL:[NSURL URLWithString:imageURL] placeholderImage:[UIImage imageNamed:@"defaultTagView"] completed:^(UIImage* image, NSError* error, SDImageCacheType cacheType, NSURL* imageURL) {
            
            if (error) {
                NSLog(@"Error downloading image at URL %@: %@", imageURL, error.localizedDescription);
                weakImageView.image = [UIImage imageNamed:@"imageNotAvailable"];
            } else if (image) {
                NSLog(@"applying telestration to image");
                UIImage* imageWithTelestration = [tele renderOverImage:image view:weakImageView];
                weakImageView.image = imageWithTelestration;
            }
        }];
    } else {
        NSString *url = [[tag.thumbnails allValues] firstObject];
        [self sd_setImageWithURL:[NSURL URLWithString:url] placeholderImage:[UIImage imageNamed:@"defaultTagView"] completed:^(UIImage* image, NSError* error, SDImageCacheType cacheType, NSURL* imageURL) {
            if (error) {
                NSLog(@"Error downloading image at URL %@: %@", imageURL, error.localizedDescription);
                weakImageView.image = [UIImage imageNamed:@"imageNotAvailable"];
            }
        }];
    }
}


@end
