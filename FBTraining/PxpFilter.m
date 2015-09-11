//
//  PxpFilter.m
//  Live2BenchNative
//
//  Created by dev on 2015-07-29.
//  Copyright © 2015 DEV. All rights reserved.
//

#import "PxpFilter.h"
#import "Tag.h"


@implementation PxpFilter
{
    NSMutableArray  * _filteredTagsPool;
    NSMutableSet    * _unfilteredTagsSet;
    NSMutableArray  * _rawTagsPool;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _filteredTagsPool       = [[NSMutableArray alloc]init];
        _filterModules          = [[NSMutableArray alloc]init];
        _filtersOwnPredicates   = [[NSMutableArray alloc]init];
        _unfilteredTagsSet      = [[NSMutableSet alloc]init];
        _filtersOwnPredicates   = [[NSMutableArray alloc]init];
        _rawTagsPool            = [[NSMutableArray alloc]init];
    }
    return self;
}


-(void)filterTags:(NSArray*)tags
{

    [_rawTagsPool removeAllObjects];
    [_rawTagsPool addObjectsFromArray:tags];
    
    [_unfilteredTagsSet removeAllObjects];
    [_unfilteredTagsSet addObjectsFromArray:tags];
    
    [_filteredTagsPool removeAllObjects];
    [_filteredTagsPool addObjectsFromArray:tags];
    

    
    // this pre filters the data for ignored tags
    for (NSPredicate * pred in _filtersOwnPredicates) {
        [_filteredTagsPool filterUsingPredicate:pred];
        [_unfilteredTagsSet filterUsingPredicate:pred];
    }
    
    NSInteger filerModCount = [_filterModules count];
    for (NSInteger i=0; i<filerModCount; i++) {
        id <PxpFilterModuleProtocol> filterMod = _filterModules[i];
        [filterMod filterTags:_filteredTagsPool];
    }
    
    [self filteringComplete];
}



// This will filter the mini array and add them to the file arrray
-(void)addTags:(NSArray*)tags
{
    
    [_rawTagsPool addObjectsFromArray:tags];

    NSMutableArray * addedTags =  [[NSMutableArray alloc]initWithArray:tags];
    [_unfilteredTagsSet addObjectsFromArray:tags];
    for (NSPredicate * pred in _filtersOwnPredicates) {
        [addedTags filterUsingPredicate:pred];
    }
    
    NSInteger filerModCount = [_filterModules count];
    for (NSInteger i = filerModCount-1; i>=0; i--) {
        id <PxpFilterModuleProtocol> filterMod = _filterModules[i];
        [filterMod filterTags:addedTags];
        NSLog(@"");
    }
    
    
    [_filteredTagsPool addObjectsFromArray:addedTags];
    [self filteringComplete];
}

-(void)removeTags:(NSArray*)tags
{
    for (Tag * tag  in tags) {
        if ([_filteredTagsPool containsObject:tag]){
            [_filteredTagsPool removeObject:tag];
            [_unfilteredTagsSet removeObject:tag];
            [_rawTagsPool removeObject:tag];
        }
    }
    [self filteringComplete];
}

-(void)clear
{
    [_rawTagsPool removeAllObjects];
    [_filteredTagsPool removeAllObjects];
    [self filteringComplete];
}

-(void)refresh
{
    if (_delegate && [_delegate respondsToSelector:@selector(onFilterChange:)]){
        [_delegate onFilterChange:self];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_FILTER_TAG_CHANGE  object:self];
}


-(void)addModules:(NSArray*)modules
{
    for (id <PxpFilterModuleProtocol>  mod in modules) {
        if (![_filterModules containsObject:mod]){
            [_filterModules addObject:mod];
        }
    }
    
    if (_delegate && [_delegate respondsToSelector:@selector(onFilterChange:)]){
        [_delegate onFilterChange:self];
    }
}
-(void)removeModules:(NSArray*)modules
{
    for (id <PxpFilterModuleProtocol>  mod in modules) {
        if ([_filterModules containsObject:mod]){
            [_filterModules removeObject:mod];
        }
    }
    if (_delegate && [_delegate respondsToSelector:@selector(onFilterChange:)]){
        [_delegate onFilterChange:self];
    }
    
}
-(void)removeAllModules
{
    [_filterModules removeAllObjects];
    if (_delegate && [_delegate respondsToSelector:@selector(onFilterChange:)]){
        [_delegate onFilterChange:self];
    }
}


// These predicates will make it so the rawTag ignore what ever is not filtered out by the prdicates
-(void)addPredicates:(NSArray*)predicates
{
    for (NSPredicate * pred   in predicates) {
        if (![_filtersOwnPredicates containsObject:pred]){
            [_filtersOwnPredicates addObject:pred];
        }
    }
    if (_delegate && [_delegate respondsToSelector:@selector(onFilterChange:)]){
        [_delegate onFilterChange:self];
    }
}
-(void)removePredicates:(NSArray*)predicates
{
    for (NSPredicate * pred   in predicates) {
        if ([_filtersOwnPredicates containsObject:pred]){
            [_filtersOwnPredicates removeObject:pred];
        }
    }
    if (_delegate && [_delegate respondsToSelector:@selector(onFilterChange:)]){
        [_delegate onFilterChange:self];
    }
}
-(void)removeAllPredicates
{
    [_filtersOwnPredicates removeAllObjects];
    if (_delegate && [_delegate respondsToSelector:@selector(onFilterChange:)]){
        [_delegate onFilterChange:self];
    }
}




-(void)filteringComplete
{
    if (_delegate){
        [_delegate onFilterComplete:self];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_FILTER_TAG_CHANGE  object:self];
}


#pragma mark - Getters

-(NSArray*)filteredTags
{
    return [_filteredTagsPool copy];
}


-(NSArray*)unfilteredTags
{
    return [_unfilteredTagsSet allObjects];
}


-(NSArray*)rawTags
{
    return [_rawTagsPool copy];
}


@end
