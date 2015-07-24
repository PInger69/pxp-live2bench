//
//  TagNameSelectTableViewController.h
//  Live2BenchNative
//
//  Created by Nico Cvitak on 2015-07-22.
//  Copyright © 2015 DEV. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TagNameSelectResponder.h"

@interface TagNameSelectTableViewController : UITableViewController

@property (weak, nonatomic, nullable) id<TagNameSelectResponder> tagNameSelectResponder;

- (void)setTagDescriptors:(nonnull NSArray *)tagNames;

@end
