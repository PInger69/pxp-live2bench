//
//  GDContentsTableCell.h
//  Live2BenchNative
//
//  Created by Si Te Feng on 8/14/14.
//  Copyright (c) 2014 DEV. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GTLDrive.h"

@interface GDContentsTableCell : UITableViewCell




@property (nonatomic, strong) GTLDriveFile* driveFile;

@property (nonatomic, strong) NSString* fullPathString;



@end
