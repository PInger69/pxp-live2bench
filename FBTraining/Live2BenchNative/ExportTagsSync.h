//
//  ExportTagsSync.h
//  Live2BenchNative
//
//  Created by Si Te Feng on 7/22/14.
//  Copyright (c) 2014 DEV. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, JPExportTagType)
{
    JPExportTagTypeSportsCode,
    JPExportTagTypeLive2Bench,
    JPExportTagTypeCSV
};

@protocol JPExportTagSyncDelegate;
@interface ExportTagsSync : NSObject
{
    NSMutableString*    _xmlString;
    
    
    
    
}


@property (nonatomic, assign) JPExportTagType type;

@property (nonatomic, strong) NSDictionary* thumbDict;
@property (nonatomic, strong) NSDictionary* statsDicts;
@property (nonatomic, assign) CGPoint  duration;


@property (nonatomic, strong) id<JPExportTagSyncDelegate> delegate;

@property (nonatomic, strong, readonly) NSData* fileData;


- (id)initWithGlobalsCurrentEventThumbnails: (NSDictionary*)dict;
- (id)initWithGlobalsCurrentEventThumbnails: (NSDictionary*)dict withType: (JPExportTagType)type; //DOES NOT SUPPORT CSV TYPE!

- (id)initWithStatsDict: (NSDictionary*)dict;


- (void)startConvertingAsynchronously;




@end

@protocol JPExportTagSyncDelegate

- (void)exportTagSync: (ExportTagsSync*)sync didFinishConvertingWithFileData: (NSData*)data;


@end
