//
//  ImageAssetManager.h
//  ImageAssetManager
//
//  Created by dev on 2015-02-02.
//  Copyright (c) 2015 Avoca Technologies. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UIKit/UIKit.h"

@interface ImageAssetManager : NSObject 

@property (strong, nonatomic) NSString *pathForFolderContainingImages;
@property (assign, nonatomic) NSTimeInterval timeOutInterval;

-(void)imageForURL: (NSString *) imageURLString atImageView: (UIImageView *) viewReference;



@end
