//
//  LocalTagSyncManager.h
//  Live2BenchNative
//
//  Created by dev on 2016-06-20.
//  Copyright © 2016 DEV. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EncoderProtocol.h"

@interface LocalTagSyncManager : NSObject
@property (nonatomic, strong)   NSString                *localPath;

-(instancetype)initWithDocsPath:(NSString*)aDocsPath;
-(void)addTag:(NSDictionary*)tagData;
-(void)addMod:(NSDictionary*)tagData;
-(void)updateWithEncoder:(id<EncoderProtocol>)encoder;
@end
