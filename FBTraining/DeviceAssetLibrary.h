//
//  DeviceAssetLibrary.h
//  Live2BenchNative
//
//  Created by dev on 2016-01-12.
//  Copyright © 2016 DEV. All rights reserved.
//

#import <Foundation/Foundation.h>



@interface DeviceAssetLibrary : NSObject

+(DeviceAssetLibrary*) getInstance;

@property (nonatomic,strong) NSMutableDictionary * contentDictionary; // Key is file names
@property (nonatomic,assign) BOOL isLibraryShared;


@end
