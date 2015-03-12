//
//  NSArray+BinarySearch.m
//  BinarySearch
//
//  Created by Ole Begemann on 19.04.10.
//  Copyright 2010 Ole Begemann. All rights reserved.
//

#import "NSArray+BinarySearch.h"


@interface NSArray (BinarySearchPrivate)
- (NSInteger)binarySearch:(id)searchItem minIndex:(NSInteger)minIndex maxIndex:(NSInteger)maxIndex;
@end


@implementation NSArray (BinarySearch)

- (NSInteger)binarySearch:(id)searchItem
{
    if (searchItem == nil)
    {
        return -1;
    }
    
    if([self containsObject:searchItem]){
        return [self indexOfObject:searchItem]+1;
    }
    
    int maximIndex =[self count] - 1;
    if([[self objectAtIndex:maximIndex] floatValue] < [searchItem floatValue])
    {
        return self.count;
    }
    return [self binarySearch:searchItem minIndex:0 maxIndex:maximIndex];
}



- (NSInteger)binarySearch:(id)searchItem minIndex:(NSInteger)minIndex maxIndex:(NSInteger)maxIndex
{
    // If the subarray is empty, return not found
    if (maxIndex < minIndex)
    {
        return -1;
    }

    NSInteger midIndex = (minIndex + maxIndex) / 2;
    id itemAtMidIndex = [self objectAtIndex:midIndex];
   // //NSLog(@"min - %d max - %d mid -%d  search - %@",minIndex,maxIndex,midIndex,searchItem);
    
    if ([searchItem floatValue] >[itemAtMidIndex floatValue])
    {
        if(maxIndex ==minIndex || midIndex==minIndex) //didnt find exact value, but we found the closest value
        {
            return midIndex+1;
        }
        return [self binarySearch:searchItem minIndex:midIndex + 1 maxIndex:maxIndex];
    }
    else if ([searchItem floatValue] <[itemAtMidIndex floatValue])
    {
        if(maxIndex ==minIndex || minIndex==midIndex) //didnt find exact value, but we found the closest value
        {
            return midIndex;
        }
        return [self binarySearch:searchItem minIndex:minIndex maxIndex:midIndex - 1];
    }
    
    return midIndex;
        
}

@end