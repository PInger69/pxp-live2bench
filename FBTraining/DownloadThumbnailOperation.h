//
//  DownloadThumbnailOperation.h
//  Live2BenchNative
//
//  Created by dev on 2016-02-25.
//  Copyright © 2016 DEV. All rights reserved.
//

#import "BooleanOperation.h"
#import "ImageAssetManager.h"

@interface DownloadThumbnailOperation : BooleanOperation

@property (nonatomic,weak)      ImageAssetManager   * imageAssetManager;
@property (nonatomic,weak)      UIImageView         * imageView;
@property (nonatomic,strong)    NSString            * url;
@property (nonatomic,strong)    NSError             * error;

-(instancetype)initImageAssetManager:(ImageAssetManager*)aIAM url:(NSString*)aUrl;
-(instancetype)initImageAssetManager:(ImageAssetManager*)aIAM url:(NSString*)aUrl imageView:(UIImageView*)aImageView;

@end
