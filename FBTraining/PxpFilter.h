//
//  PxpFilter.h
//  Live2BenchNative
//
//  Created by dev on 2015-07-29.
//  Copyright © 2015 DEV. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PxpFilterDelegate.h"


@protocol PxpFilterModuleProtocol <NSObject>


@property (nonatomic,weak)      PxpFilter  * parentFilter;

-(void)filterTags:(NSMutableArray*)tagsToFilter;
-(void)reset;

@end


@interface PxpFilter : NSObject


@property (nonatomic,weak)      id <PxpFilterDelegate>  delegate;
@property (nonatomic,strong)    NSMutableArray          * filtersOwnPredicates;
@property (nonatomic,strong)    NSMutableArray          * filterModules;
@property (nonatomic,strong)    NSArray                 * tags;

// this will add a new list and clear out previous tags
-(void)filterTags:(NSArray*)tags;

// this will add tags thru the list add them to the current list
-(void)addTags:(NSArray*)tags;

// this will remove tags and run the on filter complete
-(void)removeTags:(NSArray*)tags;

// This will remove all tags in the filter
-(void)clear;

-(void)refresh;


-(void)addModules:(NSArray*)modules;
-(void)removeModules:(NSArray*)modules;
-(void)removeAllModules;


-(void)addPredicates:(NSArray*)predicates;
-(void)removePredicates:(NSArray*)predicates;
-(void)removeAllPredicates;



@end
