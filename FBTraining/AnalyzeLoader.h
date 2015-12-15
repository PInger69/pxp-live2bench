//
//  AnalyzeLoader.h
//  Live2BenchNative
//
//  Created by dev on 2015-12-08.
//  Copyright © 2015 DEV. All rights reserved.
//


#import <Foundation/Foundation.h>
#import "Tag.h"
#import "Clip.h"

#define ANALYZE_LOADER_STATE_IDLE           @"idle"
#define ANALYZE_LOADER_STATE_GET_URLS       @"getting urls"
#define ANALYZE_LOADER_STATE_DOWNLOADING    @"download mp4"
#define ANALYZE_LOADER_STATE_COMPLETE       @"complete"



@class AnalyzeLoader;


@protocol AnalyzeLoaderDelegate <NSObject>



@required
-(void)onCompletion:(AnalyzeLoader*)analyzeLoader finalClip:(Clip*)clip;

@optional
-(void)onProgress:(AnalyzeLoader*)analyzeLoader;

@end




// this will take a tag download all the sources to a clip and then on completetion with return a Clip

@interface AnalyzeLoader : NSObject

@property (nonatomic,weak) id <AnalyzeLoaderDelegate> delegate;
@property (nonatomic,weak) Tag* currentTag;
@property (nonatomic, strong) NSString * status;

-(instancetype)initWithTag:(Tag*)tag;
-(void)start;

@end
