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
    NSMutableArray * _filteredTags;

}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _filteredTags           = [[NSMutableArray alloc]init];
        _filterModules          = [[NSMutableArray alloc]init];
        _filtersOwnPredicates   = [[NSMutableArray alloc]init];
    }
    return self;
}


-(void)filterTags:(NSArray*)tags
{
    [_filteredTags removeAllObjects];
    _filteredTags = [NSMutableArray arrayWithArray:tags];
    
    for (NSPredicate * pred in _filtersOwnPredicates) {
        [_filteredTags filterUsingPredicate:pred];
    }
    
    NSInteger filerModCount = [_filterModules count];
    for (NSInteger i=0; i<filerModCount; i++) {
        id <PxpFilterModuleProtocol> filterMod = _filterModules[i];
        [filterMod filterTags:_filteredTags];
    }
    
    [self filteringComplete];
}



// This will filter the mini array and add them to the file arrray
-(void)addTags:(NSArray*)tags
{
    NSMutableArray * addedTags =  [[NSMutableArray alloc]initWithArray:tags];
  
    for (NSPredicate * pred in _filtersOwnPredicates) {
        [addedTags filterUsingPredicate:pred];
    }
    
    NSInteger filerModCount = [_filterModules count];
    for (NSInteger i=0; i<filerModCount; i++) {
        id <PxpFilterModuleProtocol> filterMod = _filterModules[i];
        [filterMod filterTags:addedTags];
    }
    
    
    [_filteredTags addObjectsFromArray:addedTags];
    [self filteringComplete];
}

-(void)removeTags:(NSArray*)tags
{
    for (Tag * tag  in tags) {
        if ([_filteredTags containsObject:tag]){
            [_filteredTags removeObject:tag];
        }
    }
    [self filteringComplete];
}

-(void)clear
{
    [_filteredTags removeAllObjects];
    [self filteringComplete];
}

-(void)refresh
{
    if (_delegate && [_delegate respondsToSelector:@selector(onFilterChange:)]){
        [_delegate onFilterChange:self];
    }
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
    _tags = [_filteredTags copy];
    if (_delegate){
        [_delegate onFilterComplete:self];
    }

}

@end
