//
//  FilterProcessor.m
//  Live2BenchNative
//
//  Created by dev on 7/14/2014.
//  Copyright (c) 2014 DEV. All rights reserved.
//

#import "FilterProcessor.h"


/**
 *  This class is made to taking in a Dictionary or Array and return an array based of keys that have been selected
 */
@implementation FilterProcessor
{
    

}


-(id)initWithTagKey:(NSString*)key
{
    self = [super init];
    if (self) {
        myType = key;
    }
    return self;
}

/**
 *  This is the block to that will do the sorting in the processing
 *  by taking the values of the tag and making a key to do the filtering
 *
 *  @param blk
 */
-(void)setFilterBlock:(NSString* (^)(NSDictionary*))blk
{
    filterBlock =blk;
}



#pragma TODO maybe this should keep track of the selected filters just in case
/**
 *  When a list is added it is copied and passed thru with out filtering
 *
 *  @param list from previous component
 */
-(void)inputArray:(NSArray*)list
{
    unfilteredList = [list copy];
    [self updateWith:nil];
}

/**
 *  This updates by taking the unfiltered list and evaluates the tags based of the (NSSet*)filters whitch was the 
 *  was the buttons that were selected during the FilterScrollerView
 *
 *  @param filters Selected Filtering
 */
-(void)updateWith:(NSSet*)filters
{
//    NSLog(@"update!!! %@",myType);
    
    // If no buttons are selected or exist just pass the list to the next componet
    if (filters == nil || filters.count == 0){
        filteredList = unfilteredList;
    }
    //This is using the myType as the key to the evaluated Tag Dict
    else if (filterBlock == NULL){
        NSPredicate *scrubber1 = [NSPredicate predicateWithBlock:^BOOL(NSDictionary * evaluatedObject, NSDictionary *bindings){
            NSString * tagValue = evaluatedObject[myType];
            return [filters containsObject:tagValue];
        }];
        
        filteredList = [unfilteredList filteredArrayUsingPredicate:scrubber1];
    }
    // This is using the same block that was used to make the buttons in the FilterScrollView
    else {
          NSPredicate *scrubber2 = [NSPredicate predicateWithBlock:^BOOL(NSDictionary * evaluatedObject, NSDictionary *bindings){
                                    NSString * tagValue = filterBlock(evaluatedObject);
                                    return [filters containsObject:tagValue];
                                    }];
        filteredList = [unfilteredList filteredArrayUsingPredicate:scrubber2];
    }
}


/**
 *  This updates by taking the unfiltered list and evaluates the tags based of the list of predicate whitch relates to the
 *  buttons that were selected during the FilterComponenent
 *
 *  @param filters Selected Filtering
 */
-(void)updateWithPredicate:(NSArray*)predicates
{
    if (predicates.count == 0){
        filteredList = unfilteredList;
    } else {
        NSArray * inProgress = [unfilteredList copy];
        for (NSPredicate * pred in predicates) {
            inProgress = [inProgress filteredArrayUsingPredicate:pred];
        }
        filteredList = inProgress;
    }
}


/**
 *  Gets the list of tags scrubbed that will be taken by the next link component
 *
 *  @return list of tags
 */
-(NSArray*)processedList
{
    return filteredList;
}



-(NSMutableArray*)sortArrayByTime:(NSMutableArray*)arr
{
    NSArray *sortedArray;
    sortedArray = [arr sortedArrayUsingComparator:(NSComparator)^(id a, id b) {
        NSNumber *num1 =[ NSNumber numberWithFloat:[[a objectForKey:@"starttime"] floatValue]];
        NSNumber *num2 = [ NSNumber numberWithFloat:[[b objectForKey:@"starttime"] floatValue]];
        
        return [num1 compare:num2];
    }];
    
    return (NSMutableArray*)sortedArray;
}


@end
