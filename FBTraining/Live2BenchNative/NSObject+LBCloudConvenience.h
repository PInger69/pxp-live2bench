//
//  NSObject+GTLConvenience.h
//  Live2BenchNative
//
//  Created by Si Te Feng on 8/13/14.
//  Copyright (c) 2014 DEV. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GTLDrive.h"

@interface NSObject (LBCloudConvenience)


- (GTLDriveFileThumbnail*)GTLThumbnailWithMIMEType: (NSString*)mimeType;

- (UIImage*)imageWithMIMEType: (NSString*)mimeType;
- (UIImage*)imageWithTypeString: (NSString*)type;

- (BOOL)isMIMETypeFolder;
- (NSString*)MIMETypeWithTypeString: (NSString*)typeString;
- (NSString*)MIMETypeWithDropboxTypeString: (NSString*)typeString;


/*Only year, month, and day*/
- (NSString*)cloudDriveFolderNameWithTodaysDateWithCalendarUnit: (NSCalendarUnit)unit;

- (NSString*)dropboxTodayFolderPath;

@end
