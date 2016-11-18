//
//  ImageAssetManager.h
//  ImageAssetManager
//
//  Created by dev on 2015-02-02.
//  Copyright (c) 2015 Avoca Technologies. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UIKit/UIKit.h"
#import "PxpTelestration.h"

@interface ImageAssetManager : NSObject 

@property (strong, nonatomic, nullable) NSString *pathForFolderContainingImages;
@property (assign, nonatomic) NSTimeInterval timeOutInterval;
@property (nonatomic,strong, nullable) NSMutableDictionary *arrayOfClipImages;

+(nonnull instancetype)getInstance;

-(void)imageForURL: (nonnull NSString *) imageURLString atImageView: (nonnull UIImageView *) viewReference;
-(void)imageForURL: (nonnull NSString *) imageURLString atImageView: (nonnull UIImageView *) viewReference withTelestration:(nullable PxpTelestration *)telestration;

-(void)thumbnailsPreload:(NSArray*)list;
-(void)thumbnailsPreloadLocal:(NSArray*)list;
-(void)thumbnailsUnload:(NSArray*)list;
-(void)thumbnailsUnloadAll;
-(void)thumbnailsLoadedToView:(UIImageView*)imageView imageURL:(NSString*)aImageUrl;

@end
