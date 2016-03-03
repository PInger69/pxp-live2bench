//
//  DeviceAssetLibrary.m
//  Live2BenchNative
//
//  Created by dev on 2016-01-12.
//  Copyright © 2016 DEV. All rights reserved.
//

#import "DeviceAssetLibrary.h"
#import <Photos/Photos.h>

@interface DeviceAssetLibrary  ()

@property (nonatomic,strong) NSOperationQueue * queue;

@end


@implementation DeviceAssetLibrary



static DeviceAssetLibrary * _instance;

+(void)initialize
{

    _instance = [DeviceAssetLibrary new];
}


+(DeviceAssetLibrary*) getInstance
{
    return _instance;

}

- (instancetype)init
{
    self = [super init];
    if (self) {

        // set up operationQueue
        self.queue              = [NSOperationQueue new];
        self.contentDictionary  = [NSMutableDictionary new];
        [self buildCaching];
        
        PHImageManager *manager = [PHImageManager defaultManager];

        
        PHFetchResult * list = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionTypeAlbum options:nil];
        
        for (NSInteger i=0; i<[list count]; i++) {
            PHAssetCollection * assetCollection = list[i];
             NSLog(@"");
            
            PHFetchOptions * fetchOptions = [PHFetchOptions new];
            
            fetchOptions.predicate = [NSPredicate predicateWithFormat:@"mediaType = %i",PHAssetMediaTypeVideo ];
            
//            PHFetchResult * assetsInCollection = [PHAsset fetchAssetsInAssetCollection:assetCollection options:fetchOptions];
//            
//            if ([assetsInCollection count]) {
//                
//                for (PHAsset * phAssetObj in assetsInCollection) {
////                    PHImageRequestID * req =
//                    (void)[ manager requestAVAssetForVideo:phAssetObj options:0 resultHandler:^(AVAsset * _Nullable asset, AVAudioMix * _Nullable audioMix, NSDictionary * _Nullable info) {
//                        NSString * fileName = [[(AVURLAsset *)asset URL] lastPathComponent];
//                        @try {
//                            
//                            // <This is to prevent  malloc: *** error for object 0x146740300: pointer being freed was not allocated>
//                            [self.contentDictionary removeObjectForKey:fileName];
//                            // </>
//                            [self.contentDictionary setObject:@{@"path":[(AVURLAsset *)asset URL]} forKey:fileName];
//                        }
//                        @catch (NSException *exception) {
//                            NSLog(@"%@", exception.reason);
//                        }
//                        @finally {
////                            NSLog(@"Char at index %d cannot be found", index);
////                            NSLog(@"Max index is: %d", [test length]-1);
//                        }
//                        
//                        NSLog(@"%@",self.contentDictionary);
//                    }];
//                }
//                
//           
//
//            }


        }
        
 
        
    }
    return self;
}






-(void)buildCaching
{
    // this is just a temp fix some crash issue
    if (YES) {
        return;
    }
    
    PHCachingImageManager   * cachingImageManager   = [[PHCachingImageManager alloc] init];
    PHFetchOptions          * options               = [[PHFetchOptions alloc] init];
    options.predicate                               = [NSPredicate predicateWithFormat:@"mediaType = %i",PHAssetMediaTypeVideo ];
    options.sortDescriptors                         = @[[NSSortDescriptor sortDescriptorWithKey:@"" ascending:YES]];
    
    PHFetchResult           * results               = [PHAsset fetchAssetsWithMediaType:PHAssetMediaTypeImage options:nil];

    NSMutableArray<PHAsset *> *assets               = [[NSMutableArray alloc] init];
    
    [results enumerateObjectsUsingBlock:^(id  _Nonnull object, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([object isKindOfClass:[PHAsset class]]) {
            [assets addObject:object];
        }
    }];

    [cachingImageManager startCachingImagesForAssets:assets
                                          targetSize:PHImageManagerMaximumSize
                                         contentMode:PHImageContentModeAspectFit
                                             options:nil];
    
    
    
}


// not done
-(BOOL)isLibraryShared
{
    return YES;
}




@end
