//
//  FilterProcessorFBTforPlayers.m
//  Live2BenchNative
//
//  Created by dev on 8/8/2014.
//  Copyright (c) 2014 DEV. All rights reserved.
//

/**
 *  This is a filter spacific class used for sorting the players in the 
 *  foot ball training app.
 *  This class was made because the tag data contaings a key to an Array
 *  rather then a normal value
 *  so what this filter will do is have a custom block that will check 
 *  all items in the array and compare them to the NSSet of filters
 *  if it contains the value then it will be sent along with the update
 *  
 *  Should this be fixed or can this be boiled down a bit more?
 */

#import "FilterProcessorFBTforPlayers.h"

@implementation FilterProcessorFBTforPlayers

/**
 *  update with the pressed buttons
 *
 *  @param filters buttons selected
 */
-(void)updateWith:(NSSet*)filters
{

    // If no buttons are selected or exist just pass the list to the next componet
    if (filters == nil || filters.count == 0){
        filteredList = unfilteredList;
    }
    else {
        NSPredicate *scrubber = [NSPredicate predicateWithBlock:^BOOL(NSDictionary * evaluatedObject, NSDictionary *bindings){
            NSArray * players = [evaluatedObject objectForKey:@"player"];
            
            for (NSString *playerNum in players){
                if ([filters containsObject:playerNum]){
                    return YES;
                }
            }
           
        
            
            return NO;
        }];
        
        
        filteredList = [unfilteredList filteredArrayUsingPredicate:scrubber];
    }
}

@end
