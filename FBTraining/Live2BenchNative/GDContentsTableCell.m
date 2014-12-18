//
//  GDContentsTableCell.m
//  Live2BenchNative
//
//  Created by Si Te Feng on 8/14/14.
//  Copyright (c) 2014 DEV. All rights reserved.
//

#import "GDContentsTableCell.h"
#import "NSObject+LBCloudConvenience.h"

@implementation GDContentsTableCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
        self.imageView.contentMode = UIViewContentModeScaleAspectFit;
        
    }
    return self;
}



- (void)setDriveFile:(GTLDriveFile *)driveFile
{
    _driveFile = driveFile;
    
    self.imageView.image = [self imageWithMIMEType: driveFile.mimeType];
    self.textLabel.text = driveFile.title;
    
}



- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}



@end
