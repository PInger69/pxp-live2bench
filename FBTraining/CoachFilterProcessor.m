//
//  CoachFilterProcessor.m
//  Live2BenchNative
//
//  Created by dev on 8/28/2014.
//  Copyright (c) 2014 DEV. All rights reserved.
//

#import "CoachFilterProcessor.h"

@implementation CoachFilterProcessor



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

   
            BOOL isAPick =  NO;
            if ( [evaluatedObject objectForKey:myType] != nil)
            {
                NSString * tagValue = (NSString*)[evaluatedObject objectForKey:myType];
                if ([tagValue isEqualToString:@"1"]) isAPick = YES;
            }
            
            return isAPick;
        }];
        filteredList = [unfilteredList filteredArrayUsingPredicate:scrubber2];
    }
}

@end
