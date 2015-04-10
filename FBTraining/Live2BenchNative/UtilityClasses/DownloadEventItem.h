//
//  DownloadEventItem.h
//  Live2BenchNative
//
//  Created by dev on 2015-04-07.
//  Copyright (c) 2015 DEV. All rights reserved.
//

#import "DownloadItem.h"

@interface DownloadEventItem : DownloadItem

/**
 *  This takes in an Array of Dicts @[@{@"path":<path>,@"dest":<dest>, ...}]
 *
 *  @param aListOfURLAndDestination
 *
 *  @return
 */
-(instancetype)initWithURL:(NSArray*)aListOfURLAndDestination;

@end
