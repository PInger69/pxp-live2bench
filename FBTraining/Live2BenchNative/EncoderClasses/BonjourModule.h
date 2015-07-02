//
//  BonjourModule.h
//  Live2BenchNative
//
//  Created by dev on 2015-06-30.
//  Copyright © 2015 DEV. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol BonjourModuleDelegate <NSObject>
-(void)registerEncoder:(NSString*)name ip:(NSString*)ip;
@end



@interface BonjourModule : NSObject <NSNetServiceBrowserDelegate,NSNetServiceDelegate>

@property (nonatomic,strong)    NSMutableDictionary         * dictOfIPs;        
@property (nonatomic,assign)    BOOL                        searching;
@property (nonatomic,weak)      id <BonjourModuleDelegate>  delegate;

- (instancetype)initWithDelegate:(id <BonjourModuleDelegate>)aDelegate;
-(void)reset;
-(void)clear;

@end
