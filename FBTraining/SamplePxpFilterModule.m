//
//  SamplePxpFilterModule.m
//  Live2BenchNative
//
//  Created by dev on 2015-07-29.
//  Copyright © 2015 DEV. All rights reserved.
//

#import "SamplePxpFilterModule.h"


@implementation SamplePxpFilterModule
{
    NSPredicate *__nullable _combo;
}

@synthesize modified = _modified;
@synthesize parentFilter = _parentFilter;

- (instancetype)initWithArray:(NSArray*)args
{
    self = [super init];
    if (self) {
        
        NSMutableArray * toCombo  = [[NSMutableArray alloc]init];
        
        for (NSString * t in args) {
            [toCombo addObject:[NSPredicate predicateWithFormat:@"name != %@", t]];
        }
        
        _combo = [NSCompoundPredicate andPredicateWithSubpredicates:toCombo];
    }
    return self;
}

- (void)filterTags:(NSMutableArray *)tagsToFilter
{
    
    [tagsToFilter filterUsingPredicate:_combo];


}

- (void)reset {
    
}

@end
