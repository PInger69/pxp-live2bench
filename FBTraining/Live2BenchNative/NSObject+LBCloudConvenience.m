//
//  NSObject+GTLConvenience.m
//  Live2BenchNative
//
//  Created by Si Te Feng on 8/13/14.
//  Copyright (c) 2014 DEV. All rights reserved.
//

#import "NSObject+LBCloudConvenience.h"
#import "GTLBase64.h"
#import "NSString+LBConvenience.h"

@implementation NSObject (LBCloudConvenience)

- (GTLDriveFileThumbnail*)GTLThumbnailWithMIMEType: (NSString*)mimeType
{
    UIImage* image = [self imageWithMIMEType:mimeType];
    NSData* imageData = UIImageJPEGRepresentation(image, 7);
    
    
    GTLDriveFileThumbnail* thumbnail = [[GTLDriveFileThumbnail alloc] init];
    thumbnail.image = GTLEncodeWebSafeBase64(imageData);
    return thumbnail;
}


- (UIImage*)imageWithMIMEType: (NSString*)mimeType
{
    NSString* imageName = @"infoIcon";
    
    {
        if([mimeType isEqual:@"text/plain"])
        {
            imageName = @"txtIcon.png";
        }
        else if([mimeType isEqual:@"application/vnd.google-apps.folder"])
        {
            imageName = @"folderIcon.png";
        }
        else if([mimeType isEqual:@"text/xml"])
        {
            imageName = @"xmlIcon.png";
        }
        else if([mimeType isEqual:@"text/csv"])
        {
            imageName = @"csvIcon.png";
        }
        else if([mimeType isEqual:@"application/pdf"])
        {
            imageName = @"pdfIcon.png";
        }
        else if([mimeType isEqual:@"video/mp4"])
        {
            imageName = @"mp4Icon.png";
        }
    }
    
    return [UIImage imageNamed:imageName];
}



- (BOOL)isMIMETypeFolder
{
    return [self isEqual:@"application/vnd.google-apps.folder"];
}



- (UIImage*)imageWithTypeString: (NSString*)type
{
    NSString* imageName = @"infoIcon";
    
    imageName = [NSString stringWithFormat:@"%@Icon.png", type];
    
    UIImage* typeImage = [UIImage imageNamed:imageName];
    
    if(typeImage)
        return typeImage;
    
    return [UIImage imageNamed:@"infoIcon"];
    
}


- (NSString*)MIMETypeWithTypeString: (NSString*)typeString
{
    NSDictionary* mimeTypesFromTypeString = @{@"txt":@"text/plain", @"csv":@"text/csv", @"xml":@"text/xml", @"mp4":@"video/mp4", @"pdf":@"application/pdf"};
    
    NSString* mimeType = [mimeTypesFromTypeString objectForKey:typeString];
    
    if(mimeType)
        return mimeType;
    else
        return typeString;
    
}


- (NSString*)MIMETypeWithDropboxTypeString: (NSString*)typeString;
{
    NSString* mimeType = typeString;
    
    NSArray* typesToCheck = @[@"text/csv",@"text/xml",@"text/plain"];
    
    for(NSString* type in typesToCheck)
    {
        if([typeString rangeOfString:type].location!=NSNotFound)
            mimeType = type;
    }
    
    if([typeString isEqual:@"application/xml"])
        mimeType = @"text/xml";
    
    return mimeType;
 
}


#pragma mark - Date Methods
/*Only year, month, and day*/
- (NSString*)cloudDriveFolderNameWithTodaysDateWithCalendarUnit: (NSCalendarUnit)unit
{
    NSDate* date = [NSDate date];
    NSDateComponents* dateComponents = [[NSCalendar currentCalendar] components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:date];
    
    NSString* resultString = nil;
    
    if(unit == NSCalendarUnitYear)
    {
        resultString = [NSString stringWithFormat:@"%d", dateComponents.year];
    }
    else if(unit == NSCalendarUnitMonth)
    {
        resultString = [NSString monthFullStringWithInt:dateComponents.month];
    }
    else if(unit == NSCalendarUnitDay)
    {
        resultString = [NSString stringWithFormat:@"%d", dateComponents.day];
    }
    
    return resultString;
}



- (NSString*)dropboxTodayFolderPath
{
    NSString* path = @"/";
    path = [path stringByAppendingPathComponent:[self cloudDriveFolderNameWithTodaysDateWithCalendarUnit:NSCalendarUnitYear]];
    path = [path stringByAppendingPathComponent:[self cloudDriveFolderNameWithTodaysDateWithCalendarUnit:NSCalendarUnitMonth]];
    path = [path stringByAppendingPathComponent:[self cloudDriveFolderNameWithTodaysDateWithCalendarUnit:NSCalendarUnitDay]];
    
    return path;
}



@end
