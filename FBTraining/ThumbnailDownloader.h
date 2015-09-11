//
//  ThumbnailDownloader.h
//  Live2BenchNative
//
//  Created by dev on 2015-09-09.
//  Copyright © 2015 DEV. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ActionListItem.h"
#import "ImageAssetManager.h"

@interface ThumbnailDownloader : NSObject <ActionListItem,NSURLConnectionDataDelegate>


@property (nonatomic,assign) BOOL isFinished;
@property (nonatomic,assign) BOOL isSuccess;
@property (nonatomic,weak)  id <ActionListItemDelegate>  delegate;
@property (nonatomic,weak)  ActionList      * listItemOwner;

-(void)start;
-(instancetype)initImageAssetManager:(ImageAssetManager*)aIAM url:(NSString*)aUrl;
-(instancetype)initImageAssetManager:(ImageAssetManager*)aIAM url:(NSString*)aUrl imageView:(UIImageView*)aImageview;



@end
