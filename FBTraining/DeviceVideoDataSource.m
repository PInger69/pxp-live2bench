//
//  DeviceVideoDataSource.m
//  Live2BenchNative
//
//  Created by dev on 2016-06-09.
//  Copyright © 2016 DEV. All rights reserved.
//

#import "DeviceVideoDataSource.h"
#import <Photos/Photos.h>
#import "VideoCollectionViewCell.h"

@implementation DeviceVideoDataSource


- (instancetype)init
{
    self = [super init];
    if (self) {
        // get video
        self.videos = [[NSMutableArray alloc] init];
        
        PHFetchOptions *allPhotosOptions = [[PHFetchOptions alloc] init];
        allPhotosOptions.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:YES]];
        allPhotosOptions.predicate       = [NSPredicate predicateWithFormat:@"mediaType == %d", PHAssetMediaTypeVideo];
        
        PHFetchResult *allPhotos = [PHAsset fetchAssetsWithOptions:allPhotosOptions];
        PHFetchResult *fetchResult = @[allPhotos][0];
        int x;
        for (x = 0; x < fetchResult.count; x ++) {
            PHAsset *asset = fetchResult[x];
            if (asset.mediaType == PHAssetMediaTypeVideo) {
                self.videos[x] = asset;
                
            }
        }
        
        
        
    }
    return self;
}


#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
{
    return [self.videos count];
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    UITableViewCell *cell = [[UITableViewCell alloc]init];
    
    PHImageManager *manager = [PHImageManager defaultManager];
    
    if (cell.tag) {
        [manager cancelImageRequest:(PHImageRequestID)cell.tag];
    }
    
    PHAsset *asset = self.videos[indexPath.row];
    
    if (asset.creationDate) {
        cell.textLabel.text = [NSDateFormatter localizedStringFromDate:asset.creationDate
                                                             dateStyle:NSDateFormatterMediumStyle
                                                             timeStyle:NSDateFormatterMediumStyle];
    } else {
        cell.textLabel.text = nil;
    }
    
    cell.tag = [manager requestImageForAsset:asset
                                  targetSize:CGSizeMake(100.0, 100.0)
                                 contentMode:PHImageContentModeAspectFill
                                     options:nil
                               resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
                                   cell.imageView.image = result;
                               }];
    
    return cell;
}
#pragma mark - UICollectionViewDataSource


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.videos count];
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{

    return nil;
    
////        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
////    (thumbnailCell*)[cv dequeueReusableCellWithReuseIdentifier:@"thumbnailCell" forIndexPath:indexPath];
//    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"thumbnailCell" forIndexPath:indexPath];
//    
////    UICollectionViewCell *cell = [UICollectionViewCell new];
//    
//    PHImageManager *manager = [PHImageManager defaultManager];
//    
//    if (cell.tag) {
//        [manager cancelImageRequest:(PHImageRequestID)cell.tag];
//    }
//    
//    PHAsset *asset = self.videos[indexPath.row];
//
//    cell.tag = [manager requestImageForAsset:asset
//                                  targetSize:CGSizeMake(100.0, 100.0)
//                                 contentMode:PHImageContentModeAspectFill
//                                     options:nil
//                               resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
//                                   
//                                   UIImageView * img = [[UIImageView alloc]initWithImage:result];
//                                   [cell.contentView addSubview:img];
//                               }];
//    
//    return cell;

}


@end
