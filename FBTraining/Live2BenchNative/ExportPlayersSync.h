//
//  ExportPlayersSync.h
//  Live2BenchNative
//
//  Created by Si Te Feng on 7/29/14.
//  Copyright (c) 2014 DEV. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol JPExportPlayersSyncDelegate;
@class Globals;
@interface ExportPlayersSync : NSObject
{
    Globals* globals;
    
    NSArray* playersArray;
}


//xml- XML,   csv- CSV
@property (nonatomic, strong) NSString* exportType;
@property (nonatomic, strong) NSString* resultString;

@property (nonatomic, weak) id<JPExportPlayersSyncDelegate> delegate;


//- (instancetype)initWithType: (NSInteger)type;
- (void)startConvertingAsynchronously;




@end

@protocol JPExportPlayersSyncDelegate <NSObject>

- (void)exportPlayersSync:(ExportPlayersSync*)syncer didFinishLoadingWithString:(NSString *)result;

@end
